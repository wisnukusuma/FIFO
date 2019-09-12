`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2019 09:48:49 AM
// Design Name: 
// Module Name: FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO#(parameter p_DEPTH=32,parameter p_WIDTH=8)(
input wire i_clk,
input wire i_rst,
//write ports
input wire i_wr_en,
input wire [p_WIDTH-1:0] i_wr_data,
output wire o_full,
//read ports
input wire i_rd_en,
output wire [p_WIDTH-1:0]o_rd_data,
output wire o_empty
    );
reg [p_WIDTH-1:0] r_FIFO_data[p_DEPTH-1:0] ;
reg [p_DEPTH-1:0] r_wr_index=32'b0;
reg [p_DEPTH-1:0] r_rd_index=32'b0;
reg [p_DEPTH+1:-1] r_FIFO_count=32'b0; 
reg r_full=0;
reg r_empty=0;
reg r_Ena;
reg r_wea;
reg [3:0] r_addra; 
reg [31:0] r_dina;
wire [31:0]  r_douta;
 blk_mem_gen_0 BRAM_Inst
   (
    .clka(i_clk),
    .ena(r_Ena),
    .wea(r_wea),
    .addra(r_addra),
    .dina(r_dina), 
    .douta(r_douta) );

always@(posedge i_clk)
begin
if(r_FIFO_count==p_DEPTH)
r_full<=1'b1;
else
r_full<=1'b0;
end
always@(posedge i_clk)
begin
if(r_FIFO_count==32'd0)
r_empty<=1'b1;
else
r_empty<=1'b0;
end
always@(posedge i_clk)
begin
if (i_rst)
 r_FIFO_count<={p_DEPTH{1'b0}};
 else begin
//              -- Keeps track of the total number of words in the FIFO
      if (i_wr_en == 1'b1 && i_rd_en ==1'b0&& r_FIFO_count <p_DEPTH) 
        r_FIFO_count <= r_FIFO_count + 1;
      else if (i_wr_en == 1'b0 && i_rd_en == 1'b1&& r_FIFO_count >32'd0)
        r_FIFO_count <= r_FIFO_count - 1;       
      end     
      
end
always @ (posedge i_clk) begin
if (i_rst)
r_rd_index<={p_DEPTH{1'b0}};
else begin
 if (i_rd_en == 1'b1 && o_empty == 1'b0) begin 
       if (r_rd_index == p_DEPTH-1) 
         r_rd_index <= 32'b0;
       else
         r_rd_index <= r_rd_index + 1'b1;
         end
end
end

always @ (posedge i_clk) begin
if (i_rst)
 r_wr_index<={p_DEPTH{1'b0}};
else begin
  if (i_wr_en == 1'b1 && o_full == 1'b0)begin
  if( r_wr_index == p_DEPTH-1 )
    r_wr_index <= {p_DEPTH{1'b0}};
  else
    r_wr_index <= r_wr_index + 1'b1;
    end
end
end
always @ (posedge i_clk) begin
      if( i_wr_en == 1'b1) 
        r_FIFO_data[r_wr_index] <= i_wr_data;
end
assign o_full= r_full;
assign o_empty= r_empty;
assign o_rd_data=r_FIFO_data[r_rd_index];
endmodule
