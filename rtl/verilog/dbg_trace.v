//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_trace.v                                                 ////
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
// Revision 1.1.1.1  2001/05/18 06:35:06  mohor
// Initial release
//
//


`include "dbg_timescale.v"
`include "dbg_defines.v"

// module Trace
module dbg_trace (Wp, Bp, DataIn, OpSelect, LsStatus, IStatus, CpuStall, 
                  Mclk, Reset, TraceChain, ContinMode, TraceEnable, RecSelDepend,
                  WpTrigger, BpTrigger, LSSTrigger, ITrigger, TriggerOper, WpQualif, 
                  BpQualif, LSSQualif, IQualif, QualifOper, RecordPC_Wp, RecordLSEA_Wp, 
                  RecordLDATA_Wp, RecordSDATA_Wp, RecordReadSPR_Wp, RecordWriteSPR_Wp, 
                  RecordINSTR_Wp, RecordPC_Bp, RecordLSEA_Bp, RecordLDATA_Bp, 
                  RecordSDATA_Bp, RecordReadSPR_Bp, RecordWriteSPR_Bp, RecordINSTR_Bp, 
                  WpTriggerValid, BpTriggerValid, LSSTriggerValid, ITriggerValid, 
                  WpQualifValid, BpQualifValid, LSSQualifValid, IQualifValid, ReadBuffer,
                  WpStop, BpStop, LSSStop, IStop, StopOper, WpStopValid, BpStopValid, 
                  LSSStopValid, IStopValid 
                 );

parameter Tp = 1;


input [10:0] Wp;        // Watchpoints
input        Bp;        // Breakpoint
input [31:0] DataIn;    // Data from the RISC
input [3:0]  LsStatus;  // Load/Store status
input [1:0]  IStatus;   // Instruction status

input        Mclk;      // Master clock (RISC clock)
input        Reset;     // Reset
input        ReadBuffer;// Instruction for reading a sample from the Buffer

// from registers
input ContinMode;
input TraceEnable;
input RecSelDepend;

input [10:0] WpTrigger;
input        BpTrigger;
input [3:0]  LSSTrigger;
input [1:0]  ITrigger;
input [1:0]  TriggerOper;

input [10:0] WpQualif;
input        BpQualif;
input [3:0]  LSSQualif;
input [1:0]  IQualif;
input [1:0]  QualifOper;

input [10:0] WpStop;
input        BpStop;
input [3:0]  LSSStop;
input [1:0]  IStop;
input [1:0]  StopOper;

input [10:0] RecordPC_Wp;
input [10:0] RecordLSEA_Wp;
input [10:0] RecordLDATA_Wp;
input [10:0] RecordSDATA_Wp;
input [10:0] RecordReadSPR_Wp;
input [10:0] RecordWriteSPR_Wp;
input [10:0] RecordINSTR_Wp;

input RecordPC_Bp;
input RecordLSEA_Bp;
input RecordLDATA_Bp;
input RecordSDATA_Bp;
input RecordReadSPR_Bp;
input RecordWriteSPR_Bp;
input RecordINSTR_Bp;

input WpTriggerValid;
input BpTriggerValid;
input LSSTriggerValid;
input ITriggerValid;

input WpQualifValid;
input BpQualifValid;
input LSSQualifValid;
input IQualifValid;

input WpStopValid;
input BpStopValid;
input LSSStopValid;
input IStopValid;
// end: from registers


