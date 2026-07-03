	`timescale 1ns/1ps
module cache_controller(
    input clk,
    input rst,
    input        cpu_read,
    input        cpu_write,
    input [31:0] cpu_addr,
    input [31:0] cpu_wdata,
    input [3:0]  cpu_byte_en,
    output reg        cpu_ready,
    output reg [31:0] cpu_rdata, 
    input [21:0] tag_out_way0,
    input valid_out_way0,
    input dirty_out_way0,
    input lru_bit,
    input [21:0] tag_out_way1,
    input valid_out_way1,
    input dirty_out_way1,
    output reg way0_write_en,
    output reg way1_write_en,
    output reg [5:0] tag_index,
    output reg [21:0] tag_in,
    output reg tag_write_en,
    output reg refill_en,
    output reg valid_in,
    input [127:0] line_out_way0,
    input [127:0] line_out_way1,
    output reg [127:0] refill_data,
    output reg [5:0] data_index,    
    output reg        write_hit_en,
    output reg [1:0]  word_sel,
    output reg [31:0] write_data,
    output reg [3:0]  write_byte_en,
    output reg way0_dirty_write,
    output reg way1_dirty_write,
    output reg way0_dirty_value,
    output reg way1_dirty_value,
    output reg way0_refill_en,
    output reg way1_refill_en,
    output reg way0_data_write_en,
    output reg way1_data_write_en,
    output reg access_way0,
    output reg access_way1,  
    output reg read_hit,
    output reg read_miss,
    output reg write_hit,
    output reg write_miss,
    output reg mem_read,
    output reg mem_write,
    output reg [31:0] mem_addr,
    output reg [127:0] mem_wdata,
    input mem_ready,
    input [127:0] mem_rdata
);
    localparam IDLE      = 4'd0;
    localparam LOOKUP    = 4'd1;
    localparam CHECK     = 4'd2;
    localparam WAIT_MEM  = 4'd3;
    localparam REFILL    = 4'd4;
    localparam RESPOND   = 4'd5;
    localparam WRITE_HIT = 4'd6;
    localparam WRITEBACK = 4'd7;
    localparam WAIT_WB   = 4'd8;
    reg [3:0] state;
    reg [31:0] victim_addr;
    reg [21:0] victim_tag;
    reg victim_way;
    reg [31:0] req_addr;
    reg [21:0] req_tag;
    reg [5:0]  req_index;
    reg [3:0]  req_offset;
    reg        req_write;
    reg [31:0] req_wdata;
    reg [3:0]  req_byte_en;
    wire way0_hit;
    wire way1_hit;
    assign way0_hit =
        valid_out_way0 &&
        (tag_out_way0 == req_tag);
    assign way1_hit =
        valid_out_way1 &&
        (tag_out_way1 == req_tag);
always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        cpu_ready <= 0;
        cpu_rdata <= 0;
        mem_read <= 0;
        mem_addr <= 0;
        mem_write <= 0;
        mem_wdata <= 0;
        refill_en <= 0;
        refill_data <= 0;
        tag_write_en <= 0;
        tag_index <= 0;
        tag_in <= 0;
        valid_in <= 0;
        data_index <= 0;
        write_hit_en  <= 0;
        word_sel      <= 0;
        write_data    <= 0;
        write_byte_en <= 0;
        read_hit   <= 0;
        read_miss  <= 0;
        way0_refill_en <= 0;
        way1_refill_en <= 0;
        write_hit  <= 0;
        write_miss <= 0;
        way0_write_en <= 0;
        way1_write_en <= 0;
        way0_data_write_en <= 0;
        way1_data_write_en <= 0;
        way0_dirty_write <= 0;
        way1_dirty_write <= 0;
        way0_dirty_value <= 0;
        way1_dirty_value <= 0;
        access_way0 <= 0;
        access_way1 <= 0;
    end
    else begin
        access_way0 <= 1'b0;
        access_way1 <= 1'b0;
        write_hit_en <= 1'b0;
        mem_write <= 1'b0;
        write_byte_en <= 4'b0000;
        read_hit   <= 1'b0;
        read_miss  <= 1'b0;
        write_hit  <= 1'b0;
        write_miss <= 1'b0;
        way0_write_en <= 1'b0;
        way1_write_en <= 1'b0;
        way0_refill_en <= 1'b0;
        way1_refill_en <= 1'b0;
        way0_data_write_en <= 1'b0;
        way1_data_write_en <= 1'b0;
        way0_dirty_write <= 1'b0;
        way1_dirty_write <= 1'b0;
        case(state)
            IDLE: begin
                cpu_ready <= 0;
                if(cpu_read || cpu_write) begin
                    req_addr <= cpu_addr;
                    req_write   <= cpu_write;
                    req_wdata   <= cpu_wdata;
                    req_byte_en <= cpu_byte_en;
                    req_tag    <= cpu_addr[31:10];
                    req_index  <= cpu_addr[8:4];
                    req_offset <= cpu_addr[3:0];
                    tag_index  <= cpu_addr[9:4];
                    data_index <= cpu_addr[9:4];
                    state <= LOOKUP;
                end
            end
            LOOKUP: begin
                state <= CHECK;
            end
            CHECK: begin
                if(way0_hit || way1_hit) begin
                    if(way0_hit)
                        access_way0 <= 1'b1;
                    if(way1_hit)
                        access_way1 <= 1'b1;
                    if(req_write) begin
                        write_hit <= 1'b1;
                        data_index <= req_index;
                        word_sel <= req_addr[3:2];
                        write_data <= req_wdata;
                        write_byte_en <= req_byte_en;
                        if(way0_hit)
                            way0_data_write_en <= 1'b1;
                        else
                            way1_data_write_en <= 1'b1;
                        if(way0_hit) begin
                            way0_dirty_write <= 1'b1;
                            way0_dirty_value <= 1'b1;
                        end
                        else begin
                            way1_dirty_write <= 1'b1;
                            way1_dirty_value <= 1'b1;
                        end
                        state <= WRITE_HIT;
                    end
                    else begin   
                        read_hit <= 1'b1;
                        if(way0_hit) begin
                            case(req_addr[3:2])
                                2'b00: cpu_rdata <= line_out_way0[31:0];
                                2'b01: cpu_rdata <= line_out_way0[63:32];
                                2'b10: cpu_rdata <= line_out_way0[95:64];
                                2'b11: cpu_rdata <= line_out_way0[127:96];
                            endcase
                        end
                        else begin
                            case(req_addr[3:2])
                                2'b00: cpu_rdata <= line_out_way1[31:0];
                                2'b01: cpu_rdata <= line_out_way1[63:32];
                                2'b10: cpu_rdata <= line_out_way1[95:64];
                                2'b11: cpu_rdata <= line_out_way1[127:96];
                            endcase
                        end
                        state <= RESPOND;
                    end
                end
                else begin
                    if(req_write)
                        write_miss <= 1'b1;
                    else
                        read_miss <= 1'b1;
                    if(lru_bit == 1'b0 &&
                        valid_out_way0 &&
                        dirty_out_way0) begin
                        victim_way  <= 1'b0;
                        victim_tag  <= tag_out_way0;
                        victim_addr <= {tag_out_way0, req_index, 4'b0000};
                        state <= WRITEBACK;
                    end
                    else if(lru_bit == 1'b1 &&
                        valid_out_way1 &&
                        dirty_out_way1) begin
                        victim_way  <= 1'b1;
                        victim_tag  <= tag_out_way1;
                        victim_addr <= {tag_out_way1, req_index, 4'b0000};
                        state <= WRITEBACK;
                    end
                    else begin
                        mem_addr <= {req_addr[31:4], 4'b0000};
                        mem_read <= 1'b1;
                        state <= WAIT_MEM;
                    end
                end          
            end
            WRITEBACK: begin
                mem_addr <= victim_addr;
                if(victim_way == 1'b0)
                    mem_wdata <= line_out_way0;
                else
                    mem_wdata <= line_out_way1;
                mem_write <= 1'b1;
                state <= WAIT_WB;
            end
            WAIT_MEM: begin              
                if(mem_ready) begin 
                    mem_read <= 1'b0;
                    refill_data <= mem_rdata;
                    state <= REFILL;
                end
            end
            REFILL: begin
                case(req_addr[3:2])
                    2'b00: cpu_rdata <= mem_rdata[31:0];
                    2'b01: cpu_rdata <= mem_rdata[63:32];
                    2'b10: cpu_rdata <= mem_rdata[95:64];
                    2'b11: cpu_rdata <= mem_rdata[127:96];
                endcase
                tag_index  <= req_index;
                data_index <= req_index;
                tag_in     <= req_tag;
                valid_in   <= 1'b1;
                refill_data <= mem_rdata;
                if(!valid_out_way0) begin
                    victim_way <= 1'b0;
                    way0_refill_en <= 1'b1;
                    way0_write_en  <= 1'b1;
                    way0_dirty_write <= 1'b1;
                    way0_dirty_value <= 1'b0;           
                end
                else if(!valid_out_way1) begin
                    victim_way <= 1'b1;
                    way1_refill_en <= 1'b1;
                    way1_write_en  <= 1'b1;
                    way1_dirty_write <= 1'b1;
                    way1_dirty_value <= 1'b0;              
                end
                else begin
                    victim_way <= lru_bit;
                    if(lru_bit == 1'b0) begin                     
                        way0_refill_en <= 1'b1;
                        way0_write_en  <= 1'b1;
                        way0_dirty_write <= 1'b1;
                        way0_dirty_value <= 1'b0;              
                    end
                    else begin                       
                        way1_refill_en <= 1'b1;
                        way1_write_en  <= 1'b1;
                        way1_dirty_write <= 1'b1;
                        way1_dirty_value <= 1'b0;
                    end
                end
                state <= RESPOND;
            end     
            WRITE_HIT: begin
                write_hit_en <= 1'b0;
                cpu_ready <= 1'b1;
                write_byte_en <= 4'b0000;
                state <= IDLE;               
            end
            RESPOND: begin                
                 refill_en <= 1'b0;
                 tag_write_en <= 1'b0;
                 cpu_ready <= 1'b1;
                 state <= IDLE;         
            end
            WAIT_WB: begin
                if(mem_ready) begin        
                    mem_addr <= {req_addr[31:4],4'b0000};
                    mem_read <= 1'b1;
                    state <= WAIT_MEM;
                end
            end
        endcase
    end
end
endmodule