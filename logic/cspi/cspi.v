// CSPI 链式SPI
// 接受固定长度的串行数据，存入RAM，支持AHB读出 
// 所存入的数据对应的时钟将被吸收掉，不会输出到CO_CK
module cspi  #(parameter RX_BYTES = 52)(
    input wire        clk,
    input wire        ahb_addr_valid,
    input wire        reset_n,

    input       [1:0]  mem_ahb_htrans,
    input              mem_ahb_hready,
    input              mem_ahb_hwrite,
    input       [31:0] mem_ahb_haddr,
    input       [2:0]  mem_ahb_hsize,
    input       [2:0]  mem_ahb_hburst,
    input       [31:0] mem_ahb_hwdata,
    output tri1        mem_ahb_hreadyout,
    output tri0        mem_ahb_hresp,
    output reg [31:0] mem_ahb_hrdata,

    output reg        intr,
    input             CI_CS,
    input             CI_CK,
    input             CI_DAT,
    output            CO_CS,
    output            CO_CK,
    output            CO_DAT
);

parameter READ_LATENCY = 3;

// reg cs_reg;
reg dat_reg;

assign CO_CS = ci_cs_dly[0];
assign CO_CK = ci_ck_absorbed;//ci_ck_dly[0] & (!ck_absorbed);
assign CO_DAT = dat_reg;

// assign CO_CS = ahb_addr_valid;
// assign CO_CK = read_req;//(addr_latched[2]) & ahb_addr_valid;//byte_we;//ck_reg & (!ck_absorbed);
// assign CO_DAT = rd_busy;//(addr_latched[3]) & ahb_addr_valid;

localparam [1:0] STATE_IDLE    = 2'd0;
localparam [1:0] STATE_RECEIVE = 2'd1;
localparam [1:0] STATE_DONE    = 2'd2;

reg [1:0] state_reg;
reg [11:0] rx_byte_count;
reg [3:0] bit_count;     // 字节内位计数

// 检测CI_CS下降沿 
reg[1:0] ci_cs_dly;
wire ci_cs_falling;

reg  ci_ck_absorbed;

// 检测CI_CK上升沿
reg[1:0] ci_ck_dly;
wire ci_ck_rising;
wire ci_ck_falling;
assign ci_cs_falling = (ci_cs_dly == 2'b10);
assign ci_ck_rising = (ci_ck_dly == 2'b01);
assign ci_ck_falling = (ci_ck_dly == 2'b10);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        ci_cs_dly <= 2'b11;
        ci_ck_dly <= 2'b00;
    end else begin
        ci_cs_dly <= {ci_cs_dly[0], CI_CS};
        ci_ck_dly <= {ci_ck_dly[0], CI_CK};
    end
end


reg [7:0] shift_byte;
reg [9:0] wr_add_reg;
wire [7:0] rd_add;
reg byte_we;
wire [31:0] ram_data;

// RAM 读取
reg                 rd_busy;
reg [31:0]          addr_latched;
reg [READ_LATENCY:0] rd_cnt;   // 计数器，够用即可
reg [7:0]           rx_byte;
wire read_req = ahb_addr_valid && mem_ahb_htrans[1] && mem_ahb_hready && !mem_ahb_hwrite;

wire ram_ack; // RAM 数据有效指示（这里假设固定1周期延迟）
assign ram_ack = (rd_busy && (rd_cnt == READ_LATENCY));

// 准备 RAM 地址（地址锁存后一拍才出数据）
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    rd_busy <= 1'b0;
    rd_cnt  <= { (READ_LATENCY+1){1'b0} };
    addr_latched <= 32'b0;
  end else begin
    if(read_req && !rd_busy) begin
      // 捕获地址，启动一个读事务
      addr_latched <= mem_ahb_haddr;
      rd_busy <= 1'b1;
      rd_cnt  <= { (READ_LATENCY+1){1'b0} };
    end else if(rd_busy) begin
      rd_cnt <= rd_cnt + 1'b1;
      if(ram_ack) begin
        rd_busy <= 1'b0;
      end
    end
  end
end

always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    mem_ahb_hrdata <= 32'b0;
  end else begin //if(ram_ack) 
    mem_ahb_hrdata <= ram_data;
  end
end

assign rd_add = addr_latched[9:2];

ram_1k_8b ram_inst(
    .clock(clk),
    .data(rx_byte),
    .rdaddress(rd_add), // mem_ahb_haddr[9:2]
    .wraddress(wr_add_reg), // rx_byte_count[9:0]  //wr_add_reg
    .wren(byte_we),
    .q(ram_data) 
);


reg reception_complete;
wire ahb_read = ahb_addr_valid; //&& mem_ahb_htrans[1] && mem_ahb_hready && !mem_ahb_hwrite;

assign mem_ahb_hreadyout = (rd_busy) ? (ram_ack) : 1'b1;
assign mem_ahb_hresp = 1'b0;


always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state_reg <= STATE_IDLE;
        rx_byte_count <= 12'd0;
        bit_count <= 4'd0;
        shift_byte <= 8'd0;
        byte_we <= 1'b0;
        wr_add_reg <= 10'd0;
        intr <= 1'b0;
        reception_complete <= 1'b0;
    end else begin
        if (CI_CS) begin // CS拉高复位
            state_reg <= STATE_IDLE;
            rx_byte_count <= 12'd0;
            bit_count <= 4'd0;
            shift_byte <= 8'd0;
            byte_we <= 1'b0;
        end else begin
            case (state_reg)
                STATE_IDLE: begin // 等待CS下降沿
                    intr <= 1'b0;
                    byte_we <= 1'b0;
                    shift_byte <= 8'd0;
                    reception_complete <= 1'b0;
                    if (ci_cs_falling) begin
                        state_reg <= STATE_RECEIVE;
                        rx_byte_count <= 12'd0;
                        bit_count <= 4'd0;
                    end
                end
                STATE_RECEIVE: begin // 接收数据
                    if (ci_ck_rising) begin
                        
                        if (bit_count == 4'd7) begin
                            bit_count <= 4'd0;
                            if (rx_byte_count < RX_BYTES) begin
                                byte_we <= 1'b1;
                                rx_byte <= {shift_byte[6:0], dat_reg};
                                wr_add_reg <= rx_byte_count[9:0];
                                rx_byte_count <= rx_byte_count + 1'b1;
                                if (rx_byte_count == RX_BYTES - 1) begin
                                    reception_complete <= 1'b1;
                                end
                            end else begin
                                byte_we <= 1'b0;
                                
                            end

                        end else begin
                            bit_count <= bit_count + 1'b1;
                            shift_byte <= {shift_byte[6:0], dat_reg};
                        end
                    end
                    if (ci_ck_falling) begin
                        byte_we <= 1'b0;
                        if (reception_complete) begin
                            intr <= 1'b1;
                            state_reg <= STATE_DONE; // 接收完成，等待CS拉高
                        end
                    end
                end
                STATE_DONE: begin // 等待CS拉高复位
                    byte_we <= 1'b0;
                end
                default: state_reg <= STATE_IDLE;
            endcase
        end
    end
end

reg ck_absorbed_state;

// 信号同步
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        dat_reg <= 1'b0;
        ci_ck_absorbed <= 1'b0;
    end else begin
        dat_reg <= CI_DAT;
        ck_absorbed_state <= (state_reg == STATE_RECEIVE);
        ci_ck_absorbed <= ck_absorbed_state ? 1'b0 : CI_CK;
    end
end


endmodule



