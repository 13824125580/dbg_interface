//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_defines.v                                               ////
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
// Revision 1.3  2001/06/01 22:22:35  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.2  2001/05/18 13:10:00  mohor
// Headers changed. All additional information is now avaliable in the README.txt file.
//
// Revision 1.1.1.1  2001/05/18 06:35:08  mohor
// Initial release
//
//



// Enable TRACE
//`define TRACE_ENABLED   // Uncomment this define to activate the trace


// Define IDCODE Value
`define IDCODE_VALUE  32'hdeadbeef

// Define master clock (RISC clock)
`define	RISC_CLOCK  50   // Half period = 50 ns => MCLK = 10 Mhz

// Length of the Instruction register
`define	IR_LENGTH	4

// Length of the Data register (must be equal to the longest scan chain)
`define	DR_LENGTH	73

// Length of the CHAIN ID register
`define	CHAIN_ID_LENGTH	4

// Length of the CRC
`define	CRC_LENGTH	8

// Trace buffer size and counter and write/read pointer width
`define TRACECOUNTERWIDTH        10
`define TRACEBUFFERLENGTH        1024 //2^10
`define TRACESAMPLEWIDTH         36

// OpSelect width
`define OPSELECTWIDTH            3
`define OPSELECTIONCOUNTER       8    //2^3

// Supported Instructions
`define EXTEST          4'b0000
`define SAMPLE_PRELOAD  4'b0001
`define IDCODE          4'b0010
`define CHAIN_SELECT    4'b0011
`define INTEST          4'b0100
`define CLAMP           4'b0101
`define CLAMPZ          4'b0110
`define HIGHZ           4'b0111
`define DEBUG           4'b1000
`define BYPASS          4'b1111

// Chains
`define GLOBAL_BS_CHAIN     4'b0000
`define RISC_DEBUG_CHAIN    4'b0001
`define RISC_TEST_CHAIN     4'b0010
`define TRACE_TEST_CHAIN    4'b0011
`define REGISTER_SCAN_CHAIN 4'b0100


// Registers addresses
`define MODER_ADR           5'h00
`define TSEL_ADR            5'h01
`define QSEL_ADR            5'h02
`define SSEL_ADR            5'h03

`define RECWP0_ADR          5'h10
`define RECWP1_ADR          5'h11
`define RECWP2_ADR          5'h12
`define RECWP3_ADR          5'h13
`define RECWP4_ADR          5'h14
`define RECWP5_ADR          5'h15
`define RECWP6_ADR          5'h16
`define RECWP7_ADR          5'h17
`define RECWP8_ADR          5'h18
`define RECWP9_ADR          5'h19
`define RECWP10_ADR         5'h1A
`define RECBP0_ADR          5'h1B


// Registers default values (after reset)
`define MODER_DEF           32'h00000000
`define TSEL_DEF            32'h00000000
`define QSEL_DEF            32'h00000000
`define SSEL_DEF            32'h00000000

`define RECWP0_DEF          32'h00000000
`define RECWP1_DEF          32'h00000000
`define RECWP2_DEF          32'h00000000
`define RECWP3_DEF          32'h00000000
`define RECWP4_DEF          32'h00000000
`define RECWP5_DEF          32'h00000000
`define RECWP6_DEF          32'h00000000
`define RECWP7_DEF          32'h00000000
`define RECWP8_DEF          32'h00000000
`define RECWP9_DEF          32'h00000000
`define RECWP10_DEF         32'h00000000
`define RECBP0_DEF          32'h00000000








