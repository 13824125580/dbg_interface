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
// Revision 1.23  2004/01/14 22:59:01  mohor
// Temp version.
//
// Revision 1.22  2004/01/13 11:28:30  mohor
// tmp version.
//
// Revision 1.21  2004/01/10 07:50:41  mohor
// temp version.
//
// Revision 1.20  2004/01/09 12:49:23  mohor
// tmp version.
//
// Revision 1.19  2004/01/08 17:53:12  mohor
// tmp version.
//
// Revision 1.18  2004/01/07 11:59:48  mohor
// temp4 version.
//
// Revision 1.17  2004/01/06 17:14:59  mohor
// temp3 version.
//
// Revision 1.16  2004/01/05 12:16:50  mohor
// tmp2 version.
//
// Revision 1.15  2003/12/23 14:26:01  mohor
// New version of the debug interface. Not finished, yet.
//
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

// Text used for easier debugging
reg  [99:0] test_text;
reg   [2:0] last_wb_cmd;
reg  [99:0] last_wb_cmd_text;
reg  [31:0] wb_data;



wire  tdo_o;

wire  debug_tdi_i;
wire  bs_chain_tdi_i;
wire  mbist_tdi_i;

reg   test_enabled;

reg [31:0] result;

reg [31:0] tmp_crc;
reg [31:0] shifted_in_crc;

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
  wb_data = 32'h01234567;
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
  wb_slave.cycle_response(`ACK_RESPONSE, 9'h55, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
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

  #500;
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

//  debug_wishbone(`WB_READ8, 1'b0, 32'h12345678, 16'h4, 32'h57ecda62, result, "abc 1"); // {command, ready, addr, length, crc, result, text}
//  debug_wishbone(`WB_READ8, 1'b0, 32'h12345679, 16'h4, 32'h563476e5, result, "abc 2"); // {command, ready, addr, length, crc, result, text}
//  debug_wishbone(`WB_READ8, 1'b0, 32'h1234567a, 16'h4, 32'h545d836c, result, "abc 3"); // {command, ready, addr, length, crc, result, text}
//
//  debug_wishbone(`WB_READ16, 1'b0, 32'h12345678, 16'h4, 32'h86156251, result, "abc 4"); // {command, ready, addr, length, crc, result, text}
//  debug_wishbone(`WB_READ16, 1'b0, 32'h1234567a, 16'h4, 32'h85a43b5f, result, "abc 5"); // {command, ready, addr, length, crc, result, text}
//
  debug_wishbone(`WB_READ32, 1'b0, 32'h12345678, 16'h4, 32'hc9420a40, result, "read32 1"); // {command, ready, addr, length, crc, result, text}
//
//  debug_wishbone(`WB_READ16, 1'b0, 32'h12345679, 16'h4, 32'h87cdced6, result, "abc 6"); // {command, ready, addr, length, crc, result, text}

  #10000;
