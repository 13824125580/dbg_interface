//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_crc8_d1 crc1.v                                          ////
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
// Revision 1.6  2002/04/09 14:19:22  mohor
// Function changed to logic because of some synthesis warnings.
//
// Revision 1.5  2001/12/06 10:01:57  mohor
// Warnings from synthesys tools fixed.
//
// Revision 1.4  2001/11/26 10:47:09  mohor
// Crc generation is different for read or write commands. Small synthesys fixes.
//
// Revision 1.3  2001/10/19 11:40:02  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
//
// Revision 1.2  2001/09/20 10:11:25  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
// Revision 1.3  2001/06/01 22:22:36  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.2  2001/05/18 13:10:00  mohor
// Headers changed. All additional information is now avaliable in the README.txt file.
//
// Revision 1.1.1.1  2001/05/18 06:35:03  mohor
// Initial release
//
//
///////////////////////////////////////////////////////////////////////
// File:  CRC8_D1.v
// Date:  Fri Apr 27 20:56:55 2001
//
// Copyright (C) 1999 Easics NV.
// This source file may be used and distributed without restriction
// provided that this copyright statement is not removed from the file
// and that any derivative work contains the original copyright notice
// and the associated disclaimer.
//
// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Purpose: Verilog module containing a synthesizable CRC function
//   * polynomial: (0 1 2 8)
//   * data width: 1
//
// Info: jand@easics.be (Jan Decaluwe)
//       http://www.easics.com
///////////////////////////////////////////////////////////////////////

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_defines.v"


module dbg_crc8_d1 (data, enable_crc, reset, sync_rst_crc, crc_out, clk);

parameter Tp = 1;


input data;
input enable_crc;
input reset;
input sync_rst_crc;
input clk;


output [7:0] crc_out;
reg    [7:0] crc_out;

wire [7:0] NewCRC;

assign NewCRC[0] = data ^ crc_out[7];
assign NewCRC[1] = data ^ crc_out[0] ^ crc_out[7];
assign NewCRC[2] = data ^ crc_out[1] ^ crc_out[7];
assign NewCRC[3] = crc_out[2];
assign NewCRC[4] = crc_out[3];
assign NewCRC[5] = crc_out[4];
assign NewCRC[6] = crc_out[5];
assign NewCRC[7] = crc_out[6];
  


always @ (posedge clk or posedge reset)
begin
  if(reset)
    crc_out[7:0] <= #Tp 0;
  else
  if(sync_rst_crc)
    crc_out[7:0] <= #Tp 0;
  else
  if(enable_crc)
    crc_out[7:0] <= #Tp NewCRC;
end



endmodule
