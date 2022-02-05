`timescale 1ns / 1ps

module gen_Clk25M  (
	 	input CLK_IN1,
		input RESET,
		output CLK_OUT1
   );

assign CLK_OUT1=CLK_IN1;



// reg cfreq = 0;

// assign clk25M = cfreq[0];
// always @(posedge clk) begin
// 		cfreq<=cfreq+1;
// end

endmodule