//  xxx(4'b1001, 32'he579b242);

  debug_wishbone(`WB_READ32, 1'b1, 32'h12345678, 16'h4, 32'hc9420a40, result, "read32 2"); // {command, ready, addr, length, crc, result, text}

  #10000;
  wb_slave.cycle_response(`ACK_RESPONSE, 9'h55, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone(`WB_READ32, 1'b1, 32'h12346668, 16'h4, 32'hc935a962, result, "read32 3"); // {command, ready, addr, length, crc, result, text}

  #10000;
  wb_slave.cycle_response(`ERR_RESPONSE, 9'h03, 8'h2);   // (`ERR_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone(`WB_READ32, 1'b1, 32'h12346668, 16'h4, 32'hc935a962, result, "read32 4"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_STATUS, 1'b0, 32'h0, 16'h0, 32'hc7b0424d, result, "status 1"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_STATUS, 1'b0, 32'h0, 16'h0, 32'hc7b0424d, result, "status 2"); // {command, ready, addr, length, crc, result, text}

  #10000;
  wb_slave.cycle_response(`ACK_RESPONSE, 9'h012, 8'h2);   // (`ACK_RESPONSE, wbs_waits, wbs_retries);
  debug_wishbone(`WB_READ32, 1'b1, 32'h12347778, 16'hc, 32'hd9ce3bbe, result, "read32 5"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_WRITE32, 1'b0, 32'h12346668, 16'h8, 32'hc5a58ff5, result, "wr32 len8"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_WRITE16, 1'b0, 32'h12344446, 16'h8, 32'hed029606, result, "wr16 len8"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_WRITE8, 1'b0, 32'h1234010e, 16'h8, 32'h359e2d2a, result, "wr8 len8"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_GO, 1'b0, 32'h0, 16'h0, 32'h5e9dd377, result, "go 1"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_READ32, 1'b1, 32'h12340100, 16'hc, 32'h8bbeb90d, result, "read32 6"); // {command, ready, addr, length, crc, result, text}
//  debug_wishbone(`WB_READ32, 1'b1, 32'h12340100, 16'hfffc, 32'h4cb960cd, result, "read32 6"); // {command, ready, addr, length, crc, result, text}

  #10000;
//  debug_wishbone(`WB_READ16, 1'b1, 32'h12340102, 16'he, 32'hcedab37c, result, "read16 7"); // {command, ready, addr, length, crc, result, text}
//  debug_wishbone(`WB_READ16, 1'b1, 32'h12340102, 16'hfffe, 32'h9dd6abc, result, "read16 7"); // {command, ready, addr, length, crc, result, text}

  #10000;
//  debug_wishbone(`WB_READ8, 1'b1, 32'h12348804, 16'h6, 32'hbe993245, result, "read8 8"); // {command, ready, addr, length, crc, result, text}  
//  debug_wishbone(`WB_READ8, 1'b1, 32'h12348804, 16'hfffc, 32'h56143d53, result, "read8 8"); // {command, ready, addr, length, crc, result, text}

  #10000;
  debug_wishbone(`WB_GO, 1'b0, 32'h0, 16'h0, 32'hd4b43491, result, "go 2"); // {command, ready, addr, length, crc, result, text}




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
  $display("\n\nSimulation end.");
  #1000 $stop;

end


task initialize_memory;
  input [31:0] start_addr;
  input [31:0] length;
  integer i;
  reg [31:0] addr;
  begin
//    for (i=0; i<length; i=i+4)    // inverted address
//      begin
//        addr = start_addr + i;
//        wb_slave.wr_mem(addr, {addr[7:0], addr[15:8], addr[23:16], addr[31:24]}, 4'hf);    // adr, data, sel
//      end
    for (i=0; i<length; i=i+4)
      begin
        addr = start_addr + i;
        wb_slave.wr_mem(addr, {addr[7:0], addr[7:0]+2'd1, addr[7:0]+2'd2, addr[7:0]+2'd3}, 4'hf);    // adr, data, sel
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
    gen_clk(5);
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







task debug_wishbone;
  input [2:0]   command;
  input         ready;
  input [31:0]  addr;
  input [15:0]  length;
  input [31:0]  crc;
  output [31:0] result;
  input [99:0]  text;
  integer i;
  
  begin
   $write("(%0t) Task debug_wishbone: ", $time);

    test_text = text;
    shifted_in_crc = crc;

    case (command)
      `WB_STATUS   : 
        begin
          $display("wb_status (crc=0x%0x (%0s))", crc, text);
          debug_wishbone_status(command, crc);
          last_wb_cmd = `WB_STATUS;  last_wb_cmd_text = "WB_STATUS";
        end 
      `WB_READ8    :  
        begin
          $display("wb_read8 (ready=%0d, adr=0x%0x, length=0x%0x, crc=0x%0x (%0s))", ready, addr, length, crc, text);
          debug_wishbone_set_addr(command, ready, addr, length, crc);
          last_wb_cmd = `WB_READ8;  last_wb_cmd_text = "WB_READ8";
        end
      `WB_READ16   :  
        begin
          $display("wb_read16 (ready=%0d, adr=0x%0x, length=0x%0x, crc=0x%0x (%0s))", ready, addr, length, crc, text);
          debug_wishbone_set_addr(command, ready, addr, length, crc);
          last_wb_cmd = `WB_READ16;  last_wb_cmd_text = "WB_READ16";
        end
      `WB_READ32   :  
        begin
          $display("wb_read32 (ready=%0d, adr=0x%0x, length=0x%0x, crc=0x%0x (%0s))", ready, addr, length, crc, text);
          debug_wishbone_set_addr(command, ready, addr, length, crc);
          last_wb_cmd = `WB_READ32;  last_wb_cmd_text = "WB_READ32";
        end
      `WB_WRITE8   :  
        begin
          $display("wb_write8 (adr=0x%0x, length=0x%0x, crc=0x%0x (%0s))", addr, length, crc, text);
          debug_wishbone_set_addr(command, ready, addr, length, crc);
          last_wb_cmd = `WB_WRITE8;  last_wb_cmd_text = "WB_WRITE8";
        end
      `WB_WRITE16  :  
        begin
          $display("wb_write16 (adr=0x%0x, length=0x%0x, crc=0x%0x (%0s))", addr, length, crc, text);
          debug_wishbone_set_addr(command, ready, addr, length, crc);
          last_wb_cmd = `WB_WRITE16;  last_wb_cmd_text = "WB_WRITE16";
        end
      `WB_WRITE32  :  
        begin
          $display("wb_write32 (adr=0x%0x, length=0x%0x, crc=0x%0x (%0s))", addr, length, crc, text);
          debug_wishbone_set_addr(command, ready, addr, length, crc);
          last_wb_cmd = `WB_WRITE32;  last_wb_cmd_text = "WB_WRITE32";
        end
      `WB_GO       :  
        begin
          $display("wb_go, crc=0x%0x (%0s))", crc, text);
          debug_wishbone_go(command, crc);
//          $display("wb_go_tmp, crc=0x%0x (%0s))", crc, text);
//          debug_wishbone_go_tmp(command, crc);
          last_wb_cmd = `WB_GO;  last_wb_cmd_text = "WB_GO";
        end
    endcase
  end
endtask       // debug_wishbone






task debug_wishbone_set_addr;
  input [2:0]   command;
  input         wait_for_wb_ready;
  input [31:0]  addr;
  input [15:0]  length;
  input [31:0]  crc;
  integer i;
  
  begin
    $display("(%0t) Task debug_wishbone_set_addr: ", $time);

    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b0; // chain_select bit = 0
    gen_clk(1);

    for(i=2; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      gen_clk(1);
    end

    for(i=31; i>=0; i=i-1)       // address
    begin
      tdi_pad_i<=#1 addr[i];
      gen_clk(1);
    end
 
    for(i=15; i>=0; i=i-1)       // length
    begin
      tdi_pad_i<=#1 length[i];
      gen_clk(1);
    end

    for(i=31; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 crc[i];
      gen_clk(1);
    end

    tdi_pad_i<=#1 'hz;
    if (wait_for_wb_ready)
      begin
        gen_clk(`STATUS_LEN -1);   // Generating 4 clocks to read out status. Going to pause_dr at the end
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
      end
    else
      gen_clk(`STATUS_LEN);   // Generating 4 clocks to read out status.

    for(i=0; i<`CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_set_addr





task debug_wishbone_status;
  input [2:0]   command;
  input [31:0]  crc;
  integer i;
  
  begin
    $display("(%0t) Task debug_wishbone_status: ", $time);

    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b0; // chain_select bit = 0
    gen_clk(1);

    for(i=2; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      gen_clk(1);
    end

    for(i=31; i>=0; i=i-1)      // crc
    begin
      tdi_pad_i<=#1 crc[i];
      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;
    gen_clk(`STATUS_LEN);   // Generating 4 clocks to read out status.

    for(i=0; i<`CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_status




task debug_wishbone_go;
  input [2:0]   command;
  input [31:0]  crc;
  integer i;
  reg   [4:0]   pointer; 
 
  begin
    $display("(%0t) Task debug_wishbone_go (previous command was %0s): ", $time, last_wb_cmd_text);

    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b0; // chain_select bit = 0
    gen_clk(1);

    for(i=2; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      gen_clk(1);
    end


    if ((last_wb_cmd == `WB_WRITE8) | (last_wb_cmd == `WB_WRITE16) | (last_wb_cmd == `WB_WRITE32))  // When WB_WRITEx was previously activated, data needs to be shifted.
      begin
        for (i=0; i<(dbg_tb.i_dbg_top.i_dbg_wb.len << 3); i=i+1)
          begin
            if (!(i%32))
              begin
                wb_data = wb_data + 32'h11111111;
                $display("\t\twb_data = 0x%x", wb_data);
              end
            pointer = 31-i[4:0];
            tdi_pad_i<=#1 wb_data[pointer];
            gen_clk(1);

          end
      end


    for(i=31; i>=0; i=i-1)      // crc
    begin
      tdi_pad_i<=#1 crc[i];
      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;



    if ((last_wb_cmd == `WB_READ8) | (last_wb_cmd == `WB_READ16) | (last_wb_cmd == `WB_READ32))  // When WB_WRITEx was previously activated, data needs to be shifted.
      begin
        $display("\t\tGenerating %0d clocks to read %0d data bytes.", dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_limit, dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_limit>>3);
        for (i=0; i<(dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_limit); i=i+1)
          gen_clk(1);
      end


    gen_clk(`STATUS_LEN);   // Generating 4 clocks to read out status.

    for(i=0; i<`CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_go





task debug_wishbone_go_tmp;
  input [2:0]   command;
  input [31:0]  crc;
  integer i;
  reg   [4:0]   pointer; 
 
  begin
    $display("(%0t) Task debug_wishbone_go_tmp (previous command was %0s): ", $time, last_wb_cmd_text);

    tms_pad_i<=#1 1;
    gen_clk(1);
    tms_pad_i<=#1 0;
    gen_clk(2);  // we are in shiftDR

    tdi_pad_i<=#1 1'b0; // chain_select bit = 0
    gen_clk(1);

    for(i=2; i>=0; i=i-1)
    begin
      tdi_pad_i<=#1 command[i]; // command
      gen_clk(1);
    end


    if ((last_wb_cmd == `WB_WRITE8) | (last_wb_cmd == `WB_WRITE16) | (last_wb_cmd == `WB_WRITE32))  // When WB_WRITEx was previously activated, data needs to be shifted.
      begin
        for (i=0; i<(dbg_tb.i_dbg_top.i_dbg_wb.len << 3); i=i+1)
          begin
            if (!(i%32))
              begin
                wb_data = wb_data + 32'h11111111;
                $display("\t\twb_data = 0x%x", wb_data);
              end
            pointer = 31-i[4:0];
            tdi_pad_i<=#1 wb_data[pointer];
            gen_clk(1);

          end
      end


    for(i=31; i>=0; i=i-1)      // crc
    begin
      tdi_pad_i<=#1 crc[i];
      gen_clk(1);
    end

    tdi_pad_i<=#1 1'hz;



    if ((last_wb_cmd == `WB_READ8) | (last_wb_cmd == `WB_READ16) | (last_wb_cmd == `WB_READ32))  // When WB_WRITEx was previously activated, data needs to be shifted.
      begin
        $display("\t\tGenerating %0d clocks to read %0d data bytes.", dbg_tb.i_dbg_top.i_dbg_wb.len << 3, dbg_tb.i_dbg_top.i_dbg_wb.len);
        $display("\t\tFirst half");
//        for (i=0; i<(dbg_tb.i_dbg_top.i_dbg_wb.len << 3); i=i+1)

        for (i=0; i<(dbg_tb.i_dbg_top.i_dbg_wb.len << 3)/2; i=i+1)
          begin
          gen_clk(1);
          end

        tms_pad_i<=#1 1;
        gen_clk(1);         // to exit1_dr
        tms_pad_i<=#1 0;
        gen_clk(1);         // to pause_dr
        gen_clk(1000);      // wait in pause_dr
        tms_pad_i<=#1 1;
        gen_clk(1);         // to exit2_dr
        tms_pad_i<=#1 0;    // to shift_dr
        gen_clk(1);

        $display("\t\tSecond half");
        for (i=0; i<(dbg_tb.i_dbg_top.i_dbg_wb.len << 3)/2; i=i+1)
          begin
          gen_clk(1);
          end

      end


    gen_clk(`STATUS_LEN);   // Generating 4 clocks to read out status.

    for(i=0; i<`CRC_LEN -1; i=i+1)  // Getting in the CRC
    begin
      gen_clk(1);
    end

    tms_pad_i<=#1 1;
    gen_clk(1);         // to exit1_dr

    tms_pad_i<=#1 1;
    gen_clk(1);         // to update_dr
    tms_pad_i<=#1 0;
    gen_clk(1);         // to run_test_idle
  end
endtask       // debug_wishbone_go_tmp













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


// Printing CRC
//always @ (posedge dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_end)
always @ (dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt or dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc)
begin
  #2;
  if (dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt == 0)
    tmp_crc = dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc;
end


// Detecting CRC error
always @ (posedge dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt_end)
begin
  #2;
  if (~dbg_tb.i_dbg_top.crc_match)
    begin
      $display("\t\tCRC ERROR !!!");
      $display("\t\tCRC needed (%0s) = 0x%0x , shifted_in = 0x%0x", test_text, tmp_crc, shifted_in_crc);
      $stop;
    end
end



// Detecting errors in counters
always @ (dbg_tb.i_dbg_top.i_dbg_wb.cmd_cnt or 
          dbg_tb.i_dbg_top.i_dbg_wb.cmd_cnt_end or
          dbg_tb.i_dbg_top.i_dbg_wb.addr_len_cnt or
          dbg_tb.i_dbg_top.i_dbg_wb.addr_len_cnt_end or
          dbg_tb.i_dbg_top.i_dbg_wb.data_cnt or
          dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_end or
          dbg_tb.i_dbg_top.i_dbg_wb.cmd_cnt_en or
          dbg_tb.i_dbg_top.i_dbg_wb.addr_len_cnt_en or
          dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_en or
          dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt_en or
          dbg_tb.i_dbg_top.i_dbg_wb.status_cnt1
          //dbg_tb.i_dbg_top.i_dbg_wb.status_cnt2 or
          //dbg_tb.i_dbg_top.i_dbg_wb.status_cnt3 or
          //dbg_tb.i_dbg_top.i_dbg_wb.status_cnt4
          // dbg_tb.i_dbg_top.i_dbg_wb. or
         )
begin
  if ((~dbg_tb.i_dbg_top.i_dbg_wb.cmd_cnt_end) & (
                                                  dbg_tb.i_dbg_top.i_dbg_wb.addr_len_cnt_en |
                                                  dbg_tb.i_dbg_top.i_dbg_wb.data_cnt_en     |
                                                  dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt_en      |
                                                  dbg_tb.i_dbg_top.i_dbg_wb.status_cnt1
                                                 )
     )
    begin
      $display("\n\n\t\t(%0t) ERROR in counters !!!", $time);
      #10000;
      $stop;
    end



end






endmodule // dbg_tb


