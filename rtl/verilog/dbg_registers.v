//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_registers.v                                             ////
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
// Revision 1.1.1.1  2001/05/18 06:35:10  mohor
// Initial release
//
//

`include "dbg_timescale.v"
`include "dbg_defines.v"

module dbg_registers(DataIn, DataOut, Address, RW, Access, Clk, Reset
                     `ifdef TRACE_ENABLED
                     , 
                     ContinMode, 
                     TraceEnable, RecSelDepend, WpTrigger, BpTrigger, LSSTrigger, 
                     ITrigger, TriggerOper, WpQualif, BpQualif, LSSQualif, IQualif, 
                     QualifOper, RecordPC_Wp, RecordLSEA_Wp, RecordLDATA_Wp, 
                     RecordSDATA_Wp, RecordReadSPR_Wp, RecordReadSPR_Bp, 
                     RecordWriteSPR_Wp, RecordWriteSPR_Bp, RecordINSTR_Wp, RecordPC_Bp, 
                     RecordLSEA_Bp, RecordLDATA_Bp, RecordSDATA_Bp, RecordINSTR_Bp, 
                     WpTriggerValid, BpTriggerValid, LSSTriggerValid, ITriggerValid, 
                     WpQualifValid, BpQualifValid, LSSQualifValid, IQualifValid,
                     WpStop, BpStop, LSSStop, IStop, StopOper, WpStopValid, BpStopValid, 
                     LSSStopValid, IStopValid 
                     `endif
                    );

parameter Tp = 1;

input [31:0] DataIn;
input [4:0] Address;

input RW;
input Access;
input Clk;
input Reset;

output [31:0] DataOut;
reg    [31:0] DataOut;

`ifdef TRACE_ENABLED
  output RecSelDepend;
  output ContinMode;
  output TraceEnable;
  
  output [10:0] WpTrigger;
  output        BpTrigger;
  output [3:0]  LSSTrigger;
  output [1:0]  ITrigger;
  output [1:0]  TriggerOper;
  
  output        WpTriggerValid;
  output        BpTriggerValid;
  output        LSSTriggerValid;
  output        ITriggerValid;
  
  output [10:0] WpQualif;
  output        BpQualif;
  output [3:0]  LSSQualif;
  output [1:0]  IQualif;
  output [1:0]  QualifOper;
  
  output        WpQualifValid;
  output        BpQualifValid;
  output        LSSQualifValid;
  output        IQualifValid;
  
  output [10:0] WpStop;
  output        BpStop;
  output [3:0]  LSSStop;
  output [1:0]  IStop;
  output [1:0]  StopOper;
  
  output WpStopValid;
  output BpStopValid;
  output LSSStopValid;
  output IStopValid;
  
  output [10:0] RecordPC_Wp;
  output [10:0] RecordLSEA_Wp;
  output [10:0] RecordLDATA_Wp;
  output [10:0] RecordSDATA_Wp;
  output [10:0] RecordReadSPR_Wp;
  output [10:0] RecordWriteSPR_Wp;
  output [10:0] RecordINSTR_Wp;
  
  
  output RecordPC_Bp;
  output RecordLSEA_Bp;
  output RecordLDATA_Bp;
  output RecordSDATA_Bp;
  output RecordReadSPR_Bp;
  output RecordWriteSPR_Bp;
  output RecordINSTR_Bp;
`endif

