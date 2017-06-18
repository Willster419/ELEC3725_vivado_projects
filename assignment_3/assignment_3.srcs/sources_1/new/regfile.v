`timescale 1ns / 1ps

module regfile(
  input [31:0] Aselect,//select the register index to read from to store into abus
  input [31:0] Bselect,//select the register index to read from to store into bbus
  input [31:0] Dselect,//select the register to write to from dbus
  input [31:0] dbus,//data in
  output [31:0] abus,//data out
  output [31:0] bbus,//data out
  input clk
  );
  //wire [31:0] abusW;
  //wire [31:0] bbusW;
  //assign abus = abusW;
  //assign bbus = bbusW;
  assign abus = Aselect[0] ? 32'b0 : 32'bz;//in case it's the 0
  assign bbus = Bselect[0] ? 32'b0 : 32'bz;
  DNegflipFlop myFlips[30:0](//32 wide register
      .dbus(dbus),
      .abus(abus),
      .Dselect(Dselect[31:1]),
      .Bselect(Bselect[31:1]),
      .Aselect(Aselect[31:1]),
      .bbus(bbus),
      .clk(clk)
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
  module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus, clk);
    input [31:0] dbus;
    input Dselect;//the select write bit for this register
    input Bselect;//the select read bit for this register
    input Aselect;
    input clk;
    output [31:0] abus;
    output [31:0] bbus;
    reg [31:0] data;
    always @(negedge clk) begin
      if(Dselect) begin
      data = dbus;
      end
    end
    assign abus = Aselect ? data : 32'bz;
    assign bbus = Bselect ? data : 32'bz;
  endmodule
