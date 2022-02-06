`timescale 1ns / 1ps

module FSM_game # (
		parameter AW = 3,
		parameter DW = 3)
	(
	 	input clk, input rst,
		input sw0, input sw1, input sw2, input sw3,
		input sw4, 	input sw5, 	input sw6, 	input sw7,
		output reg [DW-1:0] cuadroColores0,
		output reg [DW-1:0] cuadroColores1,
		output reg [DW-1:0] cuadroColores2,
		output reg [DW-1:0] cuadroColores3,
		output reg [DW-1:0] cuadroColores4,
		output reg [DW-1:0] cuadroColores5,
		output reg [DW-1:0] cuadroColores6,
		output reg [DW-1:0] cuadroColores7
   );

	/*
	Lógica para simular un cambio de color cuando se oprime 
	un interruptor dentro del rango [0, 7]. El cambio de color
	viene dado como el negado del color actual almacenado
	en la posición de memoria respectiva. Por ejemplo, si 
	se oprime el interruptor 2 y a ese le corresponde el color 
	001 (sin oprimir el interruptor), el resultado será 110.
	*/
	localparam colorBase = 3'b010;
	always @(posedge clk) begin
			if (sw0)
				cuadroColores0 = colorBase;
			else 
				cuadroColores0 = 3'b111;
			if (sw1)
				cuadroColores1 = colorBase;
			else
				cuadroColores1 = 3'b001;
			if (sw2)
				cuadroColores2 = colorBase;
			else
				cuadroColores2 = 3'b001;
			if (sw3)
				cuadroColores3 = colorBase;
			else
				cuadroColores3 = 3'b110;
			if (sw4)
				cuadroColores4 = colorBase;
			else
				cuadroColores4 = 3'b011;
			if (sw5)
				cuadroColores5 = colorBase;
			else
				cuadroColores5 = 3'b110;
			if (sw6)
				cuadroColores6 = colorBase;
			else
				cuadroColores6 = 3'b011;
			if (sw7)
				cuadroColores7 = colorBase;
			else
				cuadroColores7 = 3'b111;
	end

endmodule
