
module step_motors_pwm8 #(parameter LINES_NUM = 16, BASE_ADDRESS = 16'h0000) ( 
  input wire clk,                    
  input wire rst,
  input wire we,                      
  input wire[15:0] regIndex,       
  input wire[15:0] regData,           
  input wire nEn,                   
  input wire mode,                    
  input wire incTrigger,            
  output wire[LINES_NUM*8-1:0] pwmOut); 
  
  
  reg[7:0] pwmCnt = 0;
  reg [15:0] pwmList [LINES_NUM-1:0]; 

  reg[(LINES_NUM * 8 -1):0] data = 0;
  assign pwmOut = data;
  
  wire weForThis;

  reg aabb;

  assign weForThis = we;
  
  always @(posedge clk or posedge rst)
  begin
  
    if(rst) begin
    integer j;
    aabb <= 0;
    for (j = 0; j < LINES_NUM; j = j + 1) begin
      pwmList[j] <= 16'h0800;
    end
		
	  end else begin 
	 
	   if(weForThis) begin

      if(regIndex & 16'h00ff) begin
        aabb <= regData[0] ;
      end else begin
        pwmList[(regIndex)>>1] <= regData;
      end
		end
	 end

  end
 
reg motor_en;

  always @ (posedge clk or posedge rst)  
  begin 
  
  if(rst) begin
  pwmCnt <= 0;
  motor_en <= 1;
  
  end else begin

    motor_en <= !nEn;
    
    if(incTrigger) begin
      if(pwmCnt == 8'd127)
	       pwmCnt <= 0;
		  else
		    pwmCnt <= pwmCnt + 8'd1;
	    end

  end

  end
  


  
  genvar i;
  generate
  for(i = 0; i < LINES_NUM; i=i+1) begin: gg

    always @ (posedge clk or posedge rst) begin
	 
	 if(rst) begin
	 
	 
		data[i] <= 0;
		data[LINES_NUM + i] <= 0;
		data[LINES_NUM * 2 + i] <= 0;
		data[LINES_NUM * 3 + i] <= 0;
		data[LINES_NUM * 4 + i] <= 0;
		data[LINES_NUM * 5 + i] <= 0;
		data[LINES_NUM * 6 + i] <= 0;
		data[LINES_NUM * 7 + i] <= 0;
		
		//waveCnt <= 0;
	 
	 end else begin
	 
		if(motor_en) begin // Y

    if(aabb) begin /// AABB
      if(pwmList[i][7] == 1) 

        begin // a
          if(pwmCnt < pwmList[i][6:0]) begin
            data[i] <= 1;
            data[LINES_NUM + i] <= 1;
          end
          else begin
            data[i] <= 0;
            data[LINES_NUM + i] <= 0;

          end
          
          data[LINES_NUM*2 + i] <= 0;
          data[LINES_NUM*3 + i] <= 0;

        end // a
        else begin // a
          if(pwmCnt < pwmList[i][6:0]) begin
            data[LINES_NUM*2 + i] <= 1;
            data[LINES_NUM*3 + i] <= 1;
          end
          else begin
            data[LINES_NUM*2 + i] <= 0;
            data[LINES_NUM*3 + i] <= 0;
          end
          data[i] <= 0;
          data[LINES_NUM + i] <= 0;
        end // a
    if(pwmList[i][15] == 1) begin // a
      if(pwmCnt < pwmList[i][14:8]) begin
        data[LINES_NUM*4 + i] <= 1;
        data[LINES_NUM*5 + i] <= 1;
      end
      else begin
        data[LINES_NUM*4 + i] <= 0;
        data[LINES_NUM*5 + i] <= 0;
      end
      data[LINES_NUM*6 + i] <= 0;
      data[LINES_NUM*7 + i] <= 0;
 
    end // a
    else begin // a
      if(pwmCnt < pwmList[i][14:8]) begin
        data[LINES_NUM*6 + i] <= 1;
      data[LINES_NUM*7 + i] <= 1;
      end
      else begin
     data[LINES_NUM*6 + i] <= 0;
      data[LINES_NUM*7 + i] <= 0;
      end
         data[LINES_NUM*4 + i] <= 0;
        data[LINES_NUM*5 + i] <= 0;
   end //a

    end else  /// ABBA
    begin
      if(pwmList[i][7] == 1) 

        begin // a
          if(pwmCnt < pwmList[i][6:0]) begin
            data[i] <= 1;
            data[LINES_NUM + i] <= 1;
          end
          else begin
            data[i] <= 0;
            data[LINES_NUM + i] <= 0;

          end
          
          data[LINES_NUM*4 + i] <= 0;
          data[LINES_NUM*5 + i] <= 0;

        end // a
        else begin // a
          if(pwmCnt < pwmList[i][6:0]) begin
            data[LINES_NUM*4 + i] <= 1;
            data[LINES_NUM*5 + i] <= 1;
          end
          else begin
            data[LINES_NUM*4 + i] <= 0;
            data[LINES_NUM*5 + i] <= 0;
          end
          data[i] <= 0;
          data[LINES_NUM + i] <= 0;
        end // a
    if(pwmList[i][15] == 1) begin // a
      if(pwmCnt < pwmList[i][14:8]) begin
        data[LINES_NUM*2 + i] <= 1;
        data[LINES_NUM*3 + i] <= 1;
      end
      else begin
        data[LINES_NUM*2 + i] <= 0;
        data[LINES_NUM*3 + i] <= 0;
      end
      data[LINES_NUM*6 + i] <= 0;
      data[LINES_NUM*7 + i] <= 0;
 
    end // a
    else begin // a
      if(pwmCnt < pwmList[i][14:8]) begin
        data[LINES_NUM*6 + i] <= 1;
      data[LINES_NUM*7 + i] <= 1;
      end
      else begin
     data[LINES_NUM*6 + i] <= 0;
      data[LINES_NUM*7 + i] <= 0;
      end
         data[LINES_NUM*2 + i] <= 0;
        data[LINES_NUM*3 + i] <= 0;
   end //a
    end
	  
    end else begin// y

		data[LINES_NUM * 3 + i] <= 0;
		data[LINES_NUM * 2 + i] <= 0;
		data[LINES_NUM * 1 + i] <= 0;
		data[LINES_NUM * 0 + i] <= 0;
    data[LINES_NUM * 7 + i] <= 0;
		data[LINES_NUM * 6 + i] <= 0;
		data[LINES_NUM * 5 + i] <= 0;
		data[LINES_NUM * 4 + i] <= 0;
	 end // y
	 
	 end
	 end
  end
  endgenerate


endmodule

