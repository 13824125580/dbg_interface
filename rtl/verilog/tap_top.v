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
                tms_pad_i, tck_pad_i, trst_pad_i, tdi_pad_i, tdo_pad_o, tdo_padoen_o,

                // RISC signals
                risc_clk_i, risc_addr_o, risc_data_i, risc_data_o, wp_i, 
                bp_i, opselect_o, lsstatus_i, istatus_i, risc_stall_o, reset_o, 
                
                // WISHBONE common signals
                wb_rst_i, wb_clk_i, 

                // WISHBONE master interface
                wb_adr_o, wb_dat_o, wb_dat_i, wb_cyc_o, wb_stb_o, wb_sel_o,
                wb_we_o, wb_ack_i, wb_cab_o, wb_err_i
              );

parameter Tp = 1;

// JTAG pins
input   tms_pad_i;                  // JTAG test mode select pad
input   tck_pad_i;                  // JTAG test clock pad
input   trst_pad_i;                 // JTAG test reset pad
input   tdi_pad_i;                  // JTAG test data input pad
output  tdo_pad_o;                  // JTAG test data output pad
output  tdo_padoen_o;               // Output enable for JTAG test data output pad 


// RISC signals
input         risc_clk_i;                 // Master clock (RISC clock)
input  [31:0] risc_data_i;                // RISC data inputs (data that is written to the RISC registers)
input  [10:0] wp_i;                       // Watchpoint inputs
input         bp_i;                       // Breakpoint input
input  [3:0]  lsstatus_i;                 // Load/store status inputs
input  [1:0]  istatus_i;                  // Instruction status inputs
output [31:0] risc_addr_o;                // RISC address output (for adressing registers within RISC)
output [31:0] risc_data_o;                // RISC data output (data read from risc registers)
output [`OPSELECTWIDTH-1:0] opselect_o;   // Operation selection (selecting what kind of data is set to the risc_data_i)
output                      risc_stall_o; // Stalls the RISC
output                      reset_o;      // Resets the RISC


// WISHBONE common signals
input         wb_rst_i;                   // WISHBONE reset
input         wb_clk_i;                   // WISHBONE clock

// WISHBONE master interface
output [31:0] wb_adr_o;
output [31:0] wb_dat_o;
input  [31:0] wb_dat_i;
output        wb_cyc_o;
output        wb_stb_o;
output  [3:0] wb_sel_o;
output        wb_we_o;
input         wb_ack_i;
output        wb_cab_o;
input         wb_err_i;


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
reg     INTESTSelected;
reg     CLAMPSelected;
reg     CLAMPZSelected;
reg     HIGHZSelected;
reg     DEBUGSelected;
reg     BYPASSSelected;

reg     BypassRegister;               // Bypass register

wire    trst;                         // trst is active high while trst_pad_i is active low
wire    tck;
wire    TMS;
wire    tdi;
wire    TDOData;

wire    RiscDebugScanChain;
wire    WishboneScanChain;
wire    RegisterScanChain;
wire    bs_chain_o;


assign trst = ~trst_pad_i;                // trst_pad_i is active low
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
always @ (negedge tck)
begin
  if(ShiftIR)
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
    JTAG_DR_IN[12:0] <= #Tp {tdi, JTAG_DR_IN[12:1]};
  else
  if(DEBUGSelected & ShiftDR)
    begin
      if(RiscDebugScanChain | WishboneScanChain)
        JTAG_DR_IN[73:0] <= #Tp {tdi, JTAG_DR_IN[73:1]};
      else
      if(RegisterScanChain)
        JTAG_DR_IN[46:0] <= #Tp {tdi, JTAG_DR_IN[46:1]};
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

always @ (posedge tck)
begin
  if(ShiftDR)
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
  INTESTSelected          = 0;
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
    `INTEST:            INTESTSelected          = 1;    // Internal test
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
always @ (LatchedJTAG_IR or TDOInstruction or TDOData or TDOBypassed or bs_chain_o or ShiftIR or Exit1IR)
begin
  if(ShiftIR | Exit1IR)
    tdo_pad_o <=#Tp TDOInstruction;
  else
    begin
      case(LatchedJTAG_IR)
        `IDCODE:            tdo_pad_o <=#Tp TDOData;      // Reading ID code
        `CHAIN_SELECT:      tdo_pad_o <=#Tp TDOData;      // Selecting the chain
        `DEBUG:             tdo_pad_o <=#Tp TDOData;      // Debug
        `SAMPLE_PRELOAD:    tdo_pad_o <=#Tp bs_chain_o;   // Sampling/Preloading
        `EXTEST:            tdo_pad_o <=#Tp bs_chain_o;   // External test
        default:            tdo_pad_o <=#Tp TDOBypassed;  // BYPASS instruction
      endcase
    end
end

// Tristate control for tdo_pad_o pin
assign tdo_padoen_o = ShiftIR | ShiftDR | Exit1IR | Exit1DR | UpdateDR;

/**********************************************************************************
*                                                                                 *
*   End: Multiplexing TDO data                                                    *
*                                                                                 *
**********************************************************************************/




// Connecting dbg_top module
dbg_top i_dbg_top (
                    // RISC signals
                    .risc_clk_i(risc_clk_i),      .risc_addr_o(risc_addr_o),  .risc_data_i(risc_data_i), 
                    .risc_data_o(risc_data_o),    .wp_i(wp_i),                .bp_i(bp_i), 
                    .opselect_o(opselect_o),      .lsstatus_i(lsstatus_i),    .istatus_i(istatus_i), 
                    .risc_stall_o(risc_stall_o),  .reset_o(reset_o), 
                    
                    // WISHBONE common signals
                    .wb_rst_i(wb_rst_i),          .wb_clk_i(wb_clk_i), 
                    
                    // WISHBONE master interface
                    .wb_adr_o(wb_adr_o),          .wb_dat_o(wb_dat_o),        .wb_dat_i(wb_dat_i), 
                    .wb_cyc_o(wb_cyc_o),          .wb_stb_o(wb_stb_o),        .wb_sel_o(wb_sel_o), 
                    .wb_we_o(wb_we_o),            .wb_ack_i(wb_ack_i),        .wb_cab_o(wb_cab_o), 
                    .wb_err_i(wb_err_i), 
                    
                    // TAP states
                    .ShiftDR(ShiftDR),            .Exit1DR(Exit1DR),          .UpdateDR(UpdateDR), 
                    .UpdateDR_q(UpdateDR_q), 
                    
                    // Instructions
                    .IDCODESelected(IDCODESelected), 
                    .CHAIN_SELECTSelected(CHAIN_SELECTSelected), 
                    .DEBUGSelected(DEBUGSelected), 
                    
                    // TAP signals
                    .trst(trst),                  .tck(tck),                  .tdi(tdi),
                    .TDOData(TDOData), 
                    
                    .BypassRegister(BypassRegister)

                  );



// Connecting bender_jtag module
jtag_chain i_jtag_chain   (
                            .capture_dr_i(CaptureDR),           .shift_dr_i(ShiftDR), 
                            .update_dr_i(UpdateDR),             .extest_selected_i(EXTESTSelected), 
                            .bs_chain_i(tdi),                   .bs_chain_o(bs_chain_o)
                          );

endmodule
