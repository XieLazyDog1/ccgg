module user_ip (
  input              CI_CK,
  input              CI_CS,
  input              CI_DAT,
  output tri0        CO_CK,
  output tri0        CO_CS,
  output tri0        CO_DAT,
  output tri0        D0,
  output tri0        D1,
  output tri0        D10,
  output tri0        D11,
  output tri0        D12,
  output tri0        D13,
  output tri0        D14,
  output tri0        D15,
  output tri0        D16,
  output tri0        D17,
  output tri0        D18,
  output tri0        D19,
  output tri0        D2,
  output tri0        D20,
  output tri0        D21,
  output tri0        D22,
  output tri0        D23,
  output tri0        D3,
  output tri0        D4,
  output tri0        D5,
  output tri0        D6,
  output tri0        D7,
  output tri0        D8,
  output tri0        D9,
  output tri0        LM_CK,
  input              LM_D0,
  input              LM_D1,
  input              LM_D2,
  input              LM_D3,
  input              LM_D4,
  input              LM_D5,
  output tri0        LM_LD,
  output tri0        SH1,
  output tri0        SH2,
  output tri0        SH3,
  output tri0        SH4,
  output tri0        SH5,
  output tri0        SH6,
  output tri0        ST1,
  output tri0        ST2,
  output tri0        csp_intr_in,
  input              sys_clock,
  input              bus_clock,
  input              resetn,
  input              stop,
  input       [1:0]  mem_ahb_htrans,
  input              mem_ahb_hready,
  input              mem_ahb_hwrite,
  input       [31:0] mem_ahb_haddr,
  input       [2:0]  mem_ahb_hsize,
  input       [2:0]  mem_ahb_hburst,
  input       [31:0] mem_ahb_hwdata,
  output tri1        mem_ahb_hreadyout,
  output tri0        mem_ahb_hresp,
  output tri0 [31:0] mem_ahb_hrdata,
  output tri0        slave_ahb_hsel,
  output tri1        slave_ahb_hready,
  input              slave_ahb_hreadyout,
  output tri0 [1:0]  slave_ahb_htrans,
  output tri0 [2:0]  slave_ahb_hsize,
  output tri0 [2:0]  slave_ahb_hburst,
  output tri0        slave_ahb_hwrite,
  output tri0 [31:0] slave_ahb_haddr,
  output tri0 [31:0] slave_ahb_hwdata,
  input              slave_ahb_hresp,
  input       [31:0] slave_ahb_hrdata,
  output tri0 [3:0]  ext_dma_DMACBREQ,
  output tri0 [3:0]  ext_dma_DMACLBREQ,
  output tri0 [3:0]  ext_dma_DMACSREQ,
  output tri0 [3:0]  ext_dma_DMACLSREQ,
  input       [3:0]  ext_dma_DMACCLR,
  input       [3:0]  ext_dma_DMACTC,
  output tri0 [3:0]  local_int
);

wire reset = ~resetn;
assign mem_ahb_hreadyout = csp_slave_sel ? csp_slave_ready : 1'b1;
assign slave_ahb_hready  = 1'b1;

assign mem_ahb_hresp = 1'b0;

wire csp_slave_ready;

