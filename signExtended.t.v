`timescale 1 ns / 1 ps
`include "signExtended.v"

module testSignExtended();
	
	wire[31:0] out;
	reg[15:0] in;
    signExtended se(out, in);

    initial begin
    $display("inputs           | Output");
    in = 16'h00FF; #10
    $display("%b | %b", in, out);
    in = 16'hFAAF; #10
    $display("%b | %b", in, out);
    end

endmodule