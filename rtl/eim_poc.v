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

module eim_poc
  (
   // system clock and reset
   input wire 	       clk48,

   // EIM interface pins from CPU
   input wire 	       eim_bclk,   // EIM burst clock. Started by the CPU.
   input wire 	       eim_cs0_n,  // Chip select (active low).
   inout wire [7 : 0]  eim_da,     // Bidirectional address and data port.
   input wire 	       eim_lba_n,  // Latch address signal (active low).
   input wire 	       eim_wr_n,   // Write enable signal (active low).
   input wire 	       eim_oe_n,   // Output enable signal (active low).
   output wire 	       eim_wait_n, // Data wait signal (active low).

   output wire [2 : 0]  led
   );

  
  //--------------------------------------------------------------------
  // Generate clock and reset using PLL resources and trees.
  //--------------------------------------------------------------------
  wire sys_clk;
  wire rst_n;
  
  clk_reset_gen clk_reset_geb_ins (
                                   .clk_ref(clk48),
                                   .clk(sys_clk),
                                   .rst_n(rst_n)
                                   );

   //----------------------------------------------------------------
   // EIM Arbiter
   //
   // EIM arbiter handles EIM access and transfers it into
   // `sys_clk' clock domain.
   //----------------------------------------------------------------

   eim_arbiter eim_arbiter_inst
     (
      .eim_bclk(eim_bclk),
      .eim_cs0_n(eim_cs0_n),
      .eim_da(eim_da),
      .eim_a(eim_a),
      .eim_lba_n(eim_lba_n),
      .eim_wr_n(eim_wr_n),
      .eim_oe_n(eim_oe_n),
      .eim_wait_n(eim_wait_n),

      .sys_clk(sys_clk),

      .sys_addr(sys_eim_addr),
      .sys_wren(sys_eim_wr),
      .sys_data_out(sys_eim_dout),
      .sys_rden(sys_eim_rd),
      .sys_data_in(sys_eim_din)
      );


   //----------------------------------------------------------------
   // LED Driver
   //
   // A simple utility LED driver that turns on the Novena
   // board LED when the EIM interface is active.
   //----------------------------------------------------------------
   eim_indicator eim_indicator_inst
     (
      .sys_clk(sys_clk),
      .sys_rst_n(rst_n),
      .eim_active(sys_eim_wr | sys_eim_rd),
      .led_out(led_pin)
      );


endmodule // eim_poc

//======================================================================
// EOF eim_poc.v
//======================================================================
