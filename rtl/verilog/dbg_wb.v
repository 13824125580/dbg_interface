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
reg    [31:0] wb_dat_o;
reg     [3:0] wb_sel_o;

reg           tdo_o;

reg    [50:0] dr;
wire          enable;
reg     [1:0] cmd_cnt;
wire          cmd_cnt_end;
reg           cmd_cnt_end_q;
reg     [5:0] addr_len_cnt;
reg     [5:0] addr_len_cnt_limit;
wire          addr_len_cnt_end;
reg     [5:0] crc_cnt;
wire          crc_cnt_end;
reg           crc_cnt_end_q;
reg    [18:0] data_cnt;
reg    [18:0] data_cnt_limit;
wire          data_cnt_end;
reg           status_reset_en;


reg [`STATUS_CNT -1:0]      status_cnt;
// reg [31:0] data_tck;


reg [2:0]  cmd, cmd_old;
reg [31:0] adr;
reg [15:0] len;
reg start_tck;
reg start_sync1;
reg start_wb;
reg start_wb_q;


wire status_cnt_end;

assign enable = wishbone_ce_i & shift_dr_i;
assign shift_crc_o = wishbone_ce_i & status_cnt_end & shift_dr_i;  // Signals dbg module to shift out the CRC


always @ (posedge tck_i)
begin
//  if (enable & ((~addr_len_cnt_end) | (~cmd_cnt_end)))
  if (enable & ((~addr_len_cnt_end) | (~cmd_cnt_end) | (~data_cnt_end)))
    dr <= #1 {dr[49:0], tdi_i};
end


//always @ (posedge tck_i)
//begin
//  if (enable & (data_cnt_end))  // Igor !!! perhaps not needed data_cnt_end
//    data_tck <= #1 {data_tck[30:0], tdi_i};
//end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    cmd_cnt <= #1 'h0;
  else if (update_dr_i)
    cmd_cnt <= #1 'h0;
  else if (enable & (~cmd_cnt_end))
    cmd_cnt <= #1 cmd_cnt + 1'b1;
end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    addr_len_cnt <= #1 'h0;
  else if (update_dr_i)
    addr_len_cnt <= #1 'h0;
  else if (enable & cmd_cnt_end & (~addr_len_cnt_end))
    addr_len_cnt <= #1 addr_len_cnt + 1'b1;
end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    data_cnt <= #1 'h0;
  else if (update_dr_i)
    data_cnt <= #1 'h0;
  else if (enable & cmd_cnt_end & (~data_cnt_end))
    data_cnt <= #1 data_cnt + 1'b1;
end


wire byte, half, long;
reg byte_q, half_q, long_q;


assign byte = data_cnt[2:0] == 3'h0;
assign half = data_cnt[3:0] == 4'h0;
assign long = data_cnt[4:0] == 5'h0;


always @ (posedge tck_i)
begin
  byte_q <= #1 byte;
  half_q <= #1 half;
  long_q <= #1 long;
end



reg cmd_write;
reg cmd_read;
reg cmd_go;

//wire previous_cmd_read;
wire previous_cmd_write;
//assign previous_cmd_read = (cmd == `WB_READ8) | (cmd == `WB_READ16) | (cmd == `WB_READ32);
assign previous_cmd_write = (cmd == `WB_WRITE8) | (cmd == `WB_WRITE16) | (cmd == `WB_WRITE32);

reg [2:0] cmd_new;

always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    cmd_new  <= #1 3'h0;
  else if (cmd_cnt_end & (~cmd_cnt_end_q))
    cmd_new <= #1 dr[2:0];
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    cmd_read  <= #1 1'b0;
  else if (cmd_cnt_end & (~cmd_cnt_end_q))
    cmd_read <= #1 (dr[2:0] == `WB_READ8) | (dr[2:0] == `WB_READ16) | (dr[2:0] == `WB_READ32);
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    cmd_write  <= #1 1'b0;
  else if (cmd_cnt_end & (~cmd_cnt_end_q))
    cmd_write <= #1 (dr[2:0] == `WB_WRITE8) | (dr[2:0] == `WB_WRITE16) | (dr[2:0] == `WB_WRITE32);
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    cmd_go  <= #1 1'b0;
  else if (cmd_cnt_end & (~cmd_cnt_end_q))
    cmd_go <= #1 (dr[2:0] == `WB_GO);
end
                                                                                                                                                                                    
                                                                                                                                                                                    



always @ (cmd_cnt_end or cmd_cnt_end_q or dr)
begin
  if (cmd_cnt_end & (~cmd_cnt_end_q))
    begin
      // (current command is WB_STATUS or WB_GO)
      if ( (dr[2:0] == `WB_STATUS) | (dr[2:0] == `WB_GO) )
        addr_len_cnt_limit = 6'd0;
      // (current command is WB_WRITEx or WB_READx)
      else
        addr_len_cnt_limit = 6'd48;
    end
end
    


