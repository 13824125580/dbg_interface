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
// Revision 1.12  2004/01/14 22:59:18  mohor
// Temp version.
//
// Revision 1.11  2004/01/14 12:29:40  mohor
// temp version. Resets will be changed in next version.
//
// Revision 1.10  2004/01/13 11:28:14  mohor
// tmp version.
//
// Revision 1.9  2004/01/10 07:50:24  mohor
// temp version.
//
// Revision 1.8  2004/01/09 12:48:44  mohor
// tmp version.
//
// Revision 1.7  2004/01/08 17:53:36  mohor
// tmp version.
//
// Revision 1.6  2004/01/07 11:58:56  mohor
// temp4 version.
//
// Revision 1.5  2004/01/06 17:15:19  mohor
// temp3 version.
//
// Revision 1.4  2004/01/05 12:16:00  mohor
// tmp2 version.
//
// Revision 1.3  2003/12/23 16:22:46  mohor
// Tmp version.
//
// Revision 1.2  2003/12/23 15:26:26  mohor
// Small fix.
//
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
                rst_i,

                // WISHBONE common signals
                wb_clk_i,
                                                                                
                // WISHBONE master interface
                wb_adr_o, wb_dat_o, wb_dat_i, wb_cyc_o, wb_stb_o, wb_sel_o,
                wb_we_o, wb_ack_i, wb_cab_o, wb_err_i, wb_cti_o, wb_bte_o 

              );

// JTAG signals
input         tck_i;
input         tdi_i;
output        tdo_o;

// TAP states
input         shift_dr_i;
input         pause_dr_i;
input         update_dr_i;

input         wishbone_ce_i;
input         crc_match_i;
output        crc_en_o;
output        shift_crc_o;
input         rst_i;
// WISHBONE common signals
input         wb_clk_i;
                                                                                
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
reg    [31:0] wb_dat_o;
reg     [3:0] wb_sel_o;

reg           tdo_o;

reg    [50:0] dr;
wire          enable;
wire          cmd_cnt_en;
reg     [1:0] cmd_cnt;
wire          cmd_cnt_end;
reg           cmd_cnt_end_q;
wire          addr_len_cnt_en;
reg     [5:0] addr_len_cnt;
reg     [5:0] addr_len_cnt_limit;
wire          addr_len_cnt_end;
wire          crc_cnt_en;
reg     [5:0] crc_cnt;
wire          crc_cnt_end;
reg           crc_cnt_end_q;
wire          data_cnt_en;
reg    [18:0] data_cnt;
reg    [18:0] data_cnt_limit;
wire          data_cnt_end;
reg           data_cnt_end_q;
reg           status_reset_en;

reg           crc_match_reg;

reg     [2:0] cmd, cmd_old, dr_cmd_latched;
reg    [31:0] adr;
reg    [15:0] len;
reg           start_rd_tck;
reg           rd_tck_started;
reg           start_rd_sync1;
reg           start_wb_rd;
reg           start_wb_rd_q;
reg           start_wr_tck;
reg           start_wr_sync1;
reg           start_wb_wr;
reg           start_wb_wr_q;

wire          dr_read;
wire          dr_write;
wire          dr_go;

reg           dr_write_latched;
reg           dr_read_latched;
reg           dr_go_latched;

wire          status_cnt_end;

wire          byte, half, long;
reg           byte_q, half_q, long_q;
reg           byte_q2, half_q2, long_q2;
reg           cmd_read;
reg           cmd_write;
reg           cmd_go;

reg           status_cnt1, status_cnt2, status_cnt3, status_cnt4;

