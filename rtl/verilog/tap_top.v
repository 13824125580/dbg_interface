//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tap_top.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/projects/DebugInterface/           ////
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
//// Copyright (C) 2000, 2001, 2002 Authors                       ////
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
// Revision 1.8  2003/10/21 09:48:31  simons
// Mbist support added.
//
// Revision 1.7  2002/11/06 14:30:10  mohor
// Trst active high. Inverted on higher layer.
//
// Revision 1.6  2002/04/22 12:55:56  mohor
// tdo_padoen_o changed to tdo_padoe_o. Signal is active high.
//
// Revision 1.5  2002/03/26 14:23:38  mohor
// Signal tdo_padoe_o changed back to tdo_padoen_o.
//
// Revision 1.4  2002/03/25 13:16:15  mohor
// tdo_padoen_o changed to tdo_padoe_o. Signal was always active high, just
// not named correctly.
//
// Revision 1.3  2002/03/12 14:30:05  mohor
// Few outputs for boundary scan chain added.
//
// Revision 1.2  2002/03/12 10:31:53  mohor
// tap_top and dbg_top modules are put into two separate modules. tap_top
// contains only tap state machine and related logic. dbg_top contains all
// logic necessery for debugging.
//
// Revision 1.1  2002/03/08 15:28:16  mohor
// Structure changed. Hooks for jtag chain added.
//
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_defines.v"

// Top module
module tap_top(
                // JTAG pins
                tms_pad_i, tck_pad_i, trst_pad_i, tdi_pad_i, tdo_pad_o, tdo_padoe_o,

                // TAP states
                ShiftDR, Exit1DR, UpdateDR, UpdateDR_q, CaptureDR, SelectDRScan,
                
                // Instructions
                IDCODESelected, CHAIN_SELECTSelected, DEBUGSelected, EXTESTSelected, MBISTSelected,
                
                // TDO from dbg module
                TDOData_dbg, BypassRegister,
                
                // From Boundary Scan Chain
                bs_chain_i,

                // From Mbist Chain
                mbist_so_i,

                // Selected chains
                RegisterScanChain,
                CpuDebugScanChain0,
                CpuDebugScanChain1,
                CpuDebugScanChain2,
                CpuDebugScanChain3,
                WishboneScanChain


                
              );

parameter Tp = 1;

// JTAG pins
input   tms_pad_i;                  // JTAG test mode select pad
input   tck_pad_i;                  // JTAG test clock pad
input   trst_pad_i;                 // JTAG test reset pad
input   tdi_pad_i;                  // JTAG test data input pad
output  tdo_pad_o;                  // JTAG test data output pad
output  tdo_padoe_o;                // Output enable for JTAG test data output pad 

// TAP states
output  ShiftDR;
output  Exit1DR;
output  UpdateDR;
output  UpdateDR_q;
output  CaptureDR;
output  SelectDRScan;

// Instructions
output  IDCODESelected;
output  CHAIN_SELECTSelected;
output  DEBUGSelected;
output  EXTESTSelected;
output  MBISTSelected;

input   TDOData_dbg;
output  BypassRegister;

// From Boundary Scan Chain
input   bs_chain_i;

// From Mbist Chain
input   mbist_so_i;

// Selected chains
input   RegisterScanChain;
input   CpuDebugScanChain0;
input   CpuDebugScanChain1;
input   CpuDebugScanChain2;
input   CpuDebugScanChain3;
input   WishboneScanChain;


reg     tdo_pad_o;

// TAP states
reg     TestLogicReset;
reg     RunTestIdle;
reg     SelectDRScan;
reg     CaptureDR;
reg     ShiftDR;
reg     Exit1DR;
reg     PauseDR;
reg     Exit2DR;
reg     UpdateDR;

reg     SelectIRScan;
reg     CaptureIR;
reg     ShiftIR;
reg     Exit1IR;
reg     PauseIR;
reg     Exit2IR;
reg     UpdateIR;