output [`OPSELECTWIDTH-1:0]  OpSelect; // Operation select (what kind of information is avaliable on the DataIn)
output        CpuStall;   // CPU stall (stalls the RISC)
output [39:0] TraceChain; // Scan shain from the trace module


reg [`TRACECOUNTERWIDTH:0] Counter;
reg [`TRACECOUNTERWIDTH-1:0] WritePointer;
reg [`TRACECOUNTERWIDTH-1:0] ReadPointer;
reg CpuStall;
reg CpuStall_q;
reg [`OPSELECTWIDTH-1:0] StallCounter;

reg [`TRACESAMPLEWIDTH-1:0] Buffer[0:`TRACEBUFFERLENGTH-1];

reg TriggerLatch;


/**********************************************************************************
*                                                                                 *
*   Generation of the trigger                                                     *
*                                                                                 *
**********************************************************************************/
wire TempWpTrigger = |(Wp[10:0] & WpTrigger[10:0]);
wire TempBpTrigger = Bp & BpTrigger;
wire TempLSSTrigger = LsStatus[3:0] == LSSTrigger[3:0];
wire TempITrigger = IStatus[1:0] == ITrigger[1:0];

wire TempTriggerAND =  (  (TempWpTrigger  | ~WpTriggerValid)
                        & (TempBpTrigger  | ~BpTriggerValid) 
                        & (TempLSSTrigger | ~LSSTriggerValid) 
                        & (TempITrigger   | ~ITriggerValid)
                       ) 
                       & (WpTriggerValid | BpTriggerValid | LSSTriggerValid | ITriggerValid);

wire TempTriggerOR =   (  (TempWpTrigger  &  WpTriggerValid)
                        | (TempBpTrigger  &  BpTriggerValid) 
                        | (TempLSSTrigger &  LSSTriggerValid) 
                        | (TempITrigger   &  ITriggerValid)
                       );

wire Trigger = TraceEnable & (~TriggerOper[1]?  1 :                               // any
                               TriggerOper[0]?  TempTriggerAND : TempTriggerOR    // AND : OR
                             );

/**********************************************************************************
*                                                                                 *
*   Generation of the qualifier                                                   *
*                                                                                 *
**********************************************************************************/
wire TempWpQualifier = |(Wp[10:0] & WpQualif[10:0]);
wire TempBpQualifier = Bp & BpQualif;
wire TempLSSQualifier = LsStatus[3:0] == LSSQualif[3:0];
wire TempIQualifier = IStatus[1:0] == IQualif[1:0];

wire TempQualifierAND =  (  (TempWpQualifier  | ~WpQualifValid)
                          & (TempBpQualifier  | ~BpQualifValid) 
                          & (TempLSSQualifier | ~LSSQualifValid) 
                          & (TempIQualifier   | ~IQualifValid)
                         ) 
                         & (WpQualifValid | BpQualifValid | LSSQualifValid | IQualifValid);

wire TempQualifierOR =   (  (TempWpQualifier  &  WpQualifValid)
                          | (TempBpQualifier  &  BpQualifValid) 
                          | (TempLSSQualifier &  LSSQualifValid) 
                          | (TempIQualifier   &  IQualifValid)
                         );


wire Stop;
wire Qualifier = TraceEnable & ~Stop & (~QualifOper[1]? 1 :                                   // any
                                         QualifOper[0]? TempQualifierAND  :  TempQualifierOR  // AND : OR
                                       );

/**********************************************************************************
*                                                                                 *
*   Generation of the stop signal                                                 *
*                                                                                 *
**********************************************************************************/
wire TempWpStop = |(Wp[10:0] & WpStop[10:0]);
wire TempBpStop = Bp & BpStop;
wire TempLSSStop = LsStatus[3:0] == LSSStop[3:0];
wire TempIStop = IStatus[1:0] == IStop[1:0];

wire TempStopAND =  (  (TempWpStop  | ~WpStopValid)
                          & (TempBpStop  | ~BpStopValid) 
                          & (TempLSSStop | ~LSSStopValid) 
                          & (TempIStop   | ~IStopValid)
                         ) 
                         & (WpStopValid | BpStopValid | LSSStopValid | IStopValid);

wire TempStopOR =   (  (TempWpStop  &  WpStopValid)
                          | (TempBpStop  &  BpStopValid) 
                          | (TempLSSStop &  LSSStopValid) 
                          | (TempIStop   &  IStopValid)
                         );


assign Stop = TraceEnable & (~StopOper[1]? 0 :                         // nothing
                              StopOper[0]? TempStopAND  :  TempStopOR  // AND : OR
                            );



/**********************************************************************************
*                                                                                 *
*   Generation of the TriggerLatch                                                *
*                                                                                 *
**********************************************************************************/
wire Reset_TriggerLatch = Reset | TriggerLatch & ~TraceEnable;
always @(posedge Mclk or posedge Reset_TriggerLatch)
begin
  if(Reset_TriggerLatch)
    TriggerLatch<=#Tp 0;
  else
  if(Trigger)
    TriggerLatch<=#Tp 1;
end


/**********************************************************************************
*                                                                                 *
*   CpuStall, counter and pointers generation                                     *
*                                                                                 *
**********************************************************************************/
reg BufferFullDetected;
reg [`OPSELECTIONCOUNTER-1:0] RecEnable;

