`timescale 1ns / 1ps



module UART_Testbench;

  parameter c_CLOCK_PERIOD_NS = 10;
  parameter c_CLKS_PER_BIT    = 10;

   
  reg r_Clock;






  
  ////////////////////////////////////////////////////////////////////////////////// encoder
  	// Inputs



	// Outputs
	wire ChainCode_Encoder;
	wire done_Encoder;
	wire error_Encoder;
	wire [15:0] perimiter_output;
	wire [15:0] area_output;
	wire [5:0] start_pixel_x_Encoder;
	wire [5:0] start_pixel_y_Encoder;

	// Instantiate the Unit Under Test (UUT)
	encoder Encoder_Uart (  
		.reset(0), 
		.clk(r_Clock), 
		.start(0), 
		
						//output
		.code(ChainCode_Encoder), 
		.done(done_Encoder), 
		.error(error_Encoder), 
		.perimiter_output(perimiter_output), 
		.area_output(area_output), 
		.start_pixel_x(start_pixel_x_Encoder), 
		.start_pixel_y(start_pixel_y_Encoder)
	);
  
  
    //////////////////////////////////////////////////////////////////////////////////
  
  
  	// Inputs
	reg reset;
	reg start;



	// Outputs
	wire [5:0] current_x;
	wire [5:0] current_y;
	wire error_decoder;
	wire Packet_finish_flag;
   wire [3:0] Chain_Code_Packet;
  
   
		Decoder #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) Decoder_Uart
									///inputs
    (.CLK(r_Clock),
     .input_serial_bit(ChainCode_Encoder),
		.reset(reset), 
		.start(start), 
		.start_pixel_x(start_pixel_x_Encoder), 
		.start_pixel_y(start_pixel_y_Encoder), 
		.Area(area_output),
		.perimiter(perimiter_output),
		
											/////outputs
		.Packet_Done_output(Packet_finish_flag),
		.ChainCode_ouput(Chain_Code_Packet),
		.error(error_decoder),
		.current_x(current_x),
		.current_y(current_y),
		.done(done_Decoder)
     );
	  
	  
	      //////////////////////////////////////////////////////////////////////////////////
	  
	  
	  
	  
	  
	  
	  

	initial begin
	
		r_Clock = 0;


	end
	
	
	
   always
		  begin
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
	 end
endmodule

