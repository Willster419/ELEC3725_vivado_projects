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
        
    //wire [31:0] abusW;
    //wire [31:0] bbusW;
    //wire [31:0] dbusW;
    
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


module regfile(
  input [31:0] Aselect,//select the register index to read from to store into abus
  input [31:0] Bselect,//select the register index to read from to store into bbus
  input [31:0] Dselect,//select the register to write to from dbus
  input [31:0] dbus,//data in
  output [31:0] abus,//data out
  output [31:0] bbus,//data out
  input clk
  );

  assign abus = Aselect[0] ? 32'b0 : 32'bz;
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
  endmodule

module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus, clk);
  input [31:0] dbus;
  input Dselect;//the select write bit for this register
  input Bselect;//the select read bit for this register
  input Aselect;
  input clk;
  output [31:0] abus;
  output [31:0] bbus;
  wire wireclk;
  reg [31:0] data;
  
  assign wireclk = clk & Dselect;
  
  always @(negedge wireclk) begin
    data = dbus;    
  end
  assign abus = Aselect ? data : 32'bz;
  assign bbus = Bselect ? data : 32'bz;
endmodule
