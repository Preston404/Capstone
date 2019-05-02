

/* TODO:
 Implement RPM measurement
 Add LUT ROM for division
 Write script to generate .mif file
 Get PWM value from C code

 Comparator Notes:
 The impression of the device corresponds to the circle in the pinout
 The device only works with 5V from the arduino
*/

module alorium_esc
  (
   // Clock and Reset
   input clk,
   input reset_n,
   // Inputs
   //input new_seed,
   //input enable,
   //input wire [7:0] seed,
   //input long_hb,
   // Output
   //output reg heartbeat,
   //output reg [7:0] lfsr_data,
	
	input wire[7:0] esc_pwm,
	input new_pwm,
	
	// IC Drivers
	output                    IN_1,
	output                    SD_1,
	output                    IN_2,
	output                    SD_2,
	output                    IN_3,
	output                    SD_3,
	
	// Feedback Sensors
	input                 feedback_1,
	input                 feedback_2,
	input                 feedback_3,
	
	output sync,
	output sync2
	
	
  );

  
   parameter HIGH = 1'b1;
   parameter LOW =  1'b0;
	reg[7:0] sw_pwm;
	reg sw_val_rdy;  
  
   // Random LFSR stuff from example project
   //reg [29:0] hb_cnt;
	
   //assign feedback = ~(lfsr_data[7] ^ lfsr_data[5] ^ 
   //                    lfsr_data[4] ^ lfsr_data[3]);
   
   always @(posedge clk) begin

      if (!reset_n) begin
         //heartbeat <= 0;
         //hb_cnt <= 0;
         // LFSR register cannot be all 1's for XNOR LFSR
	      //lfsr_data <= 8'h01;
			sw_val_rdy <= 1'b0;
			sw_pwm <= 8'b00000000;
      end
      else if (new_pwm) begin
         // LFSR register cannot be all 1's for XNOR LFSR
         //lfsr_data <= &seed ? 8'h01 : seed;
         //hb_cnt <= hb_cnt + 1;
			sw_pwm <= esc_pwm;
			sw_val_rdy <= 1'b1;
      end
