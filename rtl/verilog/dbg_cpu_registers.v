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
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_cpu_defines.v"

module dbg_cpu_registers  (
                            data_in, 
                            data_out, 
                            address, 
                            rw, 
                            access, 
                            clk, 
                            bp, 
                            reset, 
                            cpu_stall, 
                            cpu_stall_all, 
                            cpu_sel, 
                            cpu_reset 
                          );


input            [7:0]  data_in;
input            [1:0]  address;

input                   rw;
input                   access;
input                   clk;
input                   bp;
input                   reset;

output           [7:0]  data_out;
reg              [7:0]  data_out;

output                  cpu_stall;
output                  cpu_stall_all;
output [`CPU_NUM -1:0]  cpu_sel;
output                  cpu_reset;

wire             [2:1]  cpu_op_out;
wire   [`CPU_NUM -1:0]  cpu_sel_out;

wire                    cpuop_wr;
wire                    cpusel_wr;

reg                     cpu_stall_bp;



assign cpuop_wr      = access & rw & (address == `CPUOP_ADR);
assign cpusel_wr     = access & rw & (address == `CPUSEL_ADR);



always @(posedge clk or posedge reset)
begin
  if(reset)
    cpu_stall_bp <= 1'b0;
  else if(bp)                     // Breakpoint sets bit
    cpu_stall_bp <= 1'b1;
  else if(cpuop_wr)               // Register access can set or clear bit
    cpu_stall_bp <= data_in[0];
end


dbg_register #(2, 0)          CPUOP  (.data_in(data_in[2:1]),           .data_out(cpu_op_out[2:1]), .write(cpuop_wr),   .clk(clk), .reset(reset));
dbg_register #(`CPU_NUM, 0)   CPUSEL (.data_in(data_in[`CPU_NUM-1:0]),  .data_out(cpu_sel_out),     .write(cpusel_wr),  .clk(clk), .reset(reset));


always @ (posedge clk)
begin
  case (address)         // Synthesis parallel_case
    `CPUOP_ADR  : data_out<= #1 {5'h0, cpu_op_out[2:1], cpu_stall};
    `CPUSEL_ADR : data_out<= #1 {{(8-`CPU_NUM){1'b0}}, cpu_sel_out};
    default     : data_out<= #1 8'h0;
  endcase
end


assign cpu_stall          = bp | cpu_stall_bp;   // bp asynchronously sets the cpu_stall, then cpu_stall_bp (from register) holds it active
assign cpu_stall_all      = cpu_op_out[2];       // this signal is used to stall all the cpus except the one that is selected in cpusel register
assign cpu_sel            = cpu_sel_out;
assign cpu_reset          = cpu_op_out[1];

endmodule

