//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_tb.v                                                    ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/projects/DebugInterface/           ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2003 Authors                            ////
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
// Revision 1.14  2003/10/23 16:16:30  mohor
// CRC logic changed.
//
// Revision 1.13  2003/08/28 13:54:33  simons
// Three more chains added for cpu debug access.
//
// Revision 1.12  2002/05/07 14:44:52  mohor
// mon_cntl_o signals that controls monitor mux added.
//
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
`include "dbg_wb_defines.v"
//`include "dbg_tb_defines.v"

// Test bench
module dbg_tb;

parameter TCLK = 50;   // Clock half period (Clok period = 100 ns => 10 MHz)

reg   tms_pad_i;
reg   tck_pad_i;
reg   trst_pad_i;
reg   tdi_pad_i;
wire  tdo_pad_o;
wire  tdo_padoe_o;

wire  shift_dr_o;
wire  pause_dr_o;
wire  update_dr_o;

wire  extest_select_o;
wire  sample_preload_select_o;
wire  mbist_select_o;
wire  debug_select_o;

// WISHBONE common signals
reg   wb_rst_i;
reg   wb_clk_i;
                                                                                                                                                             
// WISHBONE master interface
wire [31:0] wb_adr_o;
wire [31:0] wb_dat_o;
wire [31:0] wb_dat_i;
wire        wb_cyc_o;
wire        wb_stb_o;
wire  [3:0] wb_sel_o;
wire        wb_we_o;
wire        wb_ack_i;
wire        wb_cab_o;
wire        wb_err_i;
wire  [2:0] wb_cti_o;
wire  [1:0] wb_bte_o;






wire  tdo_o;

wire  debug_tdi_i;
wire  bs_chain_tdi_i;
wire  mbist_tdi_i;

reg   test_enabled;

reg [31:0] result;

wire tdo;

assign tdo = tdo_padoe_o? tdo_pad_o : 1'hz;

// Connecting TAP module
tap_top i_tap_top (
                    .tms_pad_i(tms_pad_i), 
                    .tck_pad_i(tck_pad_i), 
                    .trst_pad_i(!trst_pad_i), 
                    .tdi_pad_i(tdi_pad_i), 
                    .tdo_pad_o(tdo_pad_o), 
                    .tdo_padoe_o(tdo_padoe_o), 
                
                    // TAP states
                    .shift_dr_o(shift_dr_o),
                    .pause_dr_o(pause_dr_o),
                    .update_dr_o(update_dr_o),
                
                    // Select signals for boundary scan or mbist
                    .extest_select_o(extest_select_o),
                    .sample_preload_select_o(sample_preload_select_o),
                    .mbist_select_o(mbist_select_o),
                    .debug_select_o(debug_select_o),

                    // TDO signal that is connected to TDI of sub-modules.
                    .tdo_o(tdo_o),

                    // TDI signals from sub-modules
                    .debug_tdi_i(debug_tdi_i),        // from debug module
                    .bs_chain_tdi_i(bs_chain_tdi_i),  // from Boundary Scan Chain
                    .mbist_tdi_i(mbist_tdi_i)         // from Mbist Chain

               );


dbg_top i_dbg_top  (
                
                    .trst_i(!trst_pad_i),
                    .tck_i(tck_pad_i),
                    .tdi_i(tdo_o),
                    .tdo_o(debug_tdi_i),
    
                    // TAP states
                    .shift_dr_i   (shift_dr_o),
                    .pause_dr_i   (pause_dr_o),
                    .update_dr_i  (update_dr_o),
    
                    // Instructions
                    .debug_select_i(debug_select_o),

                    // WISHBONE common signals
                    .wb_rst_i      (wb_rst_i),
                    .wb_clk_i      (wb_clk_i),
                                                                                                                                                               
                    // WISHBONE master interface
                    .wb_adr_o      (wb_adr_o),
                    .wb_dat_o      (wb_dat_o),
                    .wb_dat_i      (wb_dat_i),
                    .wb_cyc_o      (wb_cyc_o),
                    .wb_stb_o      (wb_stb_o),
                    .wb_sel_o      (wb_sel_o),
                    .wb_we_o       (wb_we_o),
                    .wb_ack_i      (wb_ack_i),
                    .wb_cab_o      (wb_cab_o),
                    .wb_err_i      (wb_err_i),
                    .wb_cti_o      (wb_cti_o),
                    .wb_bte_o      (wb_bte_o)
                   );


