//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_tb.v                                                    ////
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
// Revision 1.11  2002/03/12 14:32:26  mohor
// Few outputs for boundary scan chain added.
//
// Revision 1.10  2002/03/08 15:27:08  mohor
// Structure changed. Hooks for jtag chain added.
//
// Revision 1.9  2001/10/19 11:39:20  mohor
// dbg_timescale.v changed to timescale.v This is done for the simulation of
// few different cores in a single project.
//
// Revision 1.8  2001/10/17 10:39:17  mohor
// bs_chain_o added.
//
// Revision 1.7  2001/10/16 10:10:18  mohor
// Signal names changed to lowercase.
//
// Revision 1.6  2001/10/15 09:52:50  mohor
// Wishbone interface added, few fixes for better performance,
// hooks for boundary scan testing added.
//
// Revision 1.5  2001/09/24 14:06:12  mohor
// Changes connected to the OpenRISC access (SPR read, SPR write).
//
// Revision 1.4  2001/09/20 10:10:29  mohor
// Working version. Few bugs fixed, comments added.
//
// Revision 1.3  2001/09/19 11:54:03  mohor
// Minor changes for simulation.
//
// Revision 1.2  2001/09/18 14:12:43  mohor
// Trace fixed. Some registers changed, trace simplified.
//
// Revision 1.1.1.1  2001/09/13 13:49:19  mohor
// Initial official release.
//
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


`include "timescale.v"
`include "dbg_defines.v"
`include "dbg_tb_defines.v"

// Test bench
module dbg_tb;

parameter Tp = 1;   
parameter Tclk = 50;   // Clock half period (Clok period = 100 ns => 10 MHz)


reg  P_TMS, P_TCK;
reg  P_TRST, P_TDI;
reg  wb_rst_i;
reg  Mclk;

reg [10:0] Wp;
reg Bp;
reg [3:0] LsStatus;
reg [1:0] IStatus;
reg BS_CHAIN_I;

wire P_TDO;
wire [31:0] ADDR_RISC;
wire [31:0] DATAIN_RISC;     // DATAIN_RISC is connect to DATAOUT

wire  [31:0] DATAOUT_RISC;   // DATAOUT_RISC is connect to DATAIN

wire   [`OPSELECTWIDTH-1:0] OpSelect;

wire [31:0] wb_adr_i;
wire [31:0] wb_dat_i;
reg  [31:0] wb_dat_o;
wire        wb_cyc_i;
wire        wb_stb_i;
wire  [3:0] wb_sel_i;
wire        wb_we_i;
reg         wb_ack_o;
wire        wb_cab_i;
reg         wb_err_o;

wire ShiftDR;
wire Exit1DR;
wire UpdateDR;
wire UpdateDR_q;
wire CaptureDR;
wire IDCODESelected;
wire CHAIN_SELECTSelected;
wire DEBUGSelected;
wire TDOData_dbg;
wire BypassRegister;
wire EXTESTSelected;
wire [3:0] mon_cntl_o;

// Connecting TAP module
tap_top i_tap_top
               (.tms_pad_i(P_TMS), .tck_pad_i(P_TCK), .trst_pad_i(P_TRST), .tdi_pad_i(P_TDI), 
                .tdo_pad_o(P_TDO), .tdo_padoe_o(tdo_padoe_o), 
                
                // TAP states
                .ShiftDR(ShiftDR), .Exit1DR(Exit1DR), .UpdateDR(UpdateDR), .UpdateDR_q(UpdateDR_q), 
                .CaptureDR(CaptureDR), 
                
                // Instructions
                .IDCODESelected(IDCODESelected), .CHAIN_SELECTSelected(CHAIN_SELECTSelected), 
                .DEBUGSelected(DEBUGSelected),   .EXTESTSelected(EXTESTSelected), 
                
                // TDO from dbg module
                .TDOData_dbg(TDOData_dbg), .BypassRegister(BypassRegister), 
                
                // Boundary Scan Chain
                .bs_chain_i(BS_CHAIN_I)

               );