always @ (cmd_cnt_end or cmd_cnt_end_q or dr or previous_cmd_write or len)
begin
  if (cmd_cnt_end & (~cmd_cnt_end_q))
    begin
      // (current command is WB_GO and previous command is WB_WRITEx)
      if ( (dr[2:0] == `WB_GO) & previous_cmd_write )
        data_cnt_limit = (len<<3);
      else
        data_cnt_limit = 19'h0;
    end
end
    


`define WB_STATUS     3'h0
`define WB_WRITE8     3'h1
`define WB_WRITE16    3'h2
`define WB_WRITE32    3'h3
`define WB_GO         3'h4
`define WB_READ8      3'h5
`define WB_READ16     3'h6
`define WB_READ32     3'h7





// crc counter
always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    crc_cnt <= #1 'h0;
//  else if(enable & addr_len_cnt_end & (~crc_cnt_end))
  else if(enable & cmd_cnt_end & addr_len_cnt_end & data_cnt_end & (~crc_cnt_end))
    crc_cnt <= #1 crc_cnt + 1'b1;
  else if (update_dr_i)
    crc_cnt <= #1 'h0;
end

assign cmd_cnt_end  = cmd_cnt  == 2'h3;
//assign addr_len_cnt_end = addr_len_cnt == 6'd48;
assign addr_len_cnt_end = addr_len_cnt == addr_len_cnt_limit;
assign crc_cnt_end  = crc_cnt  == 6'd32;
assign data_cnt_end = data_cnt == data_cnt_limit;

always @ (posedge tck_i)
begin
  crc_cnt_end_q <= #1 crc_cnt_end;
  cmd_cnt_end_q <= #1 cmd_cnt_end;
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
//reg address_unaligned;

reg wb_error, wb_error_sync, wb_error_tck;
reg wb_overrun, wb_overrun_sync, wb_overrun_tck;

reg busy_wb;
reg busy_tck;
reg wb_end;
reg wb_end_rst;
reg wb_end_rst_sync;
reg wb_end_sync;
reg wb_end_tck;
reg busy_sync;
reg [799:0] TDO_WISHBONE;

always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    status <= #1 'h0;
  else if(crc_cnt_end & (~crc_cnt_end_q))
    status <= #1 {crc_match_i, wb_error_tck, wb_overrun_tck, busy_tck}; // igor !!! wb_overrun_tck bo uporabljen skupaj z wb_underrun_tck,
  else if (shift_dr_i & (~status_cnt_end))
    status <= #1 {status[0], status[`STATUS_LEN -1:1]};
end
// Following status is shifted out:
// 1. bit:          1 if crc is OK, else 0
// 2. bit:          1 while WB access is in progress (busy_tck), else 0
// 3. bit:          1 if overrun occured during write (data couldn't be written fast enough)
// 4. bit:          1 if WB error occured, else 0



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
  else if (crc_cnt_end)
    begin
      tdo_o = status[0];
      TDO_WISHBONE = "status";
    end
  else
    begin
      tdo_o = 1'b0;
      TDO_WISHBONE = "zero while CRC is shifted in";
    end
end

assign crc_en_o = crc_cnt_end & (~status_cnt_end) & shift_dr_i;

reg set_addr, set_addr_sync, set_addr_wb, set_addr_wb_q;

always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i)
    begin
      if (cmd_write | cmd_read)
        begin
          cmd <= #1 dr[50:48];
          adr <= #1 dr[47:16];
          len <= #1 dr[15:0];
          set_addr <= #1 1'b1;
        end
      else
        begin
          cmd <= #1 dr[2:0];
        end

      cmd_old <= #1 cmd;
    end
  else
    set_addr <= #1 1'b0;
end


