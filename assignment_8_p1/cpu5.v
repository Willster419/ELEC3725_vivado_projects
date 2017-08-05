/************************
*  Willard Wider
*  07-23-17
*  ELEC3725
*  cpu5.v
*  building a 32 bit CPU
************************/
//cpu4 dut(.clk(clk),.ibus(ibus),.daddrbus(daddrbus),.databus(databus));
module cpu5(ibus,clk,daddrbus,databus,reset,iaddrbus);
  //just a clock
  input clk;
  //reset to clear the counter
  input reset;
  //instruction bus
  output [31:0] iaddrbus;//from PC, to SIM_OUT
  wire [31:0] iaddrbusWire1;//from mux, to PC
  wire [31:0] iaddrbusWire2;//from PC, to ?
  wire [31:0] iaddrbusWire4;//from PC, to IF_ID
  //SLT SLE control bits
  //00 = nothing, 01 = SLT, 10 = SLE
  reg [1:0] setControlBits;
  wire [1:0] setControlBitsWire1;
  wire [1:0] setControlBitsWire2;
  //for SLT/SLE operations
  wire ZBit;//high when rs(a) - rt(b) = 0, 1 otherwise
  wire [31:0] potentialSLEBit;//the value to set to dbus if it is a SLE operation
  wire [31:0] potentialSLTBit;
  wire [31:0] actualSLBit;
  //the cout(finally) for the alu
  wire ALUCoutWire;
  //BEQ and BNE congtrol bits
  //reg to set wether to "kill" the instruction in the pipeline
  //00 = noting, 01 = BEQ, 10 = BNE
  reg [1:0] branchControlBit;
  wire [1:0] branchControlBitWire1;
  wire [1:0] branchControlBitWire2;
  wire [1:0] branchControlBitWire3;
  //program counter wires to be piped into the IF_ID stage
  wire [31:0] PCWire1;//form IF_ID, to branchCalcWire1
  //the wire for the branch calculation, part 1 (immediate sign extended, bit shifted by 2 for *4)
  wire [31:0] branchCalcWire1;//from immediate, to branchCalcwire2
  //the wire for the branch calculation, part 2 (+4)
  wire [31:0] branchCalcWire2;//from branchCalcWire1, to mux4
  //the new bus things
  output [31:0] daddrbus;//from EX_MEM, to SIM_OUT
  inout [31:0] databus;//from SIM_IN/EX_MEM, to SIM_OUT/MEM_WB
  //decoder tings
  wire [5:0] opCode;//from IF_ID
  wire [5:0] funktion;//from IF_ID
  //ibus
  input [31:0] ibus;//in for IF_ID
  wire [31:0] ibusWire;//out for IF_ID
  //Aselect
  wire [31:0] AselectWire;//from rs, to regfile
  wire [5:0] rs;//from ibusWire, to AselectWire
  //Bselect
  wire [31:0] BselectWire;//from rt, to regfile
  wire [5:0] rt;//from ibsuWire, to BselectWire and mxu1
  //imm select
  reg immBit1;//from IF_ID(ibusWire), to mux1 and ID_EX
  wire immBit2;//from ID_EX, to mux2
  //load word save word flag
  reg [1:0] lwSwFlag1;//from IF_ID, to ID_EX
  wire [1:0] lwSwFlag2;//from ID_EX, to EX_MEM
  wire [1:0] lwSwFlag3;//from EX_MEM, to MEM_WB
  wire [1:0] lwSwFlag4;//from MEM_WB, to mux3
  //Dselect
  wire [31:0] DselectWire1;//from muxOut, to ID_EX
  wire [5:0] rd;//from ID_EX, to mux1
  wire [31:0] DselectWire2;//from ID_EX, to EX_MM
  wire [31:0] DselectWire3;//from EX_MEM, to MEM_WB
  wire [31:0] DselectWire3_5;//from MEM_WB, to mux3
  wire [31:0] DselectWire4;//from mux3, to regfile
  //abus
  //output [31:0] abus;//from ID_EX, to SIM_OUT
  wire [31:0] abusWire1;//from regOut, to ID_EX
  wire [31:0] abusWire2;//from ID_EX, to ALU
  //bbus
  //output [31:0] bbus;//from mux2Out, to SIM_OUT
  wire [31:0] bbusWire1;//from regOut, to ID_EX
  wire [31:0] bbusWire2;//from ID_EX, to mux2/EX_MEM
  wire [31:0] bbusWire3;//from EX_MEM, to memory logic
  wire [31:0] bbusWire3_5;//from memory logic, to MEM_WB
  wire [31:0] bbusWire4;//from MEM_WB, to mux3
  //dbus
  //output [31:0] dbus;//from EX_MEM, to SIM_OUT
  wire [31:0] dbusWire1;//from ALU, to dbusWire1_5(SLE_MUX_TEST)
  wire [31:0] dbusWire1_5;//from SLE_MUX_TEST to EX_MEM
  wire [31:0] dbusWire2;//from EM_MEM, to MEM_WB
  wire [31:0] dbusWire3;//from MEM_WB, to mux3
  //mux3
  wire [31:0] mux3Out;//from dbusWire3/bbusWire4, to regfile
  //mux2
  wire [31:0] mux2Out;//from bbusWire2/immWire2, to ALU
  //mux4 deciding wire
  wire mux4Controller;//controls the pc address bus
  //immediate
  wire [31:0] immWire1;//from IF_ID, to ID_EX
  wire [31:0] immWire2;//from ID_EX, to mux2
  //S
  reg [2:0] SWire1;//from IF_ID, to ID_EX
  wire [2:0] SWire2;//from ID_EX, to ALU
  //Cin
  reg CinWire1;//from IF_ID, to ID_EX
  wire CinWire2;//form ID_EX, to ALU
  //init
  initial begin
    immBit1 = 1'bx;
    CinWire1 = 1'bx;
    SWire1 = 3'bxxx;
    lwSwFlag1 = 2'bxx;
    branchControlBit = 2'b0;
    setControlBits = 2'b00;
  end
  //latch for pipeline 0(PC)
  //module pipeline_0_latch(clk, iaddrbusWire1, iaddrbusOut);
  pipeline_0_latch PC(.clk(clk),.iaddrbusWire1(iaddrbusWire1),.iaddrbusOut(iaddrbusWire2),.reset(reset));
  //assign the output
  assign iaddrbus = mux4Controller? branchCalcWire2 : iaddrbusWire2;
  //iaddrbusWire4 gets feed into the IF_ID stage
  assign iaddrbusWire4 = iaddrbusWire2;
  //feed the pc back into itself. may update iaddrbusWire2 from the IF_ID stage
  assign iaddrbusWire1 = mux4Controller? branchCalcWire2 : iaddrbusWire2;
  //PIPELINE_0_END
  //latch for pipeline 1(IF_ID)
  //module pipeline_1_latch(clk, ibus, ibusWire);
  pipeline_1_latch IF_ID(.clk(clk),.ibus(ibus),.ibusWire(ibusWire),.PCIn(iaddrbusWire4),.PCOut(PCWire1));
  //PIPELINE_1_START
  //decode the input command
  assign opCode = ibusWire[31:26];
  assign rs = ibusWire[25:21];
  assign rt = ibusWire[20:16];
  assign rd = ibusWire[15:11];
  assign funktion = ibusWire[5:0];
  assign immWire1 = ibusWire[15]? {16'b1111111111111111,ibusWire[15:0]} : {16'b0000000000000000,ibusWire[15:0]};
  //for the change in the opcode which is like always
  always @(ibusWire) begin
  //first mux value is to assume 0
  immBit1 = 1;
  CinWire1 = 0;
  branchControlBit = 0;
  setControlBits = 0;
  //assume not doing anything with the load or save
  lwSwFlag1 = 2'b00;
  //write the cases for the opcode (immediate)
  case (opCode)
    6'b000011: begin
      //addi
      SWire1 = 3'b010;
    end
    6'b000010: begin
      //subi
      SWire1 = 3'b011;
      CinWire1 = 1;
    end
    6'b000001: begin
      //xori
      SWire1 = 3'b000;
    end
    6'b001111: begin
      //andi
      SWire1 = 3'b110;
    end
    6'b001100: begin
      //ori
      SWire1 = 3'b100;
    end
    6'b011110: begin
      //load word, but still addi
      SWire1 = 3'b010;
      lwSwFlag1 = 2'b01;
    end
    6'b011111: begin
      //store word, but still addi
      SWire1 = 3'b010;
      lwSwFlag1 = 2'b10;
    end
    6'b110000: begin
      //BEQ
      //need this?
      SWire1 = 3'b010;//yes, yes i do
      //set control bit
      branchControlBit = 2'b01;
    end
    6'b110001: begin
      //BNE
      //need this?
      SWire1 = 3'b010;//yes, yes i do
      //set control bit
      branchControlBit = 2'b10;
    end
    //if 00000
    6'b000000: begin
      //write the mux value here
      immBit1= 0;
      //then write the cases for the funct
      case (funktion)
        6'b000011: begin
          //add
          SWire1 = 3'b010;
        end
        6'b000010: begin
          //sub
          SWire1 = 3'b011;
          CinWire1 = 1;
        end
        6'b000001: begin
          //xor
          SWire1 = 3'b000;
        end
        6'b000111: begin
          //and
          SWire1 = 3'b110;
        end
        6'b000100: begin
          //or
          SWire1 = 3'b100;
        end
        6'b110110: begin
          //SLT
          //00 = nothing, 01 = SLT, 10 = SLE
          setControlBits = 2'b01;
          //set to subtraction
          SWire1 = 3'b011;
        end
        6'b110111: begin
          //SLE
          //00 = nothing, 01 = SLT, 10 = SLE
          setControlBits = 2'b10;
          //set to subtraction
          SWire1 = 3'b011;
        end
      endcase
    end
  endcase
  end
  //write the select lines
  assign AselectWire = 1 << rs;
  //only write to Bselect for real if it's actually goign to use Bselect
  //i don't think this line matters but i feel like it's good pratice
  //assign BselectWire = immBit1?  32'hxxxxxxxx: 1 << rt;
  assign BselectWire = 1 << rt;
  //mux1
  //Rd for R, imm = false
  //Rt for I, imm = true
  assign DselectWire1 = immBit1? 1<<rt : 1<<rd;
  regfile Reggie3(.clk(clk),.Aselect(AselectWire),.Bselect(BselectWire),.Dselect(DselectWire4),.abus(abusWire1),.bbus(bbusWire1),.dbus(mux3Out));
  //update the muxWire4 controll if the instruction is BEQ or BNE, and if it is actually equal
  //mux4Controller = 1 if ((BEQ and abus == bbus) or (BNE and bbus != abus)), 0 otherwise
  //00 = noting, 01 = BEQ, 10 = BNE
  //reg [1:0] branchControlBit;
  assign mux4Controller = ((!clk) && ((branchControlBit==2'b01) && (abusWire1 == bbusWire1)) || ((branchControlBit==2'b10) && (abusWire1!=bbusWire1)))? 1: 0;
  //the branch calculation
  assign branchCalcWire1 = immWire1 << 2;
  assign branchCalcWire2 = branchCalcWire1 + PCWire1;
  //PIPELINE_1_END
  //latch for pipeline 2(ID_EX)
  pipeline_2_latch ED_EX(.clk(clk),.abusWire1(abusWire1),.bbusWire1(bbusWire1),.DselectWire1(DselectWire1),.immWire1(immWire1),.SWire1(SWire1),
  .CinWire1(CinWire1),.immBit1(immBit1),.lwSwFlag1(lwSwFlag1),.abusWire2(abusWire2),.bbusWire2(bbusWire2),.immWire2(immWire2),.CinWire2(CinWire2),
  .DselectWire2(DselectWire2),.immBit2(immBit2),.SWire2,.lwSwFlag2(lwSwFlag2),.setControlBits(setControlBits),.setControlBitsWire1(setControlBitsWire1),
  .branchControlBit(branchControlBit),.branchControlBitWire1(branchControlBitWire1));
  //PIPELINE_2_START
  //assign abus output
  //assign abus = abusWire2;
  //mux2
  //immWire for true, Bselet for false
  assign mux2Out = immBit2? immWire2: bbusWire2;
  //assign bbus output
  //assign bbus = mux2Out;
  //make the ALU
  //module alu32 (d, Cout, V, a, b, Cin, S);
  alu32 literallyLogic(.d(dbusWire1),.a(abusWire2),.b(mux2Out),.Cin(CinWire2),.S(SWire2),.Cout(ALUCoutWire));
  //wipe the dbus if it's an SLT or an SLE
  //zero result flag
  assign ZBit = (dbusWire1==0)? 1:0;
  //potential values for if the instruction is for SLT or SLE
  assign potentialSLTBit = (!ALUCoutWire && !ZBit)? 32'h00000001:32'h00000000;
  assign potentialSLEBit = (!ALUCoutWire || ZBit)? 32'h00000001:32'h00000000;
  //a determinate wire that uses SLT or SLE, assuming if not one, than the other
  //(a wire later decides if that always "lateer" choosen one is actually used
  //00 = nothing, 01 = SLT, 10 = SLE
  assign actualSLBit = (setControlBitsWire1 == 2'b01)? potentialSLTBit: potentialSLEBit;
  //the wire that is used for the new dbusWire, adds a check for if the result needs to be the SLT or not
  //SLE_MUX_TEST
  assign dbusWire1_5 = (setControlBitsWire1 > 2'b00)? actualSLBit:dbusWire1;
  //PIPELINE_2_END
  //latch for pipeline 3(EX_MEM)
  pipeline_3_latch EX_MEME (.clk(clk),.dbusWire1(dbusWire1_5),.DselectWire2(DselectWire2),.bbusWire2(bbusWire2),.lwSwFlag2(lwSwFlag2),.dbusWire2(dbusWire2),
  .DselectWire3(DselectWire3),.bbusWire3(bbusWire3),.lwSwFlag3(lwSwFlag3),.branchControlBitWire1(branchControlBitWire1),.branchControlBitWire2(branchControlBitWire2));
  //PIPELINE_3_SRART
  //assign output values
  //try again with ternary operators
  //one for the databus and one for bbusWire3
  assign bbusWire3_5 = (lwSwFlag3==2'b01)? databus: bbusWire3;
  assign databus = (lwSwFlag3 == 2'b10)? bbusWire3: 32'hzzzzzzzz;
  assign daddrbus = dbusWire2;
  //PIPELINE_3_END
  //latch for pipeline 4(MEM_WB)
  pipeline_4_latch MEM_WB (.clk(clk),.dbusWire2(dbusWire2),.DselectWire3(DselectWire3),.bbusWire3(bbusWire3_5),.lwSwFlag3(lwSwFlag3),.dbusWire3(dbusWire3),.DselectWire4(DselectWire3_5),
  .bbusWire4(bbusWire4),.lwSwFlag4(lwSwFlag4),.branchControlBitWire2(branchControlBitWire2),.branchControlBitWire3(branchControlBitWire3));
  //PIPELINE_4_START
  //the "mux" for the data writeBack
  assign mux3Out = (lwSwFlag4 == 2'b01)? bbusWire4:dbusWire3;
  //disable the writeback if it's a store word OR if it's a beq branch
  assign DselectWire4 = ((lwSwFlag4 == 2'b10) ||(branchControlBitWire3 > 2'b00))? 32'h00000001: DselectWire3_5;
  //PIPELINE_4_END
endmodule
//phase 0 pipeline latch (PC)
module pipeline_0_latch(clk, iaddrbusWire1, iaddrbusOut, reset);
  input clk, reset;
  input [31:0] iaddrbusWire1;
  output [31:0] iaddrbusOut;
  reg [31:0] iaddrbusOut;
  reg startBit;
  initial begin
  startBit = 1;
  end
  always@(posedge clk) begin
    //if reset is high, reset the counter
    //iaddrbusOut = iaddrbusWire1+4;
    iaddrbusOut = (reset|startBit)? 0:iaddrbusWire1+4;
    startBit = 0;
  end
endmodule
//phase 1 pipeline latch(IF_ID)
module pipeline_1_latch(clk, ibus, ibusWire, PCIn, PCOut);
  input [31:0] ibus, PCIn;
  input clk;
  output [31:0] ibusWire, PCOut;
  reg [31:0] ibusWire, PCOut;
  always @(posedge clk) begin
    //if terminator bit is high from previous instruction (with BEQ/BNE)
    //we don't care about this instruction, kill it
    //which is actually setting it to 
    ibusWire = ibus;
    //EDIT: this is delayed branching, other instructions can be put in place (terminator is not a thing)
    PCOut = PCIn;
  end
endmodule
//phase 2 pipeline latch(ID_EX)
module pipeline_2_latch(clk, abusWire1, bbusWire1, DselectWire1, immWire1, SWire1, CinWire1,immBit1,lwSwFlag1,
abusWire2,bbusWire2,immWire2,SWire2,CinWire2,DselectWire2,immBit2,lwSwFlag2,setControlBits,setControlBitsWire1,
branchControlBit,branchControlBitWire1);
  input clk, CinWire1,immBit1;
  input [31:0] abusWire1, bbusWire1, DselectWire1, immWire1;
  input [2:0] SWire1;
  input [1:0] lwSwFlag1;
  input [1:0] setControlBits;
  input [1:0] branchControlBit;
  output CinWire2,immBit2;
  output [31:0] abusWire2, bbusWire2, DselectWire2, immWire2;
  output [2:0] SWire2;
  output [1:0] lwSwFlag2;
  output [1:0] setControlBitsWire1;
  output [1:0] branchControlBitWire1;
  reg CinWire2,immBit2;
  reg [31:0] abusWire2, bbusWire2, DselectWire2, immWire2;
  reg [2:0] SWire2;
  reg [1:0] lwSwFlag2;
  reg [1:0] setControlBitsWire1;
  reg [1:0] branchControlBitWire1;
  always @(posedge clk) begin
    abusWire2 = abusWire1;
    bbusWire2 = bbusWire1;
    DselectWire2 = DselectWire1;
    immWire2 = immWire1;
    SWire2 = SWire1;
    CinWire2 = CinWire1;
    immBit2 = immBit1;
    lwSwFlag2 = lwSwFlag1;
    setControlBitsWire1 = setControlBits;
    branchControlBitWire1 = branchControlBit;
  end
endmodule
//phase 3 pipeliune latch(EX_MEM)
module pipeline_3_latch(clk, dbusWire1, DselectWire2, bbusWire2, lwSwFlag2, dbusWire2, DselectWire3,bbusWire3,lwSwFlag3,branchControlBitWire1,branchControlBitWire2);
  input clk;
  input [31:0] dbusWire1, DselectWire2, bbusWire2;
  input [1:0] lwSwFlag2;
  input [1:0] branchControlBitWire1;
  output [31:0] dbusWire2, DselectWire3, bbusWire3;
  output [1:0] lwSwFlag3;
  output [1:0] branchControlBitWire2;
  reg [31:0] dbusWire2, DselectWire3, bbusWire3;
  reg [1:0] lwSwFlag3;
  reg [1:0] branchControlBitWire2;
  always @(posedge clk) begin
    dbusWire2 = dbusWire1;
    DselectWire3 = DselectWire2;
    bbusWire3 = bbusWire2;
    lwSwFlag3 = lwSwFlag2;
    branchControlBitWire2 = branchControlBitWire1;
  end
endmodule
//phase 4 pipeline latch(MEM_WB)
module pipeline_4_latch(clk, dbusWire2, DselectWire3, bbusWire3, lwSwFlag3, dbusWire3, DselectWire4,bbusWire4,lwSwFlag4,branchControlBitWire2,branchControlBitWire3);
  input clk;
  input [31:0] dbusWire2, DselectWire3, bbusWire3;
  input [1:0] lwSwFlag3;
  input [1:0] branchControlBitWire2;
  output [31:0] dbusWire3, DselectWire4, bbusWire4;
  output [1:0] lwSwFlag4;
  output [1:0] branchControlBitWire3;
  reg [31:0] dbusWire3, DselectWire4, bbusWire4;
  reg [1:0] lwSwFlag4;
  reg [1:0] branchControlBitWire3;
  always @(posedge clk) begin
    dbusWire3 = dbusWire2;
    DselectWire4 = DselectWire3;
    bbusWire4 = bbusWire3;
    lwSwFlag4 = lwSwFlag3;
    branchControlBitWire3 = branchControlBitWire2;
  end
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
  initial begin
  data = 32'h00000000;
  end
  
  always @(negedge clk) begin
    if(Dselect) begin
      data = dbus;
    end
  end
  assign abus = Aselect? data : 32'hzzzzzzzz;
  assign bbus = Bselect? data : 32'hzzzzzzzz;
endmodule
//Below this point is code from assignment 1//

//The declaration of the entire ALU itself.
module alu32 (d, Cout, V, a, b, Cin, S);
  output[31:0] d;//the output bus
  output Cout, V;//Cout is the bit for it it needs to carry over ?/ V is the overflow bit.
  input [31:0] a, b;//the two input buses
  input Cin;//the bit for marking if it is carrying over from a ?
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
    g = a & bint;//generate carry
    p = a ^ bint;//proragate carry
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
