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
   output wire rgb_led0_b,

   output reg pb13b,        // Extra GPIO
   output reg pb4b,
   output reg pb4a,
   output reg pb6a,
   output wire pb6b
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

  // Unused
  assign eim_wait_n = 1'b1;

  // Test memory with associated address and data hold registers.
  reg [7:0] memory [256];
  reg [7:0] address_reg;
  reg [7:0] dout_reg;

  // Edge detection registers.
  reg lba_last_reg;
  reg wr_last_reg;

  // Two stage sample registers for all inputs asynch realitive clk48.
  // The purpose of this is to solve Clock Domain Crossing (CDC).
  reg [1:0] eim_da_0_reg;
  reg [1:0] eim_da_1_reg;
  reg [1:0] eim_da_2_reg;
  reg [1:0] eim_da_3_reg;
  reg [1:0] eim_da_4_reg;
  reg [1:0] eim_da_5_reg;
  reg [1:0] eim_da_6_reg;
  reg [1:0] eim_da_7_reg;

  reg [1:0] eim_lba_n_reg;
  reg [1:0] eim_wr_n_reg;

  reg [1:0] eim_oe_n_reg;

  assign pb6b = clk48; // For debug, output the clock onto a spare GPIO

  always @(posedge clk48) begin
    pb13b <=0;  // For debug, use GPIO to output pulses when various events are triggered
    pb4b <= 0;
    pb4a <= 0;
    pb6a <= 0;

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
        pb13b <= 1;
        address_reg <= cdc_da_bus;

        // If this is a write cycle, then we don't need to read from the memory.
        // It doesn't matter in this example, but would matter if this has to
        // go over a bus. In that case, we also need to manipulate WAIT to
        // hang the EIM bus until the data is ready, so the whole thing becomes
        // more complicated.
        if(eim_wr_n_reg[1] == 1) begin
            dout_reg <= memory[cdc_da_bus];
        end
      end
    end

    // read in data when WR goes high
    // The iMX6 EIM peripheral cannot add a delay before asserting this signal,
    // so if for instance we need to add a delay to allow the data lines to
    // settle, we need to do this on the FPGA side.
    wr_last_reg <= eim_wr_n_reg[1];
    if(wr_last_reg != eim_wr_n_reg[1]) begin
      if(eim_wr_n_reg[1] == 1) begin
        memory[address_reg] <= cdc_da_bus;
      end
    end
  end

endmodule // eim_poc

//======================================================================
// EOF eim_poc.v
//======================================================================
