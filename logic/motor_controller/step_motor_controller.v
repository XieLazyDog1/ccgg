
module step_motor_controller_dual#(parameter LINES_NUM = 8, LINE_BYTES = 1)(

input wire hclk,
input wire rst,

input wire[15:0] address,
input wire[15:0] wrData,
input wire wr,

output wire[LINES_NUM-1:0]  sdata,
output wire sto,
output wire shi,

input wire nENIn, // 0: enable motors, 1: disable motors
output wire dbg
);

localparam integer MOTOR_NUM = LINES_NUM * LINE_BYTES / 4; // 每条线控制双路电机

 
reg[1:0] serialOutputTrigger = 2'b0; 
reg pwmUpdateTrigger = 1'b0;

reg[7:0] serialTrigCounter = 0; 
reg serialOutState = 0;       

reg nEN;

reg motor_mode = 0;


wire [(LINES_NUM * 8 * LINE_BYTES - 1):0] pwmDataOut;
assign dbg = motor_mode; //pwmDataOut[0];

step_motors_pwm4 #(.LINES_NUM(LINES_NUM)) sm_pwm(
 .clk(hclk),
 .rst(rst), 
 .we(wr),                    
 .regIndex(address),         
 .regData(wrData),                
 .nEn(nEN),                     
 .mode(motor_mode),                  
 .incTrigger(pwmUpdateTrigger), 
 .pwmOut(pwmDataOut)
);


serial595Chain #(.NUM_OF_595_LINE(LINES_NUM), .LINE_BYTES(LINE_BYTES)) serial(
    .base_clk(hclk),
    .rst(rst),
    .trigger((serialOutputTrigger!=2'b0)),
    .data(pwmDataOut), 
    .sto(sto),
    .shi(shi),
    .sdata(sdata)
);

always @ (posedge hclk or posedge rst)  
begin  
  
  if(rst)begin
  
  nEN <= 1'b0;
  motor_mode <= 0;
  serialOutState <= 1;
  serialOutputTrigger <= 0;
  serialTrigCounter <= 0;
  pwmUpdateTrigger <= 0;
  
  end else begin
	// if(nEN == 0)begin
	// serialOutState <= 1;	
  // end
  
  if(serialTrigCounter == 8'd36) begin 
    if(serialOutState) begin 
      serialTrigCounter <= 0;
		
		// if(nEN == 1) begin   
    //     serialOutState <= 0;	
		// end
	  pwmUpdateTrigger <= 1'b1;

	end
	
  end else begin
    serialTrigCounter <= serialTrigCounter + 8'd1;
    
	 if(pwmUpdateTrigger) begin
		serialOutputTrigger <= 2'd2;  
	 end else begin
		if(serialOutputTrigger>0)begin
			serialOutputTrigger <= serialOutputTrigger - 2'd1;
		end
	 end
	 
	 pwmUpdateTrigger <= 1'b0;
  end

  nEN <= nENIn; 
 
  end
  
end

endmodule