reg [`STATUS_LEN -1:0] status;

reg           wb_error, wb_error_sync, wb_error_tck;
reg           wb_overrun, wb_overrun_sync, wb_overrun_tck;
reg           underrun_tck;

reg           busy_wb;
reg           busy_tck;
reg           wb_end;
reg           wb_end_rst;
reg           wb_end_rst_sync;
reg           wb_end_sync;
reg           wb_end_tck, wb_end_tck_q;
reg           busy_sync;
reg   [799:0] tdo_text;
reg   [399:0] latching_data_text;
reg           latch_data;
reg   [199:0] status_text;

reg           set_addr, set_addr_sync, set_addr_wb, set_addr_wb_q;
reg           read_cycle;
reg           write_cycle;
reg     [2:0] rw_type;
wire   [31:0] input_data;

wire          len_eq_0;
wire          crc_cnt_31;

reg     [1:0] ptr;
reg     [2:0] fifo_cnt;
wire          fifo_full;
wire          fifo_empty;
reg     [7:0] mem [0:3];
reg     [2:0] mem_ptr;
reg           wishbone_ce_sync;
reg           wishbone_ce_rst;
wire          go_prelim;



assign enable = wishbone_ce_i & shift_dr_i;
assign crc_en_o = enable & crc_cnt_end & (~status_cnt_end);
assign shift_crc_o = enable & status_cnt_end;  // Signals dbg module to shift out the CRC


// Selecting where to take the data from 
always @ (posedge tck_i)
begin
  if (update_dr_i)
    ptr <= #1 2'h0;
  else if (read_cycle & crc_cnt_31) // first latch
    ptr <= #1 ptr + 1'b1;
  else if (read_cycle & byte & (~byte_q))
    ptr <= ptr + 1'd1;
end


// Shift register for shifting in and out the data
always @ (posedge tck_i)
begin
  if (read_cycle & crc_cnt_31)
    begin
      dr[31:0] <= #1 input_data[31:0];
      latch_data <= #1 1'b1;
      latching_data_text = "First latch";
    end
  else if (read_cycle & crc_cnt_end)
    begin
      case (rw_type)  // synthesis parallel_case full_case
        `WB_READ8 : begin
                      if(byte & (~byte_q))
                        begin
                          case (ptr)    // synthesis parallel_case
                            2'b00 : dr[31:24] <= #1 input_data[31:24];
                            2'b01 : dr[31:24] <= #1 input_data[23:16];
                            2'b10 : dr[31:24] <= #1 input_data[15:8];
                            2'b11 : dr[31:24] <= #1 input_data[7:0];
                          endcase
                          latch_data <= #1 1'b1;
                          latching_data_text = "8 bit latched";
                        end
                      else
                        begin
                          dr[31:24] <= #1 {dr[30:24], 1'b0};
                          latch_data <= #1 1'b0;
                          latching_data_text = "8 bit shifted";
                        end
                    end
        `WB_READ16: begin
                      if(half & (~half_q))
                        begin
                          if (ptr[1])
                            dr[31:16] <= #1 input_data[15:0];
                          else
                            dr[31:16] <= #1 input_data[31:16];
                          latching_data_text = "16 bit latched";
                          latch_data <= #1 1'b1;
                        end
                      else
                        begin
                          dr[31:16] <= #1 {dr[30:16], 1'b0};
                          latch_data <= #1 1'b0;
                          latching_data_text = "16 bit shifted";
                        end
                    end
        `WB_READ32: begin
                      if(long & (~long_q))
                        begin
                          dr[31:0] <= #1 input_data[31:0];
                          latch_data <= #1 1'b1;
                          latching_data_text = "32 bit latched";
                        end
                      else
                        begin
                          dr[31:0] <= #1 {dr[30:0], 1'b0};
                          latch_data <= #1 1'b0;
                          latching_data_text = "32 bit shifted";
                        end
                    end
      endcase
    end
  else if (enable & ((~addr_len_cnt_end) | (~cmd_cnt_end) | ((~data_cnt_end) & write_cycle)))
    begin
    dr <= #1 {dr[49:0], tdi_i};
    latch_data <= #1 1'b0;
    latching_data_text = "tdi shifted in";
    end
  else
    latching_data_text = "nothing";
end


assign cmd_cnt_en = enable & (~cmd_cnt_end);


// Command counter
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    cmd_cnt <= #1 'h0;
  else if (update_dr_i)
    cmd_cnt <= #1 'h0;
  else if (cmd_cnt_en)
    cmd_cnt <= #1 cmd_cnt + 1'b1;
end


assign addr_len_cnt_en = enable & cmd_cnt_end & (~addr_len_cnt_end);


// Address/length counter
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    addr_len_cnt <= #1 'h0;
  else if (update_dr_i)
    addr_len_cnt <= #1 'h0;
  else if (addr_len_cnt_en)
    addr_len_cnt <= #1 addr_len_cnt + 1'b1;
end


assign data_cnt_en = enable & (~data_cnt_end) & (cmd_cnt_end & write_cycle | crc_cnt_end & read_cycle);


// Data counter
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    data_cnt <= #1 'h0;
  else if (update_dr_i)
    data_cnt <= #1 'h0;
  else if (data_cnt_en)
    data_cnt <= #1 data_cnt + 1'b1;
end



assign byte = data_cnt[2:0] == 3'd7;
assign half = data_cnt[3:0] == 4'd15;
assign long = data_cnt[4:0] == 5'd31;


always @ (posedge tck_i)
begin
  byte_q <= #1 byte;
  half_q <= #1 half;
  long_q <= #1 long;
  byte_q2 <= #1 byte_q;
  half_q2 <= #1 half_q;
  long_q2 <= #1 long_q;
end


assign dr_read = (dr[2:0] == `WB_READ8) | (dr[2:0] == `WB_READ16) | (dr[2:0] == `WB_READ32);
assign dr_write = (dr[2:0] == `WB_WRITE8) | (dr[2:0] == `WB_WRITE16) | (dr[2:0] == `WB_WRITE32);
assign dr_go = dr[2:0] == `WB_GO;


// Latching instruction
always @ (posedge tck_i)
begin
  if (update_dr_i)
    begin
      dr_cmd_latched = 3'h0;
      dr_read_latched  <= #1 1'b0;
      dr_write_latched  <= #1 1'b0;
      dr_go_latched  <= #1 1'b0;
    end
  else if (cmd_cnt_end & (~cmd_cnt_end_q))
    begin
      dr_cmd_latched = dr[2:0];
      dr_read_latched <= #1 dr_read;
      dr_write_latched <= #1 dr_write;
      dr_go_latched <= #1 dr_go;
    end
end


// Upper limit. Address/length counter counts until this value is reached
always @ (posedge tck_i)
begin
  if (cmd_cnt == 2'h2)
    begin
      if ((~dr[0])  & (~tdi_i))                                   // (current command is WB_STATUS or WB_GO)
        addr_len_cnt_limit = 6'd0;
      else                                                        // (current command is WB_WRITEx or WB_READx)
        addr_len_cnt_limit = 6'd48;
    end
end
    

assign go_prelim = (cmd_cnt == 2'h2) & dr[1] & (~dr[0]) & (~tdi_i); 


// Upper limit. Data counter counts until this value is reached.
always @ (posedge tck_i)
begin
  if (update_dr_i)
    data_cnt_limit = {len, 3'b000};
end


assign crc_cnt_en = enable & (~crc_cnt_end) & (cmd_cnt_end & addr_len_cnt_end  & (~write_cycle) | (data_cnt_end & write_cycle));


// crc counter
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    crc_cnt <= #1 'h0;
  else if(crc_cnt_en)
    crc_cnt <= #1 crc_cnt + 1'b1;
  else if (update_dr_i)
    crc_cnt <= #1 'h0;
end

assign cmd_cnt_end  = cmd_cnt  == 2'h3;
assign addr_len_cnt_end = addr_len_cnt == addr_len_cnt_limit;
assign crc_cnt_end  = crc_cnt  == 6'd32;
assign crc_cnt_31 = crc_cnt  == 6'd31;
assign data_cnt_end = (data_cnt == data_cnt_limit);

always @ (posedge tck_i)
begin
  crc_cnt_end_q  <= #1 crc_cnt_end;
  cmd_cnt_end_q  <= #1 cmd_cnt_end;
  data_cnt_end_q <= #1 data_cnt_end;
end


// Status counter is made of 4 serialy connected registers
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    status_cnt1 <= #1 1'b0;
  else if (update_dr_i)
    status_cnt1 <= #1 1'b0;
  else if (data_cnt_end & read_cycle |
           crc_cnt_end & (~read_cycle)
          )
    status_cnt1 <= #1 1'b1;
end


always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    begin
      status_cnt2 <= #1 1'b0;
      status_cnt3 <= #1 1'b0;
      status_cnt4 <= #1 1'b0;
    end
  else if (update_dr_i)
    begin
      status_cnt2 <= #1 1'b0;
      status_cnt3 <= #1 1'b0;
      status_cnt4 <= #1 1'b0;
    end
  else
    begin
      status_cnt2 <= #1 status_cnt1;
      status_cnt3 <= #1 status_cnt2;
      status_cnt4 <= #1 status_cnt3;
    end
end


assign status_cnt_end = status_cnt4;


// Status register
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    begin
    status <= #1 'h0;
    status_text <= #1 "reset";
    end
  else if(crc_cnt_end & (~crc_cnt_end_q) & (~read_cycle))
    begin
    status <= #1 {crc_match_i, wb_error_tck, wb_overrun_tck, busy_tck};
    status_text <= #1 "!!!READ";
    end
  else if (data_cnt_end & (~data_cnt_end_q) & read_cycle)
    begin
    status <= #1 {crc_match_reg, wb_error_tck, underrun_tck, busy_tck};
    status_text <= #1 "READ";
    end
  else if (shift_dr_i & (~status_cnt_end))
    begin
    status <= #1 {status[0], status[`STATUS_LEN -1:1]};
    status_text <= #1 "shift";
    end