`ifdef TRACE_ENABLED
  wire MODER_Acc =   (Address == `MODER_ADR)   & Access;
  wire TSEL_Acc =    (Address == `TSEL_ADR)    & Access;
  wire QSEL_Acc =    (Address == `QSEL_ADR)    & Access;
  wire SSEL_Acc =    (Address == `SSEL_ADR)    & Access;
  wire RECWP0_Acc =  (Address == `RECWP0_ADR)  & Access;
  wire RECWP1_Acc =  (Address == `RECWP1_ADR)  & Access;
  wire RECWP2_Acc =  (Address == `RECWP2_ADR)  & Access;
  wire RECWP3_Acc =  (Address == `RECWP3_ADR)  & Access;
  wire RECWP4_Acc =  (Address == `RECWP4_ADR)  & Access;
  wire RECWP5_Acc =  (Address == `RECWP5_ADR)  & Access;
  wire RECWP6_Acc =  (Address == `RECWP6_ADR)  & Access;
  wire RECWP7_Acc =  (Address == `RECWP7_ADR)  & Access;
  wire RECWP8_Acc =  (Address == `RECWP8_ADR)  & Access;
  wire RECWP9_Acc =  (Address == `RECWP9_ADR)  & Access;
  wire RECWP10_Acc = (Address == `RECWP10_ADR) & Access;
  wire RECBP0_Acc =  (Address == `RECBP0_ADR)  & Access;
  
  wire MODER_Wr =   MODER_Acc   &  RW;
  wire TSEL_Wr =    TSEL_Acc    &  RW;
  wire QSEL_Wr =    QSEL_Acc    &  RW;
  wire SSEL_Wr =    SSEL_Acc    &  RW;
  wire RECWP0_Wr =  RECWP0_Acc  &  RW;
  wire RECWP1_Wr =  RECWP1_Acc  &  RW;
  wire RECWP2_Wr =  RECWP2_Acc  &  RW;
  wire RECWP3_Wr =  RECWP3_Acc  &  RW;
  wire RECWP4_Wr =  RECWP4_Acc  &  RW;
  wire RECWP5_Wr =  RECWP5_Acc  &  RW;
  wire RECWP6_Wr =  RECWP6_Acc  &  RW;
  wire RECWP7_Wr =  RECWP7_Acc  &  RW;
  wire RECWP8_Wr =  RECWP8_Acc  &  RW;
  wire RECWP9_Wr =  RECWP9_Acc  &  RW;
  wire RECWP10_Wr = RECWP10_Acc &  RW;
  wire RECBP0_Wr =  RECBP0_Acc  &  RW;
  
  wire MODER_Rd =   MODER_Acc   &  ~RW;
  wire TSEL_Rd =    TSEL_Acc    &  ~RW;
  wire QSEL_Rd =    QSEL_Acc    &  ~RW;
  wire SSEL_Rd =    SSEL_Acc    &  ~RW;
  wire RECWP0_Rd =  RECWP0_Acc  &  ~RW;
  wire RECWP1_Rd =  RECWP1_Acc  &  ~RW;
  wire RECWP2_Rd =  RECWP2_Acc  &  ~RW;
  wire RECWP3_Rd =  RECWP3_Acc  &  ~RW;
  wire RECWP4_Rd =  RECWP4_Acc  &  ~RW;
  wire RECWP5_Rd =  RECWP5_Acc  &  ~RW;
  wire RECWP6_Rd =  RECWP6_Acc  &  ~RW;
  wire RECWP7_Rd =  RECWP7_Acc  &  ~RW;
  wire RECWP8_Rd =  RECWP8_Acc  &  ~RW;
  wire RECWP9_Rd =  RECWP9_Acc  &  ~RW;
  wire RECWP10_Rd = RECWP10_Acc &  ~RW;
  wire RECBP0_Rd =  RECBP0_Acc  &  ~RW;
`endif


`ifdef TRACE_ENABLED
  wire [31:0] MODEROut;
  wire [31:0] TSELOut;
  wire [31:0] QSELOut;
  wire [31:0] SSELOut;
  
  wire [31:0] RECWP0Out;
  wire [31:0] RECWP1Out;
  wire [31:0] RECWP2Out;
  wire [31:0] RECWP3Out;
  wire [31:0] RECWP4Out;
  wire [31:0] RECWP5Out;
  wire [31:0] RECWP6Out;
  wire [31:0] RECWP7Out;
  wire [31:0] RECWP8Out;
  wire [31:0] RECWP9Out;
  wire [31:0] RECWP10Out;
  wire [31:0] RECBP0Out;
`endif


`ifdef TRACE_ENABLED
  dbg_register #(32) MODER  (.DataIn(DataIn), .DataOut(MODEROut),   .Write(MODER_Wr),   .Clk(Clk), .Reset(Reset), .Default(`MODER_DEF));
  dbg_register #(32) TSEL   (.DataIn(DataIn), .DataOut(TSELOut),    .Write(TSEL_Wr),    .Clk(Clk), .Reset(Reset), .Default(`TSEL_DEF));
  dbg_register #(32) QSEL   (.DataIn(DataIn), .DataOut(QSELOut),    .Write(QSEL_Wr),    .Clk(Clk), .Reset(Reset), .Default(`QSEL_DEF));
  dbg_register #(32) SSEL   (.DataIn(DataIn), .DataOut(SSELOut),    .Write(SSEL_Wr),    .Clk(Clk), .Reset(Reset), .Default(`SSEL_DEF));
  
  dbg_register #(32) RECWP0 (.DataIn(DataIn), .DataOut(RECWP0Out),  .Write(RECWP0_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP0_DEF));
  dbg_register #(32) RECWP1 (.DataIn(DataIn), .DataOut(RECWP1Out),  .Write(RECWP1_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP1_DEF));
  dbg_register #(32) RECWP2 (.DataIn(DataIn), .DataOut(RECWP2Out),  .Write(RECWP2_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP2_DEF));
  dbg_register #(32) RECWP3 (.DataIn(DataIn), .DataOut(RECWP3Out),  .Write(RECWP3_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP3_DEF));
  dbg_register #(32) RECWP4 (.DataIn(DataIn), .DataOut(RECWP4Out),  .Write(RECWP4_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP4_DEF));
  dbg_register #(32) RECWP5 (.DataIn(DataIn), .DataOut(RECWP5Out),  .Write(RECWP5_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP5_DEF));
  dbg_register #(32) RECWP6 (.DataIn(DataIn), .DataOut(RECWP6Out),  .Write(RECWP6_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP6_DEF));
  dbg_register #(32) RECWP7 (.DataIn(DataIn), .DataOut(RECWP7Out),  .Write(RECWP7_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP7_DEF));
  dbg_register #(32) RECWP8 (.DataIn(DataIn), .DataOut(RECWP8Out),  .Write(RECWP8_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP8_DEF));
  dbg_register #(32) RECWP9 (.DataIn(DataIn), .DataOut(RECWP9Out),  .Write(RECWP9_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECWP9_DEF));
  dbg_register #(32) RECWP10(.DataIn(DataIn), .DataOut(RECWP10Out), .Write(RECWP10_Wr), .Clk(Clk), .Reset(Reset), .Default(`RECWP10_DEF));
  dbg_register #(32) RECBP0 (.DataIn(DataIn), .DataOut(RECBP0Out),  .Write(RECBP0_Wr),  .Clk(Clk), .Reset(Reset), .Default(`RECBP0_DEF));
