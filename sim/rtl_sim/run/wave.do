// Signalscan Version 6.7p1


define noactivityindicator
define analog waveform lines
define add variable default overlay off
define waveform window analogheight 1
define terminal automatic
define buttons control \
  1 opensimmulationfile \
  2 executedofile \
  3 designbrowser \
  4 waveform \
  5 source \
  6 breakpoints \
  7 definesourcessearchpath \
  8 exit \
  9 createbreakpoint \
  10 creategroup \
  11 createmarker \
  12 closesimmulationfile \
  13 renamesimmulationfile \
  14 replacesimulationfiledata \
  15 listopensimmulationfiles \
  16 savedofile
define buttons waveform \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 zoomin \
  7 zoomout \
  8 zoomoutfull \
  9 expand \
  10 createmarker \
  11 designbrowser:1 \
  12 variableradixbinary \
  13 variableradixoctal \
  14 variableradixdecimal \
  15 variableradixhexadecimal \
  16 variableradixascii
define buttons designbrowser \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 cdupscope \
  7 getallvariables \
  8 getdeepallvariables \
  9 addvariables \
  10 addvarsandclosewindow \
  11 closewindow \
  12 scopefiltermodule \
  13 scopefiltertask \
  14 scopefilterfunction \
  15 scopefilterblock \
  16 scopefilterprimitive
define buttons event \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 move \
  7 closewindow \
  8 duplicate \
  9 defineasrisingedge \
  10 defineasfallingedge \
  11 defineasanyedge \
  12 variableradixbinary \
  13 variableradixoctal \
  14 variableradixdecimal \
  15 variableradixhexadecimal \
  16 variableradixascii
define buttons source \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 createbreakpoint \
  7 creategroup \
  8 createmarker \
  9 createevent \
  10 createregisterpage \
  11 closewindow \
  12 opensimmulationfile \
  13 closesimmulationfile \
  14 renamesimmulationfile \
  15 replacesimulationfiledata \
  16 listopensimmulationfiles
define buttons register \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 createregisterpage \
  7 closewindow \
  8 continuefor \
  9 continueuntil \
  10 continueforever \
  11 stop \
  12 previous \
  13 next \
  14 variableradixbinary \
  15 variableradixhexadecimal \
  16 variableradixascii
define show related transactions  
define exit prompt
define event search direction forward
define variable nofullhierarchy
define variable nofilenames
define variable nofullpathfilenames
include bookmark with filenames
include scope history without filenames
define waveform window listpane 10.93
define waveform window namepane 18.99
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Igor Mohor"
define print border
define print color blackonwhite
define print command "/usr/ucb/lpr -P%P"
define print printer  lp
define print range visible
define print variable visible
define rise fall time low threshold percentage 10
define rise fall time high threshold percentage 90
define rise fall time low value 0
define rise fall time high value 3.3
define sendmail command "/usr/lib/sendmail"
define sequence time width 30.00
define snap

