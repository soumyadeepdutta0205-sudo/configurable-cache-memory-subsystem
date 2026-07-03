`timescale 1ns/1ps
module tb_cache_top;
    reg clk;
    reg rst;
    reg cpu_read;
    reg [31:0] cpu_addr;
    reg cpu_write;
    reg [31:0] cpu_wdata;
    reg [3:0] cpu_byte_en;
    wire cpu_ready;
    wire [31:0] cpu_rdata;
    wire [31:0] read_hits;
    wire [31:0] read_misses;
    wire [31:0] write_hits;
    wire [31:0] write_misses;
    wire [31:0] total_accesses;
    integer errors;
    cache_top uut (
        .clk(clk),
        .rst(rst),
        .cpu_read(cpu_read),
        .cpu_write(cpu_write),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_byte_en(cpu_byte_en),
        .cpu_ready(cpu_ready),
        .cpu_rdata(cpu_rdata),
        .read_hits(read_hits),
        .read_misses(read_misses),
        .write_hits(write_hits),
        .write_misses(write_misses),
        .total_accesses(total_accesses)
    );
    always #5 clk = ~clk;
    task do_read;
        input [31:0] addr;
    begin
        @(posedge clk);
        cpu_addr <= addr;
        cpu_read <= 1'b1;
        @(posedge clk);
        cpu_read <= 1'b0;
        wait(cpu_ready == 1'b0);
        wait(cpu_ready == 1'b1);
    end
    endtask
    task check_read;
        input [31:0] expected;
    begin
        if(cpu_rdata !== expected) begin
            $display("[FAIL] @ %0t", $time);
            $display("Expected = %h", expected);
            $display("Actual   = %h", cpu_rdata);
            errors = errors + 1;
        end
        else begin
            $display("[PASS] @ %0t", $time);
        end
    end
    endtask
    initial begin
        errors = 0;
        clk = 0;
        rst = 1;
        cpu_read = 0;
        cpu_addr = 0;
        cpu_write   = 0;
        cpu_wdata   = 0;
        cpu_byte_en = 0;
        #20;
        rst = 0;
        @(posedge clk);
        cpu_addr <= 32'h00000008;
        cpu_read <= 1'b1;
        @(posedge clk);
        cpu_read <= 1'b0;
        wait(cpu_ready);
        check_read(32'h00000002);
        #50;
        @(posedge clk);
        cpu_addr <= 32'h00000008;
        cpu_read <= 1'b1;
        @(posedge clk);
        cpu_read <= 1'b0;
        wait(cpu_ready);
        check_read(32'h00000002);
        @(posedge clk);
        cpu_addr    <= 32'h00000008;
        cpu_wdata   <= 32'hAAAAAAAA;
        cpu_byte_en <= 4'b1111;
        cpu_write   <= 1'b1;
        @(posedge clk);
        cpu_write <= 1'b0;
        #50;
        @(posedge clk);
        cpu_addr <= 32'h00000008;
        cpu_read <= 1'b1;
        @(posedge clk);
        cpu_read <= 1'b0;
        wait(cpu_ready)
        check_read(32'hAAAAAAAA);
        @(posedge clk);
        cpu_addr <= 32'h00000408;
        cpu_read <= 1'b1;
        @(posedge clk);
        cpu_read <= 1'b0;
        wait(cpu_ready);
        check_read(32'h00000102);
        do_read(32'h00000800);
        #10;
        check_read(32'h00000200);
        do_read(32'h00000008);
        #10;
        check_read(32'hAAAAAAAA);
        #100;
        if(read_hits !== 32'd3) begin
            $display("[FAIL] Read Hits");
            errors = errors + 1;
        end
        else
            $display("[PASS] Read Hits");
        if(read_misses !== 32'd3) begin
            $display("[FAIL] Read Misses");
            errors = errors + 1;
        end
        else
            $display("[PASS] Read Misses");
        if(write_hits !== 32'd1) begin
            $display("[FAIL] Write Hits");
            errors = errors + 1;
        end
        else
            $display("[PASS] Write Hits");
        if(write_misses !== 32'd0) begin
            $display("[FAIL] Write Misses");
            errors = errors + 1;
        end
        else
            $display("[PASS] Write Misses");
        if(total_accesses !== 32'd7) begin
            $display("[FAIL] Total Accesses");
            errors = errors + 1;
        end
        else
            $display("[PASS] Total Accesses");
        $display("");
        if(errors == 0)
            $display("CACHE TOP TEST PASSED");
        else
            $display("CACHE TOP TEST FAILED : %0d ERRORS", errors);
        $finish;
    end
endmodule