`endif


`ifdef TRACE_ENABLED
always @ (posedge Clk)
begin
  if(MODER_Rd)    DataOut<= #Tp MODEROut;
  else
  if(TSEL_Rd)     DataOut<= #Tp TSELOut;
  else
  if(QSEL_Rd)     DataOut<= #Tp QSELOut;
  else
  if(SSEL_Rd)     DataOut<= #Tp SSELOut;
  else
  if(RECWP0_Rd)   DataOut<= #Tp RECWP0Out;
  else
  if(RECWP1_Rd)   DataOut<= #Tp RECWP1Out;
  else
  if(RECWP2_Rd)   DataOut<= #Tp RECWP2Out;
  else
  if(RECWP3_Rd)   DataOut<= #Tp RECWP3Out;
  else
  if(RECWP4_Rd)   DataOut<= #Tp RECWP4Out;
  else
  if(RECWP5_Rd)   DataOut<= #Tp RECWP5Out;
  else
  if(RECWP6_Rd)   DataOut<= #Tp RECWP6Out;
  else
  if(RECWP7_Rd)   DataOut<= #Tp RECWP7Out;
  else
  if(RECWP8_Rd)   DataOut<= #Tp RECWP8Out;
  else
  if(RECWP9_Rd)   DataOut<= #Tp RECWP9Out;
  else
  if(RECWP10_Rd)  DataOut<= #Tp RECWP10Out;
  else
  if(RECBP0_Rd)   DataOut<= #Tp RECBP0Out;
  else            DataOut<= #Tp 'h0;
