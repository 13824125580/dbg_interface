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
define waveform window listpane 13.22
define waveform window namepane 20.97
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
      dbg_tb.i_tap_top.tdi_pad_i \
      dbg_tb.i_tap_top.tdo_pad_o \
      dbg_tb.i_tap_top.tdo_padoe_o \
      dbg_tb.i_tap_top.tms_pad_i \
      dbg_tb.i_tap_top.trst_pad_i \
      dbg_tb.i_tap_top.TestLogicReset \
      dbg_tb.i_tap_top.RunTestIdle \
      dbg_tb.i_tap_top.SelectDRScan \
      dbg_tb.i_tap_top.CaptureDR \
      dbg_tb.i_tap_top.SelectIRScan \
      dbg_tb.i_tap_top.CaptureIR \
      dbg_tb.i_tap_top.PauseDR \
      dbg_tb.i_tap_top.ShiftDR \
      dbg_tb.i_tap_top.ShiftIR \
      dbg_tb.i_tap_top.PauseIR \
      dbg_tb.i_tap_top.UpdateDR \
      dbg_tb.i_tap_top.UpdateIR \
      dbg_tb.i_tap_top.UpdateDR_q \
      dbg_tb.i_tap_top.Exit1DR \
      dbg_tb.i_tap_top.Exit1IR \
      dbg_tb.i_dbg_top.CrcMatch \
      dbg_tb.i_dbg_top.crc_cnt[3:0]'h \
      dbg_tb.i_dbg_top.crc_bypassed \
      dbg_tb.i_dbg_top.CalculatedCrcIn[7:0]'h \
      dbg_tb.i_dbg_top.CalculatedCrcOut[7:0]'h \
      dbg_tb.i_dbg_top.BitCounter[7:0]'h \
      dbg_tb.i_dbg_top.CalculatedCrcOut[7:0]'h \
      dbg_tb.i_dbg_top.BitCounter[7:0]'h \
      dbg_tb.i_dbg_top.TDOData \
      dbg_tb.i_dbg_top.crc_cnt[3:0]'h \
      dbg_tb.i_tap_top.JTAG_IR[3:0]'h \
      dbg_tb.i_tap_top.LatchedJTAG_IR[3:0]'h \
      dbg_tb.i_tap_top.BypassRegister \
      dbg_tb.i_tap_top.CHAIN_SELECTSelected \
      dbg_tb.i_tap_top.DEBUGSelected \
      dbg_tb.i_tap_top.EXTESTSelected \
      dbg_tb.i_tap_top.IDCODESelected \
      dbg_tb.i_tap_top.MBISTSelected \
      dbg_tb.i_tap_top.CpuDebugScanChain0 \
      dbg_tb.i_tap_top.CpuDebugScanChain1 \
      dbg_tb.i_tap_top.CpuDebugScanChain2 \
      dbg_tb.i_tap_top.CpuDebugScanChain3 \
      dbg_tb.i_tap_top.RegisterScanChain \
      dbg_tb.i_tap_top.WishboneScanChain \
      dbg_tb.i_tap_top.TDOData_dbg \
      dbg_tb.i_tap_top.bs_chain_i \
      dbg_tb.i_tap_top.mbist_so_i \

add group \
    dbg_registers \
      dbg_tb.i_dbg_top.dbgregs.CPUOPOut[2:1]'h \
      dbg_tb.i_dbg_top.dbgregs.CPUOP_Acc \
      dbg_tb.i_dbg_top.dbgregs.CPUOP_Rd \
      dbg_tb.i_dbg_top.dbgregs.CPUOP_Wr \
      dbg_tb.i_dbg_top.dbgregs.CPUSELOut[1:0]'h \
      dbg_tb.i_dbg_top.dbgregs.CPUSEL_Acc \
      dbg_tb.i_dbg_top.dbgregs.CPUSEL_Rd \
      dbg_tb.i_dbg_top.dbgregs.CPUSEL_Wr \
      dbg_tb.i_dbg_top.dbgregs.CpuStallBp \
      dbg_tb.i_dbg_top.dbgregs.MODEROut[31:0]'h \
      dbg_tb.i_dbg_top.dbgregs.MODER_Acc \
      dbg_tb.i_dbg_top.dbgregs.MODER_Rd \
      dbg_tb.i_dbg_top.dbgregs.MODER_Wr \
      dbg_tb.i_dbg_top.dbgregs.MONCNTLOut[3:0]'h \
      dbg_tb.i_dbg_top.dbgregs.MON_CNTL_Acc \
      dbg_tb.i_dbg_top.dbgregs.MON_CNTL_Rd \
      dbg_tb.i_dbg_top.dbgregs.MON_CNTL_Wr \
      dbg_tb.i_dbg_top.dbgregs.WB_CNTLOut[1:0]'h \
      dbg_tb.i_dbg_top.dbgregs.WB_CNTL_Acc \
      dbg_tb.i_dbg_top.dbgregs.WB_CNTL_Rd \
      dbg_tb.i_dbg_top.dbgregs.WB_CNTL_Wr \
      dbg_tb.i_dbg_top.dbgregs.access \
      dbg_tb.i_dbg_top.dbgregs.address[4:0]'h \
      dbg_tb.i_dbg_top.dbgregs.bp \
      dbg_tb.i_dbg_top.dbgregs.clk \
      dbg_tb.i_dbg_top.dbgregs.cpu_reset \
      dbg_tb.i_dbg_top.dbgregs.cpu_stall \
      dbg_tb.i_dbg_top.dbgregs.cpu_stall_all \
      dbg_tb.i_dbg_top.dbgregs.cpu_sel[1:0]'h \
      dbg_tb.i_dbg_top.dbgregs.data_in[31:0]'h \
      dbg_tb.i_dbg_top.dbgregs.data_out[31:0]'h \
      dbg_tb.i_dbg_top.dbgregs.mon_cntl_o[3:0]'h \
      dbg_tb.i_dbg_top.dbgregs.reset \
      dbg_tb.i_dbg_top.dbgregs.rw \
      dbg_tb.i_dbg_top.dbgregs.wb_cntl_o[1:0]'h \

