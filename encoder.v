`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:16:29 01/29/2024 
// Design Name: 
// Module Name:    encoder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module encoder(input reset, input clk, input start, output reg code, output reg done, 
					output reg error, output reg [15:0] perimiter_output, output reg [15:0] area_output, 
					output reg [5:0] start_pixel_x, output reg [5:0] start_pixel_y);
	
	reg [63:0] picture [63:0];
	reg [63:0] edges [63:0];
	reg [63:0] temp [63:0];
	
	reg [5:0] current_x = 63;
	reg [5:0] current_y = 63;
	
	reg [5:0] start_x = 63;
	reg [5:0] start_y = 63;
	
	reg [5:0] temp_index_x = 63;
	reg [5:0] temp_index_y = 63;
	
	reg [15:0] perimiter = 0;
	reg [15:0] area = 0;
	
	reg [3:0] vector_table [255:0];
	reg [15:0] vector_table_index = 0;
	
	reg [15:0] sending_vector_index = 0;
	reg [1:0] sending_vector_bit_index = 0;
	
	reg [7:0] sending_data_clk = 0;
	parameter clk_per_bit = 10;
	
	reg [2:0] state = 1;
	parameter [2:0] idle_state = 0;
	parameter [2:0] finding_area_permiter_state = 1;
	parameter [2:0] finding_start_point_state = 2;
	parameter [2:0] encoding_state = 3;
	parameter [2:0] transmition_state = 4;
	
	reg [2:0] transmition_pattern_state = 1;
	parameter [2:0] sending_start_bit = 1;
	parameter [2:0] sending_packet_bit = 2;
	parameter [2:0] sending_stop_bit = 3;
	
		
	// initialization
	integer x;
	integer y;
	integer vector_file;
	initial begin
		//vector_file = $fopen("F:/fpga_hw/vector_6.txt", "a");
		$readmemb("sample_test1.txt", picture);
		for (x = 0; x < 64; x = x + 1)begin 
			for (y = 0; y < 64; y = y + 1)begin
				if (picture[x][y])begin
					edges[x][y] = ~(picture[x - 1][y]
										 &picture[x][y - 1]
										 &picture[x][y + 1]
										 &picture[x + 1][y]);
					temp[x][y] =  ~(picture[x - 1][y]
										 &picture[x][y - 1]
										 &picture[x][y + 1]
										 &picture[x + 1][y]);
				end
				else begin
					edges[x][y] = 0;
					temp[x][y] = 0;
				end
			end
		end
	end
	
	
	// state machine
	always @ (posedge clk) begin
		// reset signal
		if (reset) begin
			state <= 1;
			current_x <= 63;
			current_y <= 63;
			start_x <= 63;
			start_y <= 63;
			temp_index_x <= 63;
			temp_index_y <= 63;
			vector_table_index <= 0;
			perimiter <= 0;
	      area <= 0;
			sending_vector_index <= 0;
			sending_vector_bit_index <= 0;
			sending_data_clk <= 0;
		end

		
		// normal routine
		else begin
			// idle state
			if (state == idle_state) begin
				if (start) begin
					state <= finding_area_permiter_state;
				end
			end
			
			
			// finding area permiter
			if (state == finding_area_permiter_state)begin
				if(temp_index_y == 0 & temp_index_x == 0)begin
					state <= finding_start_point_state;
					area_output <= area;
					perimiter_output <= perimiter;
				end
				if (picture[temp_index_x][temp_index_y] == 1) begin
					area <= area + 1;
					if (picture[temp_index_x - 1][temp_index_y] == 0) begin
						if (picture[temp_index_x][temp_index_y - 1] == 0) begin
							if (picture[temp_index_x][temp_index_y + 1] == 0) begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 4; // 0000
								end
								else begin
									perimiter <= perimiter + 3; // 0001
								end
							end
							else begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 3; // 0010
								end
								else begin
									perimiter <= perimiter + 2; // 0011
								end
							end
						end
						else begin
							if (picture[temp_index_x][temp_index_y + 1] == 0) begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 3; // 0100
								end
								else begin
									perimiter <= perimiter + 2; // 0101
								end
							end
							else begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 2; // 0110
								end
								else begin
									perimiter <= perimiter + 1; // 0111
								end
							end
						end
					end
					else begin
						if (picture[temp_index_x][temp_index_y - 1] == 0) begin
							if (picture[temp_index_x][temp_index_y + 1] == 0) begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 3; // 1000
								end
								else begin
									perimiter <= perimiter + 2; // 1001
								end
							end
							else begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 2; // 1010
								end
								else begin
									perimiter <= perimiter + 1; // 1011
								end
							end
						end
						else begin
							if (picture[temp_index_x][temp_index_y + 1] == 0) begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 2; // 1100
								end
								else begin
									perimiter <= perimiter + 1; // 1101
								end
							end
							else begin
								if (picture[temp_index_x + 1][temp_index_y] == 0) begin
									perimiter <= perimiter + 1; // 1110
								end
								else begin
									perimiter <= perimiter + 0; // 1111
								end
							end
						end
					end
				end
				if (temp_index_y > 0)begin
					temp_index_y <= temp_index_y - 1;
				end
				else begin
					temp_index_x <= temp_index_x - 1;
					temp_index_y <= 63;
				end
			end
			
			
			// finding starting point
			if (state == finding_start_point_state) begin
				if (picture[current_x][current_y] == 1) begin
					state <= encoding_state;
					start_pixel_x <= current_x;
					start_pixel_y <= current_y;
					start_x <= current_x;
					start_y <= current_y;
				end
				else begin
					if (current_y > 0)begin
						current_y <= current_y - 1;
					end
					else begin
						current_x <= current_x - 1;
						current_y <= 63;
					end
				end
			end
			
			
			// encoding state
			if (state == encoding_state) begin
				// vector 0
				if (edges[current_x][current_y - 1] == 1)begin
					vector_table[vector_table_index] <= 0;
					current_y <= current_y - 1;
					edges[current_x][current_y - 1] = 0;
					$display("vector 0 pushed");
					//$fwrite(vector_file, "%d\n", 0);
				end
				// vector 1
				else if (edges[current_x + 1][current_y - 1] == 1 &
							edges[current_x + 1][current_y] != 1 &
							edges[current_x][current_y - 1] != 1)begin
					vector_table[vector_table_index] <= 1;
					current_x <= current_x + 1;
					current_y <= current_y - 1;
					edges[current_x + 1][current_y - 1] = 0;
					$display("vector 1 pushed");
					//$fwrite(vector_file, "%d\n", 1);
				end
				// vector 2
				else if (edges[current_x + 1][current_y] == 1)begin
					vector_table[vector_table_index] <= 2;
					current_x <= current_x + 1;
					edges[current_x + 1][current_y] = 0;
					$display("vector 2 pushed");
					//$fwrite(vector_file, "%d\n", 2);
				end
				// vector 3
				else if (edges[current_x + 1][current_y + 1] == 1 &
							edges[current_x + 1][current_y] != 1 &
							edges[current_x][current_y + 1] != 1)begin
					vector_table[vector_table_index] <= 3;
					current_x <= current_x + 1;
					current_y <= current_y + 1;
					edges[current_x + 1][current_y + 1] = 0;
					$display("vector 3 pushed");
					//$fwrite(vector_file, "%d\n", 3);
				end
				// vector 4
				else if (edges[current_x][current_y + 1] == 1)begin
					vector_table[vector_table_index] <= 4;
					current_y <= current_y + 1;
					edges[current_x][current_y + 1] = 0;
					$display("vector 4 pushed");
					//$fwrite(vector_file, "%d\n", 4);
				end
				// vector 5
				else if (edges[current_x - 1][current_y + 1] == 1 &
							edges[current_x - 1][current_y] != 1 &
							edges[current_x][current_y + 1] != 1)begin
					vector_table[vector_table_index] <= 5;
					current_x <= current_x - 1;
					current_y <= current_y + 1;
					edges[current_x - 1][current_y + 1] = 0;
					$display("vector 5 pushed");
					//$fwrite(vector_file, "%d\n", 5);
				end
				// vector 6
				else if (edges[current_x - 1][current_y] == 1)begin
					vector_table[vector_table_index] <= 6;
					current_x <= current_x - 1;
					edges[current_x - 1][current_y] = 0;
					$display("vector 6 pushed");
					//$fwrite(vector_file, "%d\n", 6);
				end			
				// vector 7
				else if (edges[current_x - 1][current_y - 1] == 1 &
							edges[current_x - 1][current_y] != 1 &
							edges[current_x][current_y - 1] != 1)begin
					vector_table[vector_table_index] <= 7;
					current_x <= current_x - 1;
					current_y <= current_y - 1;
					edges[current_x - 1][current_y - 1] = 0;
					$display("vector 7 pushed");
					//$fwrite(vector_file, "%d\n", 7);
				end
				// finish scanning
				else begin
					vector_table[vector_table_index] <= 8;
					state <= transmition_state;
					done <= 1;
					error <= start_x != current_x | start_y != current_y;
				end
				vector_table_index <= vector_table_index + 1;
				$display("----------------------------");
			end


			// transmition state
			if (state == transmition_state) begin
				if (sending_data_clk == clk_per_bit)begin
					sending_data_clk <= 0;  // counet clk
					if (sending_vector_index < vector_table_index)begin
						// sending start bit
						if (transmition_pattern_state == sending_start_bit) begin
							$display("start bit sending");
							code <= 0;
							transmition_pattern_state <= sending_packet_bit;
						end
						// sending packet bit
						if (transmition_pattern_state == sending_packet_bit) begin
							code <= vector_table[sending_vector_index][sending_vector_bit_index];
							sending_vector_bit_index <= sending_vector_bit_index + 1;  // counter packet
							sending_vector_index <= sending_vector_index + (sending_vector_bit_index[0] 
																							& sending_vector_bit_index[1]);
							$display("code: %d", vector_table[sending_vector_index][sending_vector_bit_index]);
							if (sending_vector_bit_index[0] & sending_vector_bit_index[1])begin
								transmition_pattern_state <= sending_stop_bit;
								$display("=========================== %d", sending_vector_index);
							end
						end
						// sending stop bit
						if (transmition_pattern_state == sending_stop_bit) begin
							$display("stop bit sending");
							code <= 1;
							transmition_pattern_state <= sending_start_bit;
						end
					end
					else begin
						state <= idle_state;
					end
				end
				else begin
					sending_data_clk <= sending_data_clk + 1;
				end
			end
		end
	end

endmodule