end
// Following status is shifted out:
// 1. bit:          1 if crc is OK, else 0
// 2. bit:          1 while WB access is in progress (busy_tck), else 0
// 3. bit:          1 if overrun occured during write (data couldn't be written fast enough)
//                    or underrun occured during read (data couldn't be read fast enough)
// 4. bit:          1 if WB error occured, else 0


// TDO multiplexer
always @ (pause_dr_i or busy_tck or crc_cnt_end or crc_cnt_end_q or cmd_read or crc_match_i or 
          data_cnt_end or data_cnt_end_q or read_cycle or crc_match_reg or status or dr or cmd_go)
begin
  if (pause_dr_i)
    begin
    tdo_o = busy_tck;
    tdo_text = "busy_tck";
    end
  else if (crc_cnt_end & (~crc_cnt_end_q) & (~(read_cycle)))
    begin
      tdo_o = crc_match_i;
      tdo_text = "crc_match_i";
    end
  else if (read_cycle & crc_cnt_end & (~data_cnt_end))
    begin
    tdo_o = dr[31];
    tdo_text = "read data";
    end
  else if (read_cycle & data_cnt_end & (~data_cnt_end_q))     // cmd is already updated
    begin
      tdo_o = crc_match_reg;
      tdo_text = "crc_match_reg";
    end
  else if (crc_cnt_end & data_cnt_end)  // cmd is already updated
    begin
      tdo_o = status[0];
      tdo_text = "status";
    end
  else
    begin
      tdo_o = 1'b0;
      tdo_text = "zero while CRC is shifted in";
    end
