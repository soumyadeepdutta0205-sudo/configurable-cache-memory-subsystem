`timescale 1ns/1ps
module tag_array #(
    parameter TAG_WIDTH = 22,
    parameter NUM_LINES = 32,
    parameter INDEX_WIDTH = 6
)(
    input                       clk,
    input                       rst,
    input  [INDEX_WIDTH-1:0]    index,
    input                       write_en,
    input  [TAG_WIDTH-1:0]      tag_in,
    input                       valid_in,
    input                       dirty_in,
    input                       dirty_write,
    input                       dirty_value,
    output reg [TAG_WIDTH-1:0]  tag_out,
    output reg                  valid_out,
    output reg                  dirty_out
);   
    reg [TAG_WIDTH+1:0] tag_mem [0:NUM_LINES-1];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < NUM_LINES; i = i + 1)
                tag_mem[i] <= {(TAG_WIDTH+2){1'b0}};
            tag_out   <= {TAG_WIDTH{1'b0}};
            valid_out <= 1'b0;
            dirty_out <= 1'b0;
        end
        else begin   
            if (write_en) begin
                tag_mem[index] <= {valid_in, dirty_in, tag_in};
            end
            else if (dirty_write) begin
                tag_mem[index][TAG_WIDTH] <= dirty_value;
            end       
            tag_out   <= tag_mem[index][TAG_WIDTH-1:0];        
            dirty_out <= tag_mem[index][TAG_WIDTH];
            valid_out <= tag_mem[index][TAG_WIDTH+1];
        end
    end
endmodule