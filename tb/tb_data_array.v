`timescale 1ns/1ps
module tb_data_array;
    reg clk;
    reg rst;
    reg [5:0] index;
    wire [127:0] line_out;
    reg refill_en;
    reg [127:0] refill_data;
    reg write_hit_en;
    reg [1:0] word_sel;
    reg [31:0] cpu_wdata;
    reg [3:0] byte_en;
    integer errors;
    data_array uut (
        .clk(clk),
        .rst(rst),
        .index(index),
        .line_out(line_out),
        .refill_en(refill_en),
        .refill_data(refill_data),
        .write_hit_en(write_hit_en),
        .word_sel(word_sel),
        .cpu_wdata(cpu_wdata),
        .byte_en(byte_en)
    );
    task check_line;
        input [127:0] expected;
    begin
        if(line_out !== expected) begin
            $display("[FAIL] @ %0t", $time);
            $display("Expected = %h", expected);
            $display("Actual   = %h", line_out);
            errors = errors + 1;
        end
        else begin
            $display("[PASS] @ %0t", $time);
        end
    end
    endtask
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        errors = 0;
        rst = 1;
        index = 0;
        refill_en = 0;
        refill_data = 0;
        write_hit_en = 0;
        word_sel = 0;
        cpu_wdata = 0;
        byte_en = 0;
        #20;
        rst = 0;
        #10;
        check_line(128'h0);
        index = 0;
        refill_data =
            128'h00000003_00000002_00000001_00000000;
        refill_en = 1;
        #10;
        refill_en = 0;
        #10;
        check_line(
            128'h00000003_00000002_00000001_00000000
        );
        word_sel = 2;
        cpu_wdata = 32'hAAAAAAAA;
        byte_en = 4'b1111;
        write_hit_en = 1;
        #10;
        write_hit_en = 0;
        #10;
        check_line(
            128'h00000003_AAAAAAAA_00000001_00000000
        );
        word_sel = 1;
        cpu_wdata = 32'h000000FF;
        byte_en = 4'b0001;
        write_hit_en = 1;
        #10;
        write_hit_en = 0;
        #10;
        check_line(
            128'h00000003_AAAAAAAA_000000FF_00000000
        );
        #10;
        $display("");
        if(errors == 0)
            $display("DATA ARRAY TEST PASSED");
        else
            $display("DATA ARRAY TEST FAILED : %0d ERRORS", errors);
        $finish;
    end
endmodule 