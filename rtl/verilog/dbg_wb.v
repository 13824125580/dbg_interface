//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_wb.v                                                    ////
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
// Revision 1.1  2003/12/23 15:09:04  mohor
// New directory structure. New version of the debug interface.
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_wb_defines.v"

// Top module
module dbg_wb(
                // JTAG signals
                trst_i,     // trst_i is active high (inverted on higher layers)
                tck_i,
                tdi_i,
                tdo_o,

                // TAP states
                shift_dr_i,
                pause_dr_i,
                update_dr_i,

                wishbone_ce_i,
                crc_match_i,
                crc_en_o,
                shift_crc_o,

                // WISHBONE common signals
                wb_rst_i, wb_clk_i,
                                                                                
                // WISHBONE master interface
                wb_adr_o, wb_dat_o, wb_dat_i, wb_cyc_o, wb_stb_o, wb_sel_o,
                wb_we_o, wb_ack_i, wb_cab_o, wb_err_i, wb_cti_o, wb_bte_o 

              );

// JTAG signals
input   trst_i;
input   tck_i;
input   tdi_i;
output  tdo_o;

// TAP states
input   shift_dr_i;
input   pause_dr_i;
input   update_dr_i;

input   wishbone_ce_i;
input   crc_match_i;
output  crc_en_o;
output  shift_crc_o;

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
output  [2:0] wb_cti_o;
output  [1:0] wb_bte_o;

reg           wb_cyc_o;
reg    [31:0] wb_adr_o;
reg     [3:0] wb_sel_o;

reg           tdo_o;

reg [`WB_DR_LEN -1:0] dr;
wire enable;
reg [5:0] cnt;
reg [5:0] crc_cnt;
wire      cnt_end;
wire      crc_cnt_end;
reg       crc_cnt_end_q;


reg [`STATUS_CNT -1:0]      status_cnt;
wire status_cnt_end;

assign enable = wishbone_ce_i & shift_dr_i;
assign shift_crc_o = wishbone_ce_i & status_cnt_end & shift_dr_i;  // Signals dbg module to shift out the CRC


always @ (posedge tck_i)
begin
  if (enable & (~cnt_end))
    dr <= #1 {tdi_i, dr[`WB_DR_LEN -1:1]};
end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    cnt <= #1 'h0;
  else if (update_dr_i)
    cnt <= #1 'h0;
  else if (enable & (~cnt_end))
    cnt <= #1 cnt + 1'b1;
end

assign cnt_end = cnt == `WB_DR_LEN;


// crc counter
always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    crc_cnt <= #1 'h0;
  else if(enable & cnt_end & (~crc_cnt_end))
    crc_cnt <= #1 crc_cnt + 1'b1;
  else if (update_dr_i)
    crc_cnt <= #1 'h0;
end

assign crc_cnt_end = crc_cnt == 6'd32;

always @ (posedge tck_i)
begin
  crc_cnt_end_q <= #1 crc_cnt_end;
end

// status counter
always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    status_cnt <= #1 'h0;
  else if(shift_dr_i & crc_cnt_end & (~status_cnt_end))
    status_cnt <= #1 status_cnt + 1'b1;
  else if (update_dr_i)
    status_cnt <= #1 'h0;
end

assign status_cnt_end = status_cnt == `STATUS_LEN;
reg [`STATUS_LEN -1:0] status;
reg address_unaligned;

reg wb_error, wb_error_sync, wb_error_tck;
reg wb_timeout, wb_timeout_sync, wb_timeout_tck;


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    status <= #1 'h0;
  else if(crc_cnt_end & (~crc_cnt_end_q))
    begin
      if (dr[2:0] == `WB_STATUS)
        status <= #1 {crc_match_i, wb_error_tck, wb_timeout_tck, address_unaligned};
      else                          // Status is not updated when status read is requested
        status <= #1 {crc_match_i, 2'b10, address_unaligned};
    end
  else if (shift_dr_i & (~status_cnt_end))
    status <= #1 {status[0], status[`STATUS_LEN -1:1]};
end
// Following status is shifted out: 
// 1. bit:          1 if crc is OK, else 0
// 2. bit:          1 if address is unaligned, else 0
// 3. bit:          always 0
// 4. bit:          always 1

// Following status is shifted out: 
// 1. bit:          1 if crc is OK, else 0
// 2. bit:          1 if address is unaligned, else 0
// 3. bit:          1 if WB timeout occured, else 0
// 4. bit:          1 if WB error occured, else 0

reg busy_wb;
reg busy_tck;
reg wb_ack_latched;
reg wb_ack_latched_rst;
reg wb_ack_latched_rst_sync;
reg tck_ack_sync;
reg tck_ack;
reg busy_sync;
reg [799:0] TDO_WISHBONE;

always @ (crc_cnt_end or crc_cnt_end_q or crc_match_i or status or pause_dr_i or busy_tck)
begin
  if (pause_dr_i)
  begin
    tdo_o = busy_tck;
    TDO_WISHBONE = "busy_tck";
  end
  else if (crc_cnt_end & (~crc_cnt_end_q))
  begin
    tdo_o = crc_match_i;
    TDO_WISHBONE = "crc_match_i";
  end
  else
  begin
    tdo_o = status[0];
    TDO_WISHBONE = "status";
  end
end

assign crc_en_o = crc_cnt_end & (~status_cnt_end) & shift_dr_i;

reg [2:0]  cmd;
reg [31:0] adr;
reg [15:0] len;
reg start_tck;
reg start_sync1;
reg start_wb;
reg start_wb_q;

always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i)
    begin
      cmd <= #1 dr[2:0];
      adr <= #1 dr[34:3];
      len <= #1 dr[50:35];
      start_tck <= #1 1'b1;
    end
  else
    start_tck <= #1 1'b0;
