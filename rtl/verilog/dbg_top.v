//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_top.v                                                   ////
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
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000,2001, 2002 Authors                        ////
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
// Revision 1.32  2003/09/18 14:00:47  simons
// Lower two address lines must be always zero.
//
// Revision 1.31  2003/09/17 14:38:57  simons
// WB_CNTL register added, some syncronization fixes.
//
// Revision 1.30  2003/08/28 13:55:22  simons
// Three more chains added for cpu debug access.
//
// Revision 1.29  2003/07/31 12:19:49  simons
// Multiple cpu support added.
//
// Revision 1.28  2002/11/06 14:22:41  mohor
// Trst signal is not inverted here any more. Inverted on higher layer !!!.
//
// Revision 1.27  2002/10/10 02:42:55  mohor
// WISHBONE Scan Chain is changed to reflect state of the WISHBONE access (WBInProgress bit added). 
// Internal counter is used (counts 256 wb_clk cycles) and when counter exceeds that value, 
// wb_cyc_o is negated.
//
// Revision 1.26  2002/05/07 14:43:59  mohor
// mon_cntl_o signals that controls monitor mux added.
//
// Revision 1.25  2002/04/22 12:54:11  mohor
// Signal names changed to lower case.
//
// Revision 1.24  2002/04/17 13:17:01  mohor
// Intentional error removed.
//
// Revision 1.23  2002/04/17 11:16:33  mohor
// A block for checking possible simulation/synthesis missmatch added.
//
// Revision 1.22  2002/03/12 10:31:53  mohor
// tap_top and dbg_top modules are put into two separate modules. tap_top
// contains only tap state machine and related logic. dbg_top contains all
// logic necessery for debugging.
//
// Revision 1.21  2002/03/08 15:28:16  mohor
// Structure changed. Hooks for jtag chain added.
//
// Revision 1.20  2002/02/06 12:23:09  mohor
// LatchedJTAG_IR used when muxing TDO instead of JTAG_IR.
//
// Revision 1.19  2002/02/05 13:34:51  mohor
// Stupid bug that was entered by previous update fixed.
//
// Revision 1.18  2002/02/05 12:41:01  mohor
// trst synchronization is not needed and was removed.
//
// Revision 1.17  2002/01/25 07:58:35  mohor
// IDCODE bug fixed, chains reused to decreas size of core. Data is shifted-in
// not filled-in. Tested in hw.
//
// Revision 1.16  2001/12/20 11:17:26  mohor
// TDO and TDO Enable signal are separated into two signals.
//
// Revision 1.15  2001/12/05 13:28:21  mohor
// trst signal is synchronized to wb_clk_i.
//
// Revision 1.14  2001/11/28 09:36:15  mohor
// Register length fixed.
//
// Revision 1.13  2001/11/27 13:37:43  mohor
// CRC is returned when chain selection data is transmitted.
//
// Revision 1.12  2001/11/26 10:47:09  mohor
// Crc generation is different for read or write commands. Small synthesys fixes.
//
// Revision 1.11  2001/11/14 10:10:41  mohor
// Wishbone data latched on wb_clk_i instead of risc_clk.
//
// Revision 1.10  2001/11/12 01:11:27  mohor
// Reset signals are not combined any more.
//
// Revision 1.9  2001/10/19 11:40:01  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
//
// Revision 1.8  2001/10/17 10:39:03  mohor
// bs_chain_o added.
//
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_defines.v"

// Top module
module dbg_top(
                
                // CPU signals
                cpu_clk_i, cpu_addr_o, cpu_data_i, cpu_data_o, wp_i, 
                bp_i, opselect_o, lsstatus_i, istatus_i, 
                cpu_stall_o, cpu_stall_all_o, cpu_sel_o, reset_o,

                // WISHBONE common signals
                wb_rst_i, wb_clk_i, 

                // WISHBONE master interface
                wb_adr_o, wb_dat_o, wb_dat_i, wb_cyc_o, wb_stb_o, wb_sel_o,
                wb_we_o, wb_ack_i, wb_cab_o, wb_err_i, 

                // TAP states
                ShiftDR, Exit1DR, UpdateDR, UpdateDR_q, SelectDRScan,
                
                // Instructions
                IDCODESelected, CHAIN_SELECTSelected, DEBUGSelected, 
                
                // TAP signals
                trst_in, tck, tdi, TDOData, 
                
                BypassRegister,
                
                // Monitor mux control
                mon_cntl_o,

                // Selected chains
                RegisterScanChain,
                CpuDebugScanChain0,
                CpuDebugScanChain1,
                CpuDebugScanChain2,
                CpuDebugScanChain3,
                WishboneScanChain



              );

