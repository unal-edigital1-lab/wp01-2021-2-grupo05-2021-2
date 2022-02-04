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
	
	
	input wire sw0,
	input wire sw1,
	input wire sw2,
	input wire sw3,
	input wire sw4,
	input wire sw5,
	input wire sw6,
	input wire sw7
);


 /*
 Se va a "reducir" la resolución de tal modo que solo 
 se almacenen 8 datos en memoria. Así, el tamaño de la 
 memoria ya no viene dado por el número de píxeles
 utilizados en la visualización. 
 A saber, LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
 **/
parameter CAM_SCREEN_X = 640;
parameter CAM_SCREEN_Y = 480;

localparam AW = 3; // 2^AW = 8 celdas de memoria
localparam DW = 3; // 2^DW número de colores posibles

// Clk 
wire clk12M;
wire clk25M;

// Conexión dual por ram

wire  [AW-1: 0] DP_RAM_addr_in;  
wire  [DW-1: 0] DP_RAM_data_in;
wire DP_RAM_regW;

reg  [AW-1: 0] DP_RAM_addr_out;  
	
// Conexión VGA Driver
reg [DW-1:0] data_mem;	   // Salida de dp_ram al driver VGA
wire [DW-1:0] data_RGB444;  // salida del driver VGA al puerto
wire [9:0]VGA_posX;		   // Determinar la pos de memoria que viene del VGA
wire [8:0]VGA_posY;		   // Determinar la pos de memoria que viene del VGA

reg [DW-1:0] cuadroColores [0: 8 - 1];
wire [2:0] cuadroColores0;
wire [2:0] cuadroColores1;
wire [2:0] cuadroColores2;
wire [2:0] cuadroColores3;
wire [2:0] cuadroColores4;
wire [2:0] cuadroColores5;
wire [2:0] cuadroColores6;
wire [2:0] cuadroColores7;
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
// buffer_ram_dp #( AW, DW,"G:/Users/Administrador/Documents/UNAL Docs/2021 - II/Electronica Digital I/Lab/wp01-2021-2-grupo05-2021-2/hdl/quartus/scr/image.txt")
// 	DP_RAM(  
// 	.clk_w(clk25M), 
// 	.addr_in(DP_RAM_addr_in), 
// 	.data_in(DP_RAM_data_in),
// 	.regwrite(DP_RAM_regW), 
	
// 	.clk_r(clk25M), 
// 	.addr_out(DP_RAM_addr_out),
// 	.data_out(data_mem)
// 	);
	

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


// Primera fila
localparam cWidth = CAM_SCREEN_X/4;
localparam cHeight = CAM_SCREEN_Y/2;
localparam xc0 = cWidth;
localparam yc0 = cHeight;
localparam xc1 = cWidth*2;
// localparam yc1 = cHeight;
localparam xc2 = cWidth*3;
// localparam yc2 = cHeight;
localparam xc3 = cWidth*4;
// localparam yc3 = cHeight;
// Segunda fila
localparam xc4 = CAM_SCREEN_X/4;
// localparam yc4 = CAM_SCREEN_Y/2;
localparam xc5 = CAM_SCREEN_X/4;
// localparam yc5 = CAM_SCREEN_Y/2;
localparam xc6 = CAM_SCREEN_X/4;
// localparam yc6 = CAM_SCREEN_Y/2;
localparam xc7 = CAM_SCREEN_X/4;
// localparam yc7 = CAM_SCREEN_Y/2;

always @ (VGA_posX, VGA_posY) begin
		if ((VGA_posX>CAM_SCREEN_X-1) || (VGA_posY>CAM_SCREEN_Y-1))
			// DP_RAM_addr_out=19212; //0F0 000 1111 000
			data_mem = 3'b000;
		else
			// DP_RAM_addr_out=VGA_posX+VGA_posY*CAM_SCREEN_Y;
			if ( (VGA_posX-CAM_SCREEN_X/2)**2 + (VGA_posY-CAM_SCREEN_Y/2)**2 < (CAM_SCREEN_Y/2)**2)
				data_mem = 3'b111;
			else
				data_mem = 3'b000;
			// if (VGA_posX < xc0 && VGA_posY < yc0 )
			// 	data_mem = cuadroColores0;
			// else if ((VGA_posX > xc0 && VGA_posX < xc1) && (VGA_posY < yc0) )
			// 	data_mem = cuadroColores1;
			// else if ((VGA_posX > xc1 && VGA_posX < xc2) && (VGA_posY < yc0) )
			// 	data_mem = cuadroColores2;
			// else if ((VGA_posX > xc2 && VGA_posX < xc3) && (VGA_posY < yc0) )
			// 	data_mem = cuadroColores3;
			// 	// segunda fila
			// else if (VGA_posX < xc0 && VGA_posY > yc0 )
			// 	data_mem = cuadroColores4;
			// else if ((VGA_posX > xc0 && VGA_posX < xc1) && (VGA_posY > yc0) )
			// 	data_mem = cuadroColores5;
			// else if ((VGA_posX > xc1 && VGA_posX < xc2) && (VGA_posY > yc0) )
			// 	data_mem = cuadroColores6;
			// else if ((VGA_posX > xc2 && VGA_posX < xc3) && (VGA_posY > yc0) )
			// 	data_mem = cuadroColores7;
end


//assign DP_RAM_addr_out=10000;

/*****************************************************************************

este bloque debe crear un nuevo archivo 
**************************************************************************** */
/*
Ocho interruptores para realizar el control (cada uno) del
respectivo subcuadro de la pantalla
*/


 FSM_game  juego (
	 	clk25M, rst,
		sw0, sw1, sw2, sw3,
		sw4, sw5, sw6, sw7,
		cuadroColores0,
		cuadroColores1,
		cuadroColores2,
		cuadroColores3,
		cuadroColores4,
		cuadroColores5,
		cuadroColores6,
		cuadroColores7,
		DP_RAM_regW
		// .mem_px_addr(DP_RAM_addr_in),
		// .mem_px_data(DP_RAM_data_in),
		// .px_wr(DP_RAM_regW)
   );
endmodule