// Defining which instruction is selected
reg     EXTESTSelected;
reg     SAMPLE_PRELOADSelected;
reg     IDCODESelected;
reg     CHAIN_SELECTSelected;
reg     MBISTSelected;
reg     CLAMPSelected;
reg     CLAMPZSelected;
reg     HIGHZSelected;
reg     DEBUGSelected;
reg     BYPASSSelected;

reg     BypassRegister;               // Bypass register

wire    trst;
wire    tck;
wire    TMS;
wire    tdi;


assign trst = trst_pad_i;                // trst_pad_i is active high !!! Inverted on higher layer 
assign tck  = tck_pad_i;
assign TMS  = tms_pad_i;
assign tdi  = tdi_pad_i;


/**********************************************************************************
*                                                                                 *
*   TAP State Machine: Fully JTAG compliant                                       *
*                                                                                 *
**********************************************************************************/

// TestLogicReset state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    TestLogicReset<=#Tp 1;
  else
    begin
      if(TMS & (TestLogicReset | SelectIRScan))
        TestLogicReset<=#Tp 1;
      else
        TestLogicReset<=#Tp 0;
    end
end

// RunTestIdle state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    RunTestIdle<=#Tp 0;
  else
  if(~TMS & (TestLogicReset | RunTestIdle | UpdateDR | UpdateIR))
    RunTestIdle<=#Tp 1;
  else
    RunTestIdle<=#Tp 0;
end

// SelectDRScan state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    SelectDRScan<=#Tp 0;
  else
  if(TMS & (RunTestIdle | UpdateDR | UpdateIR))
    SelectDRScan<=#Tp 1;
  else
    SelectDRScan<=#Tp 0;
end

// CaptureDR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    CaptureDR<=#Tp 0;
  else
  if(~TMS & SelectDRScan)
    CaptureDR<=#Tp 1;
  else
    CaptureDR<=#Tp 0;
end

// ShiftDR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    ShiftDR<=#Tp 0;
  else
  if(~TMS & (CaptureDR | ShiftDR | Exit2DR))
    ShiftDR<=#Tp 1;
  else
    ShiftDR<=#Tp 0;
end

// Exit1DR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    Exit1DR<=#Tp 0;
  else
  if(TMS & (CaptureDR | ShiftDR))
    Exit1DR<=#Tp 1;
  else
    Exit1DR<=#Tp 0;
end

// PauseDR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    PauseDR<=#Tp 0;
  else
  if(~TMS & (Exit1DR | PauseDR))
    PauseDR<=#Tp 1;
  else
    PauseDR<=#Tp 0;
end

// Exit2DR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    Exit2DR<=#Tp 0;
  else
  if(TMS & PauseDR)
    Exit2DR<=#Tp 1;
  else
    Exit2DR<=#Tp 0;
end

// UpdateDR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    UpdateDR<=#Tp 0;
  else
  if(TMS & (Exit1DR | Exit2DR))
    UpdateDR<=#Tp 1;
  else
    UpdateDR<=#Tp 0;
end

// Delayed UpdateDR state
reg UpdateDR_q;
always @ (posedge tck)
begin
  UpdateDR_q<=#Tp UpdateDR;
end

// SelectIRScan state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    SelectIRScan<=#Tp 0;
  else
  if(TMS & SelectDRScan)
    SelectIRScan<=#Tp 1;
  else
    SelectIRScan<=#Tp 0;
end

// CaptureIR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    CaptureIR<=#Tp 0;
  else
  if(~TMS & SelectIRScan)
    CaptureIR<=#Tp 1;
  else
    CaptureIR<=#Tp 0;
end

// ShiftIR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    ShiftIR<=#Tp 0;
  else
  if(~TMS & (CaptureIR | ShiftIR | Exit2IR))
    ShiftIR<=#Tp 1;
  else
    ShiftIR<=#Tp 0;
end

// Exit1IR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    Exit1IR<=#Tp 0;
  else
  if(TMS & (CaptureIR | ShiftIR))
    Exit1IR<=#Tp 1;
  else
    Exit1IR<=#Tp 0;
