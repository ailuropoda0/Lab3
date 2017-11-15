// register

module register
#(
    parameter width  = 32
)
(
	output reg[width-1:0]  	q,         // data output
	input[width-1:0] 		d,         // data input
	input	 				wrenable,  // write enable
	input       			clk        // clock
);
    always @(posedge clk) begin
        if(wrenable) begin
            q <= d;
        end
    end
endmodule

module registerZero
#(
    parameter width  = 32
)
(
    output reg[width-1:0]   q,         // data output
    input[width-1:0]        d,         // data input
    input                   wrenable,  // write enable
    input                   clk        // clock
);
    always @(posedge clk) begin
        q <= 0;
    end
endmodule