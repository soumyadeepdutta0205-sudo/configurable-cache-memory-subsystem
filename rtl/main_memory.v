`timescale 1ns/1ps
module main_memory #(
    parameter MEM_WORDS = 4096
)(
    input               clk,
    input               rst,
    input               mem_read,
    input               mem_write,
    input      [31:0]   mem_addr,
    input      [127:0]  mem_wdata,
    output reg          mem_ready,
    output reg [127:0]  mem_rdata
);
    reg [31:0] memory [0:MEM_WORDS-1];
    reg [1:0] state;
    localparam IDLE = 2'd0;
    localparam WAIT1 = 2'd1;
    localparam WAIT2 = 2'd2;
    localparam RESPOND = 2'd3;
    reg [31:0] addr_reg;
    integer i;
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0; i < MEM_WORDS; i = i + 1)
                memory[i] <= i;
            mem_ready <= 0;
            mem_rdata <= 0;
            state <= IDLE;
            addr_reg <= 0;
        end
        else begin
            mem_ready <= 0;
            case(state)
                IDLE: begin
                    if(mem_read) begin
                        addr_reg <= mem_addr;
                        state <= WAIT1;
                    end
                    else if(mem_write) begin
                        memory[mem_addr[31:4] * 4 + 0]
                            <= mem_wdata[31:0];
                        memory[mem_addr[31:4] * 4 + 1]
                            <= mem_wdata[63:32];
                        memory[mem_addr[31:4] * 4 + 2]
                            <= mem_wdata[95:64];
                        memory[mem_addr[31:4] * 4 + 3]
                            <= mem_wdata[127:96];
                        mem_ready <= 1'b1;
                    end
                end
                WAIT1: begin
                    state <= WAIT2;
                end
                WAIT2: begin
                    state <= RESPOND;
                end             
                RESPOND: begin
                    mem_rdata <= {
                        memory[addr_reg[31:4] * 4 + 3],
                        memory[addr_reg[31:4] * 4 + 2],
                        memory[addr_reg[31:4] * 4 + 1],
                        memory[addr_reg[31:4] * 4 + 0]
                    };
                    mem_ready <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule