/************************
*  Willard Wider
*  6-18-17
*  ELEC3725
*  controller.v
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
  reg immHolder;
  reg [2:0] S_holder;
  reg Cin_holder;
  wire [31:0] IF_ID_OUT;//wire from IF/ID
  wire [31:0] ID_EX_IN;//wire to ID/EX
  wire [4:0] rs;//the wire to hold the split output from IF-ID
  wire [4:0] rt;
  wire [4:0] rd;
  wire [5:0] opCode;
  wire [5:0] funktion;
  wire [5:0] opCodeThing;
  wire [5:0] opCodeThing2;
  wire [31:0] EX_MEM_IN;
  wire [4:0] muxOut;
  //pipeline the instruction register, get the output into a wire
  DflipFlop IFID(.dataIn(ibus), .clk(clk), .dataOut(IF_ID_OUT));
  assign opCode = IF_ID_OUT[31:26];
  assign rs = IF_ID_OUT[25:21];
  assign rt = IF_ID_OUT[20:16];
  assign rd = IF_ID_OUT[15:11];
  assign funktion = IF_ID_OUT[5:0];
  //write the Aselet
  assign Aselect = 1 << rs;//rs
  
  //init
  initial begin
    immHolder = 1'bx;
    Cin_holder = 1'bx;
    S_holder = 3'bxxx;
    //opCodeThing2 = 5'bxxxxx;
  end
  //for the change in the opcode which is like always
  always @(IF_ID_OUT) begin
  //first mux value is to assume 0
  immHolder = 1;
  Cin_holder = 0;
  //write the cases for the opcode (immediate)
  case (opCode)
    6'b000011: begin
      //addi
      S_holder = 3'b010;
    end
    6'b000010: begin
      //subi
      S_holder = 3'b011;
      Cin_holder = 1;
    end
    6'b000001: begin
      //xori
      S_holder = 3'b000;
    end
    6'b001111: begin
      //andi
      S_holder = 3'b110;
    end
    6'b001100: begin
      //ori
      S_holder = 3'b100;
    end
    //if 00000
    6'b000000: begin
      //write the mux value here
      immHolder= 0;
      //then write the cases for the funct
      case (funktion)
        6'b000011: begin
          //add
          S_holder = 3'b010;
        end
        6'b000010: begin
          //sub
          S_holder = 3'b011;
          Cin_holder = 1;
        end
        6'b000001: begin
          //xor
          S_holder = 3'b000;
        end
        6'b000111: begin
          //and
          S_holder = 3'b110;
        end
        6'b000100: begin
          //or
          S_holder = 3'b100;
        end
      endcase
    end
  endcase
  end
  //write to Bselect
  //assign Bselect = immHolder? 1 << rt: 32'bx;
  assign Bselect = immHolder?  32'bx: 1 << rt;
  //write the input for ID_EX_IN. it's the mux
  assign muxOut = immHolder? rt:rd;//rd=R=imm low, rt=I=imm high
  assign ID_EX_IN = 1 << muxOut;
  assign opCodeThing = {immHolder,S_holder,Cin_holder};
  DflipFlop2 ID_EX(.dataIn(ID_EX_IN),.clk(clk),.dataOut(EX_MEM_IN),.opCodeThingIn(opCodeThing),.opCodeThingOut(opCodeThing2));
  //write the final outputs
  /*
  output [2:0] S;
  output Imm;
  output Cin;
  */
  assign Imm = opCodeThing2[4];
  assign S = opCodeThing2[3:1];
  assign Cin = opCodeThing2[0];
  DflipFlop EXMEMm(.dataIn(EX_MEM_IN),.clk(clk),.dataOut(Dselect));
endmodule

//a mux for selecting which output we will use
module mux(rtIn, rdIn, imSwitch, out);
  input [4:0] rtIn;
  input [4:0] rdIn;
  input imSwitch;
  output [31:0] out;
  wire  [4:0] whichIn;
  assign whichIn = imSwitch? rtIn : rdIn;
  signExtend outExtend(.in(whichIn),.out(out));
  //if imm is high, use rd, else use rt
endmodule

//opcode and funct decoder
module opFunctDecode(opcode,funct,immFlag, opCodeOutputThing);
  input [5:0] opcode;
  input [5:0] funct;
  output [11:0] opCodeOutputThing;
  assign opCodeOutputThing= {opcode,funct};
  output immFlag;
  assign immFlag = opcode? 1'b1 : 1'b0;
endmodule

//sign extension module
module signExtend(in,out);
  input [4:0] in;
  output [31:0] out;
  assign out = in[4]? {27'b0, in}: {27'b1, in};
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

//flip flop module that has a thing pass through it. requires a clock cycle to update value
module DflipFlop2(dataIn, clk, dataOut, opCodeThingIn, opCodeThingOut);
  input [31:0] dataIn;
  input clk;
  output [31:0] dataOut;
  reg [31:0] dataOut;
  input [5:0] opCodeThingIn;
  output [5:0] opCodeThingOut;
  reg [5:0] opCodeThingOut;
  always @(posedge clk) begin
    dataOut = dataIn;
    opCodeThingOut = opCodeThingIn;
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
