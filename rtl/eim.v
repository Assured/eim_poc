//======================================================================
//
// Copyright (c) 2014-2015, NORDUnet A/S All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// - Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
//
// - Neither the name of the NORDUnet nor the names of its contributors may
//   be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
// IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
// TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module eim
  (
   // system clock and reset
   input wire 	       clk,
   input wire 	       reset_n,

   // EIM interface pins from CPU
   input wire 	       eim_bclk, // EIM burst clock. Started by the CPU.
   input wire 	       eim_cs0_n, // Chip select (active low).
   inout wire [7 : 0]  eim_da, // Bidirectional address and data port.
   input wire 	       eim_lba_n, // Latch address signal (active low).
   input wire 	       eim_wr_n, // write enable signal (active low).
   input wire 	       eim_oe_n, // output enable signal (active low).
   output wire 	       eim_wait_n, // Data wait signal (active low).

   output wire [2 : 0]  led
   );

   
  //----------------------------------------------------------------
  // eim_ctrl
  //
  // EIM arbiter handles EIM accesses and transfers it into
  // `sys_clk' clock domain. It also implements the FSM part
  // of the PoC. (This should probably bli separated.)
  //----------------------------------------------------------------
   eim_ctrl eim_ctrl_inst
     (
      .sys_clk(clk),

      .eim_bclk(eim_bclk),
      .eim_cs0_n(eim_cs0_n),
      .eim_da(eim_da),
      .eim_a(eim_a),
      .eim_lba_n(eim_lba_n),
      .eim_wr_n(eim_wr_n),
      .eim_oe_n(eim_oe_n),
      .eim_wait_n(eim_wait_n),

      .led(led)
      );


endmodule // eim

//======================================================================
// EOF eim.v
//======================================================================
