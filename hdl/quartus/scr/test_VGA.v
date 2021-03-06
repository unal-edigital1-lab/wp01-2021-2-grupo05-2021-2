`timescale 1ns / 1ps

module test_VGA (
    input clk,  // Entrada reloj 
    input rst,  // Entrada reset

	// VGA

	// Sincronización horizontal y vertical 
    output VGA_Hsync_n,
    output VGA_Vsync_n,
	// Salida VGA RGB111
    output VGA_R, output VGA_G, output VGA_B,

	// control
	
	input sw0, input sw1, input sw2, input sw3,
	input sw4, input sw5, input sw6, input sw7
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

localparam AW = 3; // 2^AW = 8 direcciones de memoria
localparam DW = 3; // 2^DW número de colores posibles

// Señales clock
// wire clk12M;
wire clk25M;

// Conexión VGA Driver
reg [DW-1:0] data_mem;	    // Salida de dp_ram al driver VGA
wire [DW-1:0] data_RGB444;  // Salida del driver VGA al puerto

// Posición de memoria actual del cursor VGA
wire [9:0] VGA_posX;
wire [8:0] VGA_posY;


/* ****************************************************************************
Se asignan los bits para cada color (RGB) serán enviados al puerto VGA.
**************************************************************************** */
	
	assign VGA_R = data_RGB444[2];
	assign VGA_G = data_RGB444[1];
	assign VGA_B = data_RGB444[0];

/* ****************************************************************************
  Se genera una señal clock de 25M Hz a partir de la señal clock de la FPGA,
  la cual según el datasheet es de 50M Hz.
  
  ¿Por qué debe ser de 25M Hz?
  Como la tasa de refresco del monitor es de 60 Hz, significa que el código, 
  al recorrer todos los píxeles (640*480 = 307 200) con un reloj de 50Mhz,
  abrá recorrido la pantalla  (50Mhz/2)/307200 = 81.2 veces, puesto que las
  coordenadas del pixel se actualizan conforme cada flanco de subida del la
  señal de reloj (se divide en 2 porque es el número de flancos de subida 
  que hay). Por tanto, es necesario reducir la señal de reloj. Se reduce 
  al divisor entero más cercano (2). De este modo, con 25Mhz, se tienen
  40.6 imágenes por segundo y no hay pérdida de datos.

**************************************************************************** */
assign clk50M = clk;
// assign clk25M = clk;
half_clk clk_div_2 (.clk(clk50M), .clk_half(clk25M));

/* ****************************************************************************
No es necesario utilizar memoria RAM
**************************************************************************** */

/*
buffer_ram_dp #( AW, DW,"G:/Users/Administrador/Documents/UNAL Docs/2021 - II/Electronica Digital I/Lab/wp01-2021-2-grupo05-2021-2/hdl/quartus/scr/image.txt")
	DP_RAM (
	.clk_w(clk25M), 
	.addr_in(DP_RAM_addr_in), 
	.data_in(DP_RAM_data_in),
	.regwrite(DP_RAM_regW), 
	
	.clk_r(clk25M), 
	.addr_out(DP_RAM_addr_out),
	.data_out(data_mem)
	);
	*/
	

/* ****************************************************************************
VGA_Driver640x480
tiempo que se tarda en imprimir toda la pantalla
1 s/40.6 pantallas = 24.63ms/pantalla a 25Mhz
**************************************************************************** */
VGA_Driver640x480 VGA640x480
(
	.rst(rst),
	.clk(clk25M), 				// 25MHz  para 60 hz de 640x480
	.pixelIn(data_mem), 		// entrada del valor de color  pixel RGB 444 
	.pixelOut(data_RGB444),     // salida del valor pixel a la VGA 
	.Hsync_n(VGA_Hsync_n),	    // señal de sincronizaciÓn en horizontal negada
	.Vsync_n(VGA_Vsync_n),	    // señal de sincronizaciÓn en vertical negada 
	.posX(VGA_posX), 			// posición en horizontal del pixel siguiente
	.posY(VGA_posY) 			// posición en vertical  del pixel siguiente

);

 
/* ****************************************************************************
Lógica para actualizar el color de pixel acorde con la posición del pixel
actual de la VGA. Si el pixel se encuentra fuera del tamaño de CAM_SCREE, 
los píxeles adicionales se colorean en blanco.
**************************************************************************** */
wire [2:0] cuadroColores0;
wire [2:0] cuadroColores1;
wire [2:0] cuadroColores2;
wire [2:0] cuadroColores3;
wire [2:0] cuadroColores4;
wire [2:0] cuadroColores5;
wire [2:0] cuadroColores6;
wire [2:0] cuadroColores7;

// Primera fila
localparam 	cWidth = CAM_SCREEN_X/4, 
			cHeight = CAM_SCREEN_Y/2, 
			xc0 = cWidth,
			yc0 = cHeight, 
			xc1 = cWidth*2, 
			xc2 = cWidth*3,
			xc3 = cWidth*4;
// Segunda fila
localparam 	xc4 = CAM_SCREEN_X/4, xc5 = CAM_SCREEN_X/4,
			xc6 = CAM_SCREEN_X/4, xc7 = CAM_SCREEN_X/4;

always @ (VGA_posX, VGA_posY) begin
	if ((VGA_posX>CAM_SCREEN_X-1) || (VGA_posY>CAM_SCREEN_Y-1))
		data_mem = 3'b111; // Colorear en blanco
	else
		// if ( (VGA_posX-CAM_SCREEN_X/2)**2 + (VGA_posY-CAM_SCREEN_Y/2)**2 < (CAM_SCREEN_Y/2)**2)
		// 	data_mem = 3'b111;
		// else
		// 	data_mem = 3'b000;
		if (VGA_posX < xc0 && VGA_posY < yc0 )
			data_mem = cuadroColores0;
		else if ((VGA_posX > xc0 && VGA_posX < xc1) && (VGA_posY < yc0) )
			data_mem = cuadroColores1;
		else if ((VGA_posX > xc1 && VGA_posX < xc2) && (VGA_posY < yc0) )
			data_mem = cuadroColores2;
		else if ((VGA_posX > xc2 && VGA_posX < xc3) && (VGA_posY < yc0) )
			data_mem = cuadroColores3;
			// segunda fila
		else if (VGA_posX < xc0 && VGA_posY > yc0 )
			data_mem = cuadroColores4;
		else if ((VGA_posX > xc0 && VGA_posX < xc1) && (VGA_posY > yc0) )
			data_mem = cuadroColores5;
		else if ((VGA_posX > xc1 && VGA_posX < xc2) && (VGA_posY > yc0) )
			data_mem = cuadroColores6;
		else if ((VGA_posX > xc2 && VGA_posX < xc3) && (VGA_posY > yc0) )
			data_mem = cuadroColores7;
		else
			data_mem = 3'b100; // color rojo para los bordes
end


/*****************************************************************************
Ocho interruptores para realizar el control (cada uno) del
respectivo subcuadro de la pantalla
**************************************************************************** */

FSM_game  juego (
	clk25M, rst,
	sw0, sw1, sw2, sw3,
	sw4, sw5, sw6, sw7,
	cuadroColores0, cuadroColores1, cuadroColores2, cuadroColores3,
	cuadroColores4, cuadroColores5, cuadroColores6, cuadroColores7
	);

endmodule