end



always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q))
    crc_match_reg <= #1 crc_match_i;
end


// Latching instruction
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    begin
      cmd <= #1 'h0;
      cmd_old <= #1 'h0;
      cmd_read <= #1 1'b0; 
      cmd_write <= #1 1'b0; 
      cmd_go <= #1 1'b0;
    end
  else if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i)
    begin
      cmd <= #1 dr_cmd_latched;
      cmd_old <= #1 cmd;
      cmd_read <= #1 dr_read_latched;
      cmd_write <= #1 dr_write_latched;
      cmd_go <= #1 dr_go_latched;
    end
end


// Latching address
always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i)
    begin
      if (dr_write_latched | dr_read_latched)
        begin
          adr <= #1 dr[47:16];
          set_addr <= #1 1'b1;
        end
    end
  else
    set_addr <= #1 1'b0;
end


// Length counter
always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i & (dr_write_latched | dr_read_latched))
    len <= #1 dr[15:0];
  else if (start_rd_tck)
    begin
      case (rw_type)  // synthesis parallel_case full_case
        `WB_READ8 : len <= #1 len - 1'd1; 
        `WB_READ16: len <= #1 len - 2'd2; 
        `WB_READ32: len <= #1 len - 3'd4; 
      endcase
    end
end


assign len_eq_0 = len == 16'h0;


// Start wishbone read cycle
always @ (posedge tck_i)
begin
  if (read_cycle & (~dr_go_latched) & (~len_eq_0))              // First read after cmd is entered
    start_rd_tck <= #1 1'b1;
  else if ((~start_rd_tck) & read_cycle & (~len_eq_0) & (~fifo_full) & (~rd_tck_started))
    start_rd_tck <= #1 1'b1;
  else
    start_rd_tck <= #1 1'b0;
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    rd_tck_started <= #1 1'b0;
  else if (start_rd_tck)
    rd_tck_started <= #1 1'b1;
  else if (wb_end_tck & (~wb_end_tck_q))
    rd_tck_started <= #1 1'b0;
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    read_cycle <= #1 1'b0;
  else if (cmd_read & go_prelim)
    read_cycle <= #1 1'b1;
end


always @ (posedge tck_i)
begin
  if ((cmd_read | cmd_write) & go_prelim)
    rw_type <= #1 cmd;
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    write_cycle <= #1 1'b0;
  else if (cmd_write & go_prelim)
    write_cycle <= #1 1'b1;
end


// Start wishbone write cycle
always @ (posedge tck_i)
begin
  if (write_cycle)
    begin
      case (rw_type)  // synthesis parallel_case full_case
        `WB_WRITE8  : begin
                        if (byte_q & (~byte_q2))
                          begin
                            start_wr_tck <= #1 1'b1;
                            wb_dat_o <= #1 {4{dr[7:0]}};
                          end
                        else
                          begin
                            start_wr_tck <= #1 1'b0;
                          end
                      end
        `WB_WRITE16 : begin
                        if (half_q & (~half_q2))
                          begin
                            start_wr_tck <= #1 1'b1;
                            wb_dat_o <= #1 {2{dr[15:0]}};
                          end
                        else
                          begin
                            start_wr_tck <= #1 1'b0;
                          end
                      end
        `WB_WRITE32 : begin
                        if (long_q & (~long_q2))
                          begin
                            start_wr_tck <= #1 1'b1;
                            wb_dat_o <= #1 dr[31:0];
                          end
                        else
                          begin
                            start_wr_tck <= #1 1'b0;
                          end
                      end
      endcase
    end
  else
    start_wr_tck <= #1 1'b0;
