//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_tb.v                                                    ////
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
// Revision 1.1.1.1  2001/05/18 06:35:15  mohor
// Initial release
//
//


`include "dbg_timescale.v"
`include "dbg_defines.v"
`include "dbg_tb_defines.v"

// Test bench
module dbg_tb;

parameter Tp = 1;   
parameter Tclk = 50;   // Clock half period (Clok period = 100 ns => 10 MHz)


reg  P_TMS, P_TCK;
reg  P_TRST, P_TDI;
reg  P_PowerONReset;
reg  Mclk;

reg [10:0] Wp;
reg Bp;
reg [3:0] LsStatus;
reg [1:0] IStatus;

wire P_TDO;
wire [31:0] ADDR_RISC;
wire [31:0] DATAIN_RISC;     // DATAIN_RISC is connect to DATAOUT
wire RISC_CS;
wire RISC_RW;

wire  [31:0] DATAOUT_RISC;   // DATAOUT_RISC is connect to DATAIN

wire   [`OPSELECTWIDTH-1:0] OpSelect;

// Connecting TAP module
dbg_top dbgTAP1(.P_TMS(P_TMS), .P_TCK(P_TCK), .P_TRST(P_TRST), .P_TDI(P_TDI), 
                .P_TDO(P_TDO), .P_PowerONReset(P_PowerONReset), .Mclk(Mclk), 
                .RISC_ADDR(ADDR_RISC), .RISC_DATA_IN(DATAOUT_RISC), .RISC_DATA_OUT(DATAIN_RISC), 
                .RISC_CS(RISC_CS), .RISC_RW(RISC_RW), .Wp(Wp), .Bp(Bp), 
                .OpSelect(OpSelect), .LsStatus(LsStatus), .IStatus(IStatus)
                );


reg TestEnabled;
//integer i;



initial
begin
  TestEnabled<=#Tp 0;
  P_TMS<=#Tp 0;
  P_TCK<=#Tp 0;
  P_TDI<=#Tp 0;
  P_TRST<=#Tp 1;

  Wp<=#Tp 0;
  Bp<=#Tp 0;
  LsStatus<=#Tp 0;
  IStatus<=#Tp 0;

  P_PowerONReset<=#Tp 1;
  #100 P_PowerONReset<=#Tp 0;    // PowerONReset is active low
  #100 P_PowerONReset<=#Tp 1;
  #Tp TestEnabled<=#Tp 1;
end


// Generating master clock (RISC clock) 200 MHz
initial
begin
  Mclk<=#Tp 0;
  #1 forever #`RISC_CLOCK Mclk<=~Mclk;
end


// Generating random number for use in DATAOUT_RISC[31:0]
reg [31:0] RandNumb;
always @ (posedge Mclk or negedge P_PowerONReset) // PowerONReset is active low
begin
  if(~P_PowerONReset)
    RandNumb[31:0]<=#Tp 0;
  else
    RandNumb[31:0]<=#Tp RandNumb[31:0] + 1;
end


assign DATAOUT_RISC[31:0] = RandNumb[31:0];



always @ (posedge TestEnabled)
begin
  ResetTAP;
  GotoRunTestIdle;

