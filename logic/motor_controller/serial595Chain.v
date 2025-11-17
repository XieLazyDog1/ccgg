
module serial595Chain #(parameter NUM_OF_595_LINE = 16, LINE_BYTES = 1, CLK_SCALER = 2)(
    input wire base_clk,
    input wire rst,
    input wire trigger,
    input wire [(NUM_OF_595_LINE*LINE_BYTES*8) - 1:0] data,
    output reg sto,
    output reg shi,
    output wire [NUM_OF_595_LINE-1:0] sdata
    );
    
	 reg [3:0] scaler_counter=0; // 时钟分频计数
	 
    reg [7:0] bit_counter;
    reg [7:0] byte_counter;
    reg [NUM_OF_595_LINE-1:0] sdata_reg = 0;
    reg [NUM_OF_595_LINE*LINE_BYTES*8-1:0] shift_data = 0;
    reg [1:0] state;
    
    localparam IDLE = 2'b00, LOAD = 2'b01, SHIFT = 2'b10, LATCH = 2'b11;
    
    assign sdata = sdata_reg;
    
    always @(posedge base_clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_counter <= 0;
            byte_counter <= 0;
            sdata_reg <= 0;
            shift_data <= 0;
            sto <= 0;
            shi <= 0;
			scaler_counter <= 0;
        end else begin
		  
		      if(state == IDLE)begin
				  if (trigger) begin
                shift_data <= data;
                bit_counter <= 0;
                byte_counter <= 0;
                state <= LOAD;
                sto <= 0;
					 scaler_counter <= 0; // 分频状态也要同步
              end
				
				end else begin  // 非 IDLE 状态
			
		    	  if(scaler_counter == CLK_SCALER-1) begin // 分频时间点
				 
			case (state)
                IDLE: begin
                    
                end
                LOAD: begin
                    shi <= 0;
                    sdata_reg <= shift_data[NUM_OF_595_LINE*LINE_BYTES*8-1 -: NUM_OF_595_LINE];
                    //sdata_reg <= 0;
					shift_data <= shift_data << NUM_OF_595_LINE;
                    state <= SHIFT;
                end
                SHIFT: begin
                    shi <= 1;
                    bit_counter <= bit_counter + 8'd1;
                    if (bit_counter == 7) begin
                        bit_counter <= 0;
                        byte_counter <= byte_counter + 8'd1;
                        if (byte_counter == (LINE_BYTES-1)) begin
                            state <= LATCH;
                        end else begin
                            state <= LOAD;
                        end
                    end else begin
                        state <= LOAD;
                    end
                end
                LATCH: begin
					     sto <= 1;
                    state <= IDLE;
                end
               endcase

				    scaler_counter <= 0;
	        	  end else begin
				    scaler_counter <= scaler_counter + 4'b1;
				  end				
				end
            
        end
    end
    
endmodule