dbg_top i_dbg_top
               ( 
                .risc_clk_i(Mclk), .risc_addr_o(ADDR_RISC), .risc_data_i(DATAOUT_RISC), 
                .risc_data_o(DATAIN_RISC), .wp_i(Wp), .bp_i(Bp), .opselect_o(OpSelect), 
                .lsstatus_i(LsStatus), .istatus_i(IStatus), .risc_stall_o(), .reset_o(),
                
                .wb_rst_i(wb_rst_i), .wb_clk_i(Mclk), 
                
                .wb_adr_o(wb_adr_i), .wb_dat_o(wb_dat_i), .wb_dat_i(wb_dat_o), 
                .wb_cyc_o(wb_cyc_i), .wb_stb_o(wb_stb_i), .wb_sel_o(wb_sel_i), 
                .wb_we_o(wb_we_i),   .wb_ack_i(wb_ack_o), .wb_cab_o(wb_cab_i), 
                .wb_err_i(wb_err_o), 
                
                // TAP states
                .ShiftDR(ShiftDR), .Exit1DR(Exit1DR), .UpdateDR(UpdateDR), .UpdateDR_q(UpdateDR_q), 
                
                // Instructions
                .IDCODESelected(IDCODESelected), .CHAIN_SELECTSelected(CHAIN_SELECTSelected), 
                .DEBUGSelected(DEBUGSelected), 

                // TAP signals
                .trst_in(P_TRST), .tck(P_TCK), .tdi(P_TDI), .TDOData(TDOData_dbg), 
                
                .BypassRegister(BypassRegister), 
                
                
                .mon_cntl_o(mon_cntl_o)

               );
 
reg TestEnabled;
  
   
   
initial
begin
  TestEnabled<=#Tp 0;
  P_TMS<=#Tp 'hz;
  P_TCK<=#Tp 'hz;
  P_TDI<=#Tp 'hz;
  BS_CHAIN_I = 0;

  Wp<=#Tp 0;
  Bp<=#Tp 0;
  LsStatus<=#Tp 0;
  IStatus<=#Tp 0;

  wb_dat_o<=#Tp 32'h0;
  wb_ack_o<=#Tp 1'h0;
  wb_err_o<=#Tp 1'h0;



  wb_rst_i<=#Tp 0;
  P_TRST<=#Tp 1;
  #100 wb_rst_i<=#Tp 1;
  P_TRST<=#Tp 0;
  #100 wb_rst_i<=#Tp 0;
  P_TRST<=#Tp 1;
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
always @ (posedge Mclk or posedge wb_rst_i)
begin
  if(wb_rst_i)
    RandNumb[31:0]<=#Tp 0;
  else
    RandNumb[31:0]<=#Tp RandNumb[31:0] + 1;
end


assign DATAOUT_RISC[31:0] = RandNumb[31:0];


always @ (posedge TestEnabled)
fork

begin
  EnableWishboneSlave;  // enabling WISHBONE slave
end


begin
  ResetTAP;
  GotoRunTestIdle;