// Testing read and write to RISC registers
  SetInstruction(`CHAIN_SELECT);
  ChainSelect(`RISC_DEBUG_CHAIN, 8'h38);  // {chain, crc}
  SetInstruction(`DEBUG);
  ReadRISCRegister(32'h12345ead, 8'hbf);                 // {addr, crc}
  WriteRISCRegister(32'h11223344, 32'h12345678, 8'haf);  // {data, addr, crc}
//



// Testing read and write to internal registers
  SetInstruction(`IDCODE);
  ReadIDCode;

  SetInstruction(`CHAIN_SELECT);
  ChainSelect(`REGISTER_SCAN_CHAIN, 8'h0e);  // {chain, crc}
  SetInstruction(`DEBUG);

//
    ReadRegister(`MODER_ADR, 8'h00);           // {addr, crc}
    ReadRegister(`TSEL_ADR, 8'h64);            // {addr, crc}
    ReadRegister(`QSEL_ADR, 8'h32);            // {addr, crc}
    ReadRegister(`SSEL_ADR, 8'h56);            // {addr, crc}
    ReadRegister(`RECWP0_ADR, 8'hc4);          // {addr, crc}
    ReadRegister(`RECWP1_ADR, 8'ha0);          // {addr, crc}
    ReadRegister(`RECWP2_ADR, 8'hf6);          // {addr, crc}
    ReadRegister(`RECWP3_ADR, 8'h92);          // {addr, crc}
    ReadRegister(`RECWP4_ADR, 8'hdd);          // {addr, crc}
    ReadRegister(`RECWP5_ADR, 8'hb9);          // {addr, crc}
    ReadRegister(`RECWP6_ADR, 8'hef);          // {addr, crc}
    ReadRegister(`RECWP7_ADR, 8'h8b);          // {addr, crc}
    ReadRegister(`RECWP8_ADR, 8'h4b);          // {addr, crc}
    ReadRegister(`RECWP9_ADR, 8'h2f);          // {addr, crc}
    ReadRegister(`RECWP10_ADR, 8'h79);         // {addr, crc}
    ReadRegister(`RECBP0_ADR, 8'h1d);          // {addr, crc}
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.

    WriteRegister(32'h00000001, `MODER_ADR,   8'h53); // {data, addr, crc}
    WriteRegister(32'h00000020, `TSEL_ADR,    8'h5e); // {data, addr, crc}
    WriteRegister(32'h00000300, `QSEL_ADR,    8'hdd); // {data, addr, crc}
    WriteRegister(32'h00004000, `SSEL_ADR,    8'he2); // {data, addr, crc}
    WriteRegister(32'h00050000, `RECWP0_ADR,  8'hbe); // {data, addr, crc}
    WriteRegister(32'h00600000, `RECWP1_ADR,  8'hbc); // {data, addr, crc}
    WriteRegister(32'h07000000, `RECWP2_ADR,  8'h3a); // {data, addr, crc}
    WriteRegister(32'h80000000, `RECWP3_ADR,  8'hf7); // {data, addr, crc}
    WriteRegister(32'h09000000, `RECWP4_ADR,  8'h46); // {data, addr, crc}
    WriteRegister(32'h00a00000, `RECWP5_ADR,  8'h9a); // {data, addr, crc}
    WriteRegister(32'h000b0000, `RECWP6_ADR,  8'h37); // {data, addr, crc}
    WriteRegister(32'h0000c000, `RECWP7_ADR,  8'h54); // {data, addr, crc}
    WriteRegister(32'h00000d00, `RECWP8_ADR,  8'hc3); // {data, addr, crc}
    WriteRegister(32'h000000e0, `RECWP9_ADR,  8'h2f); // {data, addr, crc}
    WriteRegister(32'h0000000f, `RECWP10_ADR, 8'h18); // {data, addr, crc}
    WriteRegister(32'hdeadbeef, `RECBP0_ADR,  8'h80); // {data, addr, crc}

    ReadRegister(`MODER_ADR, 8'h00);           // {addr, crc}
    ReadRegister(`TSEL_ADR, 8'h64);            // {addr, crc}
    ReadRegister(`QSEL_ADR, 8'h32);            // {addr, crc}
    ReadRegister(`SSEL_ADR, 8'h56);            // {addr, crc}
    ReadRegister(`RECWP0_ADR, 8'hc4);          // {addr, crc}
    ReadRegister(`RECWP1_ADR, 8'ha0);          // {addr, crc}
    ReadRegister(`RECWP2_ADR, 8'hf6);          // {addr, crc}
    ReadRegister(`RECWP3_ADR, 8'h92);          // {addr, crc}
    ReadRegister(`RECWP4_ADR, 8'hdd);          // {addr, crc}
    ReadRegister(`RECWP5_ADR, 8'hb9);          // {addr, crc}
    ReadRegister(`RECWP6_ADR, 8'hef);          // {addr, crc}
    ReadRegister(`RECWP7_ADR, 8'h8b);          // {addr, crc}
    ReadRegister(`RECWP8_ADR, 8'h4b);          // {addr, crc}
    ReadRegister(`RECWP9_ADR, 8'h2f);          // {addr, crc}
    ReadRegister(`RECWP10_ADR, 8'h79);         // {addr, crc}
    ReadRegister(`RECBP0_ADR, 8'h1d);          // {addr, crc}
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.
//


// testing trigger and qualifier
`ifdef TRACE_ENABLED
    /* Watchpoint Wp[0] starts trigger, anything starts qualifier
    #1000 WriteRegister(`WPTRIG_0 | `WPTRIGVALID | `TRIGOP_AND, `TSEL_ADR,   8'h9c); // Wp[0] starts trigger, anything starts qualifier
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hf9); // {data, addr, crc}
    #2000 Wp=11'h001;
    */

    /* Watchpoint Wp[10] & (IStatus[1:0] == IS_FETCH) start trigger, anything starts qualifier
    #1000 WriteRegister(`WPTRIG_10 | `IS_FETCH | `WPTRIGVALID | `ISTRIGVALID | `TRIGOP_AND, `TSEL_ADR,    8'haf); // Wp[10] & IStatus = IS_FETCH start trigger, anything starts qualifier
    #1000 WriteRegister(`ENABLE | `CONTIN, `MODER_ADR,    8'hc8); // {data, addr, crc}
    #2000 Wp=11'h001;   // Wp[0] is active
    #2000 IStatus=2'b01; // IStatus =  IS_FETCH
    #1999 Wp=11'h400;   // Wp[10] is active
    */

    /* Watchpoint Wp[10] & IStatus[1:0] = IS_BRANCH start trigger, anything starts qualifier
    #1000 WriteRegister(`WPTRIG_10 | `IS_BRANCH | `WPTRIGVALID | `ISTRIGVALID | `TRIGOP_AND, `TSEL_ADR,    8'hd1); // Wp[10] & IStatus = IS_BRANCH start trigger, anything starts qualifier
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hf9); // {data, addr, crc}
    #2000 Wp=11'h001;   // Wp[0] is active
    #2000 IStatus=2'b10; // IStatus = IS_BRANCH
    #1999 Wp=11'h400;   // Wp[10] is active
    */

    /* Watchpoint Wp[5] starts qualifier, anything starts trigger
    #1000 WriteRegister(`WPQUALIF_5 | `WPQUALIFVALID | `QUALIFOP_AND, `QSEL_ADR,   8'ha3); // Wp[5] starts Qualifier, anything starts trigger
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hf9); // {data, addr, crc}
    #2000 Wp=11'h020;   // Wp[5] is active
    */

// igor !!! od tu naprej je test TRACE-A, ki sem ga zakomentiral, ker moram najprej urediti read/write registrov
    // Breakpoint Bp & LsStatus[1] start qualifier, anything starts trigger
    #1000 WriteRegister(32'h12345673, `RECBP0_ADR,   8'hfe); // Ta je brez veze in mora iti ven. tu je le zato, da bi se videlo ali se registri berejo ok
    #1000 WriteRegister(32'h00000003, `RECBP0_ADR,   8'hd5); // Breakpoint Bp selects two samples for recording
    #100  WriteRegister(32'h80000801, `SSEL_ADR,   8'ha0); // Watchpoint Wp0 stops recording
//    #1000 WriteRegister(`BPQUALIF | `LSS_LOADBYTE_ZEROEXT | `BPQUALIFVALID | `LSSQUALIFVALID | `QUALIFOP_AND, `QSEL_ADR,   8'h50); // Breakpoint Bp & LsStatus[1] start qualifier, anything starts trigger
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hf9); // {data, addr, crc}
    #2000 Bp=1;                 // Bp is active
//    #2000 LsStatus[3:0]=4'h2;   // LsStatus = LSS_LOADBYTE_ZEROEXT
    #2000 LsStatus[3:0]=4'h2;   // LsStatus = LSS_LOADBYTE_ZEROEXT
    #45 LsStatus[3:0]=4'h1;   // LsStatus != LSS_LOADBYTE_ZEROEXT ()
    #90 LsStatus[3:0]=4'h2;   // LsStatus = LSS_LOADBYTE_ZEROEXT
    WriteRegister(32'h0000000c, `RECWP5_ADR,   8'h72); // Watchpoint Wp5 selects two samples for recording
    #45 LsStatus[3:0]=4'h1;   // LsStatus != LSS_LOADBYTE_ZEROEXT ()
    #45 LsStatus[3:0]=4'h2;   // LsStatus = LSS_LOADBYTE_ZEROEXT
    Bp=0;                 // Bp is active
    Wp=11'h020;   // Wp[5] is active
    #250 Wp=11'h021;   // Wp[0] and Wp[5] are active. Wp[0] will stop recording


    #45 LsStatus[3:0]=4'h1;   // LsStatus != LSS_LOADBYTE_ZEROEXT ()
    #45 LsStatus[3:0]=4'h2;   // LsStatus = LSS_LOADBYTE_ZEROEXT
    #1000 LsStatus[3:0]=4'h1;   // LsStatus != LSS_LOADBYTE_ZEROEXT ()




    //

  #1000 WriteRegister(0, `MODER_ADR,    8'h62); // {data, addr, crc} Disable Trace
  SetInstruction(`CHAIN_SELECT);
  ChainSelect(`TRACE_TEST_CHAIN, 8'h24);  // {chain, crc}
  SetInstruction(`DEBUG);
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;
  ReadTraceBuffer;

//  for(i=0;i<1500;i=i+1)
//    ReadTraceBuffer;

// // igor !!! konec zakomentiranega trace-a
`endif  // TRACE_ENABLED



  
  #5000 GenClk(1);            // One extra TCLK for debugging purposes
  #100 $stop;

end



// Generation of the TCLK signal
task GenClk;
  input [7:0] Number;
  integer i;
  begin
    for(i=0; i<Number; i=i+1)
      begin
        #Tclk P_TCK<=1;
        #Tclk P_TCK<=0;
      end
  end
endtask


// TAP reset
task ResetTAP;
  begin
    P_TMS<=#Tp 1;
    GenClk(7);
  end
endtask


// Goes to RunTestIdle state
task GotoRunTestIdle;
  begin
    P_TMS<=#Tp 0;
    GenClk(1);
  end
endtask


// sets the instruction to the IR register and goes to the RunTestIdle state
task SetInstruction;
  input [3:0] Instr;
  integer i;
  
  begin
    P_TMS<=#Tp 1;
    GenClk(2);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftIR

    for(i=0; i<`IR_LENGTH-1; i=i+1)
    begin
      P_TDI<=#Tp Instr[i];
      GenClk(1);
    end
    
    P_TDI<=#Tp Instr[i]; // last shift
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz;    // tri-state
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle
  end
endtask


// sets the selected scan chain and goes to the RunTestIdle state
task ChainSelect;
  input [3:0] Data;
  input [7:0] Crc;
  integer i;
  
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    for(i=0; i<`CHAIN_ID_LENGTH; i=i+1)
    begin
      P_TDI<=#Tp Data[i];
      GenClk(1);
    end

    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    begin
      P_TDI<=#Tp Crc[i];
      GenClk(1);
    end

    P_TDI<=#Tp Crc[i]; // last shift
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz; // tri-state
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle
  end
endtask


// Reads the ID code
task ReadIDCode;
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    P_TDI<=#Tp 0;
    GenClk(31);
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz; // tri-state
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle
  end
endtask


// Reads sample from the Trace Buffer
task ReadTraceBuffer;
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    P_TDI<=#Tp 0;
    GenClk(47);
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz; // tri-state
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle
  end
endtask


// Reads the RISC register and latches the data so it is ready for reading
task ReadRISCRegister;
  input [31:0] Address;
  input [7:0] Crc;
  integer i;
  
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    for(i=0; i<32; i=i+1)
    begin
      P_TDI<=#Tp Address[i];  // Shifting address
      GenClk(1);
    end

    P_TDI<=#Tp 0;             // shifting RW bit = read
    GenClk(1);

    for(i=0; i<32; i=i+1)
    begin
      P_TDI<=#Tp 0;     // Shifting data. Data is not important in read cycle.
      GenClk(1);
    end

    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC.
      GenClk(1);
    end

    P_TDI<=#Tp Crc[i];   // Shifting last bit of CRC.
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz;   // Tristate TDI.
    GenClk(1);

    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle
  end
endtask


// Write the RISC register
task WriteRISCRegister;
  input [31:0] Data;
  input [31:0] Address;
  input [`CRC_LENGTH-1:0] Crc;
  integer i;
  
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    for(i=0; i<32; i=i+1)
    begin
      P_TDI<=#Tp Address[i];  // Shifting address
      GenClk(1);
    end

    P_TDI<=#Tp 1;             // shifting RW bit = write
    GenClk(1);

    for(i=0; i<32; i=i+1)
    begin
      P_TDI<=#Tp Data[i];     // Shifting data
      GenClk(1);
    end

    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC
      GenClk(1);
    end

    P_TDI<=#Tp Crc[i];        // shifting last bit of CRC
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz;        // tristate TDI
    GenClk(1);

    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle

    GenClk(10);      // Generating few clock cycles needed for the write operation to accomplish
  end
endtask


// Reads the register and latches the data so it is ready for reading
task ReadRegister;
  input [4:0] Address;
  input [7:0] Crc;
  integer i;
  
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    for(i=0; i<5; i=i+1)
    begin
      P_TDI<=#Tp Address[i];  // Shifting address
      GenClk(1);
    end

    P_TDI<=#Tp 0;             // shifting RW bit = read
    GenClk(1);

    for(i=0; i<32; i=i+1)
    begin
      P_TDI<=#Tp 0;     // Shifting data. Data is not important in read cycle.
      GenClk(1);
    end

    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC. CRC is not important in read cycle.
      GenClk(1);
    end

    P_TDI<=#Tp Crc[i];     // Shifting last bit of CRC.
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz;     // Tri state TDI
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle

    GenClk(10);      // Generating few clock cycles needed for the read operation to accomplish
  end
endtask

 
// Write the register
task WriteRegister;
  input [31:0] Data;
  input [4:0] Address;
  input [`CRC_LENGTH-1:0] Crc;
  integer i;
  
  begin
    P_TMS<=#Tp 1;
    GenClk(1);
    P_TMS<=#Tp 0;
    GenClk(2);  // we are in shiftDR

    for(i=0; i<5; i=i+1)
    begin
      P_TDI<=#Tp Address[i];  // Shifting address
      GenClk(1);
    end

    P_TDI<=#Tp 1;             // shifting RW bit = write
    GenClk(1);

    for(i=0; i<32; i=i+1)
    begin
      P_TDI<=#Tp Data[i];     // Shifting data
      GenClk(1);
    end
    
    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC
      GenClk(1);
    end

    P_TDI<=#Tp Crc[i];   // Shifting last bit of CRC
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz;   // Tri state TDI
    GenClk(1);

    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle
  end
endtask



/**********************************************************************************
*                                                                                 *
*   Printing the information to the screen                                        *
*                                                                                 *
**********************************************************************************/

// Print samples that are recorded to the trace buffer
`ifdef TRACE_ENABLED
always @ (posedge Mclk)
begin
  if(dbg_tb.dbgTAP1.dbgTrace1.WriteSample)
    $write("\n\tWritten to Trace buffer: WritePointer=0x%x, Data=0x%x", dbg_tb.dbgTAP1.dbgTrace1.WritePointer, {dbg_tb.dbgTAP1.dbgTrace1.RISC_DATA_IN, 1'b0, dbg_tb.dbgTAP1.dbgTrace1.OpSelect[`OPSELECTWIDTH-1:0]});
end
`endif


// Print selected instruction
reg UpdateIR_q;
always @ (posedge P_TCK)
begin
  UpdateIR_q<=#Tp dbg_tb.dbgTAP1.UpdateIR;
end

always @ (posedge P_TCK)
begin
  if(UpdateIR_q)
    case(dbg_tb.dbgTAP1.JTAG_IR[`IR_LENGTH-1:0])
      `EXTEST         : $write("\n\tInstruction EXTEST");
      `SAMPLE_PRELOAD : $write("\n\tInstruction SAMPLE_PRELOAD");
      `IDCODE         : $write("\n\tInstruction IDCODE");
      `CHAIN_SELECT   : $write("\n\tInstruction CHAIN_SELECT");
      `INTEST         : $write("\n\tInstruction INTEST");
      `CLAMP          : $write("\n\tInstruction CLAMP");
      `CLAMPZ         : $write("\n\tInstruction CLAMPZ");
      `HIGHZ          : $write("\n\tInstruction HIGHZ");
      `DEBUG          : $write("\n\tInstruction DEBUG");
      `BYPASS         : $write("\n\tInstruction BYPASS");
		default           :	$write("\n\tInstruction not valid. Instruction BYPASS activated !!!");
    endcase
end



// Print selected chain
always @ (posedge P_TCK)
begin
  if(dbg_tb.dbgTAP1.CHAIN_SELECTSelected & dbg_tb.dbgTAP1.UpdateDR_q)
    case(dbg_tb.dbgTAP1.Chain[`CHAIN_ID_LENGTH-1:0])
      `GLOBAL_BS_CHAIN      : $write("\nChain GLOBAL_BS_CHAIN");
      `RISC_DEBUG_CHAIN     : $write("\nChain RISC_DEBUG_CHAIN");
      `RISC_TEST_CHAIN      : $write("\nChain RISC_TEST_CHAIN");
      `TRACE_TEST_CHAIN     : $write("\nChain TRACE_TEST_CHAIN");
      `REGISTER_SCAN_CHAIN  : $write("\nChain REGISTER_SCAN_CHAIN");
    endcase
end


// print RISC registers read/write
always @ (posedge Mclk)
begin
  if(dbg_tb.dbgTAP1.RISC_CS)
    if(dbg_tb.dbgTAP1.RISC_RW)
      begin
        $write("\n\t\tWrite to RISC Register (addr=0x%h, data=0x%h)", dbg_tb.dbgTAP1.ADDR[31:0], dbg_tb.dbgTAP1.DataOut[31:0]);
      end
    else
      begin
        $write("\n\t\tRead from RISC Register (addr=0x%h, data=0x%h)", dbg_tb.dbgTAP1.ADDR[31:0], dbg_tb.dbgTAP1.RISC_DATA_IN[31:0]);
      end
end


// print registers read/write
always @ (posedge Mclk)
begin
  if(dbg_tb.dbgTAP1.RegAccess_q & ~dbg_tb.dbgTAP1.RegAccess_q2)
    begin
      if(dbg_tb.dbgTAP1.RW)
        $write("\n\t\tWrite to Register (addr=0x%h, data=0x%h)", dbg_tb.dbgTAP1.ADDR[4:0], dbg_tb.dbgTAP1.DataOut[31:0]);
      else
        $write("\n\t\tRead from Register (addr=0x%h, data=0x%h)", dbg_tb.dbgTAP1.ADDR[4:0], dbg_tb.dbgTAP1.RegDataIn[31:0]);
    end
end


// print CRC error
`ifdef TRACE_ENABLED
  wire CRCErrorReport = ~(dbg_tb.dbgTAP1.CrcMatch & (dbg_tb.dbgTAP1.CHAIN_SELECTSelected | dbg_tb.dbgTAP1.DEBUGSelected & dbg_tb.dbgTAP1.RegisterScanChain | dbg_tb.dbgTAP1.DEBUGSelected & dbg_tb.dbgTAP1.RiscDebugScanChain | dbg_tb.dbgTAP1.DEBUGSelected & dbg_tb.dbgTAP1.TraceTestScanChain));
`else  // TRACE_ENABLED not enabled
  wire CRCErrorReport = ~(dbg_tb.dbgTAP1.CrcMatch & (dbg_tb.dbgTAP1.CHAIN_SELECTSelected | dbg_tb.dbgTAP1.DEBUGSelected & dbg_tb.dbgTAP1.RegisterScanChain | dbg_tb.dbgTAP1.DEBUGSelected & dbg_tb.dbgTAP1.RiscDebugScanChain));
`endif

always @ (posedge P_TCK)
begin
  if(dbg_tb.dbgTAP1.UpdateDR & ~dbg_tb.dbgTAP1.IDCODESelected)
    begin
      if(dbg_tb.dbgTAP1.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.dbgTAP1.JTAG_DR_IN[11:4], dbg_tb.dbgTAP1.CalculatedCrcOut[`CRC_LENGTH-1:0]);
      else
      if(dbg_tb.dbgTAP1.RegisterScanChain & ~dbg_tb.dbgTAP1.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.dbgTAP1.JTAG_DR_IN[45:38], dbg_tb.dbgTAP1.CalculatedCrcOut[`CRC_LENGTH-1:0]);
      else
      if(dbg_tb.dbgTAP1.RiscDebugScanChain & ~dbg_tb.dbgTAP1.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.dbgTAP1.JTAG_DR_IN[72:65], dbg_tb.dbgTAP1.CalculatedCrcOut[`CRC_LENGTH-1:0]);

      if(CRCErrorReport)
        begin
          $write("\n\t\t\t\tCrc Error when receiving data (read or write) !!!  Crc should be: 0x%h\n", dbg_tb.dbgTAP1.CalculatedCrcIn);
          #1000 $stop;
        end
    end
end


// Print shifted IDCode
reg [31:0] TempData;
always @ (posedge P_TCK)
begin
  if(dbg_tb.dbgTAP1.IDCODESelected)
    begin
      if(dbg_tb.dbgTAP1.ShiftDR)
        TempData[31:0]<=#Tp {dbg_tb.dbgTAP1.TDOData, TempData[31:1]};
      else
      if(dbg_tb.dbgTAP1.UpdateDR)
        $write("\n\t\tIDCode = 0x%h", TempData[31:0]);
    end
end


// Print data from the trace buffer
reg [47:0] TraceData;
always @ (posedge P_TCK)
begin
  if(dbg_tb.dbgTAP1.DEBUGSelected & (dbg_tb.dbgTAP1.Chain==`TRACE_TEST_CHAIN))
    begin
      if(dbg_tb.dbgTAP1.ShiftDR)
        TraceData[47:0]<=#Tp {dbg_tb.dbgTAP1.TDOData, TraceData[47:1]};
      else
      if(dbg_tb.dbgTAP1.UpdateDR)
        $write("\n\t\TraceData = 0x%h + Crc = 0x%h", TraceData[39:0], TraceData[47:40]);
    end
end


endmodule // TB


