`timescale 1ns / 1ps

module Decoder
  #(parameter CLKS_PER_BIT = 10)
  (
   input        CLK,
   input        input_serial_bit,
	input 		[15:0] Area,
	input 		[15:0] perimiter,
	input  	reset,
  input  	start,
  input  	[5:0] start_pixel_x,
  input  	[5:0] start_pixel_y,

  
  
   output       Packet_Done_output,
   output [3:0] ChainCode_ouput,
	output reg [5:0] current_x,
	output reg [5:0] current_y,
  output reg error,
  output reg done
   );
    
	 
	 
integer i = 0;
integer z = 0;
integer j=0;
integer out;

  reg [63:0] memory [63:0]; // Assuming 64 locations for pixels storage

  initial begin
    for (j = 0; j < 64; j = j + 1) begin
      memory[j] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    end
	
  end
  
  
  
  parameter Idle      = 3'b000;
  parameter Start_Bit = 3'b001;
  parameter Data_Bit = 3'b010;
  parameter Stop_Bit = 3'b011;
  parameter finish   = 3'b100;
   

   
  reg [7:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total
  reg [3:0]     Chain_Code     = 0;
  reg           Packet_Done       = 0;
  reg [2:0]     state     = 0;

   
	reg start_pix = 1;
	
		
  
	
	always @(posedge CLK) begin
	
	
		if (Packet_Done) begin
		
		case (Chain_Code)
        4'b0000: begin // East
          current_y <= current_y - 1;
        end
        4'b0001: begin // North-East
          current_y <= current_y - 1;
          current_x <= current_x - 1;
        end
        4'b0010: begin // North
          current_x <= current_x + 1;
        end
        4'b0011: begin // North-West
          current_x <= current_x + 1;
          current_y <= current_y + 1;
        end
        4'b0100: begin // West
          current_y <= current_y + 1;
        end
        4'b0101: begin // South-West
          current_x <= current_x - 1;
          current_y <= current_y + 1;
        end
        4'b0110: begin // South
          current_x <= current_x - 1;
        end
        4'b0111: begin // South-East
          current_x <= current_x - 1;
          current_y <= current_y - 1;
        end
			4'b1000: begin // done
				done <= 1;
			end
        default: begin
          // Handle invalid chain code or additional cases
        end
		  
      endcase
		end
		
				// Initial start pixel
		if ((input_serial_bit == 1'b0 || input_serial_bit == 1'b1) && start_pix) ////get initial value of start pixel just one time 
			begin 	
					current_y <= start_pixel_y; 
					current_x <= start_pixel_x;
					start_pix <= 0;
			end
					
					
		// Store pixels in memory
		if (Packet_Done) begin
		memory[current_x][current_y] <= 1'b1;

		out = $fopen("pixels.txt", "w");
		for (i = 0; i < 64; i = i + 1) begin			
		$fwrite(out, "%b\n", memory[i]);
		end
		$fclose(out);
		end
					
							// error check
		if (current_x < 0 || current_x > 63 || current_y < 0 || current_y > 63) begin
        error <= 1;
      end else begin
        error <= 0;
      end
		
		
		
		
		end

	
	
	
	
	
	
	
  // Purpose: Control RX state machine
  always @(posedge CLK)
    begin

      case (state)
        Idle :
          begin
            Packet_Done       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (input_serial_bit == 1'b0)          // Start bit detected
              state <= Start_Bit;
            else
              state <= Idle;
          end
         
        // Check middle of start bit to make sure it's still low
        Start_Bit :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (input_serial_bit == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    state     <= Data_Bit;
                  end
                else
                  state <= Idle;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                state     <= Start_Bit;
              end
          end // case: Start_Bit
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        Data_Bit :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                state     <= Data_Bit;
              end
            else
              begin
                r_Clock_Count          <= 0;
                Chain_Code[r_Bit_Index] <= input_serial_bit;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 3)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    state   <= Data_Bit;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    state   <= Stop_Bit;
                  end
              end
          end // case: Data_Bit
     
     
        // Receive Stop bit.  Stop bit = 1
        Stop_Bit :
          begin
 
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                state     <= Stop_Bit;
              end
            else
              begin
                Packet_Done       <= 1'b1;
                r_Clock_Count <= 0;
                state     <= finish;
              end
          end // case: Stop_Bit
     
         
        // Stay here 1 clock
        finish :
          begin
            state <= Idle;
            Packet_Done   <= 1'b0;
          end
         
         
        default :
          state <= Idle;
         
      endcase
    end   
   
  assign Packet_Done_output   = Packet_Done;
  assign ChainCode_ouput = Chain_Code;
   
endmodule // uart_rx
