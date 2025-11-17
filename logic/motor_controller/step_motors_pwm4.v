
module step_motors_pwm4 #(parameter LINES_NUM = 16, BASE_ADDRESS = 16'h0000) (
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
  reg [15:0] pwmList [LINES_NUM*2-1:0];
  reg [15:00] motor_flags;

  assign aabb = motor_flags[0];

  reg[(LINES_NUM * 8 -1):0] data = 0;
  assign pwmOut = data;
  
  wire weForThis;

  assign weForThis = we;
  
  always @(posedge clk or posedge rst)
  begin
  
    if(rst) begin
    integer j;
    for (j = 0; j < LINES_NUM * 2; j = j + 1) begin
      pwmList[j] <= 33;
    end
    motor_flags <= 1;
		
	  end else begin 	 
	   if(weForThis) begin
      if (regIndex == 16'h00ff) begin
        motor_flags <= regData;
      end else begin
  		  pwmList[regIndex] <= regData; 
      end
		end
	 end

  end
 
  always @ (posedge clk or posedge rst)  
  begin 
  
  if(rst) begin
  pwmCnt <= 0;
  
  end else begin
    if(nEn) begin
    pwmCnt <= 0;
  end else begin
    if(incTrigger) begin
      if(pwmCnt == 8'd127)
	       pwmCnt <= 0;
		  else
		    pwmCnt <= pwmCnt + 8'd1;
	    end
    end
  end

  end
  
  
  genvar i;
  generate
  for(i = 0; i < LINES_NUM; i=i+1) begin: gg

    reg[19:0] waveCnt = 0;
    
    always @ (posedge clk or posedge rst) begin
	 
	 if(rst) begin
	 
	 
		data[i] <= 1;
		data[LINES_NUM + i] <= 1;
		data[LINES_NUM * 2 + i] <= 1;
		data[LINES_NUM * 3 + i] <= 1;
		data[LINES_NUM * 4 + i] <= 1;
		data[LINES_NUM * 5 + i] <= 1;
		data[LINES_NUM * 6 + i] <= 1;
		data[LINES_NUM * 7 + i] <= 1;
		
		waveCnt <= 0;
	 
	 end else begin
	 
		if((nEn == 0)) begin // Y
	   if(mode == 0) begin    /// 閻㈠灚婧€PWM閹貉冨煑濡€崇础 Z

    if(aabb) begin

      if(pwmList[i*2][15] == 1) 
        begin // a
          if(pwmCnt < pwmList[i*2][14:8]) 
            data[i] <= 0;
          else 
            data[i] <= 1;
          data[LINES_NUM + i] <= 1;
        end // a
        else begin // a
          if(pwmCnt < pwmList[i*2][14:8]) 
            data[LINES_NUM + i] <= 0;
          else 
            data[LINES_NUM + i] <= 1;
          data[i] <= 1;
        end // a
    if(pwmList[i*2][7] == 1) begin // a
      if(pwmCnt < pwmList[i*2][6:0]) 
        data[LINES_NUM*2 + i] <= 0;
      else 
        data[LINES_NUM*2 + i] <= 1;
      data[LINES_NUM*3 + i] <= 1;
    end // a
    else begin // a
      if(pwmCnt < pwmList[i*2][6:0]) 
        data[LINES_NUM*3 + i] <= 0;
      else 
        data[LINES_NUM*3 + i] <= 1;
      data[LINES_NUM*2 + i] <= 1;
   end //a
	
    if(pwmList[i*2+1][15] == 1) 
    begin // a
      if(pwmCnt < pwmList[i*2+1][14:8]) 
        data[LINES_NUM *4 + i] <= 0;
      else 
        data[LINES_NUM *4 + i] <= 1;
      data[LINES_NUM *5 + i] <= 1;
    end // a
    else begin // a
      if(pwmCnt < pwmList[i*2+1][14:8]) 
        data[LINES_NUM * 5 + i] <= 0;
      else 
        data[LINES_NUM * 5 + i] <= 1;
      data[LINES_NUM *4 + i] <= 1;
    end // a

    if(pwmList[i*2+1][7] == 1) begin // a
      if(pwmCnt < pwmList[i*2+1][6:0]) 
        data[LINES_NUM*6 + i] <= 0;
      else 
        data[LINES_NUM*6 + i] <= 1;
      data[LINES_NUM*7 + i] <= 1;
    end // a
    else begin // a
      if(pwmCnt < pwmList[i*2+1][6:0]) 
        data[LINES_NUM*7 + i] <= 0;
      else 
        data[LINES_NUM*7 + i] <= 1;
      data[LINES_NUM*6 + i] <= 1;
   end // a

    end else begin

      if(pwmList[i*2][15] == 1) 
        begin // a
          if(pwmCnt < pwmList[i*2][14:8]) 
            data[i] <= 0;
          else 
            data[i] <= 1;
          data[LINES_NUM * 2 + i] <= 1;
        end // a
        else begin // a
          if(pwmCnt < pwmList[i*2][14:8]) 
            data[LINES_NUM * 2 + i] <= 0;
          else 
            data[LINES_NUM * 2 + i] <= 1;
          data[i] <= 1;
        end // a
    if(pwmList[i*2][7] == 1) begin // a
      if(pwmCnt < pwmList[i*2][6:0]) 
        data[LINES_NUM + i] <= 0;
      else 
        data[LINES_NUM + i] <= 1;
      data[LINES_NUM*3 + i] <= 1;
    end // a
    else begin // a
      if(pwmCnt < pwmList[i*2][6:0]) 
        data[LINES_NUM*3 + i] <= 0;
      else 
        data[LINES_NUM*3 + i] <= 1;
      data[LINES_NUM + i] <= 1;
   end //a
	
    if(pwmList[i*2+1][15] == 1) 
    begin // a
      if(pwmCnt < pwmList[i*2+1][14:8]) 
        data[LINES_NUM *4 + i] <= 0;
      else 
        data[LINES_NUM *4 + i] <= 1;
      data[LINES_NUM *6 + i] <= 1;
    end // a
    else begin // a
      if(pwmCnt < pwmList[i*2+1][14:8]) 
        data[LINES_NUM * 6 + i] <= 0;
      else 
        data[LINES_NUM * 6 + i] <= 1;
      data[LINES_NUM *4 + i] <= 1;
    end // a

    if(pwmList[i*2+1][7] == 1) begin // a
      if(pwmCnt < pwmList[i*2+1][6:0]) 
        data[LINES_NUM*5 + i] <= 0;
      else 
        data[LINES_NUM*5 + i] <= 1;
      data[LINES_NUM*7 + i] <= 1;
    end // a
    else begin // a
      if(pwmCnt < pwmList[i*2+1][6:0]) 
        data[LINES_NUM*7 + i] <= 0;
      else 
        data[LINES_NUM*7 + i] <= 1;
      data[LINES_NUM*5 + i] <= 1;
   end // a

    end
		
	
	end else //z
	
	begin // 閻㈠灚婧€閸欐垵锛愬Ο鈥崇础 // z


	// if(pwmList[i*2] == 0) begin // 娑 娴狅綀銆冩稉宥呭絺婢/ a
	//     //waveCnt[i*2] <= 0;
	// 	 data[LINES_NUM * 7 + i] <= 1;
	// 	data[LINES_NUM * 6 + i] <= 1;
	// 	data[LINES_NUM * 5 + i] <= 1;
	// 	data[LINES_NUM * 4 + i] <= 1;
	// 	data[LINES_NUM * 3 + i] <= 1;
	// 	data[LINES_NUM * 2 + i] <= 1;
	// 	data[LINES_NUM * 1 + i] <= 1;
	// 	data[LINES_NUM * 0 + i] <= 1;
	//   end else begin // a

	  
	//   waveCnt <= waveCnt + 16'd1;
	//   if(waveCnt[19:3] > (pwmList[i*2]))
	//    begin // b
	// 	if(waveCnt[19:3] < (pwmList[i*2+1])) begin // c
	// 	 data[LINES_NUM * 7 + i] <= 1;
	// 	 data[LINES_NUM * 6 + i] <= 0;
	// 	 data[LINES_NUM * 5 + i] <= 0;
	// 	 data[LINES_NUM * 4 + i] <= 0;
	// 	 data[LINES_NUM * 3 + i] <= 1;
	// 	 data[LINES_NUM * 2 + i] <= 0;
	// 	 data[LINES_NUM * 1 + i] <= 0;
	// 	 data[LINES_NUM * 0 + i] <= 0;
	// 	end else begin // c
	// 	 data[LINES_NUM * 7 + i] <= 0;
	// 	 data[LINES_NUM * 6 + i] <= 0;
	// 	 data[LINES_NUM * 5 + i] <= 0;
	// 	 data[LINES_NUM * 4 + i] <= 0;
	// 	 data[LINES_NUM * 3 + i] <= 0;
	// 	 data[LINES_NUM * 2 + i] <= 0;
	// 	 data[LINES_NUM * 1 + i] <= 0;
	// 	 data[LINES_NUM * 0 + i] <= 0;
	// 	end // c
	// 	end // b
	// 	else begin // b
	// 	if(waveCnt[19:3] < (pwmList[i*2+1])) begin // c
	// 	 data[LINES_NUM * 7 + i] <= 0;
	// 	data[LINES_NUM * 6 + i] <= 0;
	// 	data[LINES_NUM * 5 + i] <= 1;
	// 	data[LINES_NUM * 4 + i] <= 0;
	// 	data[LINES_NUM * 3 + i] <= 0;
	// 	data[LINES_NUM * 2 + i] <= 0;
	// 	data[LINES_NUM * 1 + i] <= 1;
	// 	data[LINES_NUM * 0 + i] <= 0;
	// 	end else begin // c
	// 	 data[LINES_NUM * 7 + i] <= 0;
	// 	 data[LINES_NUM * 6 + i] <= 0;
	// 	 data[LINES_NUM * 5 + i] <= 0;
	// 	 data[LINES_NUM * 4 + i] <= 0;
	// 	 data[LINES_NUM * 3 + i] <= 0;
	// 	 data[LINES_NUM * 2 + i] <= 0;
	// 	 data[LINES_NUM * 1 + i] <= 0;
	// 	 data[LINES_NUM * 0 + i] <= 0;
	// 	end // c
	// 	end // b
	// 	if(waveCnt[19:4] == pwmList[i*2])
	// 	  waveCnt <= 0;

	//    end // a


	  end //z
	  
    end else begin// y
	   data[LINES_NUM * 7 + i] <= 1;
		data[LINES_NUM * 6 + i] <= 1;
		data[LINES_NUM * 5 + i] <= 1;
		data[LINES_NUM * 4 + i] <= 1;
		data[LINES_NUM * 3 + i] <= 1;
		data[LINES_NUM * 2 + i] <= 1;
		data[LINES_NUM * 1 + i] <= 1;
		data[LINES_NUM * 0 + i] <= 1;
	 end // y
	 
	 end
	 end
  end
  endgenerate


endmodule




