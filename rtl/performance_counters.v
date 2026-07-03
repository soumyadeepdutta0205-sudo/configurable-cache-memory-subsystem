`timescale 1ns/1ps
module performance_counters(
    input clk,
    input rst,
    input read_hit,
    input read_miss,
    input write_hit,
    input write_miss,
    output reg [31:0] read_hits,
    output reg [31:0] read_misses,
    output reg [31:0] write_hits,
    output reg [31:0] write_misses,
    output reg [31:0] total_accesses
);
always @(posedge clk) begin
    if(rst) begin
        read_hits      <= 0;
        read_misses    <= 0;
        write_hits     <= 0;
        write_misses   <= 0;
        total_accesses <= 0;
    end
    else begin
        if(read_hit) begin
            read_hits <= read_hits + 32'd1;
            total_accesses <= total_accesses + 1;
        end
        if(read_miss) begin
            read_misses <= read_misses + 1;
            total_accesses <= total_accesses + 1;
        end
        if(write_hit) begin
            write_hits <= write_hits + 1;
            total_accesses <= total_accesses + 1;
        end
        if(write_miss) begin
            write_misses <= write_misses + 1;
            total_accesses <= total_accesses + 1;
        end
    end
end
endmodule