end

// PauseIR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    PauseIR<=#Tp 0;
  else
  if(~TMS & (Exit1IR | PauseIR))
    PauseIR<=#Tp 1;
  else
    PauseIR<=#Tp 0;
end

// Exit2IR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    Exit2IR<=#Tp 0;
  else
  if(TMS & PauseIR)
    Exit2IR<=#Tp 1;
  else
    Exit2IR<=#Tp 0;
end

// UpdateIR state
always @ (posedge tck or posedge trst)
begin
  if(trst)
    UpdateIR<=#Tp 0;
  else
  if(TMS & (Exit1IR | Exit2IR))
    UpdateIR<=#Tp 1;
  else
    UpdateIR<=#Tp 0;
end

/**********************************************************************************
*                                                                                 *
*   End: TAP State Machine                                                        *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*   JTAG_IR:  JTAG Instruction Register                                           *
*                                                                                 *
**********************************************************************************/
wire [1:0]Status = 2'b10;     // Holds current chip status. Core should return this status. For now a constant is used.

reg [`IR_LENGTH-1:0]JTAG_IR;  // Instruction register
reg [`IR_LENGTH-1:0]LatchedJTAG_IR;

reg TDOInstruction;

always @ (posedge tck or posedge trst)
begin
  if(trst)
    JTAG_IR[`IR_LENGTH-1:0] <= #Tp 0;
  else
  if(CaptureIR)
    begin
      JTAG_IR[1:0] <= #Tp 2'b01;       // This value is fixed for easier fault detection
      JTAG_IR[3:2] <= #Tp Status[1:0]; // Current status of chip
    end
  else
  if(ShiftIR)
    JTAG_IR[`IR_LENGTH-1:0] <= #Tp {tdi, JTAG_IR[`IR_LENGTH-1:1]};
end


//TDO is changing on the falling edge of tck
always @ (negedge tck or posedge trst)
begin
  if (trst)
    TDOInstruction <= #Tp 1'b0;
  else if(ShiftIR)
    TDOInstruction <= #Tp JTAG_IR[0];
end

/**********************************************************************************
*                                                                                 *
*   End: JTAG_IR                                                                  *
*                                                                                 *
**********************************************************************************/


/**********************************************************************************
*                                                                                 *
*   JTAG_DR:  JTAG Data Register                                                  *
*                                                                                 *
**********************************************************************************/
reg [`DR_LENGTH-1:0]JTAG_DR_IN;    // Data register


always @ (posedge tck or posedge trst)
begin
  if(trst)
    JTAG_DR_IN[`DR_LENGTH-1:0]<=#Tp 0;
  else
  if(IDCODESelected)                          // To save space JTAG_DR_IN is also used for shifting out IDCODE
    begin
      if(ShiftDR)
        JTAG_DR_IN[31:0] <= #Tp {tdi, JTAG_DR_IN[31:1]};
      else
        JTAG_DR_IN[31:0] <= #Tp `IDCODE_VALUE;
    end
  else
  if(CHAIN_SELECTSelected & ShiftDR)
    JTAG_DR_IN[11:0] <= #Tp {tdi, JTAG_DR_IN[11:1]};
  else
  if(DEBUGSelected & ShiftDR)
    begin
      if(CpuDebugScanChain0 | CpuDebugScanChain1 | CpuDebugScanChain2 | CpuDebugScanChain3 | WishboneScanChain)
        JTAG_DR_IN[72:0] <= #Tp {tdi, JTAG_DR_IN[72:1]};
      else
      if(RegisterScanChain)
        JTAG_DR_IN[45:0] <= #Tp {tdi, JTAG_DR_IN[45:1]};
    end
end
 


/**********************************************************************************
*                                                                                 *
*   End: JTAG_DR                                                                  *
*                                                                                 *
**********************************************************************************/





/**********************************************************************************
*                                                                                 *
*   Bypass logic                                                                  *
*                                                                                 *
**********************************************************************************/
reg TDOBypassed;

