vlog -reportprogress 300 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_crc8_d1.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_defines.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_register.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_registers.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_sync_clk1_clk2.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_timescale.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_top.v}
vlog -reportprogress 30 -work work {C:/cvsroot/dbg_interface/rtl/verilog/dbg_trace.v}

vlog -reportprogress 300 -work work {C:/cvsroot/dbg_interface/bench/verilog/dbg_tb.v}


vsim work.dbg_tb

add wave -r -hexadecimal /*
.wave.tree zoomfull

run -all
