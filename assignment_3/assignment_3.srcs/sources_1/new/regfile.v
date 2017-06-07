`timescale 1ns / 1ps

module regfile(
  input [31:0] Aselect,//select the register index to read from to store into abus
  input [31:0] Bselect,//select the register index to read from to store into bbus
  input [31:0] Dselect,//select the register to write to from dbus
  input [31:0] dbus,//data in
  output [31:0] abus,//data out
  output [31:0] bbus,//data out
  wire [31:0] abusW,
  wire [31:0] bbusW,
  input clk
  );
  //assign abus = abusW;
  //assign bbus = bbusW;
  assign abus = Aselect[0] ? 32'b0 : abusW;//in case it's the 0
  assign bbus = Bselect[0] ? 32'b0 : bbusW;
  DNegflipFlop myFlips[31:0](//32 wide register
      .dbus(dbus),
      .abus(abusW),
      .Dselect(Dselect),
      .Bselect(Bselect),
      .Aselect(Aselect),
      .bbus(bbusW)
    );
    /*assign abus = Aselect[0] ? 32'b0 : 32'bz;//in case it's the 0
    assign bbus = Bselect[0] ? 32'b0 : 32'bz;*/
    /*always @(posedge Aselect[0]) begin
    abus = 32'b0;
    end
    always @(posedge Bselect[0]) begin
    
    end*/
  endmodule
  //negedge sensitive flipflop module flip flop module
  module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus);
    input [31:0] dbus;
    input Dselect;//the select write bit for this register
    input Bselect;//the select read bit for this register
    input Aselect;
    output [31:0] abus;
    output [31:0] bbus;
    reg [31:0] data;
    always @(posedge Dselect) begin
      data = dbus;
    end
    assign abus = Aselect ? data : 32'bz;
    assign bbus = Bselect ? data : 32'bz;
  endmodule