always @ (posedge tck or posedge trst)
begin
  if (trst)
    BypassRegister<=#Tp 1'b0;
  else if(ShiftDR)
    BypassRegister<=#Tp tdi;
end

always @ (negedge tck)
begin
  TDOBypassed<=#Tp BypassRegister;
end
/**********************************************************************************
*                                                                                 *
*   End: Bypass logic                                                             *
*                                                                                 *
**********************************************************************************/





/**********************************************************************************
*                                                                                 *
*   Activating Instructions                                                       *
*                                                                                 *
**********************************************************************************/

// Updating JTAG_IR (Instruction Register)
always @ (posedge tck or posedge trst)
begin
  if(trst)
    LatchedJTAG_IR <=#Tp `IDCODE;   // IDCODE selected after reset
  else
  if(UpdateIR)
    LatchedJTAG_IR <=#Tp JTAG_IR;
end

/**********************************************************************************
*                                                                                 *
*   End: Activating Instructions                                                  *
*                                                                                 *
**********************************************************************************/


// Updating JTAG_IR (Instruction Register)
always @ (LatchedJTAG_IR)
begin
  EXTESTSelected          = 0;
  SAMPLE_PRELOADSelected  = 0;
  IDCODESelected          = 0;
  CHAIN_SELECTSelected    = 0;
  MBISTSelected           = 0;
  CLAMPSelected           = 0;
  CLAMPZSelected          = 0;
  HIGHZSelected           = 0;
  DEBUGSelected           = 0;
  BYPASSSelected          = 0;

  case(LatchedJTAG_IR)
    `EXTEST:            EXTESTSelected          = 1;    // External test
    `SAMPLE_PRELOAD:    SAMPLE_PRELOADSelected  = 1;    // Sample preload
    `IDCODE:            IDCODESelected          = 1;    // ID Code
    `CHAIN_SELECT:      CHAIN_SELECTSelected    = 1;    // Chain select
    `MBIST:             MBISTSelected           = 1;    // Mbist test
    `CLAMP:             CLAMPSelected           = 1;    // Clamp
    `CLAMPZ:            CLAMPZSelected          = 1;    // ClampZ
    `HIGHZ:             HIGHZSelected           = 1;    // High Z
    `DEBUG:             DEBUGSelected           = 1;    // Debug
    `BYPASS:            BYPASSSelected          = 1;    // BYPASS
    default:            BYPASSSelected          = 1;    // BYPASS
  endcase
end



/**********************************************************************************
*                                                                                 *
*   Multiplexing TDO data                                                         *
*                                                                                 *
**********************************************************************************/

// This multiplexer can be expanded with number of user registers
always @ (LatchedJTAG_IR or TDOInstruction or TDOData_dbg or TDOBypassed or bs_chain_i or mbist_so_i or ShiftIR or Exit1IR)
begin
  if(ShiftIR | Exit1IR)
    tdo_pad_o <=#Tp TDOInstruction;
  else
    begin
      case(LatchedJTAG_IR)
        `IDCODE:            tdo_pad_o <=#Tp TDOData_dbg;      // Reading ID code
        `CHAIN_SELECT:      tdo_pad_o <=#Tp TDOData_dbg;      // Selecting the chain
        `DEBUG:             tdo_pad_o <=#Tp TDOData_dbg;      // Debug
        `SAMPLE_PRELOAD:    tdo_pad_o <=#Tp bs_chain_i;   // Sampling/Preloading
        `EXTEST:            tdo_pad_o <=#Tp bs_chain_i;   // External test
        `INTEST:            tdo_pad_o <=#Tp mbist_so_i;   // External test
        default:            tdo_pad_o <=#Tp TDOBypassed;  // BYPASS instruction
      endcase
    end
end

// Tristate control for tdo_pad_o pin
assign tdo_padoe_o = ShiftIR | ShiftDR | Exit1IR | Exit1DR | UpdateDR;

/**********************************************************************************
*                                                                                 *
*   End: Multiplexing TDO data                                                    *
*                                                                                 *
**********************************************************************************/

endmodule
