//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbgTB_defines.v                                             ////
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
// Revision 1.3  2001/06/01 22:23:40  mohor
// This is a backup. It is not a fully working version. Not for use, yet.
//
// Revision 1.2  2001/05/18 13:10:05  mohor
// Headers changed. All additional information is now avaliable in the README.txt file.
//
// Revision 1.1.1.1  2001/05/18 06:35:12  mohor
// Initial release
//
//

// Following defines are used in the testbench only

  // MODER register
  `define CONTIN          32'h00000001
  `define ENABLE          32'h00000002
  
  // TSEL register
  `define WPTRIG_0        32'h00000001
  `define WPTRIG_1        32'h00000002
  `define WPTRIG_2        32'h00000004
  `define WPTRIG_3        32'h00000008
  `define WPTRIG_4        32'h00000010
  `define WPTRIG_5        32'h00000020
  `define WPTRIG_6        32'h00000040
  `define WPTRIG_7        32'h00000080
  `define WPTRIG_8        32'h00000100
  `define WPTRIG_9        32'h00000200
  `define WPTRIG_10       32'h00000400
  `define WPTRIGVALID     32'h00000800
  
  `define BPTRIG          32'h00001000
  `define BPTRIGVALID     32'h00002000
  
  `define LSSTRIG_0       32'h00010000
  `define LSSTRIG_1       32'h00020000
  `define LSSTRIG_2       32'h00040000
  `define LSSTRIG_3       32'h00080000
  `define LSSTRIGVALID    32'h00100000
  
  `define ISTRIGVALID     32'h00800000
  
  `define TRIGOP_AND      32'hc0000000
  `define TRIGOP_OR       32'h80000000
  
  // QSEL register
  `define WPQUALIF_0      32'h00000001
  `define WPQUALIF_1      32'h00000002
  `define WPQUALIF_2      32'h00000004
  `define WPQUALIF_3      32'h00000008
  `define WPQUALIF_4      32'h00000010
  `define WPQUALIF_5      32'h00000020
  `define WPQUALIF_6      32'h00000040
  `define WPQUALIF_7      32'h00000080
  `define WPQUALIF_8      32'h00000100
  `define WPQUALIF_9      32'h00000200
  `define WPQUALIF_10     32'h00000400
  `define WPQUALIFVALID   32'h00000800
  
  `define BPQUALIF        32'h00001000
  `define BPQUALIFVALID   32'h00002000
  
  `define LSSQUALIF_0     32'h00010000
  `define LSSQUALIF_1     32'h00020000
  `define LSSQUALIF_2     32'h00040000
  `define LSSQUALIF_3     32'h00080000
  `define LSSQUALIFVALID  32'h00100000
  
  `define ISQUALIFVALID   32'h00800000
  
  `define QUALIFOP_AND    32'hc0000000
  `define QUALIFOP_OR     32'h80000000


  // SSEL register
  `define WPSTOP_0      32'h00000001
  `define WPSTOP_1      32'h00000002
  `define WPSTOP_2      32'h00000004
  `define WPSTOP_3      32'h00000008
  `define WPSTOP_4      32'h00000010
  `define WPSTOP_5      32'h00000020
  `define WPSTOP_6      32'h00000040
  `define WPSTOP_7      32'h00000080
  `define WPSTOP_8      32'h00000100
  `define WPSTOP_9      32'h00000200
  `define WPSTOP_10     32'h00000400
  `define WPSTOPVALID   32'h00000800
  
  `define BPSTOP        32'h00001000
  `define BPSTOPVALID   32'h00002000
  
  `define LSSSTOP_0     32'h00010000
  `define LSSSTOP_1     32'h00020000
  `define LSSSTOP_2     32'h00040000
  `define LSSSTOP_3     32'h00080000
  `define LSSSTOPVALID  32'h00100000
  
  `define ISSTOPVALID   32'h00800000
  
  `define STOPOP_AND    32'hc0000000
  `define STOPOP_OR     32'h80000000

  `define IS_NO_FETCH     32'h00000000
  `define IS_FETCH        32'h00200000
  `define IS_BRANCH       32'h00400000
  `define IS_FETCH_DELAY  32'h00600000

  `define LSS_NO_LOADSTORE      32'h00000000
  `define LSS_LOADBYTE_ZEROEXT  32'h00020000
  `define LSS_LOADBYTE_SIGNEXT  32'h00030000
  `define LSS_LOADHALF_ZEROEXT  32'h00040000
  `define LSS_LOADHALF_SIGNEXT  32'h00050000
  `define LSS_LOADWORD_ZEROEXT  32'h00060000
  `define LSS_LOADWORD_SIGNEXT  32'h00070000
  `define LSS_STORE_BYTE        32'h000A0000
  `define LSS_STORE_HALF        32'h000C0000

// End: Following defines are used in the testbench only


