//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_top.v                                                   ////
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
// Revision 1.7  2001/10/16 10:09:56  mohor
// Signal names changed to lowercase.
//
//
// Revision 1.6  2001/10/15 09:55:47  mohor
// Wishbone interface added, few fixes for better performance,
// hooks for boundary scan testing added.
//
// Revision 1.5  2001/09/24 14:06:42  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.4  2001/09/20 10:11:25  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.3  2001/09/19 11:55:13  mohor
// Asynchronous set/reset not used in trace any more.
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
// Revision 1.1.1.1  2001/05/18 06:35:02  mohor
// Initial release
//
//

`include "dbg_timescale.v"
`include "dbg_defines.v"

// Top module
module dbg_top(
                // JTAG pins
                tms_pad_i, tck_pad_i, trst_pad_i, tdi_pad_i, tdo_pad_o, 

                // Boundary Scan signals
                capture_dr_o, shift_dr_o, update_dr_o, extest_selected_o, bs_chain_i, bs_chain_o, 
                
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
input         tms_pad_i;                  // JTAG test mode select pad
input         tck_pad_i;                  // JTAG test clock pad
input         trst_pad_i;                 // JTAG test reset pad
input         tdi_pad_i;                  // JTAG test data input pad
output        tdo_pad_o;                  // JTAG test data output pad


// Boundary Scan signals
output capture_dr_o;
output shift_dr_o;
output update_dr_o;
output extest_selected_o;
input  bs_chain_i;
output bs_chain_o;

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

reg    [31:0] wb_adr_o;
reg    [31:0] wb_dat_o;
reg           wb_we_o;
reg           wb_cyc_o;

// TAP states
reg TestLogicReset;
reg RunTestIdle;
reg SelectDRScan;
reg CaptureDR;
reg ShiftDR;
reg Exit1DR;
reg PauseDR;
reg Exit2DR;
reg UpdateDR;

reg SelectIRScan;
reg CaptureIR;
reg ShiftIR;
reg Exit1IR;
reg PauseIR;
reg Exit2IR;
reg UpdateIR;


// Defining which instruction is selected
reg EXTESTSelected;
reg SAMPLE_PRELOADSelected;
reg IDCODESelected;
reg CHAIN_SELECTSelected;
reg INTESTSelected;
reg CLAMPSelected;
reg CLAMPZSelected;
reg HIGHZSelected;
reg DEBUGSelected;
reg BYPASSSelected;

reg [31:0]  ADDR;
reg [31:0]  DataOut;

reg [`OPSELECTWIDTH-1:0] opselect_o;      // Operation selection (selecting what kind of data is set to the risc_data_i)

reg [`CHAIN_ID_LENGTH-1:0] Chain;         // Selected chain
reg [31:0]  RISC_DATAINLatch;             // Data from DataIn is latched one risc_clk_i clock cycle after RISC register is
                                          // accessed for reading
reg [31:0]  RegisterReadLatch;            // Data when reading register is latched one TCK clock after the register is read.
reg         RegAccessTck;                 // Indicates access to the registers (read or write)
reg         RISCAccessTck;                // Indicates access to the RISC (read or write)
reg [7:0]   BitCounter;                   // Counting bits in the ShiftDR and Exit1DR stages
reg         RW;                           // Read/Write bit
reg         CrcMatch;                     // The crc that is shifted in and the internaly calculated crc are equal

reg         RegAccess_q;                  // Delayed signals used for accessing the registers
reg         RegAccess_q2;                 // Delayed signals used for accessing the registers
reg         RISCAccess_q;                 // Delayed signals used for accessing the RISC
reg         RISCAccess_q2;                // Delayed signals used for accessing the RISC

reg         wb_AccessTck;                 // Indicates access to the WISHBONE
reg [31:0]  WBReadLatch;                  // Data latched during WISHBONE read
reg         WBErrorLatch;                 // Error latched during WISHBONE read

wire TCK = tck_pad_i;
wire TMS = tms_pad_i;
wire TDI = tdi_pad_i;
wire RESET = ~trst_pad_i | wb_rst_i;      // trst_pad_i is active low

wire [31:0]             RegDataIn;        // Data from registers (read data)
wire [`CRC_LENGTH-1:0]  CalculatedCrcOut; // CRC calculated in this module. This CRC is apended at the end of the TDO.

wire RiscStall_reg;                       // RISC is stalled by setting the register bit
wire RiscReset_reg;                       // RISC is reset by setting the register bit
wire RiscStall_trace;                     // RISC is stalled by trace module
       
       
wire RegisterScanChain;                   // Register Scan chain selected
wire RiscDebugScanChain;                  // Risc Debug Scan chain selected
wire WishboneScanChain;                   // WISHBONE Scan chain selected

wire RiscStall_read_access;               // Stalling RISC because of the read access (SPR read)
wire RiscStall_write_access;              // Stalling RISC because of the write access (SPR write)
wire RiscStall_access;                    // Stalling RISC because of the read or write access

           
assign capture_dr_o       = CaptureDR;
assign shift_dr_o         = ShiftDR;
assign update_dr_o        = UpdateDR;
assign extest_selected_o  = EXTESTSelected;
wire   BS_CHAIN_I         = bs_chain_i;
assign bs_chain_o         = tdi_pad_i;


// This signals are used only when TRACE is used in the design
`ifdef TRACE_ENABLED
  wire [39:0] TraceChain;                 // Chain that comes from trace module
  reg  ReadBuffer_Tck;                    // Command for incrementing the trace read pointer (synchr with TCK)
  wire ReadTraceBuffer;                   // Command for incrementing the trace read pointer (synchr with MClk)
  reg  ReadTraceBuffer_q;                 // Delayed command for incrementing the trace read pointer (synchr with MClk)
  wire ReadTraceBufferPulse;              // Pulse for reading the trace buffer (valid for only one Mclk command)

  // Outputs from registers
  wire ContinMode;                        // Trace working in continous mode
  wire TraceEnable;                       // Trace enabled
  
  wire [10:0] WpTrigger;                  // Watchpoint starts trigger
  wire        BpTrigger;                  // Breakpoint starts trigger
  wire [3:0]  LSSTrigger;                 // Load/store status starts trigger
  wire [1:0]  ITrigger;                   // Instruction status starts trigger
  wire [1:0]  TriggerOper;                // Trigger operation
  
  wire        WpTriggerValid;             // Watchpoint trigger is valid
  wire        BpTriggerValid;             // Breakpoint trigger is valid
  wire        LSSTriggerValid;            // Load/store status trigger is valid
  wire        ITriggerValid;              // Instruction status trigger is valid
  
  wire [10:0] WpQualif;                   // Watchpoint starts qualifier
  wire        BpQualif;                   // Breakpoint starts qualifier
  wire [3:0]  LSSQualif;                  // Load/store status starts qualifier
  wire [1:0]  IQualif;                    // Instruction status starts qualifier
  wire [1:0]  QualifOper;                 // Qualifier operation
  
  wire        WpQualifValid;              // Watchpoint qualifier is valid
  wire        BpQualifValid;              // Breakpoint qualifier is valid
  wire        LSSQualifValid;             // Load/store status qualifier is valid
  wire        IQualifValid;               // Instruction status qualifier is valid
  
  wire [10:0] WpStop;                     // Watchpoint stops recording of the trace
  wire        BpStop;                     // Breakpoint stops recording of the trace
  wire [3:0]  LSSStop;                    // Load/store status stops recording of the trace
  wire [1:0]  IStop;                      // Instruction status stops recording of the trace
  wire [1:0]  StopOper;                   // Stop operation
  
  wire WpStopValid;                       // Watchpoint stop is valid
  wire BpStopValid;                       // Breakpoint stop is valid
  wire LSSStopValid;                      // Load/store status stop is valid
  wire IStopValid;                        // Instruction status stop is valid
  
  wire RecordPC;                          // Recording program counter
  wire RecordLSEA;                        // Recording load/store effective address
  wire RecordLDATA;                       // Recording load data
  wire RecordSDATA;                       // Recording store data
  wire RecordReadSPR;                     // Recording read SPR
  wire RecordWriteSPR;                    // Recording write SPR
  wire RecordINSTR;                       // Recording instruction
  
  // End: Outputs from registers

  wire TraceTestScanChain;                // Trace Test Scan chain selected
  wire [47:0] Trace_Data;                 // Trace data

  wire [`OPSELECTWIDTH-1:0]opselect_trace;// Operation selection (trace selecting what kind of
                                          // data is set to the risc_data_i)

`endif


/**********************************************************************************
*                                                                                 *
*   TAP State Machine: Fully JTAG compliant                                       *
*                                                                                 *
**********************************************************************************/

// TestLogicReset state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
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
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    RunTestIdle<=#Tp 0;
  else
    begin
      if(~TMS & (TestLogicReset | RunTestIdle | UpdateDR | UpdateIR))
        RunTestIdle<=#Tp 1;
      else
        RunTestIdle<=#Tp 0;
    end
end

// SelectDRScan state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    SelectDRScan<=#Tp 0;
  else
    begin
      if(TMS & (RunTestIdle | UpdateDR | UpdateIR))
        SelectDRScan<=#Tp 1;
      else
        SelectDRScan<=#Tp 0;
    end
end

// CaptureDR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    CaptureDR<=#Tp 0;
  else
    begin
      if(~TMS & SelectDRScan)
        CaptureDR<=#Tp 1;
      else
        CaptureDR<=#Tp 0;
    end
end

// ShiftDR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    ShiftDR<=#Tp 0;
  else
    begin
      if(~TMS & (CaptureDR | ShiftDR | Exit2DR))
        ShiftDR<=#Tp 1;
      else
        ShiftDR<=#Tp 0;
    end
end

// Exit1DR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    Exit1DR<=#Tp 0;
  else
    begin
      if(TMS & (CaptureDR | ShiftDR))
        Exit1DR<=#Tp 1;
      else
        Exit1DR<=#Tp 0;
    end
end

// PauseDR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    PauseDR<=#Tp 0;
  else
    begin
      if(~TMS & (Exit1DR | PauseDR))
        PauseDR<=#Tp 1;
      else
        PauseDR<=#Tp 0;
    end
end

// Exit2DR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    Exit2DR<=#Tp 0;
  else
    begin
      if(TMS & PauseDR)
        Exit2DR<=#Tp 1;
      else
        Exit2DR<=#Tp 0;
    end
end

// UpdateDR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    UpdateDR<=#Tp 0;
  else
    begin
      if(TMS & (Exit1DR | Exit2DR))
        UpdateDR<=#Tp 1;
      else
        UpdateDR<=#Tp 0;
    end
end

// Delayed UpdateDR state
reg UpdateDR_q;
always @ (posedge TCK)
begin
  UpdateDR_q<=#Tp UpdateDR;
end


// SelectIRScan state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    SelectIRScan<=#Tp 0;
  else
    begin
      if(TMS & SelectDRScan)
        SelectIRScan<=#Tp 1;
      else
        SelectIRScan<=#Tp 0;
    end
end

// CaptureIR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    CaptureIR<=#Tp 0;
  else
    begin
      if(~TMS & SelectIRScan)
        CaptureIR<=#Tp 1;
      else
        CaptureIR<=#Tp 0;
    end
end

// ShiftIR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    ShiftIR<=#Tp 0;
  else
    begin
      if(~TMS & (CaptureIR | ShiftIR | Exit2IR))
        ShiftIR<=#Tp 1;
      else
        ShiftIR<=#Tp 0;
    end
end

// Exit1IR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    Exit1IR<=#Tp 0;
  else
    begin
      if(TMS & (CaptureIR | ShiftIR))
        Exit1IR<=#Tp 1;
      else
        Exit1IR<=#Tp 0;
    end
end

// PauseIR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    PauseIR<=#Tp 0;
  else
    begin
      if(~TMS & (Exit1IR | PauseIR))
        PauseIR<=#Tp 1;
      else
        PauseIR<=#Tp 0;
    end
end

// Exit2IR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    Exit2IR<=#Tp 0;
  else
    begin
      if(TMS & PauseIR)
        Exit2IR<=#Tp 1;
      else
        Exit2IR<=#Tp 0;
    end
end

// UpdateIR state
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    UpdateIR<=#Tp 0;
  else
    begin
      if(TMS & (Exit1IR | Exit2IR))
        UpdateIR<=#Tp 1;
      else
        UpdateIR<=#Tp 0;
    end
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

always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    JTAG_IR[`IR_LENGTH-1:0] <= #Tp 0;
  else
    begin
      if(CaptureIR)
        begin
          JTAG_IR[1:0] <= #Tp 2'b01;       // This value is fixed for easier fault detection
          JTAG_IR[3:2] <= #Tp Status[1:0]; // Current status of chip
        end
      else
        begin
          if(ShiftIR)
            begin
              JTAG_IR[`IR_LENGTH-1:0] <= #Tp {TDI, JTAG_IR[`IR_LENGTH-1:1]};
            end
        end
    end
end


//TDO is changing on the falling edge of TCK
always @ (negedge TCK)
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
wire [31:0] IDCodeValue = `IDCODE_VALUE;  // IDCODE value is 32-bit long.

reg [`DR_LENGTH-1:0]JTAG_DR_IN;    // Data register
reg TDOData;


always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    JTAG_DR_IN[`DR_LENGTH-1:0]<=#Tp 0;
  else
  if(ShiftDR)
    JTAG_DR_IN[BitCounter]<=#Tp TDI;
end

wire [72:0] RISC_Data;
wire [45:0] Register_Data;
wire [72:0] WISHBONE_Data;
wire wb_Access_wbClk;

assign RISC_Data      = {CalculatedCrcOut, RISC_DATAINLatch, 33'h0};
assign Register_Data  = {CalculatedCrcOut, RegisterReadLatch, 6'h0};
assign WISHBONE_Data  = {CalculatedCrcOut, WBReadLatch, 32'h0, WBErrorLatch};


`ifdef TRACE_ENABLED
  assign Trace_Data     = {CalculatedCrcOut, TraceChain};
`endif

//TDO is changing on the falling edge of TCK
always @ (negedge TCK or posedge RESET)
begin
  if(RESET)
    begin
      TDOData <= #Tp 0;
      `ifdef TRACE_ENABLED
      ReadBuffer_Tck<=#Tp 0;
      `endif
    end
  else
  if(UpdateDR)
    begin
      TDOData <= #Tp CrcMatch;
      `ifdef TRACE_ENABLED
      if(DEBUGSelected & TraceTestScanChain & TraceChain[0])  // Sample in the trace buffer is valid
        ReadBuffer_Tck<=#Tp 1;                                // Increment read pointer
      `endif
    end
  else
    begin
      if(ShiftDR)
        begin
          if(IDCODESelected)
            TDOData <= #Tp IDCodeValue[BitCounter];           // IDCODE is shifted out
          else
          if(CHAIN_SELECTSelected)
            TDOData <= #Tp 0;
          else
          if(DEBUGSelected)
            begin
              if(RiscDebugScanChain)
                TDOData <= #Tp RISC_Data[BitCounter];         // Data read from RISC in the previous cycle is shifted out
              else
              if(RegisterScanChain)
                TDOData <= #Tp Register_Data[BitCounter];     // Data read from register in the previous cycle is shifted out
              else
              if(WishboneScanChain)
                TDOData <= #Tp WISHBONE_Data[BitCounter];     // Data read from the WISHBONE slave
              `ifdef TRACE_ENABLED
              else
              if(TraceTestScanChain)
                TDOData <= #Tp Trace_Data[BitCounter];        // Data from the trace buffer is shifted out
              `endif
            end
        end
      else
        begin
          TDOData <= #Tp 0;
          `ifdef TRACE_ENABLED
          ReadBuffer_Tck<=#Tp 0;
          `endif
        end
    end
end

/**********************************************************************************
*                                                                                 *
*   End: JTAG_DR                                                                  *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*   CHAIN_SELECT logic                                                            *
*                                                                                 *
**********************************************************************************/
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp `GLOBAL_BS_CHAIN;  // Global BS chain is selected after reset
  else
  if(UpdateDR & CHAIN_SELECTSelected & CrcMatch)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp JTAG_DR_IN[3:0];   // New chain is selected
end



/**********************************************************************************
*                                                                                 *
*   Register read/write logic                                                     *
*   RISC registers read/write logic                                               *
*                                                                                 *
**********************************************************************************/
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    begin
      ADDR[31:0]        <=#Tp 32'h0;
      DataOut[31:0]     <=#Tp 32'h0;
      RW                <=#Tp 1'b0;
      RegAccessTck      <=#Tp 1'b0;
      RISCAccessTck     <=#Tp 1'b0;
      wb_adr_o          <=#Tp 32'h0;
      wb_we_o           <=#Tp 1'h0;
      wb_dat_o          <=#Tp 32'h0;
      wb_AccessTck      <=#Tp 1'h0;
    end
  else
  if(UpdateDR & DEBUGSelected & CrcMatch)
    begin
      if(RegisterScanChain)
        begin
          ADDR[4:0]         <=#Tp JTAG_DR_IN[4:0];    // Latching address for register access
          RW                <=#Tp JTAG_DR_IN[5];      // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[37:6];   // latch data for write
          RegAccessTck      <=#Tp 1'b1;
        end
      else
      if(RiscDebugScanChain)
        begin
          ADDR[31:0]        <=#Tp JTAG_DR_IN[31:0];   // Latching address for RISC register access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          RISCAccessTck     <=#Tp 1'b1;
        end
      else
      if(WishboneScanChain)
        begin
          wb_adr_o          <=#Tp JTAG_DR_IN[31:0];   // Latching address for WISHBONE slave access
          wb_we_o           <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          wb_dat_o          <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          wb_AccessTck      <=#Tp 1'b1;               // 
        end
    end
  else
    begin
      RegAccessTck      <=#Tp 1'b0;       // This signals are valid for one TCK clock period only
      RISCAccessTck     <=#Tp 1'b0;
      wb_AccessTck      <=#Tp 1'b0;
    end
end

assign wb_sel_o[3:0] = 4'hf;
assign wb_cab_o = 1'b0;


// Synchronizing the RegAccess signal to risc_clk_i clock
dbg_sync_clk1_clk2 syn1 (.clk1(risc_clk_i),   .clk2(TCK),           .reset1(RESET),  .reset2(RESET), 
                         .set2(RegAccessTck), .sync_out(RegAccess)
                        );

// Synchronizing the RISCAccess signal to risc_clk_i clock
dbg_sync_clk1_clk2 syn2 (.clk1(risc_clk_i),    .clk2(TCK),           .reset1(RESET),  .reset2(RESET), 
                         .set2(RISCAccessTck), .sync_out(RISCAccess)
                        );


// Synchronizing the wb_Access signal to wishbone clock
dbg_sync_clk1_clk2 syn3 (.clk1(wb_clk_i),      .clk2(TCK),          .reset1(RESET),  .reset2(RESET), 
                         .set2(wb_AccessTck), .sync_out(wb_Access_wbClk)
                        );





// Delayed signals used for accessing registers and RISC
always @ (posedge risc_clk_i or posedge RESET)
begin
  if(RESET)
    begin
      RegAccess_q   <=#Tp 1'b0;
      RegAccess_q2  <=#Tp 1'b0;
      RISCAccess_q  <=#Tp 1'b0;
      RISCAccess_q2 <=#Tp 1'b0;
    end
  else
    begin
      RegAccess_q   <=#Tp RegAccess;
      RegAccess_q2  <=#Tp RegAccess_q;
      RISCAccess_q  <=#Tp RISCAccess;
      RISCAccess_q2 <=#Tp RISCAccess_q;
    end
end


// Latching data read from registers
always @ (posedge risc_clk_i or posedge RESET)
begin
  if(RESET)
    RegisterReadLatch[31:0]<=#Tp 0;
  else
  if(RegAccess_q & ~RegAccess_q2)
    RegisterReadLatch[31:0]<=#Tp RegDataIn[31:0];
end


// Chip select and read/write signals for accessing RISC
assign RiscStall_write_access = RISCAccess & ~RISCAccess_q  &  RW;
assign RiscStall_read_access  = RISCAccess & ~RISCAccess_q2 & ~RW;
assign RiscStall_access = RiscStall_write_access | RiscStall_read_access;


reg wb_Access_wbClk_q;
// Delayed signals used for accessing WISHBONE
always @ (posedge wb_clk_i or posedge RESET)
begin
  if(RESET)
    wb_Access_wbClk_q <=#Tp 1'b0;
  else
    wb_Access_wbClk_q <=#Tp wb_Access_wbClk;
end

always @ (posedge wb_clk_i or posedge RESET)
begin
  if(RESET)
    wb_cyc_o <=#Tp 1'b0;
  else
  if(wb_Access_wbClk & ~wb_Access_wbClk_q & ~(wb_ack_i | wb_err_i))
    wb_cyc_o <=#Tp 1'b1;
  else
  if(wb_ack_i | wb_err_i)
    wb_cyc_o <=#Tp 1'b0;
end

assign wb_stb_o = wb_cyc_o;


// Latching data read from registers
always @ (posedge risc_clk_i or posedge RESET)
begin
  if(RESET)
    WBReadLatch[31:0]<=#Tp 32'h0;
  else
  if(wb_ack_i)
    WBReadLatch[31:0]<=#Tp wb_dat_i[31:0];
end

// Latching WISHBONE error cycle
always @ (posedge wb_clk_i or posedge RESET)
begin
  if(RESET)
    WBErrorLatch<=#Tp 1'b0;
  else
  if(wb_err_i)
    WBErrorLatch<=#Tp 1'b1;     // Latching wb_err_i while performing WISHBONE access
  if(wb_ack_i)
    WBErrorLatch<=#Tp 1'b0;     // Clearing status
end


// Whan enabled, TRACE stalls RISC while saving data to the trace buffer.
`ifdef TRACE_ENABLED
  assign  risc_stall_o = RiscStall_access | RiscStall_reg | RiscStall_trace ;
`else
  assign  risc_stall_o = RiscStall_access | RiscStall_reg;
`endif

assign  reset_o = RiscReset_reg;


`ifdef TRACE_ENABLED
always @ (RiscStall_write_access or RiscStall_read_access or opselect_trace)
`else
always @ (RiscStall_write_access or RiscStall_read_access)
`endif
begin
  if(RiscStall_write_access)
    opselect_o = `DEBUG_WRITE_SPR;  // Write spr
  else
  if(RiscStall_read_access)
    opselect_o = `DEBUG_READ_SPR;   // Read spr
  else
`ifdef TRACE_ENABLED
    opselect_o = opselect_trace;
`else
    opselect_o = 3'h0;
`endif
end



// Latching data read from RISC
always @ (posedge risc_clk_i or posedge RESET)
begin
  if(RESET)
    RISC_DATAINLatch[31:0]<=#Tp 0;
  else
  if(RISCAccess_q & ~RISCAccess_q2)
    RISC_DATAINLatch[31:0]<=#Tp risc_data_i[31:0];
end

assign risc_addr_o = ADDR;
assign risc_data_o = DataOut;



/**********************************************************************************
*                                                                                 *
*   Read Trace buffer logic                                                       *
*                                                                                 *
**********************************************************************************/
`ifdef TRACE_ENABLED
  

// Synchronizing the trace read buffer signal to risc_clk_i clock
dbg_sync_clk1_clk2 syn4 (.clk1(risc_clk_i),     .clk2(TCK),           .reset1(RESET),  .reset2(RESET), 
                         .set2(ReadBuffer_Tck), .sync_out(ReadTraceBuffer)
                        );



  always @(posedge risc_clk_i or posedge RESET)
  begin
    if(RESET)
      ReadTraceBuffer_q <=#Tp 0;
    else
      ReadTraceBuffer_q <=#Tp ReadTraceBuffer;
  end

  assign ReadTraceBufferPulse = ReadTraceBuffer & ~ReadTraceBuffer_q;

`endif

/**********************************************************************************
*                                                                                 *
*   End: Read Trace buffer logic                                                  *
*                                                                                 *
**********************************************************************************/


/**********************************************************************************
*                                                                                 *
*   Bypass logic                                                                  *
*                                                                                 *
**********************************************************************************/
reg BypassRegister;
reg TDOBypassed;

always @ (posedge TCK)
begin
  if(ShiftDR)
    BypassRegister<=#Tp TDI;
end

always @ (negedge TCK)
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
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    LatchedJTAG_IR <=#Tp `IDCODE;   // IDCODE selected after reset
  else
  if(UpdateIR)
    LatchedJTAG_IR <=#Tp JTAG_IR;
end



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
*   Multiplexing TDO and Tristate control                                         *
*                                                                                 *
**********************************************************************************/
wire TDOShifted;
assign TDOShifted = (ShiftIR | Exit1IR)? TDOInstruction : TDOData;
/**********************************************************************************
*                                                                                 *
*   End:  Multiplexing TDO and Tristate control                                   *
*                                                                                 *
**********************************************************************************/



// This multiplexer can be expanded with number of user registers
reg TDOMuxed;
always @ (JTAG_IR or TDOShifted or TDOBypassed or BS_CHAIN_I)
begin
  case(JTAG_IR)
    `IDCODE: // Reading ID code
      begin
        TDOMuxed<=#Tp TDOShifted;
      end
    `CHAIN_SELECT: // Selecting the chain
      begin
        TDOMuxed<=#Tp TDOShifted;
      end
    `DEBUG: // Debug
      begin
        TDOMuxed<=#Tp TDOShifted;
      end
    `SAMPLE_PRELOAD:  // Sampling/Preloading
      begin
        TDOMuxed<=#Tp BS_CHAIN_I;
      end
    `EXTEST:  // External test
      begin
        TDOMuxed<=#Tp BS_CHAIN_I;
      end
    default:  // BYPASS instruction
      begin
        TDOMuxed<=#Tp TDOBypassed;
      end
  endcase
end

// Tristate control for tdo_pad_o pin
assign tdo_pad_o = (ShiftIR | ShiftDR | Exit1IR | Exit1DR | UpdateDR)? TDOMuxed : 1'bz;

/**********************************************************************************
*                                                                                 *
*   End: Activating Instructions                                                  *
*                                                                                 *
**********************************************************************************/

/**********************************************************************************
*                                                                                 *
*   Bit counter                                                                   *
*                                                                                 *
**********************************************************************************/


always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    BitCounter[7:0]<=#Tp 0;
  else
  if(ShiftDR)
    BitCounter[7:0]<=#Tp BitCounter[7:0]+1;
  else
  if(UpdateDR)
    BitCounter[7:0]<=#Tp 0;
end



/**********************************************************************************
*                                                                                 *
*   End: Bit counter                                                              *
*                                                                                 *
**********************************************************************************/



/**********************************************************************************
*                                                                                 *
*   Connecting Registers                                                          *
*                                                                                 *
**********************************************************************************/
dbg_registers dbgregs(.DataIn(DataOut[31:0]), .DataOut(RegDataIn[31:0]), 
                      .Address(ADDR[4:0]), .RW(RW), .Access(RegAccess & ~RegAccess_q), .Clk(risc_clk_i), 
                      .Bp(bp_i), .Reset(wb_rst_i), 
                      `ifdef TRACE_ENABLED
                      .ContinMode(ContinMode), .TraceEnable(TraceEnable), 
                      .WpTrigger(WpTrigger), .BpTrigger(BpTrigger), .LSSTrigger(LSSTrigger),
                      .ITrigger(ITrigger), .TriggerOper(TriggerOper), .WpQualif(WpQualif),
                      .BpQualif(BpQualif), .LSSQualif(LSSQualif), .IQualif(IQualif), 
                      .QualifOper(QualifOper), .RecordPC(RecordPC), 
                      .RecordLSEA(RecordLSEA), .RecordLDATA(RecordLDATA), 
                      .RecordSDATA(RecordSDATA), .RecordReadSPR(RecordReadSPR), 
                      .RecordWriteSPR(RecordWriteSPR), .RecordINSTR(RecordINSTR), 
                      .WpTriggerValid(WpTriggerValid), 
                      .BpTriggerValid(BpTriggerValid), .LSSTriggerValid(LSSTriggerValid), 
                      .ITriggerValid(ITriggerValid), .WpQualifValid(WpQualifValid), 
                      .BpQualifValid(BpQualifValid), .LSSQualifValid(LSSQualifValid), 
                      .IQualifValid(IQualifValid),
                      .WpStop(WpStop), .BpStop(BpStop), .LSSStop(LSSStop), .IStop(IStop), 
                      .StopOper(StopOper), .WpStopValid(WpStopValid), .BpStopValid(BpStopValid), 
                      .LSSStopValid(LSSStopValid), .IStopValid(IStopValid), 
                      `endif
                      .RiscStall(RiscStall_reg), .RiscReset(RiscReset_reg)

                     );

/**********************************************************************************
*                                                                                 *
*   End: Connecting Registers                                                     *
*                                                                                 *
**********************************************************************************/


/**********************************************************************************
*                                                                                 *
*   Connecting CRC module                                                         *
*                                                                                 *
**********************************************************************************/
wire AsyncResetCrc = RESET;
wire SyncResetCrc = UpdateDR_q;
wire [7:0] CalculatedCrcIn;     // crc calculated from the input data (shifted in)

wire EnableCrcIn = ShiftDR & 
                  ( (CHAIN_SELECTSelected                 & (BitCounter<4))  |
                    ((DEBUGSelected & RegisterScanChain)  & (BitCounter<38)) | 
                    ((DEBUGSelected & RiscDebugScanChain) & (BitCounter<65)) |
                    ((DEBUGSelected & WishboneScanChain)  & (BitCounter<65))
                  );

wire EnableCrcOut= ShiftDR & 
                   (
                    ((DEBUGSelected & RegisterScanChain)  & (BitCounter<38)) | 
                    ((DEBUGSelected & RiscDebugScanChain) & (BitCounter<65)) |
                    ((DEBUGSelected & WishboneScanChain)  & (BitCounter<65))
                    `ifdef TRACE_ENABLED
                                                                             |
                    ((DEBUGSelected & TraceTestScanChain) & (BitCounter<40)) 
                    `endif
                   );

// Calculating crc for input data
dbg_crc8_d1 crc1 (.Data(TDI), .EnableCrc(EnableCrcIn), .Reset(AsyncResetCrc), .SyncResetCrc(SyncResetCrc), 
                  .CrcOut(CalculatedCrcIn), .Clk(TCK));

// Calculating crc for output data
dbg_crc8_d1 crc2 (.Data(TDOData), .EnableCrc(EnableCrcOut), .Reset(AsyncResetCrc), .SyncResetCrc(SyncResetCrc), 
                  .CrcOut(CalculatedCrcOut), .Clk(TCK));


// Generating CrcMatch signal
always @ (posedge TCK or posedge RESET)
begin
  if(RESET)
    CrcMatch <=#Tp 1'b0;
  else
  if(Exit1DR)
    begin
      if(CHAIN_SELECTSelected)
        CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[11:4];
      else
      if(RegisterScanChain & ~CHAIN_SELECTSelected)
        CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[45:38];
      else
      if(RiscDebugScanChain & ~CHAIN_SELECTSelected)
        CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[72:65];
      else
      if(WishboneScanChain & ~CHAIN_SELECTSelected)
        CrcMatch <=#Tp CalculatedCrcIn == JTAG_DR_IN[72:65];
    end
end


// Active chain
assign RegisterScanChain   = Chain == `REGISTER_SCAN_CHAIN;
assign RiscDebugScanChain  = Chain == `RISC_DEBUG_CHAIN;
assign WishboneScanChain   = Chain == `WISHBONE_SCAN_CHAIN;

`ifdef TRACE_ENABLED
  assign TraceTestScanChain  = Chain == `TRACE_TEST_CHAIN;
`endif

/**********************************************************************************
*                                                                                 *
*   End: Connecting CRC module                                                    *
*                                                                                 *
**********************************************************************************/

/**********************************************************************************
*                                                                                 *
*   Connecting trace module                                                       *
*                                                                                 *
**********************************************************************************/
`ifdef TRACE_ENABLED
  dbg_trace dbgTrace1(.Wp(wp_i), .Bp(bp_i), .DataIn(risc_data_i), .OpSelect(opselect_trace), 
                      .LsStatus(lsstatus_i), .IStatus(istatus_i), .RiscStall_O(RiscStall_trace), 
                      .Mclk(risc_clk_i), .Reset(RESET), .TraceChain(TraceChain), 
                      .ContinMode(ContinMode), .TraceEnable_reg(TraceEnable), 
                      .WpTrigger(WpTrigger), 
                      .BpTrigger(BpTrigger), .LSSTrigger(LSSTrigger), .ITrigger(ITrigger), 
                      .TriggerOper(TriggerOper), .WpQualif(WpQualif), .BpQualif(BpQualif), 
                      .LSSQualif(LSSQualif), .IQualif(IQualif), .QualifOper(QualifOper), 
                      .RecordPC(RecordPC), .RecordLSEA(RecordLSEA), 
                      .RecordLDATA(RecordLDATA), .RecordSDATA(RecordSDATA), 
                      .RecordReadSPR(RecordReadSPR), .RecordWriteSPR(RecordWriteSPR), 
                      .RecordINSTR(RecordINSTR), 
                      .WpTriggerValid(WpTriggerValid), .BpTriggerValid(BpTriggerValid), 
                      .LSSTriggerValid(LSSTriggerValid), .ITriggerValid(ITriggerValid), 
                      .WpQualifValid(WpQualifValid), .BpQualifValid(BpQualifValid), 
                      .LSSQualifValid(LSSQualifValid), .IQualifValid(IQualifValid),
                      .ReadBuffer(ReadTraceBufferPulse),
                      .WpStop(WpStop), .BpStop(BpStop), .LSSStop(LSSStop), .IStop(IStop), 
                      .StopOper(StopOper), .WpStopValid(WpStopValid), .BpStopValid(BpStopValid), 
                      .LSSStopValid(LSSStopValid), .IStopValid(IStopValid) 
                     );
`endif
/**********************************************************************************
*                                                                                 *
*   End: Connecting trace module                                                  *
*                                                                                 *
**********************************************************************************/



endmodule
