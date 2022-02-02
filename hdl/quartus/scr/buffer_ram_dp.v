`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:    13:34:31 10/22/2019 
// Design Name: 	 Ferney alberto Beltran Molina
// Module Name:    buffer_ram_dp 
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
module buffer_ram_dp#( 
	parameter AW = 15, // Cantidad de bits  de la direccin 
	parameter DW = 12, // cantidad de Bits de los datos de cada color (RGB 444, 332, 111)
	parameter   imageFILE= "image.txt")
	(  
	input  clk_w, 
	input  [AW-1: 0] addr_in, //15 bits
	input  [DW-1: 0] data_in, //3 bits
	input  regwrite, 
	
	input  clk_r, 
	input [AW-1: 0] addr_out,
	output reg [DW-1: 0] data_out,
	input reset
	);

// Calcular el número de posiciones totales de memoria 
localparam NPOS = 2 ** AW; // Memoria

 reg [DW-1: 0] ram [0: NPOS-1]; // Creación de la memoria


//	 escritura  de la memoria port 1 
always @(posedge clk_w) begin 
       if (regwrite == 1) 
             ram[addr_in] <= data_in;
end

//	 Lectura  de la memoria port 2 
always @(posedge clk_r) begin 
		data_out <= ram[addr_out]; 
		// data_out <= 3'b111; 
		$display("Data out: %b", data_out);
		$display("Addres: %b", addr_out);
end

// integer i;
initial begin
	$readmemh(imageFILE, ram);
	// for (i=0; i<=4500; i = i+1)
	// 	ram[i] = 3'b101;
	// for (i=4501; i<=1000; i = i+1)
	// 	ram[i] = 3'b111;
//	ram[0] = 0;
//	ram[1] = 12'b1111 1111 1111;
//               F    F     F

//	ram[0] es un reg de 3 bits; ram[0][0] ram[0][1] ram[0][2]
	// ram[0] = 000000001111
//	ram[1] = 1'b111;
end


endmodule
