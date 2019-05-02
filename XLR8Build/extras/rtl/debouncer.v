

// Assumes a 16MHz clock
module debouncer(

    input in_signal,
    input clk,
    output out_signal

);


	
	reg[24:0] feedback_reg = 5'b00000_00000_00000_00000_00000;
	reg in_reg = 1'b0;
	reg out_reg = 1'b0;


	always @(posedge clk) begin
	
	    in_reg <= in_signal;
       feedback_reg[0] <= in_reg;
		 feedback_reg[1] <= feedback_reg[0];
		 feedback_reg[2] <= feedback_reg[1];
		 feedback_reg[3] <= feedback_reg[2];
		 feedback_reg[4] <= feedback_reg[3];
		 
		 feedback_reg[5] <= feedback_reg[4];
		 feedback_reg[6] <= feedback_reg[5];
		 feedback_reg[7] <= feedback_reg[6];
		 feedback_reg[8] <= feedback_reg[7];
		 feedback_reg[9] <= feedback_reg[8];

		 feedback_reg[10] <= feedback_reg[9];
		 feedback_reg[11] <= feedback_reg[10];
		 feedback_reg[12] <= feedback_reg[11];
		 feedback_reg[13] <= feedback_reg[12];
		 feedback_reg[14] <= feedback_reg[13];
		 
		 feedback_reg[15] <= feedback_reg[14];
		 feedback_reg[16] <= feedback_reg[15];
		 feedback_reg[17] <= feedback_reg[16];
		 feedback_reg[18] <= feedback_reg[17];
		 feedback_reg[19] <= feedback_reg[18];
		 
		 feedback_reg[20] <= feedback_reg[19];
		 feedback_reg[21] <= feedback_reg[20];
		 feedback_reg[22] <= feedback_reg[21];
		 feedback_reg[23] <= feedback_reg[22];
		 feedback_reg[24] <= feedback_reg[23];
		 
		 if (feedback_reg == 5'b1111111111111111111111111) begin
		     out_reg <= 1'b1;
		 end
		 else if (feedback_reg == 5'b_00000_00000_00000_00000_00000) begin
		     out_reg <= 1'b0;
		 end
	
	    out_signal <= out_reg;
	
	    /*
		 //if ((in_signal && (state == 1'b0)) || (~in_signal && (state == 1'b1))) begin
		 if (in_signal ^ state) begin 
     		 feedback_reg <= feedback_reg + 9'b000000001;
		 end
		 else begin
		     feedback_reg <= {9{1'b0}};
		 end
		 // Look for high signal (Must be high for X consecutive clocks)
		 if(state == 1'b0) begin
			  if (feedback_reg > 9'b011001000) begin // works with 32
		         out_signal <= HIGH;
			      state <= ~state;
		     end
		 end
		 // Look for low signal (Must be low for X consecutive clocks)
		 else begin
			  if (feedback_reg > 9'b011001000) begin // 32
			      state <= ~state;
					out_signal <= LOW;
			  end
		 end
		 if (feedback_reg > 9'b011001000) begin
		     state <= ~state;
		 end
		 */
	end
	
	

endmodule