/*
      else if (enable) begin
	      lfsr_data <= {lfsr_data[6:0],feedback};
         //hb_cnt <= hb_cnt + 1;
      end // else: !if(!reset_n)      
      if ((hb_cnt > 9999999)) begin
		    hb_cnt <= 0;
          heartbeat <= ~heartbeat;
      end
		else begin
		    hb_cnt <= hb_cnt + 1; 
		end
		
      if ((hb_cnt > 0)) begin
        hb_cnt <= 0;
        heartbeat <= ~heartbeat;
      end
*/

   end // always @ (posedge clk)
   
	
	// Assign motor outputs based on states
	// IN_X is source or sink
   // SD_X is enable/disable
   reg[2:0] current_state = 3'b000;
	
	assign sync2 = f1_db;
	assign sync = f3_db;
	
	
	always @(posedge clk) begin
		 
		 f1_db_reg <= f1_db;
		 f2_db_reg <= f2_db;
		 f3_db_reg <= f3_db;
		 
	
	    if(current_state == 3'b000) begin
		     //sync <= 1'b1;
		 end
		 else begin
		     //sync <= 1'b0;
		 end
	
	
	    if(current_state == 3'b000) begin        // Source 1, Sink 2
		     SD_1 <= pwm_output;
			  IN_1 <= HIGH;
			  SD_2 <= HIGH;
			  IN_2 <= LOW;
			  SD_3 <= LOW;
			  IN_3 <= LOW;
			  if((f3_db != f3_db_reg) & ~startup) begin
			      current_state <= current_state + 3'b001;
			  end
			  else if(startup) begin
			      current_state <= startup_state;
		     end
		 end
		 else if (current_state == 3'b001) begin  // Source 1, Sink 3
		     SD_1 <= pwm_output;
			  IN_1 <= HIGH;
			  SD_2 <= LOW;
			  IN_2 <= LOW;
			  SD_3 <= HIGH;
			  IN_3 <= LOW;
			  if((f2_db != f2_db_reg) & ~startup) begin
			      current_state <= current_state + 3'b001;
			  end
			  else if(startup) begin
			      current_state <= startup_state;
		     end
		 end
		 else if (current_state == 3'b010) begin  // Source 2, Sink 3
		     SD_1 <= LOW;
			  IN_1 <= LOW;
			  SD_2 <= pwm_output;
			  IN_2 <= HIGH;
			  SD_3 <= HIGH;
			  IN_3 <= LOW;
			  if((f1_db != f1_db_reg) & ~startup) begin
			      current_state <= current_state + 3'b001;
			  end
			  else if(startup) begin
			      current_state <= startup_state;
		     end
		 end
		 else if (current_state == 3'b011) begin // Source 2, Sink 1
		     SD_1 <= HIGH;
			  IN_1 <= LOW;
			  SD_2 <= pwm_output;
			  IN_2 <= HIGH;
			  SD_3 <= LOW;
			  IN_3 <= LOW;
			  if((f3_db != f3_db_reg) & ~startup) begin
			      current_state <= current_state + 3'b001;
			  end
			  else if(startup) begin
			      current_state <= startup_state;
		     end
		 end
		 else if (current_state == 3'b100) begin  // Source 3, Sink 1
		     SD_1 <= HIGH;
			  IN_1 <= LOW;
			  SD_2 <= LOW;
			  IN_2 <= LOW;
			  SD_3 <= pwm_output;
			  IN_3 <= HIGH;
			  if((f2_db != f2_db_reg) & ~startup) begin
			      current_state <= current_state + 3'b001;
			  end
			  else if(startup) begin
			      current_state <= startup_state;
		     end
		 end
		 else begin                               // Source 3, Sink 2
		     SD_1 <= LOW;
			  IN_1 <= LOW;
			  SD_2 <= HIGH;
			  IN_2 <= LOW;
			  SD_3 <= pwm_output;
			  IN_3 <= HIGH;
			  if((f1_db != f1_db_reg) & ~startup) begin
			      current_state <= 3'b000;
			  end
			  else if(startup) begin
			      current_state <= startup_state;
		     end
		 end

	end
	
	
	// Get the motor running using microsecond clock
	reg startup;
	reg[12:0] startup_cnt;
	reg[2:0]  startup_state;
	reg[12:0] time_to_wait;
	reg[6:0] min_time = 7'b0110010; // 50
	reg[4:0] min_step = 5'b00101;   // 5
	//parameter min_time = 50;
	//parameter min_step = 5;
	
	
	always @(posedge us_clk) begin
	    if(!reset_n) begin
		     startup_cnt <= 13'b1001110001000; // 5000
			  startup <= 1'b1;
			  //pwm_compare <= 8'b00011001; // 25
			  pwm_compare <= 8'b00101000; // 40
			  time_to_wait <= 13'b1001110001000; // 5000
			  startup_state = 3'b000;
		 end
		 //else if (sw_val_rdy) begin
		     //pwm_compare <= sw_pwm;
			  //pwm_compare <= 8'b01001011;
		 //end
		 else begin
		    if (sw_val_rdy) begin
		        pwm_compare <= sw_pwm;
			     //pwm_compare <= 8'b01001011;
		    end
			 if(startup_cnt > min_time + min_step && startup == 1'b1) begin 
				  // Check for end of wait period
				  if(time_to_wait == 13'b0000000000000) begin
						time_to_wait <= startup_cnt - min_step;
						if(startup_cnt > 13'b0001000000000)	begin // 1000
						    startup_cnt <= startup_cnt - min_step; 
					   end
						else begin
						    //pwm_compare <= 8'b00110010; // 50
							 //startup <= 1'b0;
						end
						// Go to next state
						if(startup_state != 3'b101) begin
							 startup_state <= startup_state + 3'b001;
						end 
						else begin
							 startup_state <= 3'b000;
						end
				  end
				  else begin
						time_to_wait <= time_to_wait - 1;
				  end
			 end
			 else begin
				  //startup <= 1'b0;
				  if (pwm_compare < 8'b00110010) begin
				      //pwm_compare <= 8'b00110010; // 50;
				  end 
			 end	
		 end 
	end

	
	
	// Generate PWM signal
	reg      pwm_output  = 1'b0;
	reg[7:0] pwm_count   = 8'b00000000;
	reg[7:0] pwm_compare;
	
	always @(posedge clk) begin
		 
		 // PWM comparitor
	    if(pwm_count < pwm_compare) begin
	        pwm_output <= HIGH;
       end	
		 else begin
		     pwm_output <= LOW;
		 end
		 pwm_count <= pwm_count + 1;
		 
	end
	
	
   // Generate Slower clocks
	reg[3:0]  us_clk_reg = 3'b0000;
	reg       us_clk = 0;
	reg[13:0] ms_clk_reg = 14'b00000000000000;
	reg       ms_clk = 0;
   always @(posedge clk) begin
	    // Microsecond clock
 	    us_clk_reg <= us_clk_reg + 1;
		 if (us_clk_reg == 4'b0000) begin
		     us_clk <= ~us_clk;
		 end
		 // Millisecond Clock
		 ms_clk_reg <= ms_clk_reg + 1;
		 if (ms_clk_reg == 12'b00000000000000) begin
		     ms_clk <= ~ms_clk;
		 end
	end
	
	
	
	// Debounce feedback signals
	wire f1_db;
	wire f2_db;
	wire f3_db;
	
	reg f1_db_reg;
	reg f2_db_reg;
	reg f3_db_reg;
	
	
	debouncer f1(
		 .clk(us_clk),
		 .in_signal(feedback_1),
		 .out_signal(f1_db)
	);
	
	debouncer f2(
		 .clk(us_clk),
		 .in_signal(feedback_2),
		 .out_signal(f2_db)
	);
	
	
	debouncer f3(
		 .clk(us_clk),
		 .in_signal(feedback_3),
		 .out_signal(f3_db)
	);
   
	
	/*
	// Measure the speed of rotation
	// Two magnets are passed every time all states are completed
	reg[22:0] clk_cnt;
	reg[3:0]  prev_state;
	reg[22:0] tot_clks;
	
	always @(posedge clk) begin
	    prev_state <= current_state;
		 
	    // Find transition from State 5 to state 0
	    if(prev_state == 3'b101 & current_state == 3'b000) begin
		     clk_cnt <= 0;
			  tot_clks <= clk_cnt;
			  if(tot_clks < RPM_clks) begin
			      // Decrease PWM
			  end
			  else if(tot_clks > RPM_clks) begin
			      // Increase PWM
			  end
		 end
		 else begin
		     clk_cnt <= clk_cnt + 1;
		 end
	end
	
	// RPM = 60 div (time_per_rotation)
	// time_per_rotation = 6 * time_per_state_cycle
	// time_per_state_cycle = clk_period * clk_cnt 
	
	reg[13:0] RPM;
	reg[21:0] RPM_clks;
	
	// Get expected number of clks for currently set RPM (16MHz Clk)
	my_ROM	my_ROM_inst (
	    .address (RPM),
	    .clock (clk),
	    .q (RPM_clks)
	); */
	
	
endmodule