add group \
    dbg_top \
      dbg_tb.i_dbg_top.BypassRegister \
      dbg_tb.i_dbg_top.CHAIN_SELECTSelected \
      dbg_tb.i_dbg_top.RegisterScanChain \
      dbg_tb.i_dbg_top.CpuDebugScanChain0 \
      dbg_tb.i_dbg_top.CpuDebugScanChain1 \
      dbg_tb.i_dbg_top.CpuDebugScanChain2 \
      dbg_tb.i_dbg_top.CpuDebugScanChain3 \
      dbg_tb.i_dbg_top.cpu_addr_o[31:0]'h \
      dbg_tb.i_dbg_top.cpu_data_i[31:0]'h \
      dbg_tb.i_dbg_top.cpu_data_o[31:0]'h \
      dbg_tb.i_dbg_top.opselect_o[2:0]'h \
      dbg_tb.i_dbg_top.cpu_sel_o[1:0]'h \
      dbg_tb.i_dbg_top.cpu_stall_all_o \
      dbg_tb.i_dbg_top.cpu_stall_o \
      dbg_tb.i_dbg_top.CpuStall_access \
      dbg_tb.i_dbg_top.CpuStall_read_access_0 \
      dbg_tb.i_dbg_top.CpuStall_read_access_1 \
      dbg_tb.i_dbg_top.CpuStall_read_access_2 \
      dbg_tb.i_dbg_top.CpuStall_read_access_3 \
      dbg_tb.i_dbg_top.CpuStall_write_access_0 \
      dbg_tb.i_dbg_top.CpuStall_write_access_1 \
      dbg_tb.i_dbg_top.CpuStall_write_access_2 \
      dbg_tb.i_dbg_top.CpuStall_write_access_3 \
      dbg_tb.i_dbg_top.cpu_clk_i \
      dbg_tb.i_dbg_top.DEBUGSelected \
      dbg_tb.i_dbg_top.Exit1DR \
      dbg_tb.i_dbg_top.IDCODESelected \
      dbg_tb.i_dbg_top.ShiftDR \
      dbg_tb.i_dbg_top.TDOData \
      dbg_tb.i_dbg_top.UpdateDR \
      dbg_tb.i_dbg_top.UpdateDR_q \
      dbg_tb.i_dbg_top.WishboneScanChain \
      dbg_tb.i_dbg_top.bp_i \
      dbg_tb.i_dbg_top.cpu_addr_o[31:0]'h \
      dbg_tb.i_dbg_top.cpu_clk_i \
      dbg_tb.i_dbg_top.cpu_data_i[31:0]'h \
      dbg_tb.i_dbg_top.cpu_data_o[31:0]'h \
      dbg_tb.i_dbg_top.cpu_sel_o[1:0]'h \
      dbg_tb.i_dbg_top.cpu_stall_all_o \
      dbg_tb.i_dbg_top.cpu_stall_o \
      dbg_tb.i_dbg_top.istatus_i[1:0]'h \
      dbg_tb.i_dbg_top.lsstatus_i[3:0]'h \
      dbg_tb.i_dbg_top.mon_cntl_o[3:0]'h \
      dbg_tb.i_dbg_top.opselect_o[2:0]'h \
      dbg_tb.i_dbg_top.reset_o \
      dbg_tb.i_dbg_top.tck \
      dbg_tb.i_dbg_top.tdi \
      dbg_tb.i_dbg_top.trst_in \
      dbg_tb.i_dbg_top.wb_ack_i \
      dbg_tb.i_dbg_top.wb_adr_o[31:0]'h \
      dbg_tb.i_dbg_top.wb_cab_o \
      dbg_tb.i_dbg_top.wb_clk_i \
      dbg_tb.i_dbg_top.wb_cyc_o \
      dbg_tb.i_dbg_top.wb_dat_i[31:0]'h \
      dbg_tb.i_dbg_top.wb_dat_o[31:0]'h \
      dbg_tb.i_dbg_top.wb_err_i \
      dbg_tb.i_dbg_top.wb_rst_i \
      dbg_tb.i_dbg_top.wb_sel_o[3:0]'h \
      dbg_tb.i_dbg_top.wb_stb_o \
      dbg_tb.i_dbg_top.wb_we_o \
      dbg_tb.i_dbg_top.wp_i[10:0]'h \
      dbg_tb.i_dbg_top.RW \


deselect all
open window designbrowser 1 geometry 64 125 855 550
open window waveform 1 geometry 14 67 1024 662
zoom at 168762.05(0)ns 0.00005926 0.00000000