parameter Tp = 1;


// CPU signals
input         cpu_clk_i;                  // Master clock (CPU clock)
input  [31:0] cpu_data_i;                 // CPU data inputs (data that is written to the CPU registers)
input  [10:0] wp_i;                       // Watchpoint inputs
input         bp_i;                       // Breakpoint input
input  [3:0]  lsstatus_i;                 // Load/store status inputs
input  [1:0]  istatus_i;                  // Instruction status inputs
output [31:0] cpu_addr_o;                 // CPU address output (for adressing registers within CPU)
output [31:0] cpu_data_o;                 // CPU data output (data read from cpu registers)
output [`OPSELECTWIDTH-1:0] opselect_o;   // Operation selection (selecting what kind of data is set to the cpu_data_i)
output         cpu_stall_o;               // Stalls the selected CPU
output         cpu_stall_all_o;           // Stalls all the rest CPUs
output [`CPU_NUM-1:0] cpu_sel_o;          // Stalls all the rest CPUs
output         reset_o;                   // Resets the CPU


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

// TAP states
input         ShiftDR;
input         Exit1DR;
input         UpdateDR;
input         UpdateDR_q;
input         SelectDRScan;

input         trst_in;
input         tck;
input         tdi;

input         BypassRegister;

output        TDOData;
output [3:0]  mon_cntl_o;

// Defining which instruction is selected
input         IDCODESelected;
input         CHAIN_SELECTSelected;
input         DEBUGSelected;

// Selected chains
output        RegisterScanChain;
output        CpuDebugScanChain0;
output        CpuDebugScanChain1;
output        CpuDebugScanChain2;
output        CpuDebugScanChain3;
output        WishboneScanChain;

reg           wb_cyc_o;

reg [31:0]    ADDR;
reg [31:0]    DataOut;

reg [`OPSELECTWIDTH-1:0] opselect_o;        // Operation selection (selecting what kind of data is set to the cpu_data_i)

reg [`CHAIN_ID_LENGTH-1:0] Chain;           // Selected chain
reg [31:0]    DataReadLatch;                // Data when reading register or CPU is latched one cpu_clk_i clock after the data is read.
reg           RegAccessTck;                 // Indicates access to the registers (read or write)
reg           CPUAccessTck0;                // Indicates access to the CPU (read or write)
reg           CPUAccessTck1;                // Indicates access to the CPU (read or write)
reg           CPUAccessTck2;                // Indicates access to the CPU (read or write)
reg           CPUAccessTck3;                // Indicates access to the CPU (read or write)
reg [7:0]     BitCounter;                   // Counting bits in the ShiftDR and Exit1DR stages
reg           RW;                           // Read/Write bit
reg           CrcMatch;                     // The crc that is shifted in and the internaly calculated crc are equal
reg           CrcMatch_q;

reg           RegAccess_q;                  // Delayed signals used for accessing the registers
reg           RegAccess_q2;                 // Delayed signals used for accessing the registers
reg           CPUAccess_q;                  // Delayed signals used for accessing the CPU 
reg           CPUAccess_q2;                 // Delayed signals used for accessing the CPU 
reg           CPUAccess_q3;                 // Delayed signals used for accessing the CPU 

reg           wb_AccessTck;                 // Indicates access to the WISHBONE
reg [31:0]    WBReadLatch;                  // Data latched during WISHBONE read
reg           WBErrorLatch;                 // Error latched during WISHBONE read
reg           WBInProgress;                 // WISHBONE access is in progress
reg [7:0]     WBAccessCounter;              // Counting access cycles. WBInProgress is cleared to 0 after counter exceeds 0xff
wire          WBAccessCounterExceed;        // Marks when the WBAccessCounter exceeds max value (oxff)
reg           WBInProgress_sync1;           // Synchronizing WBInProgress
reg           WBInProgress_tck;             // Synchronizing WBInProgress to tck clock signal

wire trst;


