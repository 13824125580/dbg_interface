  // Potrebno narediti STALL procesorja pri read-u in write-u

  // Potrebno racunati crc kadar je izbran trace. Ko delamo read iz bufferja
  // Dodati registre RISCOP


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
module dbg_top(P_TMS, P_TCK, P_TRST, P_TDI, P_TDO, P_PowerONReset, Mclk, RISC_ADDR, RISC_DATA_IN,
               RISC_DATA_OUT, RISC_CS, RISC_RW, Wp, Bp, OpSelect, LsStatus, IStatus
              );

parameter Tp = 1;

input P_TMS, P_TCK;
input P_TRST, P_TDI;
input P_PowerONReset;
input Mclk;           // High speed clock (RISC clock)
input [31:0] RISC_DATA_IN;
input [10:0] Wp;
input Bp;
input [3:0] LsStatus;
input [1:0] IStatus;

output P_TDO;
output [31:0] RISC_ADDR;
output [31:0] RISC_DATA_OUT;
output [`OPSELECTWIDTH-1:0] OpSelect;
output RISC_CS;              // CS for accessing RISC registers
output RISC_RW;              // RW for accessing RISC registers

reg    [31:0] RISC_ADDR;
reg    [31:0] ADDR;
reg    [31:0] RISC_DATA_OUT;
reg    [31:0] DataOut;

wire TCK = P_TCK;
wire TMS = P_TMS;
wire TDI = P_TDI;
wire TRST= ~P_TRST;                   // P_TRST is active low
wire PowerONReset = ~P_PowerONReset;  // PowerOnReset is active low

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

reg [`CHAIN_ID_LENGTH-1:0] Chain;         // Selected chain
reg [31:0] RISC_DATAINLatch;              // Data from DataIn is latched one Mclk clock cycle after RISC register is
                                          // accessed for reading
reg [31:0] RegisterReadLatch;             // Data when reading register is latched one TCK clock after the register is read.

wire[31:0] RegDataIn;                     // Data from registers (read data)
reg        RegAccessTck;                  // Indicates access to the registers (read or write)
reg        RISCAccessTck;                 // Indicates access to the RISC (read or write)

wire[`CRC_LENGTH-1:0] CalculatedCrcOut;   // CRC calculated in this module. This CRC is apended at the end of the TDO.

reg [7:0] BitCounter;                     // Counting bits in the ShiftDR and Exit1DR stages
reg RW;                                   // Read/Write bit

reg  CrcMatch;                            // The crc that is shifted in and the internaly calculated crc are equal




`ifdef TRACE_ENABLED
  wire [39:0] TraceChain;                   // Chain that comes from trace module
  reg  ReadBuffer_Tck;                      // Command for incrementing the trace read pointer (synchr with TCK)
  reg  ReadBuffer_Mclk;                     // Command for incrementing the trace read pointer (synchr with MClk)
  reg  DisableReadBuffer_Mclk;              // Incrementing trace read buffer can be active for one MClk clock. Then it is disabled.

  // Outputs from registers
  wire ContinMode;
  wire TraceEnable;
  wire RecSelDepend;
  
  wire [10:0] WpTrigger;
  wire        BpTrigger;
  wire [3:0]  LSSTrigger;
  wire [1:0]  ITrigger;
  wire [1:0]  TriggerOper;
  
  wire        WpTriggerValid;
  wire        BpTriggerValid;
  wire        LSSTriggerValid;
  wire        ITriggerValid;
  
  wire [10:0] WpQualif;
  wire        BpQualif;
  wire [3:0]  LSSQualif;
  wire [1:0]  IQualif;
  wire [1:0]  QualifOper;
  
  wire        WpQualifValid;
  wire        BpQualifValid;
  wire        LSSQualifValid;
  wire        IQualifValid;
  
  wire [10:0] WpStop;
  wire        BpStop;
  wire [3:0]  LSSStop;
  wire [1:0]  IStop;
  wire [1:0]  StopOper;
  
  wire WpStopValid;
  wire BpStopValid;
  wire LSSStopValid;
  wire IStopValid;
  
  wire [10:0] RecordPC_Wp;
  wire [10:0] RecordLSEA_Wp;
  wire [10:0] RecordLDATA_Wp;
  wire [10:0] RecordSDATA_Wp;
  wire [10:0] RecordReadSPR_Wp;
  wire [10:0] RecordWriteSPR_Wp;
  wire [10:0] RecordINSTR_Wp;
  
  wire RecordPC_Bp;
  wire RecordLSEA_Bp;
  wire RecordLDATA_Bp;
  wire RecordSDATA_Bp;
  wire RecordReadSPR_Bp;
  wire RecordWriteSPR_Bp;
  wire RecordINSTR_Bp;
  // End: Outputs from registers

  wire TraceTestScanChain;    // Trace Test Scan chain selected

  wire [47:0] Trace_Data;

`endif



wire RegisterScanChain;     // Register Scan chain selected
wire RiscDebugScanChain;    // Risc Debug Scan chain selected


/**********************************************************************************
*                                                                                 *
*   TAP State Machine: Fully JTAG compliant                                       *
*                                                                                 *
**********************************************************************************/
wire RESET = TRST | PowerONReset;

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
wire [1:0]Status = 2'b10;   // Holds current chip status. Core should return this status. For now a constant is used.

reg [`IR_LENGTH-1:0]JTAG_IR;   // Instruction register
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