end


always @ (posedge wb_clk_i)
begin
  start_rd_sync1  <= #1 start_rd_tck;
  start_wb_rd     <= #1 start_rd_sync1;
  start_wb_rd_q   <= #1 start_wb_rd;

  start_wr_sync1  <= #1 start_wr_tck;
  start_wb_wr     <= #1 start_wr_sync1;
  start_wb_wr_q   <= #1 start_wb_wr;

  set_addr_sync   <= #1 set_addr;
  set_addr_wb     <= #1 set_addr_sync;
  set_addr_wb_q   <= #1 set_addr_wb;
end


// wb_cyc_o
always @ (posedge wb_clk_i or posedge rst_i)
begin
  if (rst_i)
    wb_cyc_o <= #1 1'b0;
  else if ((start_wb_wr & (~start_wb_wr_q)) | (start_wb_rd & (~start_wb_rd_q)))
    wb_cyc_o <= #1 1'b1;
  else if (wb_ack_i | wb_err_i)
    wb_cyc_o <= #1 1'b0;
end


// wb_adr_o logic
always @ (posedge wb_clk_i)
begin
  if (set_addr_wb & (~set_addr_wb_q)) // Setting starting address
    wb_adr_o <= #1 adr;
  else if (wb_ack_i)
    begin
      if ((rw_type == `WB_WRITE8) | (rw_type == `WB_READ8))
        wb_adr_o <= #1 wb_adr_o + 1'd1;
      else if ((rw_type == `WB_WRITE16) | (rw_type == `WB_READ16))
        wb_adr_o <= #1 wb_adr_o + 2'd2;
      else
        wb_adr_o <= #1 wb_adr_o + 3'd4;
    end
