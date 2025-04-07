module eim_poc
  (
   // system clock and reset
   input wire  clk48,

   // Unused EIM pins
   input wire  eim_bclk,   // EIM burst clock. Started by the CPU.
   input wire  eim_cs0_n,  // Chip select (active low).
   output wire eim_wait_n, // Data wait signal (active low).

   inout wire  eim_da_0,
   inout wire  eim_da_1,
   inout wire  eim_da_2,
   inout wire  eim_da_3,
   inout wire  eim_da_4,
   inout wire  eim_da_5,
   inout wire  eim_da_6,
   inout wire  eim_da_7,

   input wire  eim_lba_n,  // Latch address signal (active low).
   input wire  eim_wr_n,   // Write enable signal (active low).
   input wire  eim_oe_n,   // Output enable signal (active low).

   output wire rgb_led0_r,
   output wire rgb_led0_g,
   output wire rgb_led0_b
   );


  //--------------------------------------------------------------------
  // Generate clock and reset using PLL resources and trees.
  // Not currently used.
  //--------------------------------------------------------------------
  wire sys_clk;
  wire rst_n;

  clk_reset_gen clk_reset_gen_ins (
                                   .clk_ref(clk48),
                                   .clk(sys_clk),
                                   .rst_n(rst_n)
                                   );


  //----------------------------------------------------------------
  // Instantiate (allocate) bidirectional I/O cells
  //----------------------------------------------------------------
  BBPD BBPD_0 (.I(dout_reg[0]), .T(eim_oe_n_reg[1]), .O(da_bus[0]), .B(eim_da_0));
  BBPD BBPD_1 (.I(dout_reg[1]), .T(eim_oe_n_reg[1]), .O(da_bus[1]), .B(eim_da_1));
  BBPD BBPD_2 (.I(dout_reg[2]), .T(eim_oe_n_reg[1]), .O(da_bus[2]), .B(eim_da_2));
  BBPD BBPD_3 (.I(dout_reg[3]), .T(eim_oe_n_reg[1]), .O(da_bus[3]), .B(eim_da_3));
  BBPD BBPD_4 (.I(dout_reg[4]), .T(eim_oe_n_reg[1]), .O(da_bus[4]), .B(eim_da_4));
  BBPD BBPD_5 (.I(dout_reg[5]), .T(eim_oe_n_reg[1]), .O(da_bus[5]), .B(eim_da_5));
  BBPD BBPD_6 (.I(dout_reg[6]), .T(eim_oe_n_reg[1]), .O(da_bus[6]), .B(eim_da_6));
  BBPD BBPD_7 (.I(dout_reg[7]), .T(eim_oe_n_reg[1]), .O(da_bus[7]), .B(eim_da_7));


  //----------------------------------------------------------------
  // LED Driver
  //
  // The LED states are mapped to the least-significant bits of the
  // first memory location
  //----------------------------------------------------------------
  assign {rgb_led0_r, rgb_led0_g, rgb_led0_b} = ~memory[0][2:0];


  //----------------------------------------------------------------
  // Register updates and response logic.
  // When OE is pulled low, output some data
  //----------------------------------------------------------------
  // Wires tp create bueses for data from the pins and the
  // corresponding data after crossing the clock domain.
  wire [7:0] da_bus;
  wire [7:0] cdc_da_bus;
  assign cdc_da_bus = {eim_da_7_reg[1], eim_da_6_reg[1], eim_da_5_reg[1], eim_da_4_reg[1],
                       eim_da_3_reg[1], eim_da_2_reg[1], eim_da_1_reg[1], eim_da_0_reg[1]};

  // Test memory with associated address and data hold registers.
  reg [7:0] memory[7:0];
  reg [7:0] address_reg;
  reg [7:0] dout_reg;

  // Edge detection registers.
  reg lba_last_reg;
  reg wr_last_reg;

  // Two stage sample registers for all inputs asynch realitive clk48.
  // The purpose of this is to solve Clock Domain Crossing (CDC).
  reg eim_da_0_reg [0 : 1];
  reg eim_da_1_reg [0 : 1];
  reg eim_da_2_reg [0 : 1];
  reg eim_da_3_reg [0 : 1];
  reg eim_da_4_reg [0 : 1];
  reg eim_da_5_reg [0 : 1];
  reg eim_da_6_reg [0 : 1];
  reg eim_da_7_reg [0 : 1];

  reg eim_lba_n_reg [0 : 1];
  reg eim_wr_n_reg[0 : 1];

  reg eim_oe_n_reg[0 : 1];


  always @(posedge clk48) begin
    // Sample data inputs.
    eim_da_0_reg[0] <= da_bus[0];
    eim_da_0_reg[1] <= eim_da_0_reg[0];

    eim_da_1_reg[0] <= da_bus[1];
    eim_da_1_reg[1] <= eim_da_1_reg[0];

    eim_da_2_reg[0] <= da_bus[2];
    eim_da_2_reg[1] <= eim_da_2_reg[0];

    eim_da_3_reg[0] <= da_bus[3];
    eim_da_3_reg[1] <= eim_da_3_reg[0];

    eim_da_4_reg[0] <= da_bus[4];
    eim_da_4_reg[1] <= eim_da_4_reg[0];

    eim_da_5_reg[0] <= da_bus[5];
    eim_da_5_reg[1] <= eim_da_5_reg[0];

    eim_da_6_reg[0] <= da_bus[6];
    eim_da_6_reg[1] <= eim_da_6_reg[0];

    eim_da_7_reg[0] <= da_bus[7];
    eim_da_7_reg[1] <= eim_da_7_reg[0];


    // Sample control inputs.
    eim_lba_n_reg [0] <= eim_lba_n;
    eim_lba_n_reg [1] <= eim_lba_n_reg [0];

    eim_wr_n_reg[0] <= eim_wr_n;
    eim_wr_n_reg[1] <= eim_wr_n_reg[0];

    eim_oe_n_reg[0] <= eim_oe_n;
    eim_oe_n_reg[1] <= eim_oe_n_reg[0];

    // capture address when LBA goes low
    lba_last_reg <= eim_lba_n_reg[1];
    if(lba_last_reg != eim_lba_n_reg[1]) begin
      if(eim_lba_n_reg[1] == 0) begin
        address_reg <= cdc_da_bus;
      end

      // Load data into output buffer when LBA goes high (in case this is a read transaction)
      // TODO: During a write transaction, RW may go low before LBA goes high. In that case,
      //       we wouldn't need to read the data here. For our trivial example it doesn't matter.
      if(eim_lba_n_reg[1] == 1) begin
        dout_reg <= memory[address];
      end
    end

    // read in data when WR goes high
    wr_last_reg <= eim_wr_n_reg[1];
    if(wr_last_reg != eim_wr_n_reg[1]) begin
      if(eim_wr_n_reg[1] == 1) begin
        memory[address] <= cdc_da_bus;
      end
    end
  end

endmodule // eim_poc

//======================================================================
// EOF eim_poc.v
//======================================================================
