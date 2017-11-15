//Program counter for a cpu, implemented as a 32-bit d flip flop
module programCounter
(
output reg[31:0]    currentCount,
output reg[3:0]     lastFourBits,
input[31:0]         newCount,
input               wrenable,
input               clk
);
	initial begin
		currentCount = -4;
	end

    always @(posedge clk) begin
        if(wrenable) begin
            currentCount = newCount;
            lastFourBits = newCount[31:28];
        end
    end

endmodule