end
`endif

`ifdef TRACE_ENABLED
  assign ContinMode = MODEROut[0];
  assign TraceEnable = MODEROut[1];
  assign RecSelDepend = MODEROut[2];
  
  assign WpTrigger[10:0]   = TSELOut[10:0];
  assign WpTriggerValid    = TSELOut[11];
  assign BpTrigger         = TSELOut[12];
  assign BpTriggerValid    = TSELOut[13];
  assign LSSTrigger[3:0]   = TSELOut[19:16];
  assign LSSTriggerValid   = TSELOut[20];
  assign ITrigger[1:0]     = TSELOut[22:21];
  assign ITriggerValid     = TSELOut[23];
  assign TriggerOper[1:0]  = TSELOut[31:30];
  
  assign WpQualif[10:0]    = QSELOut[10:0];
  assign WpQualifValid     = QSELOut[11];
  assign BpQualif          = QSELOut[12];
  assign BpQualifValid     = QSELOut[13];
  assign LSSQualif[3:0]    = QSELOut[19:16];
  assign LSSQualifValid    = QSELOut[20];
  assign IQualif[1:0]      = QSELOut[22:21];
  assign IQualifValid      = QSELOut[23];
  assign QualifOper[1:0]   = QSELOut[31:30];
  
  assign WpStop[10:0]    = SSELOut[10:0];
  assign WpStopValid     = SSELOut[11];
  assign BpStop          = SSELOut[12];
  assign BpStopValid     = SSELOut[13];
  assign LSSStop[3:0]    = SSELOut[19:16];
  assign LSSStopValid    = SSELOut[20];
  assign IStop[1:0]      = SSELOut[22:21];
  assign IStopValid      = SSELOut[23];
  assign StopOper[1:0]   = SSELOut[31:30];
  
  
  assign RecordPC_Wp[0]        = RECWP0Out[0];
  assign RecordLSEA_Wp[0]      = RECWP0Out[1];
  assign RecordLDATA_Wp[0]     = RECWP0Out[2];
  assign RecordSDATA_Wp[0]     = RECWP0Out[3];
  assign RecordReadSPR_Wp[0]   = RECWP0Out[4];
  assign RecordWriteSPR_Wp[0]  = RECWP0Out[5];
  assign RecordINSTR_Wp[0]     = RECWP0Out[6];
  
  
  assign RecordPC_Wp[1]        = RECWP1Out[0];
  assign RecordLSEA_Wp[1]      = RECWP1Out[1];
  assign RecordLDATA_Wp[1]     = RECWP1Out[2];
  assign RecordSDATA_Wp[1]     = RECWP1Out[3];
  assign RecordReadSPR_Wp[1]   = RECWP1Out[4];
  assign RecordWriteSPR_Wp[1]  = RECWP1Out[5];
  assign RecordINSTR_Wp[1]     = RECWP1Out[6];
  
  
  assign RecordPC_Wp[2]        = RECWP2Out[0];
  assign RecordLSEA_Wp[2]      = RECWP2Out[1];
  assign RecordLDATA_Wp[2]     = RECWP2Out[2];
  assign RecordSDATA_Wp[2]     = RECWP2Out[3];
  assign RecordReadSPR_Wp[2]   = RECWP2Out[4];
  assign RecordWriteSPR_Wp[2]  = RECWP2Out[5];
  assign RecordINSTR_Wp[2]     = RECWP2Out[6];
  
  
  assign RecordPC_Wp[3]        = RECWP3Out[0];
  assign RecordLSEA_Wp[3]      = RECWP3Out[1];
  assign RecordLDATA_Wp[3]     = RECWP3Out[2];
  assign RecordSDATA_Wp[3]     = RECWP3Out[3];
  assign RecordReadSPR_Wp[3]   = RECWP3Out[4];
  assign RecordWriteSPR_Wp[3]  = RECWP3Out[5];
  assign RecordINSTR_Wp[3]     = RECWP3Out[6];
  
  
  assign RecordPC_Wp[4]        = RECWP4Out[0];
  assign RecordLSEA_Wp[4]      = RECWP4Out[1];
  assign RecordLDATA_Wp[4]     = RECWP4Out[2];
  assign RecordSDATA_Wp[4]     = RECWP4Out[3];
  assign RecordReadSPR_Wp[4]   = RECWP4Out[4];
  assign RecordWriteSPR_Wp[4]  = RECWP4Out[5];
  assign RecordINSTR_Wp[4]     = RECWP4Out[6];
  
  
  assign RecordPC_Wp[5]        = RECWP5Out[0];
  assign RecordLSEA_Wp[5]      = RECWP5Out[1];
  assign RecordLDATA_Wp[5]     = RECWP5Out[2];
  assign RecordSDATA_Wp[5]     = RECWP5Out[3];
  assign RecordReadSPR_Wp[5]   = RECWP5Out[4];
  assign RecordWriteSPR_Wp[5]  = RECWP5Out[5];
  assign RecordINSTR_Wp[5]     = RECWP5Out[6];
  
  
  assign RecordPC_Wp[6]        = RECWP6Out[0];
  assign RecordLSEA_Wp[6]      = RECWP6Out[1];
  assign RecordLDATA_Wp[6]     = RECWP6Out[2];
  assign RecordSDATA_Wp[6]     = RECWP6Out[3];
  assign RecordReadSPR_Wp[6]   = RECWP6Out[4];
  assign RecordWriteSPR_Wp[6]  = RECWP6Out[5];
  assign RecordINSTR_Wp[6]     = RECWP6Out[6];
  
  
  assign RecordPC_Wp[7]        = RECWP7Out[0];
  assign RecordLSEA_Wp[7]      = RECWP7Out[1];
  assign RecordLDATA_Wp[7]     = RECWP7Out[2];
  assign RecordSDATA_Wp[7]     = RECWP7Out[3];
  assign RecordReadSPR_Wp[7]   = RECWP7Out[4];
  assign RecordWriteSPR_Wp[7]  = RECWP7Out[5];
  assign RecordINSTR_Wp[7]     = RECWP7Out[6];
  
  
  assign RecordPC_Wp[8]        = RECWP8Out[0];
  assign RecordLSEA_Wp[8]      = RECWP8Out[1];
  assign RecordLDATA_Wp[8]     = RECWP8Out[2];
  assign RecordSDATA_Wp[8]     = RECWP8Out[3];
  assign RecordReadSPR_Wp[8]   = RECWP8Out[4];
  assign RecordWriteSPR_Wp[8]  = RECWP8Out[5];
  assign RecordINSTR_Wp[8]     = RECWP8Out[6];
  
  
  assign RecordPC_Wp[9]        = RECWP9Out[0];
  assign RecordLSEA_Wp[9]      = RECWP9Out[1];
  assign RecordLDATA_Wp[9]     = RECWP9Out[2];
  assign RecordSDATA_Wp[9]     = RECWP9Out[3];
  assign RecordReadSPR_Wp[9]   = RECWP9Out[4];
  assign RecordWriteSPR_Wp[9]  = RECWP9Out[5];
  assign RecordINSTR_Wp[9]     = RECWP9Out[6];
  
  
  assign RecordPC_Wp[10]       = RECWP10Out[0];
  assign RecordLSEA_Wp[10]     = RECWP10Out[1];
  assign RecordLDATA_Wp[10]    = RECWP10Out[2];
  assign RecordSDATA_Wp[10]    = RECWP10Out[3];
  assign RecordReadSPR_Wp[10]  = RECWP10Out[4];
  assign RecordWriteSPR_Wp[10] = RECWP10Out[5];
  assign RecordINSTR_Wp[10]    = RECWP10Out[6];
  
  
  assign RecordPC_Bp         = RECBP0Out[0];
  assign RecordLSEA_Bp       = RECBP0Out[1];
  assign RecordLDATA_Bp      = RECBP0Out[2];
  assign RecordSDATA_Bp      = RECBP0Out[3];
  assign RecordReadSPR_Bp    = RECBP0Out[4];
  assign RecordWriteSPR_Bp   = RECBP0Out[5];
  assign RecordINSTR_Bp      = RECBP0Out[6];
`endif


endmodule