define source noprompt
define time units default
define userdefinedbussymbol
define user guide directory "/usr/local/designacc/signalscan-6.7p1/doc/html"
define waveform window grid off
define waveform window waveheight 14
define waveform window wavespace 6
define web browser command netscape
define zoom outfull on initial add off
add group \
    tap_top \
      dbg_tb.i_tap_top.tck_pad_i \
      dbg_tb.i_tap_top.tms_pad_i \
      dbg_tb.i_tap_top.tdi_pad_i \
      dbg_tb.i_tap_top.tdo_pad_o \
      dbg_tb.i_tap_top.tdo_padoe_o \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.test_logic_reset \
      dbg_tb.i_tap_top.run_test_idle \
      dbg_tb.i_tap_top.select_dr_scan \
      dbg_tb.i_tap_top.capture_dr \
      dbg_tb.i_tap_top.shift_dr \
      dbg_tb.i_tap_top.exit1_dr \
      dbg_tb.i_tap_top.pause_dr \
      dbg_tb.i_tap_top.exit2_dr \
      dbg_tb.i_tap_top.update_dr \
      dbg_tb.i_tap_top.select_ir_scan \
      dbg_tb.i_tap_top.capture_ir \
      dbg_tb.i_tap_top.shift_ir \
      dbg_tb.i_tap_top.exit1_ir \
      dbg_tb.i_tap_top.pause_ir \
      dbg_tb.i_tap_top.exit2_ir \
      dbg_tb.i_tap_top.update_ir \
      dbg_tb.i_tap_top.bypass_reg \
      dbg_tb.i_tap_top.bypass_select \
      dbg_tb.i_tap_top.bypassed_tdo \
      dbg_tb.i_tap_top.debug_select \
      dbg_tb.i_tap_top.extest_select \
      dbg_tb.i_tap_top.idcode_reg[31:0]'h \
      dbg_tb.i_tap_top.idcode_select \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.instruction_tdo \
      dbg_tb.i_tap_top.jtag_ir[3:0]'h \
      dbg_tb.i_tap_top.latched_jtag_ir[3:0]'h \
      dbg_tb.i_tap_top.mbist_select \
      dbg_tb.i_tap_top.sample_preload_select \
      dbg_tb.i_tap_top.trst_pad_i \
      dbg_tb.i_tap_top.tck_pad_i \

add group \
    dbg_top \
      dbg_tb.i_dbg_top.current_on_tdo[799:0]'a \
      dbg_tb.i_dbg_top.chain_select \
      dbg_tb.i_dbg_top.chain_select_error \
      dbg_tb.i_dbg_top.chain_select \
      dbg_tb.i_dbg_top.crc_cnt_end \
      dbg_tb.i_dbg_top.crc_cnt_end_q \
      dbg_tb.i_dbg_top.crc_cnt_end_q2 \
      dbg_tb.i_dbg_top.data_cnt[2:0]'h \
      dbg_tb.i_dbg_top.data_cnt_end \
      dbg_tb.i_dbg_top.crc_cnt[5:0]'h \
      dbg_tb.i_dbg_top.crc_cnt_end \
      dbg_tb.i_dbg_top.crc_match \
      dbg_tb.i_dbg_top.data_cnt_end \
      dbg_tb.i_dbg_top.debug_select_i \
      dbg_tb.i_dbg_top.shift_dr_i \
      dbg_tb.i_dbg_top.status_cnt[2:0]'h \
      dbg_tb.i_dbg_top.status_cnt_end \
      dbg_tb.i_dbg_top.tck_i \
      dbg_tb.i_dbg_top.tdi_i \
      dbg_tb.i_dbg_top.tdo_o \
      dbg_tb.i_dbg_top.trst_i \
      dbg_tb.i_dbg_top.update_dr_i \
      dbg_tb.i_dbg_top.wishbone_scan_chain \
      dbg_tb.i_dbg_top.wishbone_ce \
      dbg_tb.i_dbg_top.crc_en \
      dbg_tb.i_dbg_top.crc_en_dbg \
      dbg_tb.i_dbg_top.crc_en_wb \

add group \
    crc_out \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.clk \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc_match \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc_out \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.data \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.enable \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.shift \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.new_crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.sync_rst \

add group \
    crc_in \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.clk \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc_match \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.data \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.enable \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.new_crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.shift \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.sync_rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc[31:0]'h \