wire BufferFull = Counter[`TRACECOUNTERWIDTH:0]==`TRACEBUFFERLENGTH;
wire BufferEmpty = Counter[`TRACECOUNTERWIDTH:0]==0;
wire IncrementCounter = CpuStall_q & ~(BufferFull | BufferFullDetected) & Qualifier & RecEnable[StallCounter];
wire IncrementPointer = CpuStall_q & (~BufferFull | ContinMode) & Qualifier & RecEnable[StallCounter];

wire WriteSample = IncrementPointer;

wire Decrement = ReadBuffer & ~BufferEmpty & (~ContinMode | ContinMode & ~TraceEnable);
wire CounterEn = IncrementCounter ^ Decrement;

wire ResetCpuStall;
wire ResetStallCounter;
reg BufferFull_q;
reg BufferFull_2q;

reg Qualifier_mclk;

always @(posedge Mclk)
begin
  Qualifier_mclk<=#Tp Qualifier;
  BufferFull_q<=#Tp BufferFull;
  BufferFull_2q<=#Tp BufferFull_q;
  CpuStall_q <=#Tp CpuStall;
end


wire AsyncSetCpuStall = Qualifier & ~Qualifier_mclk & TriggerLatch | Qualifier_mclk & Trigger & ~TriggerLatch | 
                        Qualifier & Trigger & ~Qualifier_mclk & ~TriggerLatch;


wire SyncSetCpuStall = Qualifier_mclk & TriggerLatch &
                       ( 
                        (~ContinMode & ~BufferFull & ~BufferFull_q & StallCounter==`OPSELECTIONCOUNTER-1) |
                        (~ContinMode & ~BufferFull_q & BufferFull_2q & StallCounter==0)                   |
                        ( ContinMode & StallCounter==`OPSELECTIONCOUNTER-1)
                       );

assign ResetCpuStall = ( 
                        (~ContinMode & ~BufferFull & ~BufferFull_q & StallCounter==`OPSELECTIONCOUNTER-2) |
                        (~ContinMode &  ~BufferFull & BufferFull_q & StallCounter==`OPSELECTIONCOUNTER-1) |
                        ( ContinMode & StallCounter==`OPSELECTIONCOUNTER-2)
                       ) | Reset;


always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    Counter<=#Tp 0;
  else
  if(CounterEn)
    if(IncrementCounter)
      Counter[`TRACECOUNTERWIDTH:0]<=#Tp Counter[`TRACECOUNTERWIDTH:0] + 1;
    else
      Counter[`TRACECOUNTERWIDTH:0]<=#Tp Counter[`TRACECOUNTERWIDTH:0] - 1;      
end


always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    begin
      WritePointer<=#Tp 0;
      ReadPointer<=#Tp 0;
    end
  else
    begin
      if(IncrementPointer)
        WritePointer[`TRACECOUNTERWIDTH-1:0]<=#Tp WritePointer[`TRACECOUNTERWIDTH-1:0] + 1;
      // else igor !!! Probably else is missing here. Check it.
      if(Decrement & ~ContinMode | Decrement & ContinMode & ~TraceEnable)
        ReadPointer[`TRACECOUNTERWIDTH-1:0]<=#Tp ReadPointer[`TRACECOUNTERWIDTH-1:0] + 1;
      else
      if(ContinMode & IncrementPointer & (BufferFull | BufferFullDetected))
        ReadPointer[`TRACECOUNTERWIDTH-1:0]<=#Tp WritePointer[`TRACECOUNTERWIDTH-1:0] + 1;
    end
end

always @(posedge Mclk)
begin
  if(~TraceEnable)
    BufferFullDetected<=#Tp 0;
  else
  if(ContinMode & BufferFull)
    BufferFullDetected<=#Tp 1;
end


always @(posedge Mclk or posedge AsyncSetCpuStall)
begin
  if(AsyncSetCpuStall)
    CpuStall<=#Tp 1;
  else
  if(SyncSetCpuStall)
    CpuStall<=#Tp 1;
  else
  if(ResetCpuStall)
    CpuStall<=#Tp 0;
end


always @(posedge Mclk)
begin
  if(ResetStallCounter)
    StallCounter<=#Tp 0;
  else
  if(CpuStall_q & (~BufferFull | ContinMode))
    StallCounter<=#Tp StallCounter+1;
end

