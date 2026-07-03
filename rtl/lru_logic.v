`timescale 1ns/1ps
module lru_logic(
    input clk,
    input rst,
    input access_way0,
    input access_way1,
    input [5:0] index,
    output reg lru_bit
);
    reg lru_mem [0:63];
    integer i;
    always @(posedge clk) begin
        if(rst) begin
            for(i=0;i<64;i=i+1)
                lru_mem[i] <= 1'b0;
        end
        else begin
            if(access_way0)
                lru_mem[index] <= 1'b1;
            else if(access_way1)
                lru_mem[index] <= 1'b0;
        end
    end
    always @(*) begin
        lru_bit = lru_mem[index];
    end
endmodule