add group \
    wishbone \
      dbg_tb.i_dbg_top.i_dbg_wb.TDO_WISHBONE[799:0]'a \
      dbg_tb.i_dbg_top.i_dbg_wb.acc_cnt[7:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.acc_cnt_limit \
      dbg_tb.i_dbg_top.i_dbg_wb.adr[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.cmd[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.cnt[5:0]'d \
      dbg_tb.i_dbg_top.i_dbg_wb.cnt_end \
      dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt[5:0]'d \
      dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt_end \
      dbg_tb.i_dbg_top.i_dbg_wb.crc_cnt_end_q \
      dbg_tb.i_dbg_top.i_dbg_wb.enable \
      dbg_tb.i_dbg_top.i_dbg_wb.input_storage[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.len[15:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.pause_dr_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_cyc_o \
      dbg_tb.i_dbg_top.i_dbg_wb.shift_dr_i \
      dbg_tb.i_dbg_top.i_dbg_wb.start_tck \
      dbg_tb.i_dbg_top.i_dbg_wb.start_wb \
      dbg_tb.i_dbg_top.i_dbg_wb.start_wb_q \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_timeout_tck \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_error_tck \
      dbg_tb.i_dbg_top.i_dbg_wb.status[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.status_cnt[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.status_cnt_end \
      dbg_tb.i_dbg_top.i_dbg_wb.tck_i \
      dbg_tb.i_dbg_top.i_dbg_wb.tdo_o \
      dbg_tb.i_dbg_top.i_dbg_wb.trst_i \
      dbg_tb.i_dbg_top.i_dbg_wb.update_dr_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_ack_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_adr_o[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_bte_o[1:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_cab_o \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_clk_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_cti_o[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_cyc_o \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_dat_i[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_dat_o[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_err_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_rst_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_sel_o[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_stb_o \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_we_o \
      dbg_tb.i_dbg_top.i_dbg_wb.wishbone_ce_i \

add group \
    tmp \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_clk_i \
      dbg_tb.i_dbg_top.i_dbg_wb.tck_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_cyc_o \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_ack_i \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_ack_latched \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_ack_latched_rst \
      dbg_tb.i_dbg_top.i_dbg_wb.wb_ack_latched_rst_sync \
      dbg_tb.i_dbg_top.i_dbg_wb.tck_ack_sync \
      dbg_tb.i_dbg_top.i_dbg_wb.tck_ack \
      dbg_tb.i_dbg_top.i_dbg_wb.busy_wb \
      dbg_tb.i_dbg_top.i_dbg_wb.busy_sync \
      dbg_tb.i_dbg_top.i_dbg_wb.busy_tck \
      dbg_tb.i_dbg_top.i_dbg_wb.tdo_o \
      dbg_tb.i_dbg_top.pause_dr_i \
      dbg_tb.i_dbg_top.i_dbg_wb.shift_dr_i \
      dbg_tb.tdo_pad_o \
      dbg_tb.tdo_padoe_o \
      dbg_tb.tdo \
      dbg_tb.i_dbg_top.shift_crc_wb \
      dbg_tb.i_dbg_top.wishbone_ce \
      dbg_tb.i_dbg_top.i_dbg_wb.acc_cnt_limit \

add group \
    tdo_tap_top \
      dbg_tb.i_tap_top.tdi_pad_i \
      dbg_tb.i_tap_top.tdo_o \
      "tdo_o je vhod v dbg tdi_i" \
        ( \
          comment \
        ) \
      dbg_tb.i_tap_top.tdo_pad_o \
      dbg_tb.i_tap_top.tdo_padoe_o \
      dbg_tb.i_tap_top.data_tdo \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.bypassed_tdo \
      dbg_tb.i_tap_top.instruction_tdo \

add group \
    tdo_dbg_top \
      dbg_tb.i_dbg_top.tdi_i \
      dbg_tb.i_dbg_top.tdo_wb \
      "tdo_wb jw vhod v wb tdi_i" \
        ( \
          comment \
        ) \
      dbg_tb.i_dbg_top.tdi_wb \
      dbg_tb.i_dbg_top.tdo_o \
      dbg_tb.i_dbg_top.crc_out \

add group \
    tdo_wb \
      dbg_tb.i_dbg_top.i_dbg_wb.tdi_i \
      dbg_tb.i_dbg_top.i_dbg_wb.tdo_o \
      "tdo_o gre na dbg tdi_wb" \
        ( \
          comment \
        ) \


deselect all
open window waveform 1 geometry 14 67 1024 662
zoom at 123419.02(0)ns 0.00323299 0.00000000
