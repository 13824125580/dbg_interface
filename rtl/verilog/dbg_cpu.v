//////////////////////////////////////////////////////////////////////
////                                                              ////
////  dbg_cpu.v                                                   ////
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
//// Copyright (C) 2000 - 2004 Authors                            ////
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
// Revision 1.3  2004/01/17 18:01:24  mohor
// New version.
//
// Revision 1.2  2004/01/17 17:01:14  mohor
// Almost finished.
//
// Revision 1.1  2004/01/16 14:53:31  mohor
// *** empty log message ***
//
//
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "dbg_cpu_defines.v"

// Top module
module dbg_cpu(
                // JTAG signals
                tck_i,
                tdi_i,
                tdo_o,

                // TAP states
                shift_dr_i,
                pause_dr_i,
                update_dr_i,

                cpu_ce_i,
                crc_match_i,
                crc_en_o,
                shift_crc_o,
                rst_i,

                // CPU signals
                cpu_clk_i, 
                cpu_addr_o, 
                cpu_data_i, 
                cpu_data_o,
                cpu_bp_i,
                cpu_stall_o,
                cpu_stall_all_o,
                cpu_stb_o,
                cpu_sel_o,          // Not synchronized
                cpu_we_o,
                cpu_ack_i,
                cpu_rst_o


              );

// JTAG signals
input         tck_i;
input         tdi_i;
output        tdo_o;

// TAP states
input         shift_dr_i;
input         pause_dr_i;
input         update_dr_i;

input         cpu_ce_i;
input         crc_match_i;
output        crc_en_o;
output        shift_crc_o;
input         rst_i;


