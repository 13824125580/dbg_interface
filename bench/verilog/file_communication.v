//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File_communication.v                                        ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000,2001 Authors                              ////
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
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
//
//
//
//

`include "dbg_timescale.v"
`include "dbg_defines.v"
`include "dbg_tb_defines.v"

module File_communication();

parameter Tp = 1;

integer handle1, handle2;
reg [3:0] memory[0:0];
reg Mclk;
reg wb_rst_i;

reg StartTesting;
wire P_TCK;
wire P_TRST;
wire P_TDI;
wire P_TMS;
wire P_TDO;


initial
begin
  StartTesting = 0;
  wb_rst_i = 0;
  #500;
  wb_rst_i = 1;
  #500;
  wb_rst_i = 0;
  
  #2000;
  StartTesting = 1;
  $display("StartTesting = 1");


end

initial
begin
  wait(StartTesting);
  while(1)
  begin
    #1000;
    $readmemh("E:\\tmp\\out.txt", memory);
    #1000;
  end
end


always @ (posedge P_TCK)
begin
  handle2 = $fopen("E:\\tmp\\in.txt");
  $fdisplay(handle2 | 1, "%b", P_TDO);  // Vriting output data to file (TDO)
  $fclose(handle2);
end


wire [3:0]Temp = memory[0];

assign P_TCK  = Temp[0];
assign P_TRST = Temp[1];
assign P_TDI  = Temp[2];
assign P_TMS  = Temp[3];



// Generating master clock (RISC clock) 10 MHz
initial
begin
  Mclk<=#Tp 0;
  #1 forever #`RISC_CLOCK Mclk<=~Mclk;
end

// Generating random number for use in DATAOUT_RISC[31:0]
reg [31:0] RandNumb;
always @ (posedge Mclk or posedge wb_rst_i)
begin
  if(wb_rst_i)
    RandNumb[31:0]<=#Tp 0;
  else
    RandNumb[31:0]<=#Tp RandNumb[31:0] + 1;
end

wire [31:0] DataIn = RandNumb;

// Connecting dbgTAP module
dbg_top dbg1  (.tms_pad_i(P_TMS), .tck_pad_i(P_TCK), .trst_pad_i(P_TRST), .tdi_pad_i(P_TDI), .tdo_pad_o(P_TDO), 
               .wb_rst_i(wb_rst_i), .mclk(Mclk), .risc_addr_o(), .risc_data_i(DataIn),
               .risc_data_o(), .risc_cs_o(), .risc_rw_o(), .wp_i(11'h0), .bp_i(1'b0), 
               .opselect_o(), .lsstatus_i(4'h0), .istatus_i(2'h0), 
               . risc_stall_o(), . risc_reset_o() 
              );




endmodule // TAP
