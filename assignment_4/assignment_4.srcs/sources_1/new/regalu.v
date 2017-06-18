/************************
*  Willard Wider
*  6-14-17
*  ELEC3725
*  regalu.v
*  building a 32 bit ALU
************************/
//The regfile and ALUpipe wired together
module regalu(Aselect, Bselect, Dselect, clk, Cin, S, abus, bbus, dbus);
    input [31:0] Aselect;
    input [31:0] Bselect;
    input [31:0] Dselect;
    input clk;
    output [31:0] abus;
    output [31:0] bbus;
    output [31:0] dbus;
    input [2:0] S;
    input Cin;
    
    regfile reggie(
    .Aselect(Aselect),
    .Bselect(Bselect),
    .Dselect(Dselect),
    .dbus(dbus),
    .bbus(bbus),
    .abus(abus),
    .clk(clk)
    );
    
    alupipe alup(
    .S(S),
    .Cin(Cin),
    .clk(clk),
    .abus(abus),
    .bbus(bbus),
    .dbus(dbus)
    );
endmodule
//The top module for Assignment 3, the whole register unit
module regfile(
  input [31:0] Aselect,//select the register index to read from to store into abus
  input [31:0] Bselect,//select the register index to read from to store into bbus
  input [31:0] Dselect,//select the register to write to from dbus
  input [31:0] dbus,//data in
  output [31:0] abus,//data out
  output [31:0] bbus,//data out
  input clk
  );
  /* 
  Register index 0 is always supposed to be a 0 output, and only one select for
  A, B, and D will be high at a time. Therefore, if the A or Bselect at index 0
  is high, it means we can write all 0's to the corresponding bus. Otherwize
  write z (don't touch it)
  */
  assign abus = Aselect[0] ? 32'b0 : 32'bz;
  assign bbus = Bselect[0] ? 32'b0 : 32'bz;
  //31 wide register (don't need one for index 0
  DNegflipFlop myFlips[30:0](
      .dbus(dbus),
      .abus(abus),
      .Dselect(Dselect[31:1]),
      .Bselect(Bselect[31:1]),
      .Aselect(Aselect[31:1]),
      .bbus(bbus),
      .clk(clk)
    );
  endmodule
//module definiton for each register in the register file
module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus, clk);
  input [31:0] dbus;
  input Dselect;//the select write bit for dbus
  input Bselect;//the select read bit for bbus
  input Aselect;//the select read bit for abus
  input clk;
  output [31:0] abus;
  output [31:0] bbus;
  wire wireclk;//wire for connectitng the clock to the dselect input
  reg [31:0] data;
  assign wireclk = clk & Dselect;//wireclk will only be high if both are high
  always @(negedge wireclk) begin
    data = dbus;    
  end
  //only write to the output bus of it's select is high, otherwise write z
  //(don't actually write anything)
  assign abus = Aselect ? data : 32'bz;
  assign bbus = Bselect ? data : 32'bz;
endmodule
