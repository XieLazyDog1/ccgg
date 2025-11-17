module serial_lim_input  #(parameter  CHANNEL_NUM = 6, CHANNEL_DEPTH = 8, CLK_DIV = 10, LOAD_CLK = 2)(
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

    input            trigger,
    input      [CHANNEL_NUM-1:0] serial_lim_input_data, // parallel serial outputs
    output reg       load,
    output wire       shift
);

localparam integer DATA_WIDTH = CHANNEL_NUM * CHANNEL_DEPTH;
localparam integer CAPTURE_WORDS = (DATA_WIDTH + 31) / 32;

function integer clog2;
    input integer value;
    integer temp;
    begin
        temp = 0;
        value = value - 1;
        while (value > 0) begin
            temp = temp + 1;
            value = value >> 1;
        end
        clog2 = temp;
    end
endfunction

localparam integer READ_INDEX_WIDTH = (CAPTURE_WORDS <= 1) ? 1 : clog2(CAPTURE_WORDS);
localparam integer BIT_INDEX_WIDTH = (CHANNEL_DEPTH <= 1) ? 1 : clog2(CHANNEL_DEPTH);
localparam integer SHIFT_DIVISOR = (CLK_DIV == 0) ? 1 : CLK_DIV;

localparam [1:0] STATE_IDLE  = 2'd0;
localparam [1:0] STATE_LOAD  = 2'd1;
localparam [1:0] STATE_SHIFT = 2'd2;

reg [1:0] state_reg;
reg shift_enable;
reg [BIT_INDEX_WIDTH-1:0] bit_counter;
reg [15:0] load_counter;
reg capture_done;

reg trigger_sync0;
reg trigger_sync1;

reg [15:0] shift_div_counter;
reg shift_out;
reg shift_out_d;

reg [CHANNEL_DEPTH-1:0] shift_buffer [0:CHANNEL_NUM-1];
reg [DATA_WIDTH-1:0] captured_data;

integer channel_idx;
integer pack_idx;

wire trigger_rise = trigger_sync0 & ~trigger_sync1;
wire shift_rise = shift_out & ~shift_out_d;
wire ahb_read_transfer = ahb_addr_valid && mem_ahb_htrans[1] && mem_ahb_hready && !mem_ahb_hwrite;
wire [2:0] read_idx_raw = mem_ahb_haddr[4:2];
// Base 32-bit words are selected with bits [4:2]. Channel data is grouped
// with channel 0 in the least significant CHANNEL_DEPTH bits, channel 1
// next, etc., so each 32-bit chunk is just a window into the packed sample.
wire read_idx_valid = (read_idx_raw < CAPTURE_WORDS);
wire [31:0] read_chunk = read_idx_valid ? (captured_data >> (read_idx_raw * 32)) : 32'b0;

assign mem_ahb_hreadyout = 1'b1;
assign mem_ahb_hresp = 1'b0;
assign shift = shift_out & load;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        mem_ahb_hrdata <= 32'b0;
    end else if (ahb_read_transfer) begin
        mem_ahb_hrdata <= read_chunk;
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        trigger_sync0 <= 1'b0;
        trigger_sync1 <= 1'b0;
    end else begin
        trigger_sync0 <= trigger;
        trigger_sync1 <= trigger_sync0;
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state_reg <= STATE_IDLE;
        load <= 1'b1;
        shift_enable <= 1'b0;
        load_counter <= 0;
        bit_counter <= 0;
        capture_done <= 1'b0;
    end else begin
        capture_done <= 1'b0;
        case (state_reg)
            STATE_IDLE: begin
                load <= 1'b1;
                shift_enable <= 1'b0;
                if (trigger_rise) begin
                    shift_enable <= 1'b1;
                    load <= 1'b0;
                    load_counter <= (LOAD_CLK == 0) ? 0 : LOAD_CLK - 1;
                    state_reg <= STATE_LOAD;
                end
            end
            STATE_LOAD: begin
                if (shift_rise) begin
                    if (load_counter == 16'd0) begin
                        load <= 1'b1;
                        state_reg <= STATE_SHIFT;
                        bit_counter <= 0;
                    end else begin
                        load_counter <= load_counter - 1;
                    end
                end
            end
            STATE_SHIFT: begin
                if (shift_rise) begin
                    for (channel_idx = 0; channel_idx < CHANNEL_NUM; channel_idx = channel_idx + 1) begin
                        shift_buffer[channel_idx][CHANNEL_DEPTH-1 - bit_counter] <= serial_lim_input_data[channel_idx];
                    end
                    if (bit_counter == (CHANNEL_DEPTH - 1)) begin
                        state_reg <= STATE_IDLE;
                        shift_enable <= 1'b0;
                        capture_done <= 1'b1;
                    end else begin
                        bit_counter <= bit_counter + 1;
                    end
                end
            end
        endcase
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        captured_data <= {DATA_WIDTH{1'b0}};
    end else if (capture_done) begin
        for (pack_idx = 0; pack_idx < CHANNEL_NUM; pack_idx = pack_idx + 1) begin
            captured_data[pack_idx*CHANNEL_DEPTH +: CHANNEL_DEPTH] <= {shift_buffer[pack_idx][7:4],shift_buffer[pack_idx][2],shift_buffer[pack_idx][3],shift_buffer[pack_idx][0],shift_buffer[pack_idx][1]};
        end
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        shift_div_counter <= 0;
        shift_out <= 1'b0;
        shift_out_d <= 1'b0;
    end else begin
        if (shift_enable) begin
            if (shift_div_counter == SHIFT_DIVISOR - 1) begin
                shift_div_counter <= 0;
                shift_out <= ~shift_out;
            end else begin
                shift_div_counter <= shift_div_counter + 1;
            end
        end else begin
            shift_div_counter <= 0;
            shift_out <= 1'b0;
        end
        shift_out_d <= shift_out;
    end
end

endmodule
