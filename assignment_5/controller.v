/************************
*  Willard Wider
*  6-6-17
*  ELEC3725
*  alupipe.v
*  building a 32 bit ALU
************************/
module controller(ibus, clk, Cin, Imm, S, Aselect, Bselect, Dselect);
  input [31:0] ibus;
  input clk;
  output [31:0] Aselect;
  output [31:0] Bselect;
  output [31:0] Dselect;
  output [2:0] S;
  output Imm;
  output Cin;
  wire [31:0] IFIDOUT;
  DflipFlop IFID(.dataIn(ibus), .clk(clk), .dataOut(IFIDOUT));
endmodule
//flip flop module. requires a clock cycle to update value
module DflipFlop(dataIn, clk, dataOut);
  input [31:0] dataIn;
  input clk;
  output [31:0] dataOut;
  reg [31:0] dataOut;
  always @(posedge clk) begin
    dataOut = dataIn;
  end
endmodule
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


//the top module, the ALU with piped input and output
module alupipe(S, abus, bbus, clk, Cin, dbus);
  input [31:0] abus;
  input [31:0] bbus;
  input clk;
  input [2:0] S;
  input Cin;
  output [31:0] dbus;
  wire [31:0] aInput;//connects register A output to ALU A input
  wire [31:0] bInput;//connects register B output to ALU B input
  wire [31:0] dInput;//connects register D input to ALU D output
  
  alu32 ALU(.a(aInput), .b(bInput), .Cin(Cin), .d(dInput), .S(S));
  DflipFlop AFF(.dataIn(abus), .dataOut(aInput), .clk(clk));
  DflipFlop BFF(.dataIn(bbus), .dataOut(bInput), .clk(clk));
  DflipFlop DFF(.dataIn(dInput), .dataOut(dbus), .clk(clk));
  
endmodule
//flip flop module. requires a clock cycle to update value
module DflipFlop(dataIn, clk, dataOut);
  input [31:0] dataIn;
  input clk;
  output [31:0] dataOut;
  reg [31:0] dataOut;
  always @(posedge clk) begin
    dataOut = dataIn;
  end
endmodule

//Below this point is code from assignment 1//

//The declaration of the entire ALU itself.
module alu32 (d, Cout, V, a, b, Cin, S);
  output[31:0] d;//the output bus
  output Cout, V;//Cout is the bit for it it needs to carry over to the next circuit/ V is the overflow bit.
  input [31:0] a, b;//the two input buses
  input Cin;//the bit for marking if it is carrying over from a previous circuit
  input [2:0] S;//The select bus. It defines the operation to do with input busses a and b
  
  wire [31:0] c, g, p;
  wire gout, pout;
  
  //The core ALU bus
  alu_cell mycell[31:0] (
     .d(d),
     .g(g),
     .p(p),
     .a(a),
     .b(b),
     .c(c),
     .S(S)
  );
  
  //the top Look-Ahead-Carry module.
  lac5 lac(
     .c(c),
     .gout(gout),
     .pout(pout),
     .Cin(Cin),
     .g(g),
     .p(p)
  );
  
  //the overflow module
  overflow ov(
     .Cout(Cout),
     .V(V),
     .g(gout),
     .p(pout),
     .c31(c[31]),
     .Cin(Cin)
  );
endmodule

//The module to handle a single bit operation for the top ALU module
module alu_cell (d, g, p, a, b, c, S);
  output d, g, p;
  input a, b, c;
  input [2:0] S;
  reg g,p,d,cint,bint;
  
  always @(a,b,c,S,p,g) begin 
    bint = S[0] ^ b;
    g = a & bint;
    p = a ^ bint;
    cint = S[1] & c;
   
  if(S[2]==0)
    begin
      d = p ^ cint;
    end
    
  else if(S[2]==1)
    begin
      if((S[1]==0) & (S[0]==0)) begin
        d = a | b;
      end
      else if ((S[1]==0) & (S[0]==1)) begin
        d = ~(a|b);
      end
      else if ((S[1]==1) & (S[0]==0)) begin
        d = a&b;
      end
      else
        d = 1;
      end
    end
endmodule

//The module to handle the overflow bit
module overflow (Cout, V, g, p, c31, Cin);
  output Cout, V;
  input g, p, c31, Cin;
  
  assign Cout = g|(p&Cin);
  assign V = Cout^c31;