end



//    adr   byte  |  short  |  long
//     0    1000     1100      1111
//     1    0100     err       err
//     2    0010     0011      err
//     3    0001     err       err
// wb_sel_o logic
always @ (posedge wb_clk_i or posedge rst_i)
begin
  if (rst_i)
    wb_sel_o[3:0] <= #1 4'h0;
  else
    begin
      wb_sel_o[0] <= #1 (rw_type[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (rw_type[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b11) | 
                        (rw_type[1:0] == 2'b10) & (wb_adr_o[1:0] == 2'b10);
      wb_sel_o[1] <= #1 (rw_type[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (rw_type[1] ^ rw_type[0]) & (wb_adr_o[1:0] == 2'b10);
      wb_sel_o[2] <= #1 (rw_type[1]) & (wb_adr_o[1:0] == 2'b00) | (rw_type[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b01);
      wb_sel_o[3] <= #1 (wb_adr_o[1:0] == 2'b00);
    end
end


assign wb_we_o = write_cycle;
assign wb_cab_o = 1'b0;
assign wb_stb_o = wb_cyc_o;
assign wb_cti_o = 3'h0;     // always performing single access
assign wb_bte_o = 2'h0;     // always performing single access


// Logic for detecting end of transaction
always @ (posedge wb_clk_i or posedge rst_i)
begin
  if (rst_i)
    wb_end <= #1 1'b0;
  else if (wb_ack_i | wb_err_i)
    wb_end <= #1 1'b1;
  else if (wb_end_rst)
    wb_end <= #1 1'b0;
end


always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    begin
      wb_end_sync <= #1 1'b0; 
      wb_end_tck  <= #1 1'b0;
      wb_end_tck_q<= #1 1'b0; 
    end
  else
    begin
      wb_end_sync <= #1 wb_end;
      wb_end_tck  <= #1 wb_end_sync;
      wb_end_tck_q<= #1 wb_end_tck;
    end
end


always @ (posedge wb_clk_i or posedge rst_i)
begin
  if (rst_i)
    busy_wb <= #1 1'b0;
  else if (wb_end_rst)
    busy_wb <= #1 1'b0;
  else if (wb_cyc_o) 
    busy_wb <= #1 1'b1;
end


always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
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
  wb_end_rst_sync <= #1 wb_end_tck;
  wb_end_rst  <= #1 wb_end_rst_sync;
end


// Detecting WB error
always @ (posedge wb_clk_i or posedge rst_i)
begin
  if (rst_i)
    wb_error <= #1 1'b0;
  else if(wb_err_i)
    wb_error <= #1 1'b1;
  else if(wb_ack_i & status_reset_en) // error remains active until STATUS read is performed
    wb_error <= #1 1'b0;
end


always @ (posedge tck_i)
begin
  wb_error_sync <= #1 wb_error;
  wb_error_tck  <= #1 wb_error_sync;
end


// Detecting overrun when write operation.
always @ (posedge wb_clk_i or posedge rst_i)
begin
  if (rst_i)
    wb_overrun <= #1 1'b0;
  else if(start_wb_wr & (~start_wb_wr_q) & wb_cyc_o)
    wb_overrun <= #1 1'b1;
  else if((wb_ack_i | wb_err_i) & status_reset_en) // error remains active until STATUS read is performed
    wb_overrun <= #1 1'b0;
end
 
always @ (posedge tck_i)
begin
  wb_overrun_sync <= #1 wb_overrun;
  wb_overrun_tck  <= #1 wb_overrun_sync;
end


