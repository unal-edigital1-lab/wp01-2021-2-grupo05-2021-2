`timescale 1ns / 1ps

module test_VGA(
    input wire clk,  // Entrada reloj 
    input wire rst,  // Entrada reset

	// VGA input/output  
    output wire VGA_Hsync_n,  // Señal de sincronización en horizontal
    output wire VGA_Vsync_n,  // Señal de sincronización en vertical
    output wire [3:0] VGA_R,	// Salida VGA Rojo (4 bits)
    output wire [3:0] VGA_G,  // Salida VGA Verde (4bits)
    output wire [3:0] VGA_B,  // Salida VGA Azul (4 bits)
    output wire clkout,  
	// input/output
	
	
	input wire bntr,
	input wire bntl
		
);

// TAMAÑO DE visualización 
parameter CAM_SCREEN_X = 160;
parameter CAM_SCREEN_Y = 120;

localparam AW = 15; // LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
localparam DW = 3;

// // El color es RGB 444
//  localparam RED_VGA =   12'b111100000000;
//  localparam GREEN_VGA = 12'b000011110000;
//  localparam BLUE_VGA =  12'b000000001111;

// // El color es RGB 332
// localparam RED_VGA =   8'b11100000;
// localparam GREEN_VGA = 8'b00011100;
// localparam BLUE_VGA =  8'b00000011;

// // El color es RGB 111
// localparam RED_VGA =   3'b100;
// localparam GREEN_VGA = 3'b010;
// localparam BLUE_VGA =  3'b001;

// Clk 
wire clk12M;
wire clk25M;

// Conexión dual por ram

wire  [AW-1: 0] DP_RAM_addr_in;  
wire  [DW-1: 0] DP_RAM_data_in;
wire DP_RAM_regW;

reg  [AW-1: 0] DP_RAM_addr_out;  
	
// Conexión VGA Driver
wire [DW-1:0]data_mem;	   // Salida de dp_ram al driver VGA
wire [DW-1:0]data_RGB444;  // salida del driver VGA al puerto
wire [9:0]VGA_posX;		   // Determinar la pos de memoria que viene del VGA
wire [8:0]VGA_posY;		   // Determinar la pos de memoria que viene del VGA


/* ****************************************************************************
la pantalla VGA es RGB 444, pero el almacenamiento en memoria se hace 332
por lo tanto, los bits menos significactivos deben ser cero
**************************************************************************** */
	// assign VGA_R = data_RGB444[11:10];
	// assign VGA_G = data_RGB444[7:6];
	// assign VGA_B = data_RGB444[3:2];
	
	// assign VGA_R = {data_RGB444[2], 3'b000};
	// assign VGA_G = {data_RGB444[1], 3'b000};
	// assign VGA_B = {data_RGB444[0], 3'b000};

	assign VGA_R = data_RGB444[2];
	assign VGA_G = data_RGB444[1];
	assign VGA_B = data_RGB444[0];

/* ****************************************************************************
  Este bloque se debe modificar según sea le caso. El ejemplo esta dado para
  fpga Spartan6 lx9 a 32MHz.
  usar "tools -> IP Generator ..."  y general el ip con Clocking Wizard
  el bloque genera un reloj de 25Mhz usado para el VGA , a partir de una frecuencia de 12 Mhz
**************************************************************************** */
assign clk12M = clk;

/*
cl_25_24_quartus clk25(
	.areset(rst),
	.inclk0(clk12M),
	.c0(clk25M)
	
);
*/


assign clk25M=clk;
assign clkout=clk25M;

/* ****************************************************************************
buffer_ram_dp buffer memoria dual port y reloj de lectura y escritura separados
Se debe configurar AW  según los calculos realizados en el Wp01
se recomiendia dejar DW a 8, con el fin de optimizar recursos  y hacer RGB 332
**************************************************************************** */
buffer_ram_dp #( AW, DW,"G:/Users/Administrador/Documents/UNAL Docs/2021 - II/Electronica Digital I/Lab/wp01-2021-2-grupo05-2021-2/hdl/quartus/scr/image.txt")
	DP_RAM(  
	.clk_w(clk25M), 
	.addr_in(DP_RAM_addr_in), 
	.data_in(DP_RAM_data_in),
	.regwrite(DP_RAM_regW), 
	
	.clk_r(clk25M), 
	.addr_out(DP_RAM_addr_out),
	.data_out(data_mem)
	);
	

/* ****************************************************************************
VGA_Driver640x480
**************************************************************************** */
VGA_Driver640x480 VGA640x480
(
	.rst(rst),
	.clk(clk25M), 				// 25MHz  para 60 hz de 640x480
	.pixelIn(data_mem), 		// entrada del valor de color  pixel RGB 444 
//	.pixelIn(RED_VGA), 		// entrada del valor de color  pixel RGB 444 
	.pixelOut(data_RGB444), // salida del valor pixel a la VGA 
	.Hsync_n(VGA_Hsync_n),	// señal de sincronizaciÓn en horizontal negada
	.Vsync_n(VGA_Vsync_n),	// señal de sincronizaciÓn en vertical negada 
	.posX(VGA_posX), 			// posición en horizontal del pixel siguiente
	.posY(VGA_posY) 			// posición en vertical  del pixel siguiente

);

 
/* ****************************************************************************
LÓgica para actualizar el pixel acorde con la buffer de memoria y el pixel de 
VGA si la imagen de la camara es menor que el display  VGA, los pixeles 
adicionales seran iguales al color del último pixel de memoria 
**************************************************************************** */
reg [2:0] cuadroColores[7:0];
cuadroColores[0] = 000
cuadroColores[1] = 001
cuadroColores[2] = 000
cuadroColores[3] = 000

always @ (VGA_posX, VGA_posY) begin
		if ((VGA_posX>CAM_SCREEN_X-1) || (VGA_posY>CAM_SCREEN_Y-1))
			DP_RAM_addr_out=19212; //0F0 000 1111 000
			data_men = cuadroColores[0]
		else
			DP_RAM_addr_out=VGA_posX+VGA_posY*CAM_SCREEN_Y;
end


//assign DP_RAM_addr_out=10000;

/*****************************************************************************

este bloque debe crear un nuevo archivo 
**************************************************************************** */
 FSM_game  juego(
	 	.clk(clk25M),
		.rst(rst),
		.in1(btnr),
		.in2(btnr),
		.mem_px_addr(DP_RAM_addr_in),
		.mem_px_data(DP_RAM_data_in),
		.px_wr(DP_RAM_regW)
   );
endmodule
