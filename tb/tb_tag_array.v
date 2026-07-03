`timescale 1ns/1ps
module tb_tag_array;
    reg clk;
    reg rst;
    reg [5:0] index;
    reg write_en;
    reg [21:0] tag_in;
    reg valid_in;
    reg dirty_in;
    reg dirty_write;
    reg dirty_value;
    wire [21:0] tag_out;
    wire valid_out;
    wire dirty_out;
    integer errors;
    tag_array uut (
        .clk(clk),
        .rst(rst),
        .index(index),
        .write_en(write_en),
        .tag_in(tag_in),
        .valid_in(valid_in),
        .dirty_in(dirty_in),
        .dirty_write(dirty_write),
        .dirty_value(dirty_value),
        .tag_out(tag_out),
        .valid_out(valid_out),
        .dirty_out(dirty_out)
    );
    task check_tag;
        input [21:0] exp_tag;
        input exp_valid;
        input exp_dirty;
    begin
        if(tag_out !== exp_tag ||
            valid_out !== exp_valid ||
            dirty_out !== exp_dirty) begin
            $display("[FAIL] @ %0t", $time);
            $display("Expected: tag=%h valid=%b dirty=%b", exp_tag, exp_valid, exp_dirty);
            $display("Actual  : tag=%h valid=%b dirty=%b", tag_out, valid_out, dirty_out);
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
        write_en = 0;
        tag_in = 0;
        valid_in = 0;
        dirty_in = 0;
        dirty_write = 0;
        dirty_value = 0;
        #20;
        rst = 0;
        #10;
        check_tag(22'h0, 1'b0, 1'b0);     
        index = 6'd5;
        tag_in = 22'h12345;
        valid_in = 1'b1;
        dirty_in = 1'b0;
        write_en = 1'b1;
        #10;
        write_en = 1'b0;
        #10;
        check_tag(22'h12345, 1'b1, 1'b0);      
        dirty_write = 1'b1;
        dirty_value = 1'b1;
        #10;
        dirty_write = 1'b0;
        #10;
        check_tag(22'h12345, 1'b1, 1'b1);
        #20;
        $display("");
        if(errors == 0)
            $display("TAG ARRAY TEST PASSED");
        else
            $display("TAG ARRAY TEST FAILED : %0d ERRORS", errors);
        $finish;  
    end
endmodule