always @ (posedge tck_i)
begin
  if (cmd_go & previous_cmd_write)
    begin
      case (cmd)  // synthesis parallel_case full_case
        `WB_WRITE8  : begin
                        if (byte & (~byte_q))
                          begin
                            start_tck <= #1 1'b1;
                            wb_dat_o <= #1 {4{dr[7:0]}};
                          end
                        else
                          begin
                            start_tck <= #1 1'b0;
                          end
                      end
        `WB_WRITE16 : begin
                        if (half & (~half_q))
                          begin
                            start_tck <= #1 1'b1;
                            wb_dat_o <= #1 {2{dr[15:0]}};
                          end
                        else
                          begin
                            start_tck <= #1 1'b0;
                          end
                      end
        `WB_WRITE32 : begin
                        if (long & (~long_q))
                          begin
                            start_tck <= #1 1'b1;
                            wb_dat_o <= #1 dr[31:0];
                          end
                        else
                          begin
                            start_tck <= #1 1'b0;
                          end
                      end
      endcase
    end
  else
    start_tck <= #1 1'b0;
end


always @ (posedge wb_clk_i)
begin
  start_sync1 <= #1 start_tck;
  start_wb <= #1 start_sync1;
  start_wb_q <= #1 start_wb;
  set_addr_sync <= #1 set_addr;
  set_addr_wb <= #1 set_addr_sync;
  set_addr_wb_q <= #1 set_addr_wb;
end


always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_cyc_o <= #1 1'b0;
  else if (start_wb & (~start_wb_q))
    wb_cyc_o <= #1 1'b1;
  else if (wb_ack_i | wb_err_i)
    wb_cyc_o <= #1 1'b0;
end



always @ (posedge wb_clk_i)
begin
  if (set_addr_wb & (~set_addr_wb_q)) // Setting starting address
    wb_adr_o <= #1 adr;
  else if (wb_ack_i)
    begin
      if ((cmd_new == `WB_WRITE8) | (cmd == `WB_READ8))
        wb_adr_o <= #1 wb_adr_o + 1'd1;
      else if ((cmd_new == `WB_WRITE16) | (cmd == `WB_READ16))
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

always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    begin
      wb_sel_o[3:0] <= #1 4'h0;
    end
  else
    begin
      wb_sel_o[0] <= #1 (cmd[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (cmd[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b11) | 
                        (cmd[1:0] == 2'b10) & (wb_adr_o[1:0] == 2'b10);
      wb_sel_o[1] <= #1 (cmd[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (cmd[1] ^ cmd[0]) & (wb_adr_o[1:0] == 2'b10);
      wb_sel_o[2] <= #1 (cmd[1]) & (wb_adr_o[1:0] == 2'b00) | (cmd[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b01);
      wb_sel_o[3] <= #1 (wb_adr_o[1:0] == 2'b00);
    end
end




/*
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_dat_o[31:0] <= #1 32'h0;
  else if (start_wb & (~start_wb_q))
    begin
      if (cmd[1:0] == 2'd1)                       // 8-bit access
        wb_dat_o[31:0] <= #1 {4{8'h0}};
      else if (cmd[1:0] == 2'd2)                  // 16-bit access
        wb_dat_o[31:0] <= #1 {2{16'h0}};
      else
        wb_dat_o[31:0] <= #1 32'h0;               //32-bit access
    end
end
*/

//always @ (wb_adr_o or cmd)
//begin
//  wb_sel_o[0] = (cmd[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (cmd[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b11) | 
//                (cmd[1:0] == 2'b10) & (wb_adr_o[1:0] == 2'b10);
//  wb_sel_o[1] = (cmd[1:0] == 2'b11) & (wb_adr_o[1:0] == 2'b00) | (cmd[1] ^ cmd[0]) & (wb_adr_o[1:0] == 2'b10);
//  wb_sel_o[2] = (cmd[1]) & (wb_adr_o[1:0] == 2'b00) | (cmd[1:0] == 2'b01) & (wb_adr_o[1:0] == 2'b01);
//  wb_sel_o[3] = (wb_adr_o[1:0] == 2'b00);
//end



// always @ (dr)
// begin
//   address_unaligned = (dr[1:0] == 2'b11) & (dr[4:3] > 2'b00) | (dr[1:0] == 2'b10) & (dr[3]);
// end
 


assign wb_we_o = ~cmd[2];   // Status or write (for simpler logic status is allowed)
assign wb_cab_o = 1'b0;
assign wb_stb_o = wb_cyc_o;
assign wb_cti_o = 3'h0;     // always performing single access
assign wb_bte_o = 2'h0;     // always performing single access

reg [31:0] input_data;

always @ (posedge wb_clk_i)
begin
  if(wb_ack_i)
    input_data <= #1 wb_dat_i;
end



always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_end <= #1 1'b0;
  else if (wb_ack_i | wb_err_i)
    wb_end <= #1 1'b1;
  else if (wb_end_rst)
    wb_end <= #1 1'b0;
end


always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    begin
      wb_end_sync <= #1 1'b0; 
      wb_end_tck  <= #1 1'b0; 
    end
  else
    begin
      wb_end_sync <= #1 wb_end;
      wb_end_tck  <= #1 wb_end_sync;
    end
end


always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    busy_wb <= #1 1'b0;
  else if (wb_end_rst)
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
  wb_end_rst_sync <= #1 wb_end_tck;
  wb_end_rst  <= #1 wb_end_rst_sync;
end


always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
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



always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
  if (wb_rst_i)
    wb_overrun <= #1 1'b0;
  else if(start_wb & (~start_wb_q) & wb_cyc_o)
    wb_overrun <= #1 1'b1;
  else if((wb_ack_i | wb_err_i) & status_reset_en) // error remains active until STATUS read is performed
    wb_overrun <= #1 1'b0;
end
 
always @ (posedge tck_i)
begin
  wb_overrun_sync <= #1 wb_overrun;
  wb_overrun_tck  <= #1 wb_overrun_sync;
end






// wb_error is locked until WB_STATUS is performed
always @ (posedge tck_i or posedge trst_i)
begin
  if (trst_i)
    status_reset_en <= 1'b0;
  else if((cmd_old == `WB_STATUS) & (cmd !== `WB_STATUS))
    status_reset_en <= #1 1'b1;
  else
    status_reset_en <= #1 1'b0;
end









endmodule