endmodule

//Look-Ahead Carry unit level 1. Used for the root (level 1) and first child leafs (level 2)
module lac(c, gout, pout, Cin, g, p);
  output [1:0] c;
  output gout;
  output pout;
  input Cin;
  input [1:0] g;
  input [1:0] p;

  assign c[0] = Cin;
  assign c[1] = g[0] | ( p[0] & Cin );
  assign gout = g[1] | ( p[1] & g[0] );
  assign pout = p[1] & p[0];
  
endmodule

//Look-Ahead Carry unit level 2. Contains LACs for the root and level 1. Used in level 3
module lac2 (c, gout, pout, Cin, g, p);
  output [3:0] c;
  output gout, pout;
  input Cin;
  input [3:0] g, p;
  
  wire [1:0] cint, gint, pint;
  
  lac leaf0(
     .c(c[1:0]),
     .gout(gint[0]),
     .pout(pint[0]),
     .Cin(cint[0]),
     .g(g[1:0]),
     .p(p[1:0])
  );
  
  lac leaf1(
     .c(c[3:2]),
     .gout(gint[1]),
     .pout(pint[1]),
     .Cin(cint[1]),
     .g(g[3:2]),
     .p(p[3:2])
  );
  
  lac root(
     .c(cint),
     .gout(gout),
     .pout(pout),
     .Cin(Cin),
     .g(gint),
     .p(pint)
  );
endmodule

//Look-Ahead Carry unit level 3. Contains LACs for the root and level 2. Used in level 4
module lac3 (c, gout, pout, Cin, g, p);
  output [7:0] c;
  output gout, pout;
  input Cin;
  input [7:0] g, p;
  
  wire [1:0] cint, gint, pint;
  
  lac2 leaf0(
     .c(c[3:0]),
     .gout(gint[0]),
     .pout(pint[0]),
     .Cin(cint[0]),
     .g(g[3:0]),
     .p(p[3:0])
  );
  
  lac2 leaf1(
     .c(c[7:4]),
     .gout(gint[1]),
     .pout(pint[1]),
     .Cin(cint[1]),
     .g(g[7:4]),
     .p(p[7:4])
  );
  
  lac root(
     .c(cint),
     .gout(gout),
     .pout(pout),
     .Cin(Cin),
     .g(gint),
     .p(pint)
  );
endmodule

//Look-Ahead Carry unit level 4. Contains LACs for the root and level 3. Used in level 5
module lac4 (c, gout, pout, Cin, g, p);
  output [15:0] c;
  output gout, pout;
  input Cin;
  input [15:0] g, p;
  
  wire [1:0] cint, gint, pint;
  
  lac3 leaf0(
      .c(c[7:0]),
      .gout(gint[0]),
      .pout(pint[0]),
      .Cin(cint[0]),
      .g(g[7:0]),
      .p(p[7:0])
  );
  
  lac3 leaf1(
      .c(c[15:8]),
      .gout(gint[1]),
      .pout(pint[1]),
      .Cin(cint[1]),
      .g(g[15:8]),
      .p(p[15:8])
  );
  
  lac root(
  .c(cint),
  .gout(gout),
  .pout(pout),
  .Cin(Cin),
  .g(gint),
  .p(pint)
  );
endmodule

//Look-Ahead Carry unit level 1. Caontains LACs for the root and level 4. Used in the core alu32 module
module lac5 (c, gout, pout, Cin, g, p);
  output [31:0] c;
  output gout, pout;
  input Cin;
  input [31:0] g, p;
  
  wire [1:0] cint, gint, pint;
  
  lac4 leaf0(
      .c(c[15:0]),
      .gout(gint[0]),
      .pout(pint[0]),
      .Cin(cint[0]),
      .g(g[15:0]),
      .p(p[15:0])
  );
  
  lac4 leaf1(
      .c(c[31:16]),
      .gout(gint[1]),
      .pout(pint[1]),
      .Cin(cint[1]),
      .g(g[31:16]),
      .p(p[31:16])
  );
  
  lac root(
     .c(cint),
     .gout(gout),
     .pout(pout),
     .Cin(Cin),
     .g(gint),
     .p(pint)
  );
endmodule
