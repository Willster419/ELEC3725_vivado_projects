/************************
*  Willard Wider
*  6-5-17
*  ELEC3725
*  alu32.v
*  building a 32 bit ALU
************************/
`timescale 1ns / 1ps//Unit time

//The top module of the entire project. The declaration of the entire ALU itself.
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
    bint = S[0] ^ b;//acts as an inversion for the xnor so it can be processed as xor
    g = a & bint;//used for overflow, uses xor and a value from a. covers case of last bit being high
    p = a ^ bint;//xor, for xor and xnor
    cint = S[1] & c;//for add or sub, already processed by the lacs
    //if it's supposed to be a 1, it will be a 1 if the command is add or subtract
  if(S[2]==0)
    begin
      d = p ^ cint;
    end
    
  else if(S[2]==1)
    begin
      if((S[1]==0) & (S[0]==0)) begin
        d = a | b;//or
      end
      else if ((S[1]==0) & (S[0]==1)) begin
        d = ~(a|b);//nor
      end
      else if ((S[1]==1) & (S[0]==0)) begin
        d = a&b;//and
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
