`timescale 1ns/1ps
module data_array #(
    parameter NUM_LINES   = 32,
    parameter INDEX_WIDTH = 6,
    parameter DATA_WIDTH  = 32,
    parameter WORDS_PER_LINE = 4
)(
    input                           clk,
    input                           rst,
    input  [INDEX_WIDTH-1:0]        index,
    output reg [127:0]              line_out,
    input                           refill_en,
    input  [127:0]                  refill_data,
    input                           write_hit_en,
    input  [1:0]                    word_sel,
    input  [31:0]                   cpu_wdata,
    input  [3:0]                    byte_en
);
    reg [DATA_WIDTH-1:0]
        data_mem [0:NUM_LINES-1][0:WORDS_PER_LINE-1];
    integer i, j;
    reg [DATA_WIDTH-1:0] temp_word;
    always @(posedge clk) begin
        if (rst) begin
            for(i = 0; i < NUM_LINES; i = i + 1)
                for(j = 0; j < WORDS_PER_LINE; j = j + 1)
                    data_mem[i][j] <= 32'd0;
            line_out <= 128'd0;
        end
        else begin
            if(refill_en) begin
                data_mem[index][0] <= refill_data[31:0];
                data_mem[index][1] <= refill_data[63:32];
                data_mem[index][2] <= refill_data[95:64];
                data_mem[index][3] <= refill_data[127:96];
            end
            else if(write_hit_en) begin    
                temp_word = data_mem[index][word_sel];
                if(byte_en[0])
                    temp_word[7:0] = cpu_wdata[7:0];
                if(byte_en[1])
                    temp_word[15:8] = cpu_wdata[15:8];
                if(byte_en[2])
                    temp_word[23:16] = cpu_wdata[23:16];
                if(byte_en[3])
                    temp_word[31:24] = cpu_wdata[31:24];
                data_mem[index][word_sel] <= temp_word;    
            end
            line_out <= {
                data_mem[index][3],
                data_mem[index][2],
                data_mem[index][1],
                data_mem[index][0]
            };
        end
    end
endmodule