// AHB各子模块选择信号
wire step_motor_controller_sel = (ahb_add_reg[31:12] == 20'h60000);
wire serial_input_sel = (mem_ahb_haddr[31:4] == 28'h6000100);
wire csp_slave_sel = (mem_ahb_haddr[31:16] == 16'h6001);


wire [31:0] serial_input_hrdata;
wire [31:0] csp_slave_rdata;
// AHB读数据总线多路选择
assign mem_ahb_hrdata = (serial_input_sel ? serial_input_hrdata :32'b0)|(csp_slave_sel ?  csp_slave_rdata : 32'b0);

// AHB写使能信号
reg[31:0] ahb_add_reg;
reg ahb_wr_reg;
reg ahb_ready_reg;

always @ (posedge sys_clock or posedge reset) begin
  if (reset) begin  
    ahb_ready_reg <= 1'b1;
    ahb_add_reg <= 32'b0;
    ahb_wr_reg <= 1'b0;

  end else if(mem_ahb_htrans == 2'b10)begin
    ahb_ready_reg <= 1'b0;
    ahb_add_reg <= mem_ahb_haddr;
    ahb_wr_reg <= mem_ahb_hwrite;
  end else if(!ahb_ready_reg)begin
    
    ahb_ready_reg <= 1'b1;
  end else
  begin
    ahb_ready_reg <= 1'b1;
  end
end


reg [22:0] clk10hz_cnt;
reg clock10kHz;

always @(posedge sys_clock or posedge reset) begin
  if (reset) begin
    clk10hz_cnt <= 23'd0;
    clock10kHz <= 1'b0;
  end else if (clk10hz_cnt == 23'd3999) begin
    clk10hz_cnt <= 23'd0;
    clock10kHz <= ~clock10kHz;
  end else begin
    clk10hz_cnt <= clk10hz_cnt + 1'b1;
  end
end



serial_lim_input serial_lim_input_inst (
    .clk        (sys_clock),
    .ahb_addr_valid        (serial_input_sel),
  .reset_n    (resetn),
    .mem_ahb_htrans (mem_ahb_htrans),
    .mem_ahb_hready (mem_ahb_hready),
    .mem_ahb_hwrite (mem_ahb_hwrite),
    .mem_ahb_haddr  (mem_ahb_haddr),
    .mem_ahb_hsize  (mem_ahb_hsize),
    .mem_ahb_hburst (mem_ahb_hburst),
    .mem_ahb_hwdata (mem_ahb_hwdata),
    .mem_ahb_hreadyout(),
    .mem_ahb_hresp   (),  
    .mem_ahb_hrdata  (serial_input_hrdata),

    .trigger    (clock10kHz),
    .serial_lim_input_data ({LM_D5, LM_D4, LM_D3, LM_D2, LM_D1, LM_D0}),
    .load       (LM_LD),
    .shift      (LM_CK)
);


wire [23:0] sdata;
wire sto;
wire shi;
wire motor_dbg;

assign D0 = sdata[0];
assign D1 = sdata[1];
assign D2 = sdata[2];
assign D3 = sdata[3];
assign D4 = sdata[4];
assign D5 = sdata[5];
assign D6 = sdata[6];
assign D7 = sdata[7];
assign D8 = sdata[8];
assign D9 = sdata[9];
assign D10 = sdata[10];
assign D11 = sdata[11];
assign D12 = sdata[12];
assign D13 = sdata[13];
assign D14 = sdata[14];
assign D15 = sdata[15];

assign D16 = sdata[16];
assign D17 = sdata[17];
assign D18 = sdata[18];
assign D19 = sdata[19];
assign D20 = sdata[20];
assign D21 = sdata[21];
assign D22 = sdata[22];
assign D23 = sdata[23];

assign ST1 = sto;
assign ST2 = sto;

assign SH1 = shi;
assign SH2 = shi;
assign SH3 = shi;
assign SH4 = shi;
assign SH5 = shi;
assign SH6 = shi;

wire step_motor_ctr_we = step_motor_controller_sel && (!ahb_ready_reg && ahb_wr_reg);

step_motor_controller_dual #(.LINES_NUM(24)) controller(
sys_clock,
reset,
{1'b0,ahb_add_reg[15:1]},
mem_ahb_hwdata[15:0],
step_motor_ctr_we,
sdata,
sto,
shi,
0,
motor_dbg
);


// CSPI 链式SPI
cspi cspi_inst (
    .clk        (sys_clock),
    .ahb_addr_valid (csp_slave_sel),
    .reset_n    (resetn),
    .mem_ahb_htrans (mem_ahb_htrans),
    .mem_ahb_hready (mem_ahb_hready),
    .mem_ahb_hwrite (mem_ahb_hwrite),
    .mem_ahb_haddr  (mem_ahb_haddr),
    .mem_ahb_hsize  (mem_ahb_hsize),
    .mem_ahb_hburst (mem_ahb_hburst),
    .mem_ahb_hwdata (mem_ahb_hwdata),
    .mem_ahb_hreadyout(csp_slave_ready),
    .mem_ahb_hresp   (),  
    .mem_ahb_hrdata  (csp_slave_rdata),

    .intr(csp_intr_in),
    .CI_CS      (CI_CS),
    .CI_CK      (CI_CK),
    .CI_DAT     (CI_DAT),
    .CO_CS      (CO_CS),
    .CO_CK      (CO_CK),
    .CO_DAT     (CO_DAT)
);









endmodule
