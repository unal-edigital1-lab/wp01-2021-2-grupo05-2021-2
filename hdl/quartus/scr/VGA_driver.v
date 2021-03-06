
module VGA_Driver640x480 #(
	parameter SCREEN_X = 640,
	parameter SCREEN_Y = 480
)
(
	input rst,  // Entrada reset
	input clk, 	// Entrada reloj 25MHz para 60 hz de 640x480
	input  [11:0] pixelIn, 	// entrada del valor de color  pixel 
	output  [11:0] pixelOut, // salida pixel VGA (RGB)
	output  Hsync_n,		// seÃ±al de sincronizaciÃ³n en horizontal negada
	output  Vsync_n,		// seÃ±al de sincronizaciÃ³n en vertical negada 
	output  [9:0] posX, 	// posicion en horizontal del pixel siguiente
	output  [8:0] posY 		// posicion en vertical  del pixel siguiente
);

// localparam SCREEN_X = 640; // Tamaño de la VGA horizontal 
localparam FRONT_PORCH_X =16;  // Pixeles de sincronización
localparam SYNC_PULSE_X = 96;
localparam BACK_PORCH_X = 48;
localparam TOTAL_SCREEN_X = SCREEN_X+FRONT_PORCH_X+SYNC_PULSE_X+BACK_PORCH_X; 	// total pixel pantalla en horizontal 


// localparam SCREEN_Y = 480;  // Tamaño de la VGA vertical
localparam FRONT_PORCH_Y =10;  // Pixeles de sincronización
localparam SYNC_PULSE_Y = 2;
localparam BACK_PORCH_Y = 33;
localparam TOTAL_SCREEN_Y = SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y+BACK_PORCH_Y; 	// total pixel pantalla en Vertical 


reg  [9:0] countX;
reg  [8:0] countY;

assign posX    = countX;
assign posY    = countY;

assign pixelOut = (countX<SCREEN_X) ? (pixelIn ) : (12'b000000000000) ; // Dejar en blanco la zona del porch

assign Hsync_n = ~((countX>=SCREEN_X+FRONT_PORCH_X) && (countX<SCREEN_X+SYNC_PULSE_X+FRONT_PORCH_X)); // Sincronización horizontal
assign Vsync_n = ~((countY>=SCREEN_Y+FRONT_PORCH_Y) && (countY<SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y)); // Sincronización vertical


always @(posedge clk) begin
	if (~rst) begin
		countX <= TOTAL_SCREEN_X-10; /*para la simulación sea mas rapido*/
		countY <= TOTAL_SCREEN_Y-4;/*para la simulación sea mas rapido*/
	end
	else begin 
		if (countX >= (TOTAL_SCREEN_X)) begin
			countX <= 0;
			if (countY >= (TOTAL_SCREEN_Y)) begin
				countY <= 0;
			end 
			else begin
				countY <= countY + 1;
			end
		end 
		else begin
			countX <= countX + 1;
			countY <= countY;
		end
	end
end

endmodule