wire [31:0]             RegDataIn;          // Data from registers (read data)
wire [`CRC_LENGTH-1:0]  CalculatedCrcOut;   // CRC calculated in this module. This CRC is apended at the end of the TDO.

wire CpuStall_reg;                          // CPU is stalled by setting the register bit
wire CpuReset_reg;                          // CPU is reset by setting the register bit
wire CpuStall_trace;                        // CPU is stalled by trace module
       
       
wire CpuStall_read_access_0;                // Stalling Cpu because of the read access (SPR read)
wire CpuStall_read_access_1;                // Stalling Cpu because of the read access (SPR read)
wire CpuStall_read_access_2;                // Stalling Cpu because of the read access (SPR read)
wire CpuStall_read_access_3;                // Stalling Cpu because of the read access (SPR read)
wire CpuStall_write_access_0;               // Stalling Cpu because of the write access (SPR write)
wire CpuStall_write_access_1;               // Stalling Cpu because of the write access (SPR write)
wire CpuStall_write_access_2;               // Stalling Cpu because of the write access (SPR write)
wire CpuStall_write_access_3;               // Stalling Cpu because of the write access (SPR write)
wire CpuStall_access;                       // Stalling Cpu because of the read or write access

wire BitCounter_Lt4;
wire BitCounter_Eq5;
wire BitCounter_Eq32;
wire BitCounter_Lt38;
wire BitCounter_Lt65;



// This signals are used only when TRACE is used in the design
`ifdef TRACE_ENABLED
  wire [39:0] TraceChain;                 // Chain that comes from trace module
  reg  ReadBuffer_Tck;                    // Command for incrementing the trace read pointer (synchr with tck)
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
                                          // data is set to the cpu_data_i)
  wire BitCounter_Lt40;

`endif


assign trst = trst_in;                   // trst_pad_i is active high !!! Inverted on higher layer.


/**********************************************************************************
*                                                                                 *
*   JTAG_DR:  JTAG Data Register                                                  *
*                                                                                 *
**********************************************************************************/
reg [`DR_LENGTH-1:0]JTAG_DR_IN;    // Data register
reg TDOData;


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
      if(CpuDebugScanChain0 | CpuDebugScanChain1 |
         CpuDebugScanChain2 | CpuDebugScanChain3 | WishboneScanChain)
        JTAG_DR_IN[73:0] <= #Tp {tdi, JTAG_DR_IN[73:1]};
      else
      if(RegisterScanChain)
        JTAG_DR_IN[46:0] <= #Tp {tdi, JTAG_DR_IN[46:1]};
    end
end
 
wire [73:0] CPU_Data;
wire [46:0] Register_Data;
wire [73:0] WISHBONE_Data;
wire [12:0] chain_sel_data;
wire wb_Access_wbClk;
wire [1:0] wb_cntl_o;


reg crc_bypassed;
always @ (posedge tck or posedge trst)
begin
  if(trst)
    crc_bypassed <= 0;
  else if (CHAIN_SELECTSelected)
    crc_bypassed <=#Tp 1;
  else if( 
          RegisterScanChain  & BitCounter_Eq5  |
          CpuDebugScanChain0 & BitCounter_Eq32 |
          CpuDebugScanChain1 & BitCounter_Eq32 |
          CpuDebugScanChain2 & BitCounter_Eq32 |
          CpuDebugScanChain3 & BitCounter_Eq32 |
          WishboneScanChain  & BitCounter_Eq32 )
    crc_bypassed <=#Tp tdi;              // when write is performed.
end

reg  [7:0] send_crc;
wire [7:0] CalculatedCrcIn;     // crc calculated from the input data (shifted in)

// Calculated CRC is returned when read operation is performed, else received crc is returned (loopback).
always @ (crc_bypassed or CrcMatch or CrcMatch_q or BypassRegister or CalculatedCrcOut)
  begin
    if (crc_bypassed)
      begin
        if (CrcMatch | CrcMatch_q)          // When crc is looped back, first bit is not inverted
          send_crc = {8{BypassRegister}};   // since it caused the error. By inverting it we would
        else                                // get ok crc.
          send_crc = {8{~BypassRegister}};
      end
    else
      begin
        if (CrcMatch)
          send_crc = {8{CalculatedCrcOut}};
        else
          send_crc = {8{~CalculatedCrcOut}};
      end
  end

assign CPU_Data       = {send_crc,  DataReadLatch, 33'h0, 1'b0};
assign Register_Data  = {send_crc,  DataReadLatch, 6'h0, 1'b0};
assign WISHBONE_Data  = {send_crc,  WBReadLatch, 31'h0, WBInProgress, WBErrorLatch, 1'b0};
assign chain_sel_data = {send_crc, 4'h0, 1'b0};
                                                  
                                                  
`ifdef TRACE_ENABLED                              
  assign Trace_Data     = {CalculatedCrcOut, TraceChain};
`endif

