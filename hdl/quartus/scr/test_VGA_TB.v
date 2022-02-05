`timescale 10ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:45:24 12/04/2019
// Design Name:   test_VGA
// Project Name:  test_VGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_VGA_TB;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire VGA_Hsync_n;
	wire VGA_Vsync_n;
	wire VGA_R;
	wire VGA_G;
	wire VGA_B;
	reg sw0;
	reg sw1;
	reg sw2;
	reg sw3;
	reg sw4;
	reg sw5;
	reg sw6;
	reg sw7;
	wire clkout;

	// Instantiate the Unit Under Test (UUT)
	test_VGA uut (
		.clk(clk), 
		.rst(rst), 
		.VGA_Hsync_n(VGA_Hsync_n), 
		.VGA_Vsync_n(VGA_Vsync_n), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
		.sw0(sw0),
		.sw1(sw1),
		.sw2(sw2),
		.sw3(sw3),
		.sw4(sw4),
		.sw5(sw5),
		.sw6(sw6),
		.sw7(sw7)
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1; // si es 1, deja constante countx y county
		#200;
		rst = 0;

		sw0 = 0;
		sw1 = 0;
		sw2 = 0;
		sw3 = 0;
		sw4 = 0;
		sw5 = 0;
		sw6 = 0;
		sw7 = 0;

		
	end

	always #2 clk  = ~clk;
	always #1000 begin
		sw0 = ~sw0;
		sw1 = ~sw1;
		sw2 = ~sw2;
		sw3 = ~sw3;
		sw4 = ~sw4;
		sw5 = ~sw5;
		sw6 = ~sw6;
		sw7 = ~sw7;
	end
	
	reg [9:0]line_cnt=0;
	reg [9:0]row_cnt=0;
	
	
	
	/*************************************************************************
			INICIO DE  GENERACION DE ARCHIVO test_vga	
	**************************************************************************/

	/* log para cargar de archivo*/
	integer f;
	initial begin
      f = $fopen("file_test_vga.txt","w");
   end
	
	reg clk_w = 0;
	always #1 clk_w  = ~clk_w;
	
	/* ecsritura de log para cargar se cargados en https://ericeastwood.com/lab/vga-simulator/
	kk
	*/
	initial forever begin
	@(posedge clk_w)
		$fwrite(f,"%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, {2'b00, VGA_R}, {2'b00, VGA_G}, {1'b0, VGA_B});
		$display("%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, VGA_R, VGA_G, VGA_B);
		
	end
	
endmodule
