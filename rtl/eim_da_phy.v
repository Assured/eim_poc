//======================================================================
//
// eim_da_phy.v
// ------------
// IO buffer module for the EIM DA port.
//
//
// Author: Pavel Shatov
// Copyright (c) 2015, NORDUnet A/S All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// - Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
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

module eim_da_phy
  #(parameter BUS_WIDTH = 16)
   (
    inout wire [BUS_WIDTH-1:0]  buf_io, // connect directly to top-level pins
    input wire [BUS_WIDTH-1:0]  buf_di, // drive input (value driven onto pins)
    output wire [BUS_WIDTH-1:0] buf_ro, // receiver output (value read from pins)
    input wire                  buf_t   // tristate control (driver is disabled during tristate)
    );

   //
   // ECP5 bidirectional IO-buffer.
   //
   genvar                       i;
   generate
      for (i = 0; i < BUS_WIDTH; i = i+1)
        begin: eim_da
          BB BB_inst
               (
                .B(buf_io[i]),
                .O(buf_ro[i]),
                .I(buf_di[i]),
                .T(buf_t)
                );
        end
   endgenerate

endmodule

//======================================================================
// EOF eim_da_phy.v
//======================================================================