//TDO is changing on the falling edge of tck
always @ (negedge tck or posedge trst)
begin
  if(trst)
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
            TDOData <= #Tp JTAG_DR_IN[0]; // IDCODE is shifted out 32-bits, then tdi is bypassed
          else
          if(CHAIN_SELECTSelected)
            TDOData <= #Tp chain_sel_data[BitCounter];        // Received crc is sent back
          else
          if(DEBUGSelected)
            begin
              if(CpuDebugScanChain0 | CpuDebugScanChain1 | CpuDebugScanChain2 | CpuDebugScanChain3)
                TDOData <= #Tp CPU_Data[BitCounter];          // Data read from CPU in the previous cycle is shifted out
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


//synopsys translate_off
always @ (posedge tck)
begin
  if(ShiftDR & CHAIN_SELECTSelected & BitCounter > 12)
    begin
      $display("\n%m Error: BitCounter is bigger then chain_sel_data bits width[12:0]. BitCounter=%d\n",BitCounter);
      $stop;
    end
  else
  if(ShiftDR & DEBUGSelected)
    begin
      if((CpuDebugScanChain0 | CpuDebugScanChain1 | CpuDebugScanChain2 | CpuDebugScanChain3) & BitCounter > 73)
        begin
          $display("\n%m Error: BitCounter is bigger then CPU_Data bits width[73:0]. BitCounter=%d\n",BitCounter);
          $stop;
        end
      else
      if(RegisterScanChain & BitCounter > 46)
        begin
          $display("\n%m Error: BitCounter is bigger then Register_Data bits width[46:0]. BitCounter=%d\n",BitCounter);
          $stop;
        end
      else
      if(WishboneScanChain & BitCounter > 73)
        begin
          $display("\n%m Error: BitCounter is bigger then WISHBONE_Data bits width[73:0]. BitCounter=%d\n",BitCounter);
          $stop;
        end
      `ifdef TRACE_ENABLED
      else
      if(TraceTestScanChain & BitCounter > 47)
        begin
          $display("\n%m Error: BitCounter is bigger then Trace_Data bits width[47:0]. BitCounter=%d\n",BitCounter);
          $stop;
        end
      `endif
    end