// Detecting underrun when read operation
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    underrun_tck <= #1 1'b0;
  else if(latch_data & fifo_empty & (~data_cnt_end))
    underrun_tck <= #1 1'b1;
  else if(read_cycle & status_reset_en) // error remains active until STATUS read is performed
    underrun_tck <= #1 1'b0;
end
 


// wb_error is locked until WB_STATUS is performed
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    status_reset_en <= 1'b0;
  else if((cmd_old == `WB_STATUS) & (cmd !== `WB_STATUS))
    status_reset_en <= #1 1'b1;
  else
    status_reset_en <= #1 1'b0;
end


always @ (posedge wb_clk_i)
begin
  wishbone_ce_sync <= #1  wishbone_ce_i;
  wishbone_ce_rst  <= #1 ~wishbone_ce_sync;
end


// Logic for latching data that is read from wishbone
always @ (posedge wb_clk_i)
begin
  if(wishbone_ce_rst)
    mem_ptr <= #1 'h0;
  else if (wb_ack_i)
    begin
      if (rw_type == `WB_READ8)
        mem_ptr <= #1 mem_ptr + 1'd1;
      else if (rw_type == `WB_READ16)
        mem_ptr <= #1 mem_ptr + 2'd2;
    end
end


// Logic for latching data that is read from wishbone
always @ (posedge wb_clk_i)
begin
  if (wb_ack_i)
    begin
      case (wb_sel_o)    // synthesis parallel_case full_case 
        4'b1000  :  mem[mem_ptr[1:0]] <= #1 wb_dat_i[31:24];            // byte 
        4'b0100  :  mem[mem_ptr[1:0]] <= #1 wb_dat_i[23:16];            // byte
        4'b0010  :  mem[mem_ptr[1:0]] <= #1 wb_dat_i[15:08];            // byte
        4'b0001  :  mem[mem_ptr[1:0]] <= #1 wb_dat_i[07:00];            // byte

        4'b1100  :                                                      // half
                    begin
                      mem[mem_ptr[1:0]]      <= #1 wb_dat_i[31:24];
                      mem[mem_ptr[1:0]+1'b1] <= #1 wb_dat_i[23:16];
                    end
        4'b0011  :                                                      // half
                    begin
                      mem[mem_ptr[1:0]]      <= #1 wb_dat_i[15:08];
                      mem[mem_ptr[1:0]+1'b1] <= #1 wb_dat_i[07:00];
                    end
        4'b1111  :                                                      // long
                    begin
                      mem[0] <= #1 wb_dat_i[31:24];
                      mem[1] <= #1 wb_dat_i[23:16];
                      mem[2] <= #1 wb_dat_i[15:08];
                      mem[3] <= #1 wb_dat_i[07:00];
                    end
      endcase
    end
end


assign input_data = {mem[0], mem[1], mem[2], mem[3]};


// Fifo counter and empty/full detection
always @ (posedge tck_i)
begin
  if (update_dr_i)
    fifo_cnt <= #1 'h0;
  else if (wb_end_tck & (~wb_end_tck_q) & (~latch_data))  // incrementing
    begin
      case (rw_type)  // synthesis parallel_case full_case
        `WB_READ8 : fifo_cnt <= #1 fifo_cnt + 1'd1;
        `WB_READ16: fifo_cnt <= #1 fifo_cnt + 2'd2;      
        `WB_READ32: fifo_cnt <= #1 fifo_cnt + 3'd4;
      endcase
    end
  else if (~(wb_end_tck & (~wb_end_tck_q)) & latch_data)  // decrementing
    begin
      case (rw_type)  // synthesis parallel_case full_case
        `WB_READ8 : fifo_cnt <= #1 fifo_cnt - 1'd1;
        `WB_READ16: fifo_cnt <= #1 fifo_cnt - 2'd2;      
        `WB_READ32: fifo_cnt <= #1 fifo_cnt - 3'd4;
      endcase
    end
end


assign fifo_full = fifo_cnt == 3'h4;
assign fifo_empty = fifo_cnt == 3'h0;




endmodule

