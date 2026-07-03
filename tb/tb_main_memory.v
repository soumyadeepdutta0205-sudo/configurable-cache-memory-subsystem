`timescale 1ns/1ps
module tb_main_memory;
    reg clk;
    reg rst;
    reg mem_read;
    reg mem_write;
    reg [31:0] mem_addr;
    reg [127:0] mem_wdata;
    wire mem_ready;
    wire [127:0] mem_rdata;
    integer errors;
    main_memory uut (
        .clk(clk),
        .rst(rst),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata)
    );
    task check_mem;
        input [127:0] expected;
    begin
        if(mem_rdata !== expected) begin
            $display("[FAIL] @ %0t", $time);
            $display("Expected = %h", expected);
            $display("Actual   = %h", mem_rdata);
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
        mem_read = 0;
        mem_write = 0;
        mem_addr = 0;
        mem_wdata = 0;
        #20;
        rst = 0;
        mem_addr = 32'h00000000;
        mem_read = 1;
        #10;
        mem_read = 0;
        wait(mem_ready);
        #10;
        check_mem(
            128'h00000003_00000002_00000001_00000000
        );
        mem_addr = 32'h00000000;
        mem_wdata =
            128'h00000003_AAAAAAAA_00000001_00000000;
        mem_write = 1;
        #10;
        mem_write = 0;
        #20;
        mem_addr = 32'h00000000;
        mem_read = 1;
        #10;
        mem_read = 0;
        wait(mem_ready);
        #10;
        check_mem(
            128'h00000003_AAAAAAAA_00000001_00000000
        );
        #20;
        $display("");
        if(errors == 0)
            $display("MAIN MEMORY TEST PASSED");
        else
            $display("MAIN MEMORY TEST FAILED : %0d ERRORS", errors);
        $finish;
    end
endmodule 