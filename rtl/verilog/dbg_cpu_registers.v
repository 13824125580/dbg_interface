//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_cpu_registers.v                                         ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/projects/DebugInterface/           ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2004 Authors                            ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2004/01/17 17:01:14  mohor
// Almost finished.
//
// Revision 1.1  2004/01/16 14:53:33  mohor
// *** empty log message ***
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_cpu_defines.v"

module dbg_cpu_registers  (
                            data_i, 
                            data_o, 
                            addr_i, 
                            we_i, 
                            en_i, 
                            clk_i, 
                            bp_i, 
                            rst_i,
                            cpu_clk_i, 
                            cpu_stall_o, 
                            cpu_stall_all_o, 
                            cpu_sel_o, 
                            cpu_rst_o 
                          );


input            [7:0]  data_i;
input            [1:0]  addr_i;

input                   we_i;
input                   en_i;
input                   clk_i;
input                   bp_i;
input                   rst_i;
input                   cpu_clk_i;

output           [7:0]  data_o;
reg              [7:0]  data_o;

output                  cpu_stall_o;
output                  cpu_stall_all_o;
output [`CPU_NUM -1:0]  cpu_sel_o;
output                  cpu_rst_o;

wire                    cpu_stall_all;
wire                    cpu_reset;
wire             [2:1]  cpu_op_out;
wire   [`CPU_NUM -1:0]  cpu_sel_out;

wire                    cpuop_wr;
wire                    cpusel_wr;

reg                     cpusel_wr_sync, cpusel_wr_cpu;
reg                     stall_bp, stall_bp_sync, stall_bp_tck;
reg                     stall_reg, stall_reg_sync, stall_reg_cpu;
reg                     cpu_stall_all_sync;
reg                     cpu_stall_all_o;
reg                     cpu_reset_sync;
reg                     cpu_rst_o;



assign cpuop_wr      = en_i & we_i & (addr_i == `CPU_OP_ADR);
assign cpusel_wr     = en_i & we_i & (addr_i == `CPU_SEL_ADR);


// Synchronising we for cpu_sel register that works in cpu_clk clock domain
always @ (posedge cpu_clk_i or posedge rst_i)
begin
  if (rst_i)
    begin
      cpusel_wr_sync <= #1 1'b0;
      cpusel_wr_cpu  <= #1 1'b0;
    end
  else
    begin
      cpusel_wr_sync <= #1 cpusel_wr;
      cpusel_wr_cpu  <= #1 cpusel_wr_sync;
    end
end


// Breakpoint is latched and synchronized. Stall is set and latched.
always @ (posedge cpu_clk_i or posedge rst_i)
begin
  if(rst_i)
    stall_bp <= #1 1'b0;
  else if(bp_i)
    stall_bp <= #1 1'b1;
  else if(stall_reg_cpu)
    stall_bp <= #1 1'b0;
end


// Synchronizing
always @ (posedge clk_i or posedge rst_i)
begin
  if (rst_i)
    begin
      stall_bp_sync <= #1 1'b0;
      stall_bp_tck  <= #1 1'b0;
    end
  else
    begin
      stall_bp_sync <= #1 stall_bp;
      stall_bp_tck  <= #1 stall_bp_sync;
    end
end


always @ (posedge clk_i or posedge rst_i)
begin
  if (rst_i)
    stall_reg <= #1 1'b0;
  else if (stall_bp_tck)
    stall_reg <= #1 1'b1;
  else if (cpuop_wr)
    stall_reg <= #1 data_i[0];
end


always @ (posedge cpu_clk_i or posedge rst_i)
begin
  if (rst_i)
    begin
      stall_reg_sync <= #1 1'b0;
      stall_reg_cpu  <= #1 1'b0;
    end
  else
    begin
      stall_reg_sync <= #1 stall_reg;
      stall_reg_cpu  <= #1 stall_reg_sync;
    end
end


assign cpu_stall_o = bp_i | stall_bp | stall_reg_cpu;



dbg_register #(2, 0)          CPUOP  (.data_in(data_i[2:1]),           .data_out(cpu_op_out[2:1]), .write(cpuop_wr),       .clk(clk_i),     .reset(rst_i));
dbg_register #(`CPU_NUM, 0)   CPUSEL (.data_in(data_i[`CPU_NUM-1:0]),  .data_out(cpu_sel_out),     .write(cpusel_wr_cpu),  .clk(cpu_clk_i), .reset(rst_i)); // cpu_cli_i


always @ (posedge clk_i)
begin
  case (addr_i)         // Synthesis parallel_case
    `CPU_OP_ADR  : data_o <= #1 {5'h0, cpu_op_out[2:1], stall_reg};
    `CPU_SEL_ADR : data_o <= #1 {{(8-`CPU_NUM){1'b0}}, cpu_sel_out};
    default      : data_o <= #1 8'h0;
  endcase
end


assign cpu_stall_all      = cpu_op_out[2];       // this signal is used to stall all the cpus except the one that is selected in cpusel register
assign cpu_sel_o          = cpu_sel_out;
assign cpu_reset          = cpu_op_out[1];




// Synchronizing signals from registers
always @ (posedge cpu_clk_i or posedge rst_i)
begin
  if (rst_i)
    begin
      cpu_stall_all_sync  <= #1 1'b0; 
      cpu_stall_all_o     <= #1 1'b0; 
      cpu_reset_sync      <= #1 1'b0; 
      cpu_rst_o           <= #1 1'b0; 
    end
  else
    begin
      cpu_stall_all_sync  <= #1 cpu_stall_all;
      cpu_stall_all_o     <= #1 cpu_stall_all_sync;
      cpu_reset_sync      <= #1 cpu_reset;
      cpu_rst_o           <= #1 cpu_reset_sync;
    end
end



endmodule

