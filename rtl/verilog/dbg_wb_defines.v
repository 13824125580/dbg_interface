//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_wb_defines.v                                            ////
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
//// Copyright (C) 2000 - 2003 Authors                            ////
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
// Revision 1.2  2004/01/06 17:15:19  mohor
// temp3 version.
//
// Revision 1.1  2003/12/23 15:09:04  mohor
// New directory structure. New version of the debug interface.
//
//
//


// Defining commands for wishbone
`define WB_STATUS     3'h0
`define WB_WRITE8     3'h1
`define WB_WRITE16    3'h2
`define WB_WRITE32    3'h3
`define WB_GO         3'h4
`define WB_READ8      3'h5
`define WB_READ16     3'h6
`define WB_READ32     3'h7


// Length of status
`define STATUS_LEN      4



// Enable TRACE
//`define TRACE_ENABLED  // Uncomment this define to activate the trace

// Define number of cpus supported by the dbg interface
`define CPU_NUM 2

// Define master clock (CPU clock)
//`define	CPU_CLOCK  50   // Half period = 50 ns => MCLK = 10 Mhz
`define	CPU_CLOCK  2.5   // Half period = 5 ns => MCLK = 200 Mhz



// Trace buffer size and counter and write/read pointer width. This can be expanded when more RAM is avaliable
`define TRACECOUNTERWIDTH        5  
`define TRACEBUFFERLENGTH        32 // 2^5

`define TRACESAMPLEWIDTH         36

// OpSelect width
`define OPSELECTWIDTH            3
`define OPSELECTIONCOUNTER       8    //2^3

// OpSelect (dbg_op_i) signal meaning
`define DEBUG_READ_0               0
`define DEBUG_WRITE_0              1
`define DEBUG_READ_1               2
`define DEBUG_WRITE_1              3
`define DEBUG_READ_2               4
`define DEBUG_WRITE_2              5
`define DEBUG_READ_3               6
`define DEBUG_WRITE_3              7

// Registers addresses
`define MODER_ADR           5'h00
`define TSEL_ADR            5'h01
`define QSEL_ADR            5'h02
`define SSEL_ADR            5'h03
`define CPUOP_ADR           5'h04
`define CPUSEL_ADR          5'h05
`define RECSEL_ADR          5'h10
`define MON_CNTL_ADR        5'h11
`define WB_CNTL_ADR         5'h12


// Registers default values (after reset)
`define MODER_DEF           2'h0
`define TSEL_DEF            32'h00000000
`define QSEL_DEF            32'h00000000
`define SSEL_DEF            32'h00000000
`define CPUOP_DEF           2'h0
`define RECSEL_DEF          7'h0
`define MON_CNTL_DEF        4'h0
