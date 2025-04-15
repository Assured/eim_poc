module eim_poc
  (
   // system clock and reset
   input wire 	       clk48,

   // EIM interface pins from CPU
   input wire 	       eim_bclk,   // EIM burst clock. Started by the CPU.
   input wire 	       eim_cs0_n,  // Chip select (active low).
   inout wire           eim_da_0,
   inout wire           eim_da_1,
   inout wire           eim_da_2,
   inout wire           eim_da_3,
   inout wire           eim_da_4,
   inout wire           eim_da_5,
   inout wire           eim_da_6,
   inout wire           eim_da_7,
   input wire 	       eim_lba_n,  // Latch address signal (active low).
   input wire 	       eim_wr_n,   // Write enable signal (active low).
   input wire 	       eim_oe_n,   // Output enable signal (active low).
   output wire 	       eim_wait_n, // Data wait signal (active low).

   output wire           rgb_led0_r,
   output wire           rgb_led0_g,
   output wire           rgb_led0_b
   );


  //--------------------------------------------------------------------
  // Generate clock and reset using PLL resources and trees.
  //--------------------------------------------------------------------
  wire sys_clk;
  wire rst_n;

  clk_reset_gen clk_reset_gen_ins (
                                   .clk_ref(clk48),
                                   .clk(sys_clk),
                                   .rst_n(rst_n)
                                   );



   //----------------------------------------------------------------
   // Respond to OE
   //
   // When OE is pulled low, output some data
   //----------------------------------------------------------------
  wire [7:0] da_bus;

    reg [7:0] memory[0:255];

    reg [7:0] address = 8'd0;
    reg [7:0] dout = 8'd0;

    reg lba_last = 1'd1;
    reg wr_last = 1'd1;

  BBPD BBPD_0 (.I(dout[0]), .T(eim_oe_n), .O(da_bus[0]), .B(eim_da_0));
  BBPD BBPD_1 (.I(dout[1]), .T(eim_oe_n), .O(da_bus[1]), .B(eim_da_1));
  BBPD BBPD_2 (.I(dout[2]), .T(eim_oe_n), .O(da_bus[2]), .B(eim_da_2));
  BBPD BBPD_3 (.I(dout[3]), .T(eim_oe_n), .O(da_bus[3]), .B(eim_da_3));
  BBPD BBPD_4 (.I(dout[4]), .T(eim_oe_n), .O(da_bus[4]), .B(eim_da_4));
  BBPD BBPD_5 (.I(dout[5]), .T(eim_oe_n), .O(da_bus[5]), .B(eim_da_5));
  BBPD BBPD_6 (.I(dout[6]), .T(eim_oe_n), .O(da_bus[6]), .B(eim_da_6));
  BBPD BBPD_7 (.I(dout[7]), .T(eim_oe_n), .O(da_bus[7]), .B(eim_da_7));

    always @(posedge clk48) begin
        // capture address when LBA goes low
        lba_last <= eim_lba_n;
        if(lba_last != eim_lba_n) begin
            if(eim_lba_n == 0) begin
                address <= da_bus;
            end

            // Load data into output buffer when LBA goes high (in case this is a read transaction)
            // TODO: During a write transaction, RW may go low before LBA goes high. In that case,
            //       we wouldn't need to read the data here. For our trivial example it doesn't matter.
            if(eim_lba_n == 1) begin
                dout <= memory[address];
            end
        end

        // read in data when WR goes high
        wr_last <= eim_wr_n;
        if(wr_last != eim_wr_n) begin
            if(eim_wr_n == 1) begin
                memory[address] <= da_bus;
            end
        end
    end

   //----------------------------------------------------------------
   // LED Driver
   //
   // The LED states are mapped to the least-significant bits of the
   // first memory location
   //----------------------------------------------------------------
   assign {rgb_led0_r, rgb_led0_g, rgb_led0_b} = ~memory[0][2:0];

endmodule // eim_poc

//======================================================================
// EOF eim_poc.v
//======================================================================
