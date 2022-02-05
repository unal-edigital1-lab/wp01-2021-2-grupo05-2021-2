`timescale 1ns / 1ps

module half_clk (input clk, output clk_half);

reg cfreq = 0;

assign clk_half = cfreq;

always @(posedge clk) begin
    if (cfreq > 2'b11) 
        // para que su valor no se incremente indefinidamente
        cfreq <= 0; 
    else
        cfreq <= cfreq + 1;
end

endmodule
