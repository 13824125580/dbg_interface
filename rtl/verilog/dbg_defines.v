//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_defines.v                                               ////
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
// Revision 1.14  2003/10/23 16:17:00  mohor
// CRC logic changed.
//
// Revision 1.13  2003/10/21 09:48:31  simons
// Mbist support added.
//
// Revision 1.12  2003/09/17 14:38:57  simons
// WB_CNTL register added, some syncronization fixes.
//
// Revision 1.11  2003/08/28 13:55:21  simons
// Three more chains added for cpu debug access.
//
// Revision 1.10  2003/07/31 12:19:49  simons
// Multiple cpu support added.
//
// Revision 1.9  2002/05/07 14:43:59  mohor
// mon_cntl_o signals that controls monitor mux added.
//
// Revision 1.8  2002/01/25 07:58:34  mohor
// IDCODE bug fixed, chains reused to decreas size of core. Data is shifted-in
// not filled-in. Tested in hw.
//
// Revision 1.7  2001/12/06 10:08:06  mohor
// Warnings from synthesys tools fixed.
//
// Revision 1.6  2001/11/28 09:38:30  mohor
// Trace disabled by default.
//
// Revision 1.5  2001/10/15 09:55:47  mohor
// Wishbone interface added, few fixes for better performance,
// hooks for boundary scan testing added.
//
// Revision 1.4  2001/09/24 14:06:42  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.3  2001/09/20 10:11:25  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.2  2001/09/18 14:13:47  mohor
// Trace fixed. Some registers changed, trace simplified.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
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


// Length of the CHAIN ID register
`define	CHAIN_ID_LENGTH	3

// Length of data
`define CHAIN_DATA_LEN  `CHAIN_ID_LENGTH + 1
`define DATA_CNT        3

// Length of status
`define STATUS_LEN      4
`define STATUS_CNT      3

// Length of the CRC
`define	CRC_LEN         32
`define CRC_CNT         6

// Chains
`define CPU_DEBUG_CHAIN     3'b000
`define WISHBONE_SCAN_CHAIN 3'b001