// CPU signals
input         cpu_clk_i; 
output [31:0] cpu_addr_o; 
input  [31:0] cpu_data_i; 
output [31:0] cpu_data_o;
input         cpu_bp_i;
output        cpu_stall_o;
output        cpu_stall_all_o;
output        cpu_stb_o;
output [`CPU_NUM -1:0]  cpu_sel_o;
output        cpu_we_o;
input         cpu_ack_i;
output        cpu_rst_o;


                                                                                
reg           tdo_o;
reg   [799:0] tdo_text;

wire          cmd_cnt_en;
reg     [1:0] cmd_cnt;
wire          cmd_cnt_end;
reg           cmd_cnt_end_q;
wire          addr_cnt_en;
reg     [5:0] addr_cnt;
reg     [5:0] addr_cnt_limit;
wire          addr_cnt_end;
wire          crc_cnt_en;
reg     [5:0] crc_cnt;
wire          crc_cnt_end;
reg           crc_cnt_end_q;
wire          data_cnt_en;
reg     [5:0] data_cnt;
reg     [5:0] data_cnt_limit;
wire          data_cnt_end;
reg           data_cnt_end_q;
wire          status_cnt_end;
reg           status_cnt1, status_cnt2, status_cnt3, status_cnt4;
reg     [3:0] status;
reg   [199:0] status_text;

reg           crc_match_reg;
wire          enable;

reg           read_cycle_reg;
reg           read_cycle_reg_q;
reg           read_cycle_cpu;
reg           read_cycle_cpu_q;
reg           write_cycle_reg;
reg           write_cycle_cpu;
wire          read_cycle;
wire          write_cycle;

reg    [34:0] dr;
wire    [7:0] reg_data_out;

wire          dr_read_reg;
wire          dr_write_reg;
wire          dr_read_cpu8;
wire          dr_read_cpu32;
wire          dr_write_cpu8;
wire          dr_write_cpu32;
wire          dr_go;
 
reg           dr_read_reg_latched;
reg           dr_write_reg_latched;
reg           dr_read_cpu8_latched;
reg           dr_read_cpu32_latched;
reg           dr_write_cpu8_latched;
reg           dr_write_cpu32_latched;
reg           dr_go_latched;
 
reg           cmd_read_reg;
reg           cmd_read_cpu;
reg           cmd_write_reg;
reg           cmd_write_cpu;
reg           cycle_32_bit;
reg           reg_access;

reg    [31:0] adr;
reg           set_addr;
reg   [199:0] latching_data_text;
reg           cpu_ack_sync;
reg           cpu_ack_tck;
reg           cpu_ack_tck_q;
reg           cpu_stb;
reg           cpu_stb_sync;
reg           cpu_stb_o;
wire          cpu_stall_tmp;

wire          go_prelim;
wire          crc_cnt_31;



assign enable = cpu_ce_i & shift_dr_i;
assign crc_en_o = enable & crc_cnt_end & (~status_cnt_end);
assign shift_crc_o = enable & status_cnt_end;  // Signals dbg module to shift out the CRC


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


assign addr_cnt_en = enable & cmd_cnt_end & (~addr_cnt_end);


// Address/length counter
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    addr_cnt <= #1 'h0;
  else if (update_dr_i)
    addr_cnt <= #1 'h0;
  else if (addr_cnt_en)
    addr_cnt <= #1 addr_cnt + 1'b1;
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


assign crc_cnt_en = enable & (~crc_cnt_end) & (cmd_cnt_end & addr_cnt_end  & (~write_cycle) | (data_cnt_end & write_cycle));


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


// Upper limit. Address/length counter counts until this value is reached
always @ (posedge tck_i)
begin
  if (cmd_cnt == 2'h2)
    begin
      if ((~dr[0])  & (~tdi_i))                                   // (current command is WB_STATUS or WB_GO)
        addr_cnt_limit = 6'd0;
      else                                                        // (current command is WB_WRITEx or WB_READx)
        addr_cnt_limit = 6'd32;
    end
end
    

assign cmd_cnt_end  = cmd_cnt  == 2'h3;
assign addr_cnt_end = addr_cnt == addr_cnt_limit;
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




// Latching address
always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i)
    begin
      if (~dr_go_latched)
        begin
          adr <= #1 dr[31:0];
          set_addr <= #1 1'b1;
        end
    end
  else
    set_addr <= #1 1'b0;
end


assign cpu_addr_o = adr;


// Shift register for shifting in and out the data
always @ (posedge tck_i)
begin
  if (reg_access)
    begin
      dr[31:24] <= #1 reg_data_out;
      latching_data_text = "Latch reg data";
    end
  else if (cpu_ack_tck & (~cpu_ack_tck_q) & read_cycle_cpu)
    begin
      if (cycle_32_bit)
        dr[31:0] <= #1 cpu_data_i;
      else
        dr[31:24] <= #1 cpu_data_i[7:0];
      latching_data_text = "Latch cpu data";
    end
  else if (enable & ((~addr_cnt_end) | (~cmd_cnt_end) | ((~data_cnt_end) & write_cycle) | (crc_cnt_end & (~data_cnt_end) & read_cycle)))
    begin
      dr <= #1 {dr[33:0], tdi_i};
      latching_data_text = "shifting data";
    end
  else
    latching_data_text = "nothing";
end


assign dr_read_reg    = dr[2:0] == `CPU_READ_REG;
assign dr_write_reg   = dr[2:0] == `CPU_WRITE_REG;
assign dr_read_cpu8   = dr[2:0] == `CPU_READ8;
assign dr_read_cpu32  = dr[2:0] == `CPU_READ32;
assign dr_write_cpu8  = dr[2:0] == `CPU_WRITE8;
assign dr_write_cpu32 = dr[2:0] == `CPU_WRITE32;
assign dr_go          = dr[2:0] == `CPU_GO;


// Latching instruction
always @ (posedge tck_i)
begin
  if (update_dr_i)
    begin
      dr_read_reg_latched  <= #1 1'b0;
      dr_read_cpu8_latched  <= #1 1'b0;
      dr_read_cpu32_latched  <= #1 1'b0;
      dr_write_reg_latched  <= #1 1'b0;
      dr_write_cpu8_latched  <= #1 1'b0;
      dr_write_cpu32_latched  <= #1 1'b0;
      dr_go_latched  <= #1 1'b0;
    end
  else if (cmd_cnt_end & (~cmd_cnt_end_q))
    begin
      dr_read_reg_latched <= #1 dr_read_reg;
      dr_read_cpu8_latched <= #1 dr_read_cpu8;
      dr_read_cpu32_latched <= #1 dr_read_cpu32;
      dr_write_reg_latched <= #1 dr_write_reg;
      dr_write_cpu8_latched <= #1 dr_write_cpu8;
      dr_write_cpu32_latched <= #1 dr_write_cpu32;
      dr_go_latched <= #1 dr_go;
    end
end

// Latching instruction
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    begin
      cmd_read_reg    <= #1 1'b0; 
      cmd_read_cpu    <= #1 1'b0; 
      cmd_write_reg   <= #1 1'b0; 
      cmd_write_cpu   <= #1 1'b0;
      cycle_32_bit    <= #1 1'b0; 
    end
  else if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i)
    begin
      cmd_read_reg    <= #1 dr_read_reg_latched;
      cmd_read_cpu    <= #1 dr_read_cpu8_latched | dr_read_cpu32_latched;
      cmd_write_reg   <= #1 dr_write_reg_latched;
      cmd_write_cpu   <= #1 dr_write_cpu8_latched | dr_write_cpu32_latched;
      cycle_32_bit    <= #1 dr_read_cpu32_latched | dr_write_cpu32_latched;
    end
end


// Upper limit. Data counter counts until this value is reached.
always @ (posedge tck_i or posedge rst_i)
begin
  if (rst_i)
    data_cnt_limit <= #1 6'h0;
  else if(crc_cnt_end & (~crc_cnt_end_q) & crc_match_i & (~dr_go_latched))
    begin
      if (dr_read_cpu32_latched | dr_write_cpu32_latched)
        data_cnt_limit <= #1 6'd32;
      else
        data_cnt_limit <= #1 6'd8;
    end