assign ResetStallCounter = StallCounter==(`OPSELECTIONCOUNTER-1) & ~BufferFull | Reset;


/**********************************************************************************
*                                                                                 *
*   Valid status                                                                  *
*                                                                                 *
**********************************************************************************/
wire Valid = ~BufferEmpty;


/**********************************************************************************
*                                                                                 *
*   Writing and reading the sample to/from the buffer                             *
*                                                                                 *
**********************************************************************************/
always @ (posedge Mclk)
begin
  if(WriteSample)
    Buffer[WritePointer[`TRACECOUNTERWIDTH-1:0]]<={DataIn, 1'b0, OpSelect[`OPSELECTWIDTH-1:0]};
end

assign TraceChain = {Buffer[ReadPointer], 3'h0, Valid};
  


/**********************************************************************************
*                                                                                 *
*   Operation select (to select which kind of data appears on the DATAIN lines)   *
*                                                                                 *
**********************************************************************************/
assign OpSelect[`OPSELECTWIDTH-1:0] = StallCounter[`OPSELECTWIDTH-1:0];



/**********************************************************************************
*                                                                                 *
*   Selecting which parts are going to be recorded as part of the sample          *
*                                                                                 *
**********************************************************************************/
always @(posedge Mclk or posedge Reset)
begin
  if(Reset)
    RecEnable<=#Tp 0;
  else
  if(CpuStall)
    begin
      RecEnable<=#Tp {1'b0, RecordINSTR_Wp[0],  RecordWriteSPR_Wp[0],  RecordReadSPR_Wp[0],  RecordSDATA_Wp[0],  RecordLDATA_Wp[0],  RecordLSEA_Wp[0],  RecordPC_Wp[0]} & {`OPSELECTIONCOUNTER{Wp[0]}}   |
                     {1'b0, RecordINSTR_Wp[1],  RecordWriteSPR_Wp[1],  RecordReadSPR_Wp[1],  RecordSDATA_Wp[1],  RecordLDATA_Wp[1],  RecordLSEA_Wp[1],  RecordPC_Wp[1]} & {`OPSELECTIONCOUNTER{Wp[1]}}   |
                     {1'b0, RecordINSTR_Wp[2],  RecordWriteSPR_Wp[2],  RecordReadSPR_Wp[2],  RecordSDATA_Wp[2],  RecordLDATA_Wp[2],  RecordLSEA_Wp[2],  RecordPC_Wp[2]} & {`OPSELECTIONCOUNTER{Wp[2]}}   |
                     {1'b0, RecordINSTR_Wp[3],  RecordWriteSPR_Wp[3],  RecordReadSPR_Wp[3],  RecordSDATA_Wp[3],  RecordLDATA_Wp[3],  RecordLSEA_Wp[3],  RecordPC_Wp[3]} & {`OPSELECTIONCOUNTER{Wp[3]}}   |
                     {1'b0, RecordINSTR_Wp[4],  RecordWriteSPR_Wp[4],  RecordReadSPR_Wp[4],  RecordSDATA_Wp[4],  RecordLDATA_Wp[4],  RecordLSEA_Wp[4],  RecordPC_Wp[4]} & {`OPSELECTIONCOUNTER{Wp[4]}}   |
                     {1'b0, RecordINSTR_Wp[5],  RecordWriteSPR_Wp[5],  RecordReadSPR_Wp[5],  RecordSDATA_Wp[5],  RecordLDATA_Wp[5],  RecordLSEA_Wp[5],  RecordPC_Wp[5]} & {`OPSELECTIONCOUNTER{Wp[5]}}   |
                     {1'b0, RecordINSTR_Wp[6],  RecordWriteSPR_Wp[6],  RecordReadSPR_Wp[6],  RecordSDATA_Wp[6],  RecordLDATA_Wp[6],  RecordLSEA_Wp[6],  RecordPC_Wp[6]} & {`OPSELECTIONCOUNTER{Wp[6]}}   |
                     {1'b0, RecordINSTR_Wp[7],  RecordWriteSPR_Wp[7],  RecordReadSPR_Wp[7],  RecordSDATA_Wp[7],  RecordLDATA_Wp[7],  RecordLSEA_Wp[7],  RecordPC_Wp[7]} & {`OPSELECTIONCOUNTER{Wp[7]}}   |
                     {1'b0, RecordINSTR_Wp[8],  RecordWriteSPR_Wp[8],  RecordReadSPR_Wp[8],  RecordSDATA_Wp[8],  RecordLDATA_Wp[8],  RecordLSEA_Wp[8],  RecordPC_Wp[8]} & {`OPSELECTIONCOUNTER{Wp[8]}}   |
                     {1'b0, RecordINSTR_Wp[9],  RecordWriteSPR_Wp[9],  RecordReadSPR_Wp[9],  RecordSDATA_Wp[9],  RecordLDATA_Wp[9],  RecordLSEA_Wp[9],  RecordPC_Wp[9]} & {`OPSELECTIONCOUNTER{Wp[9]}}   |
                     {1'b0, RecordINSTR_Wp[10], RecordWriteSPR_Wp[10], RecordReadSPR_Wp[10], RecordSDATA_Wp[10], RecordLDATA_Wp[10], RecordLSEA_Wp[10], RecordPC_Wp[10]}& {`OPSELECTIONCOUNTER{Wp[10]}}  |
                     {1'b0, RecordINSTR_Bp,     RecordWriteSPR_Bp,     RecordReadSPR_Bp,     RecordSDATA_Bp,     RecordLDATA_Bp,     RecordLSEA_Bp,     RecordPC_Bp}    & {`OPSELECTIONCOUNTER{Bp}};
    end
end


endmodule // Trace