end
// synopsys translate_on








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
always @ (posedge tck or posedge trst)
begin
  if(trst)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp `GLOBAL_BS_CHAIN;  // Global BS chain is selected after reset
  else
  if(UpdateDR & CHAIN_SELECTSelected & CrcMatch)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp JTAG_DR_IN[3:0];   // New chain is selected
end



/**********************************************************************************
*                                                                                 *
*   Register read/write logic                                                     *
*   CPU registers read/write logic                                                *
*                                                                                 *
**********************************************************************************/
always @ (posedge tck or posedge trst)
begin
  if(trst)
    begin
      ADDR[31:0]        <=#Tp 32'h0;
      DataOut[31:0]     <=#Tp 32'h0;
      RW                <=#Tp 1'b0;
      RegAccessTck      <=#Tp 1'b0;
      CPUAccessTck0     <=#Tp 1'b0;
      CPUAccessTck1     <=#Tp 1'b0;
      CPUAccessTck2     <=#Tp 1'b0;
      CPUAccessTck3     <=#Tp 1'b0;
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
      if(WishboneScanChain & (!WBInProgress_tck))
        begin
          ADDR              <=#Tp JTAG_DR_IN[31:0];   // Latching address for WISHBONE slave access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut           <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          wb_AccessTck      <=#Tp 1'b1;               // 
        end
      else
      if(CpuDebugScanChain0)
        begin
          ADDR[31:0]        <=#Tp JTAG_DR_IN[31:0];   // Latching address for CPU register access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          CPUAccessTck0     <=#Tp 1'b1;
        end
      else
      if(CpuDebugScanChain1)
        begin
          ADDR[31:0]        <=#Tp JTAG_DR_IN[31:0];   // Latching address for CPU register access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          CPUAccessTck1     <=#Tp 1'b1;
        end
      else
      if(CpuDebugScanChain2)
        begin
          ADDR[31:0]        <=#Tp JTAG_DR_IN[31:0];   // Latching address for CPU register access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          CPUAccessTck2     <=#Tp 1'b1;
        end
      else
      if(CpuDebugScanChain3)
        begin
          ADDR[31:0]        <=#Tp JTAG_DR_IN[31:0];   // Latching address for CPU register access
          RW                <=#Tp JTAG_DR_IN[32];     // latch R/W bit
          DataOut[31:0]     <=#Tp JTAG_DR_IN[64:33];  // latch data for write
          CPUAccessTck3     <=#Tp 1'b1;
        end
    end
  else
    begin
      RegAccessTck      <=#Tp 1'b0;       // This signals are valid for one tck clock period only
      wb_AccessTck      <=#Tp 1'b0;
      CPUAccessTck0     <=#Tp 1'b0;
      CPUAccessTck1     <=#Tp 1'b0;
      CPUAccessTck2     <=#Tp 1'b0;
      CPUAccessTck3     <=#Tp 1'b0;
    end
end


assign wb_adr_o = {ADDR[31:2] & {30{wb_cyc_o}}, 2'b0};
assign wb_we_o  = RW & wb_cyc_o;
assign wb_cab_o = 1'b0;

reg [31:0] wb_dat_o;
always @(wb_sel_o or wb_cyc_o or DataOut)
begin
  if(wb_cyc_o)
      case (wb_sel_o)
        4'b0001: wb_dat_o = {24'hx, DataOut[7:0]};
        4'b0010: wb_dat_o = {16'hx, DataOut[7:0], 8'hx};
        4'b0100: wb_dat_o = {8'hx, DataOut[7:0], 16'hx};
        4'b1000: wb_dat_o = {DataOut[7:0], 24'hx};
        4'b0011: wb_dat_o = {16'hx, DataOut[15:0]};
        4'b1100: wb_dat_o = {DataOut[15:0], 16'hx};
        default: wb_dat_o = DataOut;
      endcase
  else
    wb_dat_o = 32'hx;
end

reg [3:0] wb_sel_o;
always @(ADDR[1:0] or wb_cntl_o or wb_cyc_o)
begin
  if(wb_cyc_o)
      case (wb_cntl_o)
        2'b00:   wb_sel_o = 4'hf;
        2'b01:   wb_sel_o = ADDR[1] ? 4'h3 : 4'hc;
        2'b10:   wb_sel_o = ADDR[1] ? (ADDR[0] ? 4'h1 : 4'h2) : (ADDR[0] ? 4'h4 : 4'h8);
        default: wb_sel_o = 4'hx;
      endcase
  else
    wb_sel_o = 4'hx;
end
   
// Synchronizing the RegAccess signal to cpu_clk_i clock
dbg_sync_clk1_clk2 syn1 (.clk1(cpu_clk_i),   .clk2(tck),           .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(RegAccessTck), .sync_out(RegAccess)
                        );

// Synchronizing the wb_Access signal to wishbone clock
dbg_sync_clk1_clk2 syn2 (.clk1(wb_clk_i),     .clk2(tck),           .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(wb_AccessTck), .sync_out(wb_Access_wbClk)
                        );

// Synchronizing the CPUAccess0 signal to cpu_clk_i clock
dbg_sync_clk1_clk2 syn3 (.clk1(cpu_clk_i),    .clk2(tck),          .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(CPUAccessTck0), .sync_out(CPUAccess0)
                        );

// Synchronizing the CPUAccess1 signal to cpu_clk_i clock
dbg_sync_clk1_clk2 syn4 (.clk1(cpu_clk_i),    .clk2(tck),          .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(CPUAccessTck1), .sync_out(CPUAccess1)
                        );

// Synchronizing the CPUAccess2 signal to cpu_clk_i clock
dbg_sync_clk1_clk2 syn5 (.clk1(cpu_clk_i),    .clk2(tck),          .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(CPUAccessTck2), .sync_out(CPUAccess2)
                        );

// Synchronizing the CPUAccess3 signal to cpu_clk_i clock
dbg_sync_clk1_clk2 syn6 (.clk1(cpu_clk_i),    .clk2(tck),          .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(CPUAccessTck3), .sync_out(CPUAccess3)
                        );





// Delayed signals used for accessing registers and CPU
always @ (posedge cpu_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    begin
      RegAccess_q   <=#Tp 1'b0;
      RegAccess_q2  <=#Tp 1'b0;
      CPUAccess_q   <=#Tp 1'b0;
      CPUAccess_q2  <=#Tp 1'b0;
      CPUAccess_q3  <=#Tp 1'b0;
    end
  else
    begin
      RegAccess_q   <=#Tp RegAccess;
      RegAccess_q2  <=#Tp RegAccess_q;
      CPUAccess_q   <=#Tp CPUAccess0 | CPUAccess1 | CPUAccess2 | CPUAccess3;
      CPUAccess_q2  <=#Tp CPUAccess_q;
      CPUAccess_q3  <=#Tp CPUAccess_q2;
    end
end

// Chip select and read/write signals for accessing CPU
assign CpuStall_write_access_0 = CPUAccess0 & ~CPUAccess_q2 &  RW;
assign CpuStall_read_access_0  = CPUAccess0 & ~CPUAccess_q2 & ~RW;
assign CpuStall_write_access_1 = CPUAccess1 & ~CPUAccess_q2 &  RW;
assign CpuStall_read_access_1  = CPUAccess1 & ~CPUAccess_q2 & ~RW;
assign CpuStall_write_access_2 = CPUAccess2 & ~CPUAccess_q2 &  RW;
assign CpuStall_read_access_2  = CPUAccess2 & ~CPUAccess_q2 & ~RW;
assign CpuStall_write_access_3 = CPUAccess3 & ~CPUAccess_q2 &  RW;
assign CpuStall_read_access_3  = CPUAccess3 & ~CPUAccess_q2 & ~RW;
assign CpuStall_access = (CPUAccess0 | CPUAccess1 | CPUAccess2 | CPUAccess3) & ~CPUAccess_q3;


reg wb_Access_wbClk_q;
// Delayed signals used for accessing WISHBONE
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    wb_Access_wbClk_q <=#Tp 1'b0;
  else
    wb_Access_wbClk_q <=#Tp wb_Access_wbClk;
end

always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    wb_cyc_o <=#Tp 1'b0;
  else
  if(wb_Access_wbClk & ~wb_Access_wbClk_q)
    wb_cyc_o <=#Tp 1'b1;
  else
  if(wb_ack_i | wb_err_i | WBAccessCounterExceed)
    wb_cyc_o <=#Tp 1'b0;
end

assign wb_stb_o = wb_cyc_o;


// Latching data read from registers
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    WBReadLatch[31:0]<=#Tp 32'h0;
  else
  if(wb_ack_i)
    case (wb_sel_o)
      4'b0001: WBReadLatch[31:0]<=#Tp {24'h0, wb_dat_i[7:0]};
      4'b0010: WBReadLatch[31:0]<=#Tp {24'h0, wb_dat_i[15:8]};
      4'b0100: WBReadLatch[31:0]<=#Tp {24'h0, wb_dat_i[23:16]};
      4'b1000: WBReadLatch[31:0]<=#Tp {24'h0, wb_dat_i[31:24]};
      4'b0011: WBReadLatch[31:0]<=#Tp {16'h0, wb_dat_i[15:0]};
      4'b1100: WBReadLatch[31:0]<=#Tp {16'h0, wb_dat_i[31:16]};
      default: WBReadLatch[31:0]<=#Tp wb_dat_i[31:0];
    endcase
end

// Latching WISHBONE error cycle
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    WBErrorLatch<=#Tp 1'b0;
  else
  if(wb_err_i)
    WBErrorLatch<=#Tp 1'b1;     // Latching wb_err_i while performing WISHBONE access
  else
  if(wb_ack_i)
    WBErrorLatch<=#Tp 1'b0;     // Clearing status
end


// WBInProgress is set at the beginning of the access and cleared when wb_ack_i or wb_err_i is set
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    WBInProgress<=#Tp 1'b0;
  else
  if(wb_Access_wbClk & ~wb_Access_wbClk_q)
    WBInProgress<=#Tp 1'b1;
  else
  if(wb_ack_i | wb_err_i | WBAccessCounterExceed)
    WBInProgress<=#Tp 1'b0;
end


// Synchronizing WBInProgress
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    WBAccessCounter<=#Tp 8'h0;
  else
  if(wb_ack_i | wb_err_i | WBAccessCounterExceed)
    WBAccessCounter<=#Tp 8'h0;
  else
  if(wb_cyc_o)
    WBAccessCounter<=#Tp WBAccessCounter + 1'b1;
end

assign WBAccessCounterExceed = WBAccessCounter==8'hff;


// Synchronizing WBInProgress
always @ (posedge tck)
begin
    WBInProgress_sync1<=#Tp WBInProgress;
    WBInProgress_tck<=#Tp WBInProgress_sync1;
end


// Whan enabled, TRACE stalls CPU while saving data to the trace buffer.
`ifdef TRACE_ENABLED
  assign  cpu_stall_o = CpuStall_access | CpuStall_reg | CpuStall_trace ;
