#write format wave -window .wave C:/cvsroot/ethernet/sim/rtl_sim/run/wave.do


vlog -reportprogress 300 -work work {C:/cvsroot/dbg_interface/bench/verilog/dbg_tb.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/bench/verilog/dbg_tb_defines.v}
vlog -reportprogress 300 -work work {C:/cvsroot/dbg_interface/rtl/verilog/timescale.v}
vlog -reportprogress 300 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_crc8_d1.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_defines.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_register.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_registers.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_sync_clk1_clk2.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_top.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_trace.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/tap_top.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/jtag_chain.v}

vsim work.dbg_tb

add wave -r -hexadecimal /*

#do C:/cvsroot/ethernet/sim/rtl_sim/run/wave.do

run -all
.wave.tree zoomfull