end


always @ (posedge wb_clk_i)
begin
  start_sync1 <= #1 start_tck;
  start_wb <= #1 start_sync1;
  start_wb_q <= #1 start_wb;
end

reg [7:0] acc_cnt;
wire acc_cnt_limit;

always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_cyc_o <= #1 1'b0;
  else if (start_wb & (~start_wb_q) & cmd[2])     // "read" or "go" command   igor !!! tu pride se nekaj, ki starta vse naslednje accesse
    wb_cyc_o <= #1 1'b1;
  else if (wb_ack_i | wb_err_i | acc_cnt_limit)
    wb_cyc_o <= #1 1'b0;
end



always @ (posedge wb_clk_i)
begin
//  if (start_wb & (~start_wb_q) & (cmd > `WB_STATUS) & (cmd < `WB_GO)) // Setting starting address
  if (start_wb & (~start_wb_q) & (cmd !== `WB_STATUS) & (cmd !== `WB_GO)) // Setting starting address
    wb_adr_o <= #1 adr;
  else if (wb_ack_i)
    begin
      if ((cmd == `WB_WRITE8) | (cmd == `WB_READ8))
        wb_adr_o <= #1 wb_adr_o + 1'd1;
      else if ((cmd == `WB_WRITE16) | (cmd == `WB_READ16))
        wb_adr_o <= #1 wb_adr_o + 2'd2;
      else
        wb_adr_o <= #1 wb_adr_o + 3'd4;
    end
end


always @ (wb_adr_o or cmd)
begin
  wb_sel_o[0] = (cmd[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (cmd[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b11) | 
                (cmd[1:0] == 2'b10) & (wb_adr_o[1:0] == 2'b10);
  wb_sel_o[1] = (cmd[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (cmd[1] ^ cmd[0]) & (wb_adr_o[1:0] == 2'b10);
  wb_sel_o[2] = (cmd[1]) & (wb_adr_o[1:0] == 2'b00) | (cmd[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b01);
  wb_sel_o[3] = (wb_adr_o[1:0] == 2'b00);
end
//      byte  |  short  |  long
//  0   1000     1100      1111
//  1   0100     err       err
//  2   0010     0011      err
//  3   0001     err       err


always @ (dr)
begin
  address_unaligned = (dr[1:0] == 2'b11) & (dr[4:3] > 2'b00) | (dr[1:0] == 2'b10) & (dr[3]);
end
 
`define WB_STATUS     3'h0  // 000
`define WB_WRITE8     3'h1  // 001
`define WB_WRITE16    3'h2  // 010
`define WB_WRITE32    3'h3  // 011
`define WB_GO         3'h4  // 100
`define WB_READ8      3'h5  // 101
`define WB_READ16     3'h6  // 110
`define WB_READ32     3'h7  // 111

always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if(wb_rst_i)
    acc_cnt<= #1 8'h0;
  else
  if(wb_ack_i | wb_err_i | acc_cnt_limit)
    acc_cnt<= #1 8'h0;
  else
  if(wb_cyc_o)
    acc_cnt<= #1 acc_cnt + 1'b1;
end
                                                                                                         
assign acc_cnt_limit = acc_cnt==8'hff;


assign wb_we_o = ~cmd[2];   // Status or write (for simpler logic status is allowed)
assign wb_cab_o = 1'b0;
assign wb_stb_o = wb_cyc_o;
assign wb_cti_o = 3'h0;     // always performing single access
assign wb_bte_o = 2'h0;     // always performing single access

reg [31:0] input_storage;

always @ (posedge wb_clk_i)
begin
  if(wb_ack_i)
    input_storage <= #1 wb_dat_i;
end



always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_ack_latched <= #1 1'b0;
  else if (wb_ack_i)
    wb_ack_latched <= #1 1'b1;
  else if (wb_ack_latched_rst)
    wb_ack_latched <= #1 1'b0;
end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    begin
      tck_ack_sync <= #1 1'b0; 
      tck_ack  <= #1 1'b0; 
    end
  else
    begin
      tck_ack_sync <= #1 wb_ack_latched;
      tck_ack  <= #1 tck_ack_sync;
    end
end


always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    busy_wb <= #1 1'b0;
  else if (wb_ack_latched_rst | wb_err_i | acc_cnt_limit)
    busy_wb <= #1 1'b0;
  else if (wb_cyc_o) 
    busy_wb <= #1 1'b1;
end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    begin
      busy_sync <= #1 1'b0;
      busy_tck <= #1 1'b0;
    end
  else
    begin
      busy_sync <= #1 busy_wb;
      busy_tck <= #1 busy_sync;
    end
end


always @ (posedge wb_clk_i)
begin
  wb_ack_latched_rst_sync <= #1 tck_ack;
  wb_ack_latched_rst  <= #1 wb_ack_latched_rst_sync;
end


always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_error <= #1 1'b0;
  else if(wb_err_i)
    wb_error <= #1 1'b1;
  else if(wb_ack_i | acc_cnt_limit)
    wb_error <= #1 1'b0;
end
 
always @ (posedge tck_i)
begin
  wb_error_sync <= #1 wb_error;
  wb_error_tck  <= #1 wb_error_sync;
end


always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_timeout <= #1 1'b0;
  else if(acc_cnt_limit)
    wb_timeout <= #1 1'b1;
  else if(wb_ack_i | wb_err_i)
    wb_timeout <= #1 1'b0;
end
 
always @ (posedge tck_i)
begin
  wb_timeout_sync <= #1 wb_timeout;
  wb_timeout_tck  <= #1 wb_timeout_sync;
end


endmodule

