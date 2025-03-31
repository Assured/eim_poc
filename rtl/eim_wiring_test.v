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
   output wire 	       eim_bclk,   // EIM burst clock. Started by the CPU.
   output wire 	       eim_cs0_n,  // Chip select (active low).
   output wire           eim_da_0,
   output wire           eim_da_1,
   output wire           eim_da_2,
   output wire           eim_da_3,
   output wire           eim_da_4,
   output wire           eim_da_5,
   output wire           eim_da_6,
   output wire           eim_da_7,
   output wire 	       eim_lba_n,  // Latch address signal (active low).
   output wire 	       eim_wr_n,   // Write enable signal (active low).
   output wire 	       eim_oe_n,   // Output enable signal (active low).
   output wire 	       eim_wait_n, // Data wait signal (active low).

   output wire           rgb_led0_r,
   output wire           rgb_led0_g,
   output wire           rgb_led0_b,
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
   // LED Driver
   //
   // Flash an RGB pattern on the LED
   //----------------------------------------------------------------
    reg [26:0] led_counter = 0;
    reg [2:0] led_state = 3'b011;

    assign {rgb_led0_r, rgb_led0_g, rgb_led0_b} = led_state;

    // Every positive edge increment register by 1
    always @(posedge clk48) begin
        led_counter <= led_counter + 1;

        case(led_counter[25:24])
            2'b00: led_state <= 3'b111;
            2'b01: led_state <= 3'b011;
            2'b10: led_state <= 3'b101;
            2'b11: led_state <= 3'b110;
        endcase;
    end


   //----------------------------------------------------------------
   // Wire assignment test
   //
   // Cycle through each of the 
   //----------------------------------------------------------------
    reg [12:0] counter2 = 0;
    reg [13:0] wire_test_state = 1;

    assign {
        eim_da_0,
        eim_da_1,
        eim_da_2,
        eim_da_3,
        eim_da_4,
        eim_da_5,
        eim_da_6,
        eim_da_7,
        eim_bclk,   // EIM burst clock. Started by the CPU.
        eim_cs0_n,  // Chip select (active low).
        eim_oe_n,   // Output enable signal (active low).
        eim_wait_n, // Data wait signal (active low).
        eim_wr_n,   // Write enable signal (active low).
        eim_lba_n  // Latch address signal (active low).
        } = wire_test_state;


    always @(posedge clk48) begin
        counter2 <= counter2 + 1;

        if(counter2 == 0) begin
            wire_test_state <= {wire_test_state[0], wire_test_state[13:1]};
        end
    end

endmodule // eim_poc

//======================================================================
// EOF eim_poc.v
//======================================================================