`else
  assign  cpu_stall_o = CpuStall_access | CpuStall_reg;
`endif

assign  reset_o = CpuReset_reg;


`ifdef TRACE_ENABLED
always @ (CpuStall_write_access_0 or CpuStall_write_access_1 or 
          CpuStall_write_access_2 or CpuStall_write_access_2 or 
          CpuStall_read_access_0  or CpuStall_read_access_1  or
          CpuStall_read_access_2  or CpuStall_read_access_3  or opselect_trace)
`else
always @ (CpuStall_write_access_0 or CpuStall_write_access_1 or 
          CpuStall_write_access_2 or CpuStall_write_access_3 or 
          CpuStall_read_access_0  or CpuStall_read_access_1  or
          CpuStall_read_access_2  or CpuStall_read_access_3)
`endif
begin
  if(CpuStall_write_access_0)
    opselect_o = `DEBUG_WRITE_0;
  else
  if(CpuStall_read_access_0)
    opselect_o = `DEBUG_READ_0;
  else
  if(CpuStall_write_access_1)
    opselect_o = `DEBUG_WRITE_1;
  else
  if(CpuStall_read_access_1)
    opselect_o = `DEBUG_READ_1;
  else
  if(CpuStall_write_access_2)
    opselect_o = `DEBUG_WRITE_2;
  else
  if(CpuStall_read_access_2)
    opselect_o = `DEBUG_READ_2;
  else
  if(CpuStall_write_access_3)
    opselect_o = `DEBUG_WRITE_3;
  else
  if(CpuStall_read_access_3)
    opselect_o = `DEBUG_READ_3;
  else
`ifdef TRACE_ENABLED
    opselect_o = opselect_trace;