// Testing read and write to WISHBONE
  SetInstruction(`CHAIN_SELECT);
  ChainSelect(`WISHBONE_SCAN_CHAIN, 8'h36);  // {chain, crc}
  SetInstruction(`DEBUG);
  ReadRISCRegister(32'h87654321, 8'hfd);                 // {addr, crc}         // Wishbone and RISC accesses are similar
  WriteRISCRegister(32'h18273645, 32'hbeefbeef, 8'haa);  // {data, addr, crc}
  ReadRISCRegister(32'h87654321, 8'hfd);                 // {addr, crc}         // Wishbone and RISC accesses are similar
  ReadRISCRegister(32'h87654321, 8'hfd);                 // {addr, crc}         // Wishbone and RISC accesses are similar
//

// Testing read and write to RISC registers
  SetInstruction(`CHAIN_SELECT);
  ChainSelect(`RISC_DEBUG_CHAIN, 8'h38);  // {chain, crc}
  SetInstruction(`DEBUG);

  ReadRISCRegister(32'h12345ead, 8'hbf);                 // {addr, crc}
  WriteRISCRegister(32'h11223344, 32'h12345678, 8'haf);  // {data, addr, crc}
//


// Testing read and write to internal registers
  SetInstruction(`IDCODE);
  ReadIDCode; // muten

  SetInstruction(`CHAIN_SELECT);
  ChainSelect(`REGISTER_SCAN_CHAIN, 8'h0e);  // {chain, crc}
  SetInstruction(`DEBUG);


//
//  Testing internal registers
    ReadRegister(`MODER_ADR, 8'h00);           // {addr, crc}
    ReadRegister(`TSEL_ADR, 8'h64);            // {addr, crc}
    ReadRegister(`QSEL_ADR, 8'h32);            // {addr, crc}
    ReadRegister(`SSEL_ADR, 8'h56);            // {addr, crc}
    ReadRegister(`RECSEL_ADR, 8'hc4);          // {addr, crc}
    ReadRegister(`MON_CNTL_ADR, 8'ha0);          // {addr, crc}
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.

    WriteRegister(32'h00000001, `MODER_ADR,   8'h53); // {data, addr, crc}
    WriteRegister(32'h00000020, `TSEL_ADR,    8'h5e); // {data, addr, crc}
    WriteRegister(32'h00000300, `QSEL_ADR,    8'hdd); // {data, addr, crc}
    WriteRegister(32'h00004000, `SSEL_ADR,    8'he2); // {data, addr, crc}
    WriteRegister(32'h0000dead, `RECSEL_ADR,  8'hfb); // {data, addr, crc}
    WriteRegister(32'h0000000d, `MON_CNTL_ADR,  8'h5a); // {data, addr, crc}

    ReadRegister(`MODER_ADR, 8'h00);           // {addr, crc}
    ReadRegister(`TSEL_ADR, 8'h64);            // {addr, crc}
    ReadRegister(`QSEL_ADR, 8'h32);            // {addr, crc}
    ReadRegister(`SSEL_ADR, 8'h56);            // {addr, crc}
    ReadRegister(`RECSEL_ADR, 8'hc4);          // {addr, crc}
    ReadRegister(`MON_CNTL_ADR, 8'ha0);          // {addr, crc}
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.
    ReadRegister(5'h1f, 8'h04);                // {addr, crc}       // Register address don't exist. Read should return high-Z.
//


// testing trigger and qualifier
`ifdef TRACE_ENABLED





// Anything starts trigger and qualifier
    #1000 WriteRegister(32'h00000000, `QSEL_ADR,   8'h50);    // Any qualifier
    #1000 WriteRegister(32'h00000000, `TSEL_ADR,   8'h06);    // Any trigger
    #1000 WriteRegister(32'h00000003, `RECSEL_ADR,   8'h0c);  // Two samples are selected for recording (RECPC and RECLSEA)
    #100  WriteRegister(32'h00000000, `SSEL_ADR,   8'h34);    // No stop signal
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hd4);       // Trace enabled
// End: Anything starts trigger and qualifier //


/* Anything starts trigger, breakpoint starts qualifier
// Uncomment this part when you want to test it.
    #1000 WriteRegister(`QUALIFOP_OR | `BPQUALIFVALID | `BPQUALIF, `QSEL_ADR,   8'had);    // Any qualifier
    #1000 WriteRegister(32'h00000000, `TSEL_ADR,   8'h06);    // Any trigger
    #1000 WriteRegister(32'h0000000c, `RECSEL_ADR,   8'h0f);  // Two samples are selected for recording (RECSDATA and RECLDATA)
    #1000 WriteRegister(32'h00000000, `SSEL_ADR,   8'h34);    // No stop signal
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hd4);       // Trace enabled
    wait(dbg_tb.i_dbg_top.TraceEnable)
    @ (posedge Mclk);
      #1 Bp = 1;                                                 // Set breakpoint
    repeat(8) @(posedge Mclk);
    wait(dbg_tb.i_dbg_top.dbgTrace1.RiscStall)
      #1 Bp = 0;                                                 // Clear breakpoint
// End: Anything starts trigger, breakpoint starts qualifier */


/* Anything starts qualifier, breakpoint starts trigger
// Uncomment this part when you want to test it.
    #1000 WriteRegister(32'h00000000, `QSEL_ADR,   8'h50);    // Any qualifier
    #1000 WriteRegister(`LSSTRIG_0 | `LSSTRIG_2 | `LSSTRIGVALID | `WPTRIG_4 | `WPTRIGVALID | `TRIGOP_AND, `TSEL_ADR,   8'had);    // Trigger is AND of Watchpoint4 and LSSTRIG[0] and LSSTRIG[2]
    #1000 WriteRegister(32'h00000003, `RECSEL_ADR,   8'h0c);  // Two samples are selected for recording (RECPC and RECLSEA)
    #1000 WriteRegister(32'h00000000, `SSEL_ADR,   8'h34);    // No stop signal
    #1000 WriteRegister(`ENABLE, `MODER_ADR,    8'hd4);       // Trace enabled
    wait(dbg_tb.i_dbg_top.TraceEnable)
    @ (posedge Mclk)
      Wp[4] = 1;                                              // Set watchpoint[4]
      LsStatus = 4'h5;                                        // LsStatus[0] and LsStatus[2] are active
    @ (posedge Mclk)
      Wp[4] = 0;                                              // Clear watchpoint[4]
      LsStatus = 4'h0;                                        // LsStatus[0] and LsStatus[2] are cleared
// End: Anything starts trigger and qualifier */






// Reading data from the trace buffer
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


`endif  // TRACE_ENABLED



  
  #5000 GenClk(1);            // One extra TCLK for debugging purposes
  #1000 $stop;

end
join


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

//    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    for(i=0; i<`CRC_LENGTH; i=i+1)      // +1 because crc is 9 bit long
    begin
      P_TDI<=#Tp Crc[i];
      GenClk(1);
    end

//    P_TDI<=#Tp Crc[i]; // last shift
    P_TDI<=#Tp 1'b0;     // Crc[i]; // last shift
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

//    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    for(i=0; i<`CRC_LENGTH; i=i+1)      // crc is 9 bit long
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC.
      GenClk(1);
    end

//    P_TDI<=#Tp Crc[i];   // Shifting last bit of CRC.
    P_TDI<=#Tp 1'b0;       // Crc[i];   // Shifting last bit of CRC.
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

//    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    for(i=0; i<`CRC_LENGTH; i=i+1)      // crc is 9 bit long
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC
      GenClk(1);
    end

//    P_TDI<=#Tp Crc[i];        // shifting last bit of CRC
    P_TDI<=#Tp 1'b0;            // Crc[i];        // shifting last bit of CRC
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

//    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    for(i=0; i<`CRC_LENGTH; i=i+1)      // crc is 9 bit long
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC. CRC is not important in read cycle.
      GenClk(1);
    end

//    P_TDI<=#Tp Crc[i];     // Shifting last bit of CRC.
    P_TDI<=#Tp 1'b0;         // Crc[i];     // Shifting last bit of CRC.
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
    
//    for(i=0; i<`CRC_LENGTH-1; i=i+1)
    for(i=0; i<`CRC_LENGTH; i=i+1)      // crc is 9 bit long
    begin
      P_TDI<=#Tp Crc[i];     // Shifting CRC
      GenClk(1);
    end

//    P_TDI<=#Tp Crc[i];   // Shifting last bit of CRC
    P_TDI<=#Tp 1'b0;       // Crc[i];   // Shifting last bit of CRC
    P_TMS<=#Tp 1;        // going out of shiftIR
    GenClk(1);
      P_TDI<=#Tp 'hz;   // Tri state TDI
    GenClk(1);

    P_TMS<=#Tp 0;
    GenClk(1);       // we are in RunTestIdle

    GenClk(5);       // Extra clocks needed for operations to finish 

  end
endtask


task EnableWishboneSlave;
begin
while(1)
  begin
    if(wb_stb_i & wb_cyc_i) // WB access
//    wait (wb_stb_i & wb_cyc_i) // WB access
      begin
        @ (posedge Mclk);
        @ (posedge Mclk);
        @ (posedge Mclk);
        #1 wb_ack_o = 1;
        if(~wb_we_i) // read
          wb_dat_o = 32'hbeefdead;
        if(wb_we_i & wb_stb_i & wb_cyc_i) // write
          $display("\nWISHBONE write Data=%0h, Addr=%0h", wb_dat_i, wb_adr_i);
        if(~wb_we_i & wb_stb_i & wb_cyc_i) // read
          $display("\nWISHBONE read Data=%0h, Addr=%0h", wb_dat_o, wb_adr_i);
      end
    @ (posedge Mclk);
    #1 wb_ack_o = 0;
    wb_dat_o = 32'h0;
  end
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
  if(dbg_tb.i_dbg_top.dbgTrace1.WriteSample)
    $write("\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tWritten to Trace buffer: WritePointer=0x%x, Data=0x%x", dbg_tb.i_dbg_top.dbgTrace1.WritePointer, {dbg_tb.i_dbg_top.dbgTrace1.DataIn, 1'b0, dbg_tb.i_dbg_top.dbgTrace1.OpSelect[`OPSELECTWIDTH-1:0]});
end
`endif


// Print selected instruction
reg UpdateIR_q;
always @ (posedge P_TCK)
begin
  UpdateIR_q<=#Tp dbg_tb.i_tap_top.UpdateIR;
end

always @ (posedge P_TCK)
begin
  if(UpdateIR_q)
    case(dbg_tb.i_tap_top.LatchedJTAG_IR[`IR_LENGTH-1:0])
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
  if(dbg_tb.i_tap_top.CHAIN_SELECTSelected & dbg_tb.i_tap_top.UpdateDR_q)
    case(dbg_tb.i_dbg_top.Chain[`CHAIN_ID_LENGTH-1:0])
      `GLOBAL_BS_CHAIN      : $write("\nChain GLOBAL_BS_CHAIN");
      `RISC_DEBUG_CHAIN     : $write("\nChain RISC_DEBUG_CHAIN");
      `RISC_TEST_CHAIN      : $write("\nChain RISC_TEST_CHAIN");
      `TRACE_TEST_CHAIN     : $write("\nChain TRACE_TEST_CHAIN");
      `REGISTER_SCAN_CHAIN  : $write("\nChain REGISTER_SCAN_CHAIN");
      `WISHBONE_SCAN_CHAIN  : $write("\nChain WISHBONE_SCAN_CHAIN");
    endcase
end


// print RISC registers read/write
always @ (posedge Mclk)
begin
  if(dbg_tb.i_dbg_top.RISCAccess & ~dbg_tb.i_dbg_top.RISCAccess_q & dbg_tb.i_dbg_top.RW)
    $write("\n\t\tWrite to RISC Register (addr=0x%h, data=0x%h)", dbg_tb.i_dbg_top.ADDR[31:0], dbg_tb.i_dbg_top.DataOut[31:0]);
  else
  if(dbg_tb.i_dbg_top.RISCAccess_q & ~dbg_tb.i_dbg_top.RISCAccess_q2 & ~dbg_tb.i_dbg_top.RW)
    $write("\n\t\tRead from RISC Register (addr=0x%h, data=0x%h)", dbg_tb.i_dbg_top.ADDR[31:0], dbg_tb.i_dbg_top.risc_data_i[31:0]);
end


// print registers read/write
always @ (posedge Mclk)
begin
  if(dbg_tb.i_dbg_top.RegAccess_q & ~dbg_tb.i_dbg_top.RegAccess_q2)
    begin
      if(dbg_tb.i_dbg_top.RW)
        $write("\n\t\tWrite to Register (addr=0x%h, data=0x%h)", dbg_tb.i_dbg_top.ADDR[4:0], dbg_tb.i_dbg_top.DataOut[31:0]);
      else
        $write("\n\t\tRead from Register (addr=0x%h, data=0x%h). This data will be shifted out on next read request.", dbg_tb.i_dbg_top.ADDR[4:0], dbg_tb.i_dbg_top.RegDataIn[31:0]);
    end
end


// print CRC error
`ifdef TRACE_ENABLED
  wire CRCErrorReport = ~(dbg_tb.i_dbg_top.CrcMatch & (dbg_tb.i_dbg_top.CHAIN_SELECTSelected | dbg_tb.i_dbg_top.DEBUGSelected & dbg_tb.i_dbg_top.RegisterScanChain | dbg_tb.i_dbg_top.DEBUGSelected & dbg_tb.i_dbg_top.RiscDebugScanChain | dbg_tb.i_dbg_top.DEBUGSelected & dbg_tb.i_dbg_top.TraceTestScanChain | dbg_tb.i_dbg_top.DEBUGSelected & dbg_tb.i_dbg_top.WishboneScanChain));
`else  // TRACE_ENABLED not enabled
  wire CRCErrorReport = ~(dbg_tb.i_dbg_top.CrcMatch & (dbg_tb.i_tap_top.CHAIN_SELECTSelected | dbg_tb.i_tap_top.DEBUGSelected & dbg_tb.i_tap_top.RegisterScanChain | dbg_tb.i_tap_top.DEBUGSelected & dbg_tb.i_tap_top.RiscDebugScanChain | dbg_tb.i_tap_top.DEBUGSelected & dbg_tb.i_tap_top.WishboneScanChain));
`endif

always @ (posedge P_TCK)
begin
  if(dbg_tb.i_tap_top.UpdateDR & ~dbg_tb.i_tap_top.IDCODESelected)
    begin
      if(dbg_tb.i_tap_top.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[11:4], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LENGTH-1:0]);
      else
      if(dbg_tb.i_tap_top.RegisterScanChain & ~dbg_tb.i_tap_top.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[45:38], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LENGTH-1:0]);
      else
      if(dbg_tb.i_tap_top.RiscDebugScanChain & ~dbg_tb.i_tap_top.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[72:65], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LENGTH-1:0]);
      if(dbg_tb.i_tap_top.WishboneScanChain & ~dbg_tb.i_tap_top.CHAIN_SELECTSelected)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[72:65], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LENGTH-1:0]);

      if(CRCErrorReport)
        begin
          $write("\n\t\t\t\tCrc Error when receiving data (read or write) !!!  CrcIn should be: 0x%h\n", dbg_tb.i_dbg_top.CalculatedCrcIn);
          #1000 $stop;
        end
    end
end


// Print shifted IDCode
reg [31:0] TempData;
always @ (posedge P_TCK)
begin
  if(dbg_tb.i_tap_top.IDCODESelected)
    begin
      if(dbg_tb.i_tap_top.ShiftDR)
        TempData[31:0]<=#Tp {dbg_tb.i_tap_top.tdo_pad_o, TempData[31:1]};
      else
      if(dbg_tb.i_tap_top.UpdateDR)
        $write("\n\t\tIDCode = 0x%h", TempData[31:0]);
    end
end


// Print data from the trace buffer
reg [47:0] TraceData;
always @ (posedge P_TCK)
begin
  if(dbg_tb.i_tap_top.DEBUGSelected & (dbg_tb.i_dbg_top.Chain==`TRACE_TEST_CHAIN))
    begin
      if(dbg_tb.i_tap_top.ShiftDR)
        TraceData[47:0]<=#Tp {dbg_tb.i_tap_top.tdo_pad_o, TraceData[47:1]};
      else
      if(dbg_tb.i_tap_top.UpdateDR)
        $write("\n\t\TraceData = 0x%h + Crc = 0x%h", TraceData[39:0], TraceData[47:40]);
    end
end


endmodule // TB