wb_slave_behavioral wb_slave
                   (
                    .CLK_I(wb_clk_i),
                    .RST_I(wb_rst_i),
                    .ACK_O(wb_ack_i),
                    .ADR_I(wb_adr_o),
                    .CYC_I(wb_cyc_o),
                    .DAT_O(wb_dat_i),
                    .DAT_I(wb_dat_o),
                    .ERR_O(wb_err_i),
                    .RTY_O(),      // NOT USED for now!
                    .SEL_I(wb_sel_o),
                    .STB_I(wb_stb_o),
                    .WE_I (wb_we_o),
                    .CAB_I(1'b0)
                   );


// Initial values
initial
begin
  test_enabled = 1'b0;
  trst_pad_i = 1'b1;
  tms_pad_i = 1'hz;
  tck_pad_i = 1'hz;
  tdi_pad_i = 1'hz;

  #100;
  trst_pad_i = 1'b0;
  #100;
  trst_pad_i = 1'b1;
  #1 test_enabled<=#1 1'b1;
end

initial
begin
  wb_rst_i = 1'b0;
  #1000;
  wb_rst_i = 1'b1;
  #1000;
  wb_rst_i = 1'b0;

  // Initial values for wishbone slave model
  wb_slave.cycle_response(`ACK_RESPONSE, 8'h55, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
end

initial
begin
  wb_clk_i = 1'b0;
  forever #5 wb_clk_i = ~wb_clk_i;
end

always @ (posedge test_enabled)
begin

  $display("//////////////////////////////////////////////////////////////////");
  $display("//                                                              //");
  $display("//  (%0t) dbg_tb starting                                     //", $time);
  $display("//                                                              //");
  $display("//////////////////////////////////////////////////////////////////");

  initialize_memory(32'h12340000, 32'h00100000);  // Initialize 0x100000 bytes starting from address 0x12340000

  reset_tap;
  goto_run_test_idle;

  // Testing read and write to internal registers
  #10000;
  set_instruction(`IDCODE);
  read_id_code;

  set_instruction(`DEBUG);
  #10000;

  chain_select(`WISHBONE_SCAN_CHAIN, 32'hf2bcd929);

//  #10000;
//  xxx(4'b1001, 32'he579b242);

  #10000;

//  debug_wishbone(`WB_READ8, 32'h12345678, 32'h0, 16'h4, 32'h08359131, result); // {command, addr, data, length, crc, result}
//  debug_wishbone(`WB_READ8, 32'h12345679, 32'h0, 16'h4, 32'hadfeabe2, result); // {command, addr, data, length, crc, result}
//  debug_wishbone(`WB_READ8, 32'h1234567a, 32'h0, 16'h4, 32'hd8b08283, result); // {command, addr, data, length, crc, result}

//  debug_wishbone(`WB_READ16, 32'h12345678, 32'h0, 16'h4, 32'haf07fce0, result); // {command, addr, data, length, crc, result}
//  debug_wishbone(`WB_READ16, 32'h1234567a, 32'h0, 16'h4, 32'h7f82ef52, result); // {command, addr, data, length, crc, result}

  debug_wishbone(`WB_READ32, 32'h12345678, 32'h0, 16'h4, 32'h969b4113, result); // {command, addr, data, length, crc, result}

//  debug_wishbone(`WB_READ16, 32'h12345679, 32'h0, 16'h4, 32'h0accc633, result); // {command, addr, data, length, crc, result}

  #10000;
//  xxx(4'b1001, 32'he579b242);

  wb_slave.cycle_response(`NO_RESPONSE, 8'h03, 8'h2);   // (`NO_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone_shift_dr(`WB_READ32, 32'h12345678, 32'h0, 16'h4, 32'h969b4113, result); // {command, addr, data, length, crc, result}
  wb_slave.cycle_response(`ACK_RESPONSE, 8'h55, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);

  #10000;
  debug_wishbone_shift_dr(`WB_READ32, 32'h12346668, 32'h0, 16'h4, 32'h2ec6ae56, result); // {command, addr, data, length, crc, result}

  #10000;
  debug_wishbone_shift_dr(`WB_READ32, 32'h12346668, 32'h0, 16'h4, 32'h2ec6ae56, result); // {command, addr, data, length, crc, result}



/*
  // Testing read and write to CPU0 registers
  #10000;
  set_instruction(`CHAIN_SELECT);
  chain_select(`CPU_DEBUG_CHAIN_0, 8'h12);  // {chain, crc}
  set_instruction(`DEBUG);
  WriteCPURegister(32'h11001100, 32'h00110011, 8'h86);  // {data, addr, crc}

  ReadCPURegister(32'h11001100, 8'hdb);                 // {addr, crc}
  ReadCPURegister(32'h11001100, 8'hdb);                 // {addr, crc}
*/
  #5000 gen_clk(1);            // One extra TCLK for debugging purposes
  #1000 $stop;

end


task initialize_memory;
  input [31:0] start_addr;
  input [31:0] length;
  integer i;
  reg [31:0] addr;
  begin
    for (i=0; i<length; i=i+4)
      begin
        addr = start_addr + i;
        wb_slave.wr_mem(addr, {addr[7:0], addr[15:8], addr[23:16], addr[31:24]}, 4'hf);    // adr, data, sel
      end
  end
endtask



// Generation of the TCLK signal
task gen_clk;
  input [7:0] num;
  integer i;
  begin
    for(i=0; i<num; i=i+1)
      begin
        #TCLK tck_pad_i<=1;
        #TCLK tck_pad_i<=0;
      end
  end
endtask


// TAP reset
task reset_tap;
  begin
    $display("(%0t) Task reset_tap", $time);
    tms_pad_i<=#1 1'b1;
    gen_clk(7);
  end
endtask


// Goes to RunTestIdle state
task goto_run_test_idle;
  begin
    $display("(%0t) Task goto_run_test_idle", $time);
    tms_pad_i<=#1 1'b0;
    gen_clk(1);
  end
endtask


// sets the instruction to the IR register and goes to the RunTestIdle state
task set_instruction;
  input [3:0] instr;
  integer i;
  
  begin
    $display("(%0t) Task set_instruction", $time);
    tms_pad_i<=#1 1;
    gen_clk(2);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftIR

    for(i=0; i<`IR_LENGTH-1; i=i+1)
    begin
      tdi_pad_i<=#1 instr[i];
      gen_clk(1);
    end
    
    tdi_pad_i<=#1 instr[i]; // last shift
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
      tdi_pad_i<=#1 'hz;    // tri-state
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle
  end
endtask


// Reads the ID code
task read_id_code;
  begin
    $display("(%0t) Task read_id_code", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 0;
    gen_clk(31);

    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);

    tdi_pad_i<=#1 'hz; // tri-state
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle
  end
endtask


// sets the selected scan chain and goes to the RunTestIdle state
task chain_select;
  input [3:0]  data;
  input [31:0] crc;
  integer i;
  
  begin
    $display("(%0t) Task chain_select", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b1; // chain_select bit
    gen_clk(1);

    for(i=0; i<`CHAIN_ID_LENGTH; i=i+1)
    begin
      tdi_pad_i<=#1 data[i];
      gen_clk(1);
    end

    for(i=0; i<`CRC_LEN; i=i+1)
    begin
      tdi_pad_i<=#1 crc[`CRC_LEN -1-i];
      gen_clk(1);
    end

    gen_clk(`STATUS_LEN);   // Generating 5 clocks to read out status.


    for(i=0; i<`CRC_LEN -1; i=i+1)
    begin
      tdi_pad_i<=#1 1'b0;
      gen_clk(1);
    end

    tdi_pad_i<=#1 crc[i]; // last crc
    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tdi_pad_i<=#1 'hz;  // tri-state
    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask


// Performs 32-bit read to the selected chain
task debug_wishbone;
  input [2:0]   command;
  input [31:0]  addr;
  input [31:0]  data;
  input [15:0]  length;
  input [31:0]  crc;
  output [31:0] result;
  integer i;
  
  begin
   $write("(%0t) Task debug_wishbone: ", $time);

    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b0; // chain_select bit = 0
    gen_clk(1);

    case (command)
      `WB_STATUS   : 
        begin
          $display("wb_status");
        end 
      `WB_READ8    :  
        begin
          $display("wb_read8 (adr=0x%0x, length=0x%0x, crc=0x%0x)", addr, length, crc);
        end
      `WB_READ16   :  
        begin
          $display("wb_read16 (adr=0x%0x, length=0x%0x, crc=0x%0x)", addr, length, crc);
        end
      `WB_READ32   :  
        begin
          $display("wb_read32 (adr=0x%0x, length=0x%0x, crc=0x%0x)", addr, length, crc);
        end
      `WB_WRITE8   :  
        begin
          $display("wb_write8 (adr=0x%0x, data=0x%0x, length=0x%0x, crc=0x%0x)", addr, data, length, crc);
        end
      `WB_WRITE16  :  
        begin
          $display("wb_write16 (adr=0x%0x, data=0x%0x, length=0x%0x, crc=0x%0x)", addr, data, length, crc);
        end
      `WB_WRITE32  :  
        begin
          $display("wb_write32 (adr=0x%0x, data=0x%0x, length=0x%0x, crc=0x%0x)", addr, data, length, crc);
        end
      `WB_GO       :  
        begin
          $display("wb_go, crc=0x%0x)", crc);
        end
    endcase


 

    for(i=0; i<3; i=i+1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      gen_clk(1);
    end

    for(i=0; i<32; i=i+1)       // address
    begin
      tdi_pad_i<=#1 addr[i];
      gen_clk(1);
    end

    for(i=0; i<16; i=i+1)       // length
    begin
      tdi_pad_i<=#1 length[i];
      gen_clk(1);
    end

    for(i=0; i<`CRC_LEN; i=i+1)
    begin
      tdi_pad_i<=#1 crc[`CRC_LEN -1-i];
      gen_clk(1);
    end

    gen_clk(`STATUS_LEN);   // Generating 5 clocks to read out status.


    for(i=0; i<`CRC_LEN -1; i=i+1)
    begin
      tdi_pad_i<=#1 1'b0;
      gen_clk(1);
    end

    tdi_pad_i<=#1 crc[i]; // last crc
    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tdi_pad_i<=#1 'hz;  // tri-state
    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask






// Performs 32-bit read to the selected chain waiting some time in shift_dr
task debug_wishbone_shift_dr;
  input [2:0]   command;
  input [31:0]  addr;
  input [31:0]  data;
  input [15:0]  length;
  input [31:0]  crc;
  output [31:0] result;
  integer i;
  
  begin
   $write("(%0t) Task debug_wishbone_shift_dr: ", $time);

    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b0; // chain_select bit = 0
    gen_clk(1);

    case (command)
      `WB_STATUS   : 
        begin
          $display("wb_status");
        end 
      `WB_READ8    :  
        begin
          $display("wb_read8 (adr=0x%0x, length=0x%0x, crc=0x%0x)", addr, length, crc);
        end
      `WB_READ16   :  
        begin
          $display("wb_read16 (adr=0x%0x, length=0x%0x, crc=0x%0x)", addr, length, crc);
        end
      `WB_READ32   :  
        begin
          $display("wb_read32 (adr=0x%0x, length=0x%0x, crc=0x%0x)", addr, length, crc);
        end
      `WB_WRITE8   :  
        begin
          $display("wb_write8 (adr=0x%0x, data=0x%0x, length=0x%0x, crc=0x%0x)", addr, data, length, crc);
        end
      `WB_WRITE16  :  
        begin
          $display("wb_write16 (adr=0x%0x, data=0x%0x, length=0x%0x, crc=0x%0x)", addr, data, length, crc);
        end
      `WB_WRITE32  :  
        begin
          $display("wb_write32 (adr=0x%0x, data=0x%0x, length=0x%0x, crc=0x%0x)", addr, data, length, crc);
        end
      `WB_GO       :  
        begin
          $display("wb_go, crc=0x%0x)", crc);
        end
    endcase


 

    for(i=0; i<3; i=i+1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      gen_clk(1);
    end

    for(i=0; i<32; i=i+1)       // address
    begin
      tdi_pad_i<=#1 addr[i];
      gen_clk(1);
    end

    for(i=0; i<16; i=i+1)       // length
    begin
      tdi_pad_i<=#1 length[i];
      gen_clk(1);
    end

    for(i=0; i<`CRC_LEN; i=i+1)
    begin
      tdi_pad_i<=#1 crc[`CRC_LEN -1-i];
      gen_clk(1);
    end

    gen_clk(`STATUS_LEN -1);   // Generating 4 clocks to read out status. Going to pause_dr at the end

    tdi_pad_i<=#1 'hz;
    tms_pad_i<=#1 1;
    gen_clk(1);       // to exit1_dr
    tms_pad_i<=#1 0;
    gen_clk(1);       // to pause_dr

    while (dbg_tb.tdo_pad_o)     // waiting for wb to send "ready" 
    begin
      gen_clk(1);       // staying in pause_dr
    end
    
    tms_pad_i<=#1 1;
    gen_clk(1);       // to exit2_dr
    tms_pad_i<=#1 0;
    gen_clk(1);       // to shift_dr

    for(i=0; i<`CRC_LEN -1; i=i+1)
    begin
      tdi_pad_i<=#1 1'b0;
      gen_clk(1);
    end

    tdi_pad_i<=#1 crc[i]; // last crc
    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tdi_pad_i<=#1 'hz;  // tri-state
    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask






// Reads sample from the Trace Buffer
task ReadTraceBuffer;
  begin
    $display("(%0t) Task ReadTraceBuffer", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 0;
    gen_clk(47);
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
      tdi_pad_i<=#1 'hz; // tri-state
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle
  end
endtask


// Reads the CPU register and latches the data so it is ready for reading
task ReadCPURegister;
  input [31:0] Address;
  input [7:0] crc;
  integer i;
  
  begin
    $display("(%0t) Task ReadCPURegister", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    for(i=0; i<32; i=i+1)
    begin
      tdi_pad_i<=#1 Address[i];  // Shifting address
      gen_clk(1);
    end

    tdi_pad_i<=#1 0;             // shifting RW bit = read
    gen_clk(1);

    for(i=0; i<32; i=i+1)
    begin
      tdi_pad_i<=#1 0;     // Shifting data. Data is not important in read cycle.
      gen_clk(1);
    end

//    for(i=0; i<`CRC_LEN -1; i=i+1)
    for(i=0; i<`CRC_LEN; i=i+1)      // crc is 9 bit long
    begin
      tdi_pad_i<=#1 crc[i];     // Shifting CRC.
      gen_clk(1);
    end

//    tdi_pad_i<=#1 crc[i];   // Shifting last bit of CRC.
    tdi_pad_i<=#1 1'b0;       // crc[i];   // Shifting last bit of CRC.
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
      tdi_pad_i<=#1 'hz;   // Tristate TDI.
    gen_clk(1);

    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle
  end
endtask


// Write the CPU register
task WriteCPURegister;
  input [31:0] data;
  input [31:0] Address;
  input [`CRC_LEN -1:0] crc;
  integer i;
  
  begin
    $display("(%0t) Task WriteCPURegister", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    for(i=0; i<32; i=i+1)
    begin
      tdi_pad_i<=#1 Address[i];  // Shifting address
      gen_clk(1);
    end

    tdi_pad_i<=#1 1;             // shifting RW bit = write
    gen_clk(1);

    for(i=0; i<32; i=i+1)
    begin
      tdi_pad_i<=#1 data[i];     // Shifting data
      gen_clk(1);
    end

//    for(i=0; i<`CRC_LEN -1; i=i+1)
    for(i=0; i<`CRC_LEN; i=i+1)      // crc is 9 bit long
    begin
      tdi_pad_i<=#1 crc[i];     // Shifting CRC
      gen_clk(1);
    end

//    tdi_pad_i<=#1 crc[i];        // shifting last bit of CRC
    tdi_pad_i<=#1 1'b0;            // crc[i];        // shifting last bit of CRC
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
      tdi_pad_i<=#1 'hz;        // tristate TDI
    gen_clk(1);

    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle

    gen_clk(10);      // Generating few clock cycles needed for the write operation to accomplish
  end
endtask


// Reads the register and latches the data so it is ready for reading
task ReadRegister;
  input [4:0] Address;
  input [7:0] crc;
  integer i;
  
  begin
    $display("(%0t) Task ReadRegister", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    for(i=0; i<5; i=i+1)
    begin
      tdi_pad_i<=#1 Address[i];  // Shifting address
      gen_clk(1);
    end

    tdi_pad_i<=#1 0;             // shifting RW bit = read
    gen_clk(1);

    for(i=0; i<32; i=i+1)
    begin
      tdi_pad_i<=#1 0;     // Shifting data. Data is not important in read cycle.
      gen_clk(1);
    end

//    for(i=0; i<`CRC_LEN -1; i=i+1)
    for(i=0; i<`CRC_LEN; i=i+1)      // crc is 9 bit long
    begin
      tdi_pad_i<=#1 crc[i];     // Shifting CRC. CRC is not important in read cycle.
      gen_clk(1);
    end

//    tdi_pad_i<=#1 crc[i];     // Shifting last bit of CRC.
    tdi_pad_i<=#1 1'b0;         // crc[i];     // Shifting last bit of CRC.
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
      tdi_pad_i<=#1 'hz;     // Tri state TDI
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle

    gen_clk(10);      // Generating few clock cycles needed for the read operation to accomplish
  end
endtask

 
// Write the register
task WriteRegister;
  input [31:0] data;
  input [4:0] Address;
  input [`CRC_LEN -1:0] crc;
  integer i;
  
  begin
    $display("(%0t) Task WriteRegister", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    for(i=0; i<5; i=i+1)
    begin
      tdi_pad_i<=#1 Address[i];  // Shifting address
      gen_clk(1);
    end

    tdi_pad_i<=#1 1;             // shifting RW bit = write
    gen_clk(1);

    for(i=0; i<32; i=i+1)
    begin
      tdi_pad_i<=#1 data[i];     // Shifting data
      gen_clk(1);
    end
    
//    for(i=0; i<`CRC_LEN -1; i=i+1)
    for(i=0; i<`CRC_LEN; i=i+1)      // crc is 9 bit long
    begin
      tdi_pad_i<=#1 crc[i];     // Shifting CRC
      gen_clk(1);
    end

//    tdi_pad_i<=#1 crc[i];   // Shifting last bit of CRC
    tdi_pad_i<=#1 1'b0;       // crc[i];   // Shifting last bit of CRC
    tms_pad_i<=#1 1;        // going out of shiftIR
    gen_clk(1);
      tdi_pad_i<=#1 'hz;   // Tri state TDI
    gen_clk(1);

    tms_pad_i<=#1 0;
    gen_clk(1);       // we are in RunTestIdle

    gen_clk(5);       // Extra clocks needed for operations to finish 

  end
endtask

/*
task EnableWishboneSlave;
begin
$display("(%0t) Task EnableWishboneSlave", $time);
while(1)
  begin
    @ (posedge Mclk);
    if(wb_stb_i & wb_cyc_i) // WB access
//    wait (wb_stb_i & wb_cyc_i) // WB access
      begin
        @ (posedge Mclk);
        @ (posedge Mclk);
        @ (posedge Mclk);
        #1 wb_ack_o = 1;
        if(~wb_we_i) // read
          wb_dat_o = 32'hbeefdead;
          wb_dat_o = {wb_adr_i[3:0],   wb_adr_i[7:4],   wb_adr_i[11:8],  wb_adr_i[15:12],
                      wb_adr_i[19:16], wb_adr_i[23:20], wb_adr_i[27:24], wb_adr_i[31:28]};
        if(wb_we_i & wb_stb_i & wb_cyc_i) // write
          $display("\nWISHBONE write data=%0h, Addr=%0h", wb_dat_i, wb_adr_i);
        if(~wb_we_i & wb_stb_i & wb_cyc_i) // read
          $display("\nWISHBONE read data=%0h, Addr=%0h", wb_dat_o, wb_adr_i);
      end
    @ (posedge Mclk);
    #1 wb_ack_o = 0;
    wb_dat_o = 32'h0;
  end

end
endtask
*/





/**********************************************************************************
*                                                                                 *
*   Printing the information to the screen                                        *
*                                                                                 *
**********************************************************************************/

always @ (posedge tck_pad_i)
begin
  if(dbg_tb.i_tap_top.update_ir)
    case(dbg_tb.i_tap_top.jtag_ir[`IR_LENGTH-1:0])
      `EXTEST         : $display("\tInstruction EXTEST entered");
      `SAMPLE_PRELOAD : $display("\tInstruction SAMPLE_PRELOAD entered");
      `IDCODE         : $display("\tInstruction IDCODE entered");
      `MBIST          : $display("\tInstruction MBIST entered");
      `DEBUG          : $display("\tInstruction DEBUG entered");
      `BYPASS         : $display("\tInstruction BYPASS entered");
		default           :	$display("\n\tInstruction not valid. Instruction BYPASS activated !!!");
    endcase
end


// Print selected chain
/*
always @ (posedge tck_pad_i)
begin
  if(dbg_tb.i_tap_top.chain_select & dbg_tb.i_dbg_top.update_dr_q)
    case(dbg_tb.i_dbg_top.Chain[`CHAIN_ID_LENGTH-1:0])
      `GLOBAL_BS_CHAIN      : $write("\nChain GLOBAL_BS_CHAIN");
      `CPU_DEBUG_CHAIN_0    : $write("\nChain CPU_DEBUG_CHAIN_0");
      `CPU_DEBUG_CHAIN_1    : $write("\nChain CPU_DEBUG_CHAIN_1");
      `CPU_DEBUG_CHAIN_2    : $write("\nChain CPU_DEBUG_CHAIN_2");
      `CPU_DEBUG_CHAIN_3    : $write("\nChain CPU_DEBUG_CHAIN_3");
      `CPU_TEST_CHAIN       : $write("\nChain CPU_TEST_CHAIN");
      `TRACE_TEST_CHAIN     : $write("\nChain TRACE_TEST_CHAIN");
      `REGISTER_SCAN_CHAIN  : $write("\nChain REGISTER_SCAN_CHAIN");
      `WISHBONE_SCAN_CHAIN  : $write("\nChain WISHBONE_SCAN_CHAIN");
    endcase
end
*/

// print CPU registers read/write
/*
always @ (posedge Mclk)
begin
  if(dbg_tb.i_dbg_top.CPUAccess0 & ~dbg_tb.i_dbg_top.CPUAccess_q & dbg_tb.i_dbg_top.RW)
    $write("\n\t\tWrite to CPU Register (addr=0x%h, data=0x%h)", dbg_tb.i_dbg_top.ADDR[31:0], dbg_tb.i_dbg_top.DataOut[31:0]);
  else
  if(dbg_tb.i_dbg_top.CPUAccess_q & ~dbg_tb.i_dbg_top.CPUAccess_q2 & ~dbg_tb.i_dbg_top.RW)
    $write("\n\t\tRead from CPU Register (addr=0x%h, data=0x%h)", dbg_tb.i_dbg_top.ADDR[31:0], dbg_tb.i_dbg_top.cpu_data_i[31:0]);
end
*/

// print registers read/write
/*
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
*/

// print CRC error
/*
`ifdef TRACE_ENABLED
  wire CRCErrorReport = ~(dbg_tb.i_dbg_top.CrcMatch & (dbg_tb.i_dbg_top.chain_select | dbg_tb.i_dbg_top.debug_select & register_scan_chain | dbg_tb.i_dbg_top.debug_select & (cpu_debug_scan_chain0 | cpu_debug_scan_chain1 | cpu_debug_scan_chain2 | cpu_debug_scan_chain3) | dbg_tb.i_dbg_top.debug_select & dbg_tb.i_dbg_top.TraceTestScanChain | dbg_tb.i_dbg_top.debug_select & wishbone_scan_chain));
`else  // TRACE_ENABLED not enabled
  wire CRCErrorReport = ~(dbg_tb.i_dbg_top.CrcMatch & (dbg_tb.i_tap_top.chain_select | dbg_tb.i_tap_top.debug_select & register_scan_chain | dbg_tb.i_tap_top.debug_select & (cpu_debug_scan_chain0 | cpu_debug_scan_chain1 | cpu_debug_scan_chain2 | cpu_debug_scan_chain3) | dbg_tb.i_tap_top.debug_select & wishbone_scan_chain));
`endif
*/

/*
// print crc
always @ (posedge P_TCK)
begin
  if(dbg_tb.i_tap_top.update_dr & ~dbg_tb.i_tap_top.idcode_select)
    begin
      if(dbg_tb.i_tap_top.chain_select)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[11:4], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LEN -1:0]);
      else
      if(register_scan_chain & ~dbg_tb.i_tap_top.chain_select)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[45:38], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LEN -1:0]);
      else
      if((cpu_debug_scan_chain0 | cpu_debug_scan_chain1 | cpu_debug_scan_chain2 | cpu_debug_scan_chain3) & ~dbg_tb.i_tap_top.chain_select)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[72:65], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LEN -1:0]);
      if(wishbone_scan_chain & ~dbg_tb.i_tap_top.chain_select)
        $write("\t\tCrcIn=0x%h, CrcOut=0x%h", dbg_tb.i_dbg_top.JTAG_DR_IN[72:65], dbg_tb.i_dbg_top.CalculatedCrcOut[`CRC_LEN -1:0]);

      if(CRCErrorReport)
        begin
          $write("\n\t\t\t\tCrc Error when receiving data (read or write) !!!  CrcIn should be: 0x%h\n", dbg_tb.i_dbg_top.CalculatedCrcIn);
          #1000 $stop;
        end
      $display("\n");
    end
end
*/

// Print shifted IDCode
reg [31:0] tmp_data;
always @ (posedge tck_pad_i)
begin
  if(dbg_tb.i_tap_top.idcode_select)
    begin
      if(dbg_tb.i_tap_top.shift_dr)
        tmp_data[31:0]<=#1 {dbg_tb.tdo, tmp_data[31:1]};
      else
      if(dbg_tb.i_tap_top.update_dr)
        if (tmp_data[31:0] != `IDCODE_VALUE)
          begin
            $display("(%0t) ERROR: IDCODE not correct", $time);
            $stop;
          end
        else
          $display("\t\tIDCode = 0x%h", tmp_data[31:0]);
    end
end


// We never use following states: exit2_ir,  exit2_dr,  pause_ir or pause_dr
always @ (posedge tck_pad_i)
begin
  if(dbg_tb.i_tap_top.pause_ir | dbg_tb.i_tap_top.exit2_ir)
    begin
      $display("\n(%0t) ERROR: State pause_ir or exit2_ir detected.", $time);
      $display("(%0t) Simulation stopped !!!", $time);
      $stop;
    end
end


// sets the selected scan chain and goes to the RunTestIdle state
task xxx;
  input [3:0]  data;
  input [31:0] crc;
  integer i;
  
  begin
    $display("(%0t) Task xxx", $time);
    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    for(i=0; i<4; i=i+1)
    begin
      tdi_pad_i<=#1 data[i];
      gen_clk(1);
    end

    for(i=0; i<`CRC_LEN; i=i+1)
    begin
      tdi_pad_i<=#1 crc[`CRC_LEN - 1 - i];
      gen_clk(1);
    end

    gen_clk(`STATUS_LEN);   // Generating 5 clocks to read out status.


    for(i=0; i<`CRC_LEN -1; i=i+1)
    begin
      tdi_pad_i<=#1 1'b0;
      gen_clk(1);
    end

    tdi_pad_i<=#1 crc[i]; // last crc
    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tdi_pad_i<=#1 'hz;  // tri-state
    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask





endmodule // dbg_tb


