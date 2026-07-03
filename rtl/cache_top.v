`timescale 1ns/1ps
module cache_top(
    input clk,
    input rst,
    input        cpu_read,
    input        cpu_write,
    input [31:0] cpu_addr,
    input [31:0] cpu_wdata,
    input [3:0]  cpu_byte_en,
    output cpu_ready,
    output [31:0] cpu_rdata,
    output [31:0] read_hits,
    output [31:0] read_misses,
    output [31:0] write_hits,
    output [31:0] write_misses,
    output [31:0] total_accesses
);
    wire [21:0] tag_out_way0;
    wire valid_out_way0;
    wire dirty_out_way0;
    wire [21:0] tag_out_way1;
    wire valid_out_way1;
    wire dirty_out_way1;
    wire tag_write_en;
    wire [5:0] tag_index;
    wire [21:0] tag_in;
    wire valid_in;
    wire [127:0] line_out_way0;
    wire [127:0] line_out_way1;
    wire refill_en;
    wire [127:0] refill_data;
    wire [5:0] data_index;
    wire        write_hit_en;
    wire [1:0]  word_sel;
    wire [31:0] write_data;
    wire [3:0]  write_byte_en;
    wire read_hit;
    wire read_miss;
    wire write_hit;
    wire write_miss;
    wire way0_write_en;
    wire way1_write_en;
    wire way0_refill_en;
    wire way1_refill_en;
    wire way0_data_write_en;
    wire way1_data_write_en;
    wire way0_dirty_write;
    wire way1_dirty_write;
    wire way0_dirty_value;
    wire way1_dirty_value;
    wire access_way0;
    wire access_way1;
    wire lru_bit;
    wire mem_write;
    wire [127:0] mem_wdata;
    wire mem_read;
    wire [31:0] mem_addr;
    wire mem_ready;
    wire [127:0] mem_rdata;
    cache_controller controller (
        .clk(clk),
        .rst(rst),
        .cpu_read(cpu_read),
        .cpu_write(cpu_write),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_byte_en(cpu_byte_en),
        .cpu_ready(cpu_ready),
        .cpu_rdata(cpu_rdata), 
        .tag_out_way0(tag_out_way0),
        .valid_out_way0(valid_out_way0),
        .dirty_out_way0(dirty_out_way0),
        .tag_out_way1(tag_out_way1),
        .valid_out_way1(valid_out_way1),
        .dirty_out_way1(dirty_out_way1),
        .tag_write_en(tag_write_en),
        .tag_index(tag_index),
        .tag_in(tag_in),
        .valid_in(valid_in),
        .line_out_way0(line_out_way0),
        .line_out_way1(line_out_way1),
        .refill_en(refill_en),
        .refill_data(refill_data),
        .data_index(data_index),
        .write_hit_en(write_hit_en),
        .word_sel(word_sel),
        .write_data(write_data),
        .write_byte_en(write_byte_en),
        .read_hit(read_hit),
        .read_miss(read_miss),
        .write_hit(write_hit),
        .write_miss(write_miss),
        .mem_read(mem_read),
        .mem_addr(mem_addr),
        .mem_write(mem_write),
        .mem_wdata(mem_wdata),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .access_way0(access_way0),
        .access_way1(access_way1),
        .lru_bit(lru_bit),
        .way0_dirty_write(way0_dirty_write),
        .way1_dirty_write(way1_dirty_write),
        .way0_dirty_value(way0_dirty_value),
        .way1_dirty_value(way1_dirty_value),
        .way0_data_write_en(way0_data_write_en),
        .way1_data_write_en(way1_data_write_en),
        .way0_refill_en(way0_refill_en),
        .way1_refill_en(way1_refill_en),
        .way0_write_en(way0_write_en),
        .way1_write_en(way1_write_en)
    );
    tag_array tag_way0 (  
        .clk(clk),
        .rst(rst),
        .index(tag_index),
        .write_en(way0_write_en),
        .tag_in(tag_in),
        .valid_in(valid_in),
        .dirty_in(way0_dirty_value),
        .dirty_write(way0_dirty_write),
        .dirty_value(way0_dirty_value),
        .tag_out(tag_out_way0),
        .valid_out(valid_out_way0),
        .dirty_out(dirty_out_way0)
    );
    tag_array tag_way1 ( 
        .clk(clk),
        .rst(rst),
        .index(tag_index),
        .write_en(way1_write_en),
        .tag_in(tag_in),
        .valid_in(valid_in),
        .dirty_in(way1_dirty_value),
        .dirty_write(way1_dirty_write),
        .dirty_value(way1_dirty_value),
        .tag_out(tag_out_way1),
        .valid_out(valid_out_way1),
        .dirty_out(dirty_out_way1)
    );
    data_array data_way0 (
        .clk(clk),
        .rst(rst),
        .index(data_index),
        .line_out(line_out_way0),
        .refill_en(way0_refill_en),
        .refill_data(refill_data),
        .write_hit_en(way0_data_write_en),
        .word_sel(word_sel),
        .cpu_wdata(write_data),
        .byte_en(write_byte_en)
    );
    data_array data_way1 (
        .clk(clk),
        .rst(rst),
        .index(data_index),
        .line_out(line_out_way1),
        .refill_en(way1_refill_en),
        .refill_data(refill_data),
        .write_hit_en(way1_data_write_en),
        .word_sel(word_sel),
        .cpu_wdata(write_data),
        .byte_en(write_byte_en)
    );
    main_memory memory (
        .clk(clk),
        .rst(rst),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata)
    );
    performance_counters perf (
        .clk(clk),
        .rst(rst),
        .read_hit(read_hit),
        .read_miss(read_miss),
        .write_hit(write_hit),
        .write_miss(write_miss),
        .read_hits(read_hits),
        .read_misses(read_misses),
        .write_hits(write_hits),
        .write_misses(write_misses),
        .total_accesses(total_accesses)
    );
    lru_logic lru (
        .clk(clk),
        .rst(rst),
        .access_way0(access_way0),
        .access_way1(access_way1),
        .index(tag_index),
        .lru_bit(lru_bit)
    );
endmodule