`else
    opselect_o = 3'h0;
`endif
end


// Latching data read from CPU or registers
always @ (posedge cpu_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    DataReadLatch[31:0]<=#Tp 0;
  else
  if(CPUAccess_q & ~CPUAccess_q2)
    DataReadLatch[31:0]<=#Tp cpu_data_i[31:0];
  else
  if(RegAccess_q & ~RegAccess_q2)
    DataReadLatch[31:0]<=#Tp RegDataIn[31:0];
end

assign cpu_addr_o = ADDR;
assign cpu_data_o = DataOut;



/**********************************************************************************
*                                                                                 *
*   Read Trace buffer logic                                                       *
*                                                                                 *
**********************************************************************************/
`ifdef TRACE_ENABLED
  

// Synchronizing the trace read buffer signal to cpu_clk_i clock
dbg_sync_clk1_clk2 syn4 (.clk1(cpu_clk_i),     .clk2(tck),           .reset1(wb_rst_i),  .reset2(trst), 
                         .set2(ReadBuffer_Tck), .sync_out(ReadTraceBuffer)
                        );



  always @(posedge cpu_clk_i or posedge wb_rst_i)
  begin
    if(wb_rst_i)
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
*   Bit counter                                                                   *
*                                                                                 *
**********************************************************************************/


always @ (posedge tck or posedge trst)
begin
  if(trst)
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
dbg_registers dbgregs(.data_in(DataOut[31:0]), .data_out(RegDataIn[31:0]), 
                      .address(ADDR[4:0]), .rw(RW), .access(RegAccess & ~RegAccess_q), .clk(cpu_clk_i), 
                      .bp(bp_i), .reset(wb_rst_i), 
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
                      .cpu_stall(CpuStall_reg), .cpu_stall_all(cpu_stall_all_o), .cpu_sel(cpu_sel_o),
                      .cpu_reset(CpuReset_reg), .mon_cntl_o(mon_cntl_o), .wb_cntl_o(wb_cntl_o)

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
wire AsyncResetCrc = trst;
wire SyncResetCrc = UpdateDR_q;

assign BitCounter_Lt4   = BitCounter<4;
assign BitCounter_Eq5   = BitCounter==5;
assign BitCounter_Eq32  = BitCounter==32;
assign BitCounter_Lt38  = BitCounter<38;
assign BitCounter_Lt65  = BitCounter<65;

`ifdef TRACE_ENABLED
  assign BitCounter_Lt40 = BitCounter<40;
`endif


// wire EnableCrcIn = ShiftDR & 
//                   ( (CHAIN_SELECTSelected                  & BitCounter_Lt4) |
//                     ((DEBUGSelected & RegisterScanChain)   & BitCounter_Lt38)| 
//                     ((DEBUGSelected & CpuDebugScanChain0)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & CpuDebugScanChain1)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & CpuDebugScanChain2)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & CpuDebugScanChain3)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & WishboneScanChain)   & BitCounter_Lt65)  
//                   );

wire EnableCrc   = ShiftDR & 
                  ( (CHAIN_SELECTSelected                  & BitCounter_Lt4) |
                    ((DEBUGSelected & RegisterScanChain)   & BitCounter_Lt38)| 
                    ((DEBUGSelected & CpuDebugScanChain0)  & BitCounter_Lt65)|
                    ((DEBUGSelected & CpuDebugScanChain1)  & BitCounter_Lt65)|
                    ((DEBUGSelected & CpuDebugScanChain2)  & BitCounter_Lt65)|
                    ((DEBUGSelected & CpuDebugScanChain3)  & BitCounter_Lt65)|
                    ((DEBUGSelected & WishboneScanChain)   & BitCounter_Lt65)  
                    `ifdef TRACE_ENABLED
                                                                             |
                    ((DEBUGSelected & TraceTestScanChain) & BitCounter_Lt40) 
                    `endif
                  );

// wire EnableCrcOut= ShiftDR & 
//                    (
//                     ((DEBUGSelected & RegisterScanChain)   & BitCounter_Lt38)| 
//                     ((DEBUGSelected & CpuDebugScanChain0)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & CpuDebugScanChain1)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & CpuDebugScanChain2)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & CpuDebugScanChain3)  & BitCounter_Lt65)|
//                     ((DEBUGSelected & WishboneScanChain)   & BitCounter_Lt65)  
//                     `ifdef TRACE_ENABLED
//                                                                             |
//                     ((DEBUGSelected & TraceTestScanChain) & BitCounter_Lt40) 
//                     `endif
//                    );

// Calculating crc for input data
//dbg_crc8_d1 crc1 (.data(tdi), .enable_crc(EnableCrcIn), .reset(AsyncResetCrc), .sync_rst_crc(SyncResetCrc), 
dbg_crc8_d1 crc1 (.data(tdi), .enable_crc(EnableCrc), .reset(AsyncResetCrc), .sync_rst_crc(SyncResetCrc), 
                  .crc_out(CalculatedCrcIn), .clk(tck));

// Calculating crc for output data
//dbg_crc8_d1 crc2 (.data(TDOData), .enable_crc(EnableCrcOut), .reset(AsyncResetCrc), .sync_rst_crc(SyncResetCrc), 
dbg_crc8_d1 crc2 (.data(TDOData), .enable_crc(EnableCrc), .reset(AsyncResetCrc), .sync_rst_crc(SyncResetCrc), 
                  .crc_out(CalculatedCrcOut), .clk(tck));


reg [3:0] crc_cnt;
always @ (posedge tck or posedge trst)
begin
  if (trst)
    crc_cnt <= 0;
  else if (Exit1DR)
    crc_cnt <=#Tp 0;
//  else if ((~EnableCrcIn) & ShiftDR)
  else if ((~EnableCrc) & ShiftDR)
    crc_cnt <=#Tp crc_cnt + 1'b1;
end


// Generating CrcMatch signal.
always @ (posedge tck or posedge trst)
begin
  if(trst)
    CrcMatch <=#Tp 1'b1;
  else if (SelectDRScan)
    CrcMatch <=#Tp 1'b1;
//  else if ((~EnableCrcIn) & ShiftDR)
  else if ((~EnableCrc) & ShiftDR)
    begin
      if (tdi != CalculatedCrcIn[crc_cnt])
        CrcMatch <=#Tp 1'b0;
    end
end


// Generating CrcMatch_q signal.
always @ (posedge tck or posedge trst)
begin
  CrcMatch_q <=#Tp CrcMatch;
end
                                                                                                                             

// Active chain
assign RegisterScanChain  = Chain == `REGISTER_SCAN_CHAIN;
assign CpuDebugScanChain0 = Chain == `CPU_DEBUG_CHAIN_0;
assign CpuDebugScanChain1 = Chain == `CPU_DEBUG_CHAIN_1;
assign CpuDebugScanChain2 = Chain == `CPU_DEBUG_CHAIN_2;
assign CpuDebugScanChain3 = Chain == `CPU_DEBUG_CHAIN_3;
assign WishboneScanChain  = Chain == `WISHBONE_SCAN_CHAIN;

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
  dbg_trace dbgTrace1(.Wp(wp_i), .Bp(bp_i), .DataIn(cpu_data_i), .OpSelect(opselect_trace), 
                      .LsStatus(lsstatus_i), .IStatus(istatus_i), .CpuStall_O(CpuStall_trace), 
                      .Mclk(cpu_clk_i), .Reset(wb_rst_i), .TraceChain(TraceChain), 
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
