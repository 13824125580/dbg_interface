//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File_communication.v                                        ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC/OpenRISC Development Interface ////
////  http://www.opencores.org/cores/DebugInterface/              ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000,2001 Authors                              ////
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
//
//
//
//

`include "dbg_timescale.v"
`include "dbg_defines.v"
`include "dbg_tb_defines.v"

module File_communication();

parameter Tp = 1;

integer handle1, handle2;
reg [3:0] memory[0:0];
reg Mclk;
reg P_PowerONReset;

reg StartTesting;
wire P_TCK;
wire P_TRST;
wire P_TDI;
wire P_TMS;
wire P_TDO;


initial
begin
  StartTesting = 0;
  P_PowerONReset = 1;
  #500;
  P_PowerONReset = 0;
  #500;
  P_PowerONReset = 1;
  
//  handle2 = $fopen("file1.out");
  #1000;
//  $fdisplay(handle2 | 1, "\n\nDa vidimo, ce ta shit dela OK.");
  #1000;
//  $fclose(handle2);
//  $display("Memory = 0x%0x", memory[0]);
//  handle1 = $fopen("file1.in");
//  $fdisplay(handle2 | 1, "\n\nDa vidimo, ce dela shit od pisanja nazaj v prvi file OK.");
//  $fclose(handle1);
//  $fclose(handle2);
  StartTesting = 1;
  $display("StartTesting = 1");


end

initial
begin
  wait(StartTesting);
  while(1)
  begin
    #1000;
    $readmemh("E:\\tmp\\out.txt", memory);
//    handle2 = $fopen("E:\\tmp\\in.txt");
//    $fdisplay(handle2 | 1, "%b", P_TDO);  // Vpisem TDO v file
//    $fclose(handle2);
    #1000;
//    handle1 = $fopen("E:\\tmp\\out.txt");
//    handle2 = $fopen("E:\\tmp\\in.txt");
//    handle1 = $fopen("E:\\tmp\\out.txt");
//    $display("TDO = 0x%0x", P_TDO);
//    $fdisplay(handle1 | 1, " ");          // zbrisem Markov podatek
//    $fclose(handle1);
  end
end


always @ (posedge P_TCK)
begin
  handle2 = $fopen("E:\\tmp\\in.txt");
//  $fdisplay(handle2 | 1, "%b, %t", P_TDO, $time);  // Vpisem TDO v file
  $fdisplay(handle2 | 1, "%b", P_TDO);  // Vpisem TDO v file
//  $fdisplay(handle2 | 1, "%t", $time);  // Vpisem TDO v file
  $fclose(handle2);
end




  wire [3:0]Temp = memory[0];

  assign P_TCK = Temp[0];
  assign P_TRST = Temp[1];
  assign P_TDI = Temp[2];
  assign P_TMS = Temp[3];



// Generating master clock (RISC clock) 10 MHz
initial
begin
  Mclk<=#Tp 0;
  #1 forever #`RISC_CLOCK Mclk<=~Mclk;
end

// Generating random number for use in DATAOUT_RISC[31:0]
reg [31:0] RandNumb;
always @ (posedge Mclk or negedge P_PowerONReset) // PowerONReset is active low
begin
  if(~P_PowerONReset)
    RandNumb[31:0]<=#Tp 0;
  else
    RandNumb[31:0]<=#Tp RandNumb[31:0] + 1;
end

wire [31:0] DataIn = RandNumb;

// Connecting dbgTAP module
dbg_top dbg1  (.P_TMS(P_TMS), .P_TCK(P_TCK), .P_TRST(P_TRST), .P_TDI(P_TDI), .P_TDO(P_TDO), 
               .P_PowerONReset(P_PowerONReset), .Mclk(Mclk), .RISC_ADDR(), .RISC_DATA_IN(DataIn),
               .RISC_DATA_OUT(), .RISC_CS(), .RISC_RW(), .Wp(11'h0), .Bp(1'b0), 
               .OpSelect(), .LsStatus(4'h0), .IStatus(2'h0)
              );




endmodule // TAP