assign RISC_Data      = {CalculatedCrcOut, RISC_DATAINLatch, 33'h0};
assign Register_Data  = {CalculatedCrcOut, RegisterReadLatch, 6'h0};

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
      if(DEBUGSelected & TraceTestScanChain & TraceChain[0])  // Sample is valid
        ReadBuffer_Tck<=#Tp 1;    // Increment read pointer
      `endif
    end
  else
    begin
      if(ShiftDR)
        begin
          if(IDCODESelected)
            TDOData <= #Tp IDCodeValue[BitCounter];
          else
          if(CHAIN_SELECTSelected)
            TDOData <= #Tp 0;
          else
          if(DEBUGSelected)
            begin
              if(RiscDebugScanChain)
                TDOData <= #Tp RISC_Data[BitCounter];
              else
              if(RegisterScanChain)
                TDOData <= #Tp Register_Data[BitCounter];
              `ifdef TRACE_ENABLED
              else
              if(TraceTestScanChain)
                TDOData <= #Tp Trace_Data[BitCounter];
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
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp `GLOBAL_BS_CHAIN;
  else
  if(UpdateDR & CHAIN_SELECTSelected & CrcMatch)
    Chain[`CHAIN_ID_LENGTH-1:0]<=#Tp JTAG_DR_IN[3:0];
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
    end
  else
    begin
      RegAccessTck      <=#Tp 1'b0;       // This signals are valid for one TCK clock period only
      RISCAccessTck     <=#Tp 1'b0;
    end
end

integer ii, jj, kk;
// Relocating bits because RISC works in big endian mode
always @(ADDR)
begin
  for(ii=0; ii<32; ii=ii+1)
    RISC_ADDR[ii] = ADDR[31-ii];
end


// Relocating bits because RISC works in big endian mode
always @(DataOut)
begin
  for(jj=0; jj<32; jj=jj+1)
    RISC_DATA_OUT[jj] = DataOut[31-jj];
end

// Synchronizing the RegAccess signal to Mclk clock
dbg_sync_clk1_clk2 syn1 (.clk1(Mclk),         .clk2(TCK),           .reset1(RESET),  .reset2(RESET), 
                         .set2(RegAccessTck), .sync_out(RegAccess)
                        );

// Synchronizing the RISCAccess signal to Mclk clock
dbg_sync_clk1_clk2 syn2 (.clk1(Mclk),         .clk2(TCK),           .reset1(RESET),  .reset2(RESET), 
                         .set2(RISCAccessTck), .sync_out(RISCAccess)
                        );

reg RegAccess_q;
reg RegAccess_q2;
reg RISCAccess_q;
reg RISCAccess_q2;

always @ (posedge Mclk or posedge RESET)
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
always @ (posedge Mclk or posedge RESET)
begin
  if(RESET)
    RegisterReadLatch[31:0]<=#Tp 0;
  else
  if(RegAccess_q & ~RegAccess_q2)
    RegisterReadLatch[31:0]<=#Tp RegDataIn[31:0];
end


assign RISC_CS = RISCAccess & ~RISCAccess_q;
assign RISC_RW = RW;


reg [31:0] RISC_DATA_IN_TEMP;
// Latching data read from RISC
always @ (posedge Mclk or posedge RESET)
begin
  if(RESET)
    RISC_DATAINLatch[31:0]<=#Tp 0;
  else
  if(RISCAccess_q & ~RISCAccess_q2)
    RISC_DATAINLatch[31:0]<=#Tp RISC_DATA_IN_TEMP[31:0];
end


// Relocating bits because RISC works in big endian mode
always @(RISC_DATA_IN)
begin
  for(kk=0; kk<32; kk=kk+1)
    RISC_DATA_IN_TEMP[kk] = RISC_DATA_IN[31-kk];
end



/**********************************************************************************
*                                                                                 *
*   Read Trace buffer logic                                                       *
*                                                                                 *
**********************************************************************************/
`ifdef TRACE_ENABLED
  wire Reset_ReadBuffer_Mclk = ReadBuffer_Mclk | DisableReadBuffer_Mclk | RESET;
  
  always @(posedge Mclk)
  begin
    if(Reset_ReadBuffer_Mclk)
      ReadBuffer_Mclk<=#Tp 0;
    else
    if(ReadBuffer_Tck)
      ReadBuffer_Mclk<=#Tp 1;
  end
  
  always @(posedge Mclk)
  begin
    if(ReadBuffer_Mclk)
      DisableReadBuffer_Mclk<=#Tp 1;
    else
    if(~ReadBuffer_Tck)
      DisableReadBuffer_Mclk<=#Tp 0;
  end
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
*																																									*
*		Multiplexing TDO and Tristate control																					*
*																																									*
**********************************************************************************/
wire TDOShifted;
assign TDOShifted = (ShiftIR | Exit1IR)? TDOInstruction : TDOData;

reg TDOMuxed;


// Tristate control for P_TDO pin
assign P_TDO = (ShiftIR | ShiftDR | Exit1IR | Exit1DR | UpdateDR)? TDOMuxed : 1'bz;


/**********************************************************************************
*																																									*
*		End:	Multiplexing TDO and Tristate control																		*
*																																									*
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
    begin
      EXTESTSelected<=#Tp 0;
      SAMPLE_PRELOADSelected<=#Tp 0;
      IDCODESelected<=#Tp 1;          // After reset IDCODE is selected
      CHAIN_SELECTSelected<=#Tp 0;
      INTESTSelected<=#Tp 0;
      CLAMPSelected<=#Tp 0;
      CLAMPZSelected<=#Tp 0;
      HIGHZSelected<=#Tp 0;
      DEBUGSelected<=#Tp 0;
      BYPASSSelected<=#Tp 0;
    end
  else
  begin
    if(UpdateIR)
      begin
        case(JTAG_IR)
          `EXTEST: // External test
            begin
              EXTESTSelected<=#Tp 1;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `SAMPLE_PRELOAD: // Sample preload
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 1;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `IDCODE:  // ID Code
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 1;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end          
          `CHAIN_SELECT: // Chain select
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 1;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `INTEST: // Internal test
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 1;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `CLAMP: // Clamp
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 1;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `CLAMPZ: // ClampZ
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 1;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `HIGHZ: // High Z
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 1;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 0;
            end
          `DEBUG: // Debug
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 1;
              BYPASSSelected<=#Tp 0;
            end
          `BYPASS: // BYPASS
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 1;
            end
          default:  // BYPASS
            begin
              EXTESTSelected<=#Tp 0;
              SAMPLE_PRELOADSelected<=#Tp 0;
              IDCODESelected<=#Tp 0;
              CHAIN_SELECTSelected<=#Tp 0;
              INTESTSelected<=#Tp 0;
              CLAMPSelected<=#Tp 0;
              CLAMPZSelected<=#Tp 0;
              HIGHZSelected<=#Tp 0;
              DEBUGSelected<=#Tp 0;
              BYPASSSelected<=#Tp 1;
            end
        endcase
      end
  end
end


// This multiplexing can be expanded with number of user registers
always @ (JTAG_IR or TDOShifted or TDOBypassed)
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
//		SAMPLE_PRELOAD:	// Sampling/Preloading
//			begin
//				TDOMuxed<=#Tp ExitFromBSCell[`BSLength-1];
//			end
//		EXTEST:	// External test
//			begin
//				TDOMuxed<=#Tp ExitFromBSCell[`BSLength-1];
//			end
    default:  // BYPASS instruction
      begin
        TDOMuxed<=#Tp TDOBypassed;
      end
  endcase
end


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
                      .Address(ADDR[4:0]), .RW(RW), .Access(RegAccess & ~RegAccess_q), .Clk(Mclk), 
                      .Reset(PowerONReset)
                      `ifdef TRACE_ENABLED
                      ,
                      .ContinMode(ContinMode), .TraceEnable(TraceEnable), .RecSelDepend(RecSelDepend), 
                      .WpTrigger(WpTrigger), .BpTrigger(BpTrigger), .LSSTrigger(LSSTrigger),
                      .ITrigger(ITrigger), .TriggerOper(TriggerOper), .WpQualif(WpQualif),
                      .BpQualif(BpQualif), .LSSQualif(LSSQualif), .IQualif(IQualif), 
                      .QualifOper(QualifOper), .RecordPC_Wp(RecordPC_Wp), 
                      .RecordLSEA_Wp(RecordLSEA_Wp), .RecordLDATA_Wp(RecordLDATA_Wp), 
                      .RecordSDATA_Wp(RecordSDATA_Wp), .RecordReadSPR_Wp(RecordReadSPR_Wp), 
                      .RecordWriteSPR_Wp(RecordWriteSPR_Wp), .RecordINSTR_Wp(RecordINSTR_Wp), 
                      .RecordPC_Bp(RecordPC_Bp), .RecordLSEA_Bp(RecordLSEA_Bp),
                      .RecordLDATA_Bp(RecordLDATA_Bp), .RecordSDATA_Bp(RecordSDATA_Bp), 
                      .RecordReadSPR_Bp(RecordReadSPR_Bp), .RecordWriteSPR_Bp(RecordWriteSPR_Bp), 
                      .RecordINSTR_Bp(RecordINSTR_Bp), .WpTriggerValid(WpTriggerValid), 
                      .BpTriggerValid(BpTriggerValid), .LSSTriggerValid(LSSTriggerValid), 
                      .ITriggerValid(ITriggerValid), .WpQualifValid(WpQualifValid), 
                      .BpQualifValid(BpQualifValid), .LSSQualifValid(LSSQualifValid), 
                      .IQualifValid(IQualifValid),
                      .WpStop(WpStop), .BpStop(BpStop), .LSSStop(LSSStop), .IStop(IStop), 
                      .S  topOper(StopOper), .WpStopValid(WpStopValid), .BpStopValid(BpStopValid), 
                      .LSSStopValid(LSSStopValid), .IStopValid(IStopValid) 
                      `endif
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
wire ResetCrc = RESET | UpdateDR_q;   // igor !!! Ta asinhroni reset popraviti
wire [7:0] CalculatedCrcIn;     // crc calculated from the input data (shifted in)

wire EnableCrcIn = ShiftDR & 
                 (  (CHAIN_SELECTSelected                 & (BitCounter<4))  |
                    ((DEBUGSelected & RegisterScanChain)  & (BitCounter<38)) | 
                    ((DEBUGSelected & RiscDebugScanChain) & (BitCounter<65)) 
                 );

wire EnableCrcOut= ShiftDR & 
//                 (  (CHAIN_SELECTSelected                 & (BitCounter<4))  |  Crc is not generated because crc of data that is equal to 0 is 0.
                 (
                    ((DEBUGSelected & RegisterScanChain)  & (BitCounter<38)) | 
                    ((DEBUGSelected & RiscDebugScanChain) & (BitCounter<65)) 
                    `ifdef TRACE_ENABLED
                                                                             |
                    ((DEBUGSelected & TraceTestScanChain) & (BitCounter<40)) 
                    `endif
                 );

// Calculating crc for input data
dbg_crc8_d1 crc1 (.Data(TDI), .EnableCrc(EnableCrcIn), .ResetCrc(ResetCrc), 
                  .CrcOut(CalculatedCrcIn), .Clk(TCK));

// Calculating crc for output data
dbg_crc8_d1 crc2 (.Data(TDOData), .EnableCrc(EnableCrcOut), .ResetCrc(ResetCrc), 
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
    end
end


// Active chain
assign RegisterScanChain   = Chain == `REGISTER_SCAN_CHAIN;
assign RiscDebugScanChain  = Chain == `RISC_DEBUG_CHAIN;

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
  dbg_trace dbgTrace1(.Wp(Wp), .Bp(Bp), .DataIn(DataIn), .OpSelect(OpSelect), 
                      .LsStatus(LsStatus), .IStatus(IStatus), .CpuStall(CpuStall), 
                      .Mclk(Mclk), .Reset(RESET), .TraceChain(TraceChain), 
                      .ContinMode(ContinMode), .TraceEnable(TraceEnable), 
                      .RecSelDepend(RecSelDepend), .WpTrigger(WpTrigger), 
                      .BpTrigger(BpTrigger), .LSSTrigger(LSSTrigger), .ITrigger(ITrigger), 
                      .TriggerOper(TriggerOper), .WpQualif(WpQualif), .BpQualif(BpQualif), 
                      .LSSQualif(LSSQualif), .IQualif(IQualif), .QualifOper(QualifOper), 
                      .RecordPC_Wp(RecordPC_Wp), .RecordLSEA_Wp(RecordLSEA_Wp), 
                      .RecordLDATA_Wp(RecordLDATA_Wp), .RecordSDATA_Wp(RecordSDATA_Wp), 
                      .RecordReadSPR_Wp(RecordReadSPR_Wp), .RecordWriteSPR_Wp(RecordWriteSPR_Wp), 
                      .RecordINSTR_Wp(RecordINSTR_Wp), .RecordPC_Bp(RecordPC_Bp), 
                      .RecordLSEA_Bp(RecordLSEA_Bp), .RecordLDATA_Bp(RecordLDATA_Bp), 
                      .RecordSDATA_Bp(RecordSDATA_Bp), .RecordReadSPR_Bp(RecordReadSPR_Bp), 
                      .RecordWriteSPR_Bp(RecordWriteSPR_Bp), .RecordINSTR_Bp(RecordINSTR_Bp), 
                      .WpTriggerValid(WpTriggerValid), .BpTriggerValid(BpTriggerValid), 
                      .LSSTriggerValid(LSSTriggerValid), .ITriggerValid(ITriggerValid), 
                      .WpQualifValid(WpQualifValid), .BpQualifValid(BpQualifValid), 
                      .LSSQualifValid(LSSQualifValid), .IQualifValid(IQualifValid),
                      .ReadBuffer(ReadBuffer_Mclk),
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



endmodule // TAP