end


assign go_prelim = (cmd_cnt == 2'h2) & dr[1] & (~dr[0]) & (~tdi_i); 


always @ (posedge tck_i)
begin
  if (update_dr_i)
    read_cycle_reg <= #1 1'b0;
  else if (cmd_read_reg & go_prelim)
    read_cycle_reg <= #1 1'b1;
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    read_cycle_cpu <= #1 1'b0;
  else if (cmd_read_cpu & go_prelim)
    read_cycle_cpu <= #1 1'b1;
end


always @ (posedge tck_i)
begin
  read_cycle_reg_q <= #1 read_cycle_reg;
  read_cycle_cpu_q <= #1 read_cycle_cpu;
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    write_cycle_reg <= #1 1'b0;
  else if (cmd_write_reg & go_prelim)
    write_cycle_reg <= #1 1'b1;
end


always @ (posedge tck_i)
begin
  if (update_dr_i)
    write_cycle_cpu <= #1 1'b0;
  else if (cmd_write_cpu & go_prelim)
    write_cycle_cpu <= #1 1'b1;
end


assign read_cycle = read_cycle_reg | read_cycle_cpu;
assign write_cycle = write_cycle_reg | write_cycle_cpu;



// Start register access cycle
always @ (posedge tck_i)
begin
  if (write_cycle_reg & data_cnt_end & (~data_cnt_end_q) | read_cycle_reg & (~read_cycle_reg_q))
    begin
      reg_access <= #1 1'b1;
    end
  else
    reg_access <= #1 1'b0;
end



// Connecting dbg_cpu_registers
dbg_cpu_registers i_dbg_cpu_registers
     (
      .data_i           (dr[7:0]),
      .data_o           (reg_data_out),
      .addr_i           (adr[1:0]),
      .we_i             (write_cycle_reg),
      .en_i             (reg_access),
      .clk_i            (tck_i),
      .bp_i             (cpu_bp_i),
      .rst_i            (rst_i),
      .cpu_clk_i        (cpu_clk_i),
      .cpu_stall_o      (cpu_stall_tmp),
      .cpu_stall_all_o  (cpu_stall_all_o),
      .cpu_sel_o        (cpu_sel_o),
      .cpu_rst_o        (cpu_rst_o)
     );



assign cpu_we_o   = write_cycle_cpu;
assign cpu_data_o = dr[31:0];
assign cpu_stall_o = cpu_stb_o | cpu_stall_tmp;



// Synchronizing ack signal from cpu
always @ (posedge tck_i)
begin
  cpu_ack_sync      <= #1 cpu_ack_i;
  cpu_ack_tck       <= #1 cpu_ack_sync;
  cpu_ack_tck_q     <= #1 cpu_ack_tck;
end



// Start cpu access cycle
always @ (posedge tck_i)
begin
  if (update_dr_i)
    cpu_stb <= #1 1'b0;
  else if (cpu_ack_tck)
    cpu_stb <= #1 1'b0;
  else if (write_cycle_cpu & data_cnt_end & (~data_cnt_end_q) | read_cycle_cpu & (~read_cycle_cpu_q))
    cpu_stb <= #1 1'b1;
end



// Synchronizing cpu_stb to cpu_clk_i clock
always @ (posedge cpu_clk_i)
begin
  cpu_stb_sync  <= #1 cpu_stb;
  cpu_stb_o     <= #1 cpu_stb_sync;
end


// Latching crc
always @ (posedge tck_i)
begin
  if(crc_cnt_end & (~crc_cnt_end_q))
    crc_match_reg <= #1 crc_match_i;
end



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
    status <= #1 {crc_match_i, 1'b0, 1'b1, 1'b0};
    status_text <= #1 "!!!READ";
    end
  else if (data_cnt_end & (~data_cnt_end_q) & read_cycle)
    begin
    status <= #1 {crc_match_reg, 1'b0, 1'b1, 1'b0};
    status_text <= #1 "READ";
    end
  else if (shift_dr_i & (~status_cnt_end))
    begin
    status <= #1 {status[0], status[3:1]};
    status_text <= #1 "shift";
    end
end
// Following status is shifted out:
// 1. bit:          1 if crc is OK, else 0
// 2. bit:          1'b0
// 3. bit:          1'b1
// 4. bit:          1'b0



// TDO multiplexer
always @ (crc_cnt_end or crc_cnt_end_q or crc_match_i or data_cnt_end or data_cnt_end_q or 
          read_cycle or crc_match_reg or status or dr)
begin
  if (crc_cnt_end & (~crc_cnt_end_q) & (~(read_cycle)))
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
  else if (crc_cnt_end)
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







endmodule

