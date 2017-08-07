/************************
*  Willard Wider
*  08-04-17
*  ELEC3725
*  ARMS.v
*  building a 32 bit CPU
************************/
//ARMS dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));
module ARMS(ibus,clk,daddrbus,databus,reset,iaddrbus);
  //just a clock
  input clk;
  //reset to clear the counter
  input reset;
  //instruction bus
  output [31:0] iaddrbus;//from PC, to SIM_OUT
  wire [31:0] iaddrbusWire1;//from mux, to PC
  wire [31:0] iaddrbusWire2;//from PC, to mux4/iaddrbusWire4
  wire [31:0] iaddrbusWire4;//from PC, to IF_ID
  //SLT SLE control bits
  //00 = nothing, 01 = SLT, 10 = SLE
  reg [1:0] setControlBits;
  wire [1:0] setControlBitsWire1;
  wire [1:0] setControlBitsWire2;
  //for SLT/SLE operations
  //LEG_UPDATE: rs->rn, rt->rm
  wire ZBit;//high when rn(a) - rm(b) = 0, 1 otherwise
  wire [63:0] potentialSLEBit;//the value to set to dbus if it is a SLE operation
  wire [63:0] potentialSLTBit;
  wire [63:0] actualSLBit;
  //the cout for the alu
  wire ALUCoutWire;
  //LEG_UPDATE: add the overflow counter from the ALU
  wire overflowWire;
  //LEG_UPDATE: 7 ways to branch, to update the control bit
  //000 = noting, 001 = B, 010 = B.EQ
  //011 = B.NE, 100 = B.LT, 101 = B.GE
  //110 = CBNZ, 111 = CBZ
  reg [2:0] branchControlBit;
  wire [2:0] branchControlBitWire1;
  wire [2:0] branchControlBitWire2;
  wire [2:0] branchControlBitWire3;
  reg takeBranch;
  wire takeBranchWire1;
  //program counter wires to be piped into the IF_ID stage
  wire [31:0] PCWire1;//form IF_ID, to branchCalcWire1
  //the wire for the branch calculation, part 1 (immediate sign extended, bit shifted by 2 for *4)
  wire [63:0] branchCalcWire1;//from immediate, to branchCalcwire2
  //the wire for the branch calculation, part 2 (+4)
  wire [63:0] branchCalcWire2;//from branchCalcWire1, to mux4
  //the new buses to and from the ddr memory
  output [31:0] daddrbus;//from EX_MEM, to SIM_OUT
  inout [31:0] databus;//from SIM_IN/EX_MEM, to SIM_OUT/MEM_WB
  //decoder tings
  //LEG_UPDATE: opcode is 11 bits long now
  wire [10:0] opCode;//from IF_ID
  //LEG_UPDATE: funktion is no longer a thing, everything is in the opcode
  //wire [5:0] funktion;//from IF_ID
  //ibus
  input [31:0] ibus;//in for IF_ID
  wire [31:0] ibusWire;//out for IF_ID
  //Aselect
  wire [31:0] AselectWire;//from rs, to regfile
  //LEG_UPDATE: rs->rn
  wire [5:0] rn;//from ibusWire, to AselectWire
  //Bselect
  wire [31:0] BselectWire;//from rt, to BselectWire1
  wire [31:0] BselectWire1;//from BselectWire, to regfile
  wire [31:0] BselectWire2;
  //LEG_UPDATE: rt->rm
  wire [5:0] rm;//from ibsuWire, to BselectWire and mxu1
  //LEG_UPDATE: add a bit for MOVZ select
  //mov select
  reg movBit1;
  wire movBit2;
  wire [5:0] moveImmShftAmt;
  wire [5:0] moveImmShftAmtWire1;
  //imm select
  reg immBit1;//from IF_ID(ibusWire), to mux1 and ID_EX
  wire immBit2;//from ID_EX, to mux2
  //LEG_UPDATE: add the NZVC bit and it's potential values
  //the NZVC bit
  wire [3:0]NZVC;
  wire potentialNBit;
  wire potentialZBit;
  wire potentialVBit;
  wire potentialCBit;
  //the control for setting NZVC
  reg NZVCSetBit;
  wire NZVCSetBitWire1;
  //LEG_UPDATE: add a control bit set for LSL and LSR
  reg [1:0] shiftBit1;
  wire [1:0] shiftBit2;
  //LEG_UPDATE: add the potential LSL and LSR bits for shifting
  wire [63:0] potentialLSLResult;
  wire [63:0] potentialLSRResult;
  wire [63:0] actualLSResult;
  //load word save word flag
  reg [1:0] lwSwFlag1;//from IF_ID, to ID_EX
  wire [1:0] lwSwFlag2;//from ID_EX, to EX_MEM
  wire [1:0] lwSwFlag3;//from EX_MEM, to MEM_WB
  wire [1:0] lwSwFlag4;//from MEM_WB, to mux3
  //Dselect
  wire [63:0] DselectWire1;//from muxOut, to ID_EX
  //LEG_UPDATE: rd->rd (no change)
  wire [5:0] rd;//from ID_EX, to mux1
  wire [31:0] DselectWire2;//from ID_EX, to EX_MM
  wire [31:0] DselectWire3;//from EX_MEM, to MEM_WB
  wire [31:0] DselectWire3_5;//from MEM_WB, to mux3
  wire [31:0] DselectWire4;//from mux3, to regfile
  //LEG_UPDATE: new rt is also rd
  //abus
  //output [63:0] abus;//from ID_EX, to SIM_OUT
  wire [63:0] abusWire1;//from regOut, to ID_EX
  wire [63:0] abusWire2;//from ID_EX, to ALU
  //bbus
  //output [63:0] bbus;//from mux2Out, to SIM_OUT
  wire [63:0] bbusWire1;//from regOut, to ID_EX
  wire [63:0] bbusWire2;//from ID_EX, to mux2/EX_MEM
  wire [63:0] bbusWire3;//from EX_MEM, to memory logic
  wire [63:0] bbusWire3_5;//from memory logic, to MEM_WB
  wire [63:0] bbusWire4;//from MEM_WB, to mux3
  //dbus
  wire [63:0] dbusWire1;//from ALU, to dbusWire1_5(SLE_MUX_TEST)
  wire [63:0] dbusWire1_5;//from SLE_MUX_TEST to EX_MEM
  wire [63:0] dbusWire1_6;
  wire [63:0] dbusWire2;//from EM_MEM, to MEM_WB
  wire [63:0] dbusWire3;//from MEM_WB, to mux3
  //mux3
  wire [63:0] mux3Out;//from dbusWire3/bbusWire4, to regfile
  //mux2
  wire [63:0] mux2Out;//from bbusWire2/immWire2, to mux5
  //LEG_UPDATE: mux5
  wire [63:0] mux5;//from mux2Out/DTAddrWire2, to ALU (as b)
  wire [63:0] mux6;
  //mux4 deciding wire
  wire mux4Controller;//controls the pc address bus
  //LEG_UPDATE: remove sign extended IMM wire, it's not a thing
  //immediate
  //wire [63:0] immWire1;//from IF_ID, to ID_EX
  //wire [63:0] immWire2;//from ID_EX, to mux2
  //and add the new parsed wires
  wire [63:0] ALUImmWire1;
  wire [63:0] ALUImmWire2;
  wire [63:0] BranchAddrWire1;
  wire [63:0] CondBranchAddrType1Wire1;//for b.cond
  wire [63:0] CondBranchAddrType2Wire1;//for CBZ/CBNZ
  wire [63:0] MOVImmWire1;
  wire [63:0] MOVImmWire2;
  wire [5:0] shamt;
  wire [5:0] shamtWire1;
  wire [63:0] DTAddrWire1;
  wire [63:0] DTAddrWire2;
  wire [63:0] DTAddrWire3;
  wire [63:0] DTAddrWire4;
  //S
  reg [2:0] SWire1;//from IF_ID, to ID_EX
  wire [2:0] SWire2;//from ID_EX, to ALU
  //Cin
  reg CinWire1;//from IF_ID, to ID_EX
  wire CinWire2;//form ID_EX, to ALU
  //init
  initial begin
    immBit1 = 1'bx;
    movBit1 = 1'bx;
    NZVCSetBit = 1'bx;
    CinWire1 = 1'bx;
    SWire1 = 3'bxxx;
    lwSwFlag1 = 2'bxx;
    branchControlBit = 3'b0;
    setControlBits = 2'b00;
    shiftBit1 = 2'bxx;
    takeBranch = 1'b0;
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
  //LEG_UPDATE: updated to new leg instruction sets
  assign opCode = ibusWire[31:21];
  assign rn = ibusWire[9:5];//old rs
  assign rm = ibusWire[20:16];//old rt
  assign rd = ibusWire[4:0];
  assign shamt = ibusWire[15:10];
  assign DTAddrWire1 = ibusWire[20]? {55'b1,ibusWire[20:12]} : {55'b0,ibusWire[20:12]};
  assign moveImmShftAmt = ibusWire[22:21] << 4;
  //LEG_UPDATE: added the following
  //64_BIT_TODO: all these
  assign ALUImmWire1 = {52'b0, ibusWire[21:10]};
  assign BranchAddrWire1 = ibusWire[25]? {36'b1111,ibusWire[25:0],2'b00} : {36'b0000,ibusWire[25:0],2'b00};
  //TODO: ask marpaung about CondBranchAddr
  assign CondBranchAddrType1Wire1 = ibusWire[23]? {43'b11111111111,ibusWire[23:5],2'b00} : {43'b00000000000,ibusWire[23:5],2'b00};//b.cond
  assign MOVImmWire1= {48'b0, ibusWire[20:5]};
  //LEG_UPDATE: remove the following
  //assign immWire1 = ibusWire[15]? {16'b1111111111111111,ibusWire[15:0]} : {16'b0000000000000000,ibusWire[15:0]};
  //for the change in the opcode which is like always
  always @(ibusWire) begin
  immBit1 = 0;
  movBit1 = 0;
  CinWire1 = 0;
  branchControlBit = 3'b000;
  setControlBits = 0;
  NZVCSetBit = 0;
  //assume not doing anything with the load or save
  lwSwFlag1 = 2'b00;
  shiftBit1 = 2'b00;
  takeBranch = 1'b0;
  //write the cases for the opcode (immediate)
  //LEG_UPDATE: updated opcodes and branch condition codes
  //000 = noting, 001 = B, 010 = B.EQ
  //011 = B.NE, 100 = B.LT, 101 = B.GE
  //110 = CBNZ, 111 = CBZ
  casez (opCode)
    11'b10001011000: begin
      //add
      SWire1 = 3'b010;//add
    end
    11'b1001000100?: begin
      //addi
      SWire1 = 3'b010;
      immBit1 = 1;
    end
    11'b1011000100?: begin
      //addis
      SWire1 = 3'b010;
      immBit1 = 1;
      NZVCSetBit = 1;
    end
    11'b10101011000: begin
      //adds
      SWire1 = 3'b010;
      NZVCSetBit = 1;
    end
    11'b10001010000: begin
      //and
      SWire1 = 3'b110;//and
    end
    11'b1001001000?: begin
      //andi
      SWire1 = 3'b110;
      immBit1 = 1;
    end
    11'b1111001000?: begin
      //andis
      SWire1 = 3'b110;
      immBit1 = 1;
      NZVCSetBit = 1;
    end
    11'b11101010000: begin
      //ands
      SWire1 = 3'b110;
      NZVCSetBit = 1;
    end
    11'b10110101???: begin
      //CBNZ
      //add i guess
      SWire1 = 3'b010;
      branchControlBit = 3'b110;
      takeBranch = 1;
    end
    11'b10110100???: begin
      //CBZ
      //add i guess
      SWire1 = 3'b010;
      branchControlBit = 3'b111;
      takeBranch = 1;
    end
    11'b11001010000: begin
      //EOR (xor)
      SWire1 = 3'b000;
    end
    11'b1101001000?: begin
      //EORI(xori)
      SWire1 = 3'b000;
      immBit1 = 1;
    end
    11'b11111000010: begin
      //LDUR
      //command: rt value = from memory address, of rn value added with DTAddr
      //load word, but still addi
      SWire1 = 3'b010;
      lwSwFlag1 = 2'b01;
    end
    11'b11010011011: begin
      //LSL
      //uses shamt wire and abus to set for dbus
      //overwide bbus to be r31 and swire to be add
      //therefore it does nothing and we're not jumping around the pipeline
      shiftBit1 = 2'b01;
      SWire1 = 3'b010;
    end
    11'b11010011010: begin
      //LSR
      //see above notes
      shiftBit1 = 2'b10;
      SWire1 = 3'b010;
    end
    11'b110100101??: begin
      //MOVZ
      movBit1 = 1;
    end
    11'b10101010000: begin
      //ORR(or)
      SWire1 = 3'b100;
    end
    11'b1011001000?: begin
      //ORRI(ori)
      SWire1 = 3'b100;
      immBit1 = 1;
    end
    11'b11111000000: begin
      //STUR
      //command: memory of address, rn value added with DTAddr = rt value
      //store word, but still addi
      SWire1 = 3'b010;
      lwSwFlag1 = 2'b10;
    end
    11'b11001011000: begin
      //sub
      SWire1 = 3'b011;
      CinWire1 = 1;
    end
    11'b1101000100?: begin
      //subi
      SWire1 = 3'b011;
      CinWire1 = 1;
      immBit1 = 1;
    end
    11'b1111000100?: begin
      //subis
      SWire1 = 3'b011;
      CinWire1 = 1;
      immBit1 = 1;
      NZVCSetBit = 1;
    end
    11'b11101011000: begin
      //subs
      SWire1 = 3'b011;
      CinWire1 = 1;
      NZVCSetBit = 1;
    end
    //000 = noting, 001 = B, 010 = B.EQ
    //011 = B.NE, 100 = B.LT, 101 = B.GE
    //110 = CBNZ, 111 = CBZ
    11'b000101?????: begin
      //B
      SWire1 = 3'b010;
      //set control bit
      branchControlBit = 3'b001;
      takeBranch = 1;
    end
    11'b01010101???: begin
      //B.EQ
      SWire1 = 3'b010;
      //set control bit
      branchControlBit = 3'b010;
      takeBranch = (NZVC[2] == 1'b1)? 1:0;
    end
    11'b01010110???: begin
      //B.NE
      SWire1 = 3'b010;
      //set control bit
      branchControlBit = 3'b011;
      takeBranch = (NZVC[2] == 1'b0)? 1:0;
    end
    11'b01010111???: begin
      //B.LT(signed)
      SWire1 = 3'b010;
      //set control bit
      branchControlBit = 3'b100;
      takeBranch = (NZVC[3] != NZVC[1])? 1:0;
    end
    11'b01011000???: begin
      //B.GE(signed)
      SWire1 = 3'b010;
      //set control bit
      branchControlBit = 3'b101;
      takeBranch = (NZVC[3] == NZVC[1])? 1:0;
    end
    //TODO: figure out if these are ever used
    /*11'b: begin
      //SLT
      //00 = nothing, 01 = SLT, 10 = SLE
      setControlBits = 2'b01;
      //set to subtraction
      SWire1 = 3'b011;
    end
    11'b: begin
      //SLE
      //00 = nothing, 01 = SLT, 10 = SLE
      setControlBits = 2'b10;
      //set to subtraction
      SWire1 = 3'b011;
    end*/
  endcase
  end
  //write the select lines
  assign AselectWire = ((branchControlBit == 3'b110) || (branchControlBit == 3'b111))? 1<<rd :1 << rn;
  //only write to Bselect for real if it's actually goign to use Bselect
  //i don't think this line matters but i feel like it's good pratice
  //assign BselectWire = immBit1?  32'hxxxxxxxx: 1 << rt;
  assign BselectWire = 1 << rm;
  //LEG_UPDATE: set BselectWire to R31(0) if it's a LSL/LSR command
  assign BselectWire1 = ((shiftBit1 > 2'b00) || (movBit1))? 32'h80000000:BselectWire;
  //LEG_UPDATE: BselectWire may need to get data from Bbus in regfile if it's a store command
  assign BselectWire2 = (lwSwFlag1 == 2'b10)? 1<<rd:BselectWire1;
  //LEG_UPDATE: rt->rm
  //LEG_UPDATE: dbus always holds the result for the alu output now
  //mux1
  //Rd for R, imm = false
  //Rt for I, imm = true
  //assign DselectWire1 = immBit1? 1<<rm : 1<<rd;
  assign DselectWire1 = 1<<rd;
  regfile Reggie3(.clk(clk),.Aselect(AselectWire),.Bselect(BselectWire2),.Dselect(DselectWire4),.abus(abusWire1),.bbus(bbusWire1),.dbus(mux3Out));
  //update the muxWire4 controll if the instruction is BEQ or BNE, and if it is actually equal
  //mux4Controller = 1 if ((BEQ and abus == bbus) or (BNE and bbus != abus)), 0 otherwise
  //00 = noting, 01 = BEQ, 10 = BNE
  //CBNZ = 110, CBZ = 111
  //assign mux4Controller = ((!clk) && ((branchControlBit==2'b01) && (abusWire1 == bbusWire1)) || ((branchControlBit==2'b10) && (abusWire1!=bbusWire1)))? 1: 0;
  assign takeBranchWire1 = ((!clk) && ((branchControlBit==3'b110) && (abusWire1 != 0)) || ((branchControlBit==3'b111) && (abusWire1 == 0)))? 1:takeBranch;
  assign mux4Controller = ((!clk) && (branchControlBit > 3'b000) && (takeBranchWire1))? 1 : 0;
  //LEG_UPDATE: TODO: branch calculation is done in one step from above
  //the branch calculation
  assign branchCalcWire1 = (branchControlBit == 3'b001)? BranchAddrWire1:CondBranchAddrType1Wire1;
  assign branchCalcWire2 = branchCalcWire1 + PCWire1 - 4;
  //PIPELINE_1_END
  //latch for pipeline 2(ID_EX)
  pipeline_2_latch ED_EX(.clk(clk),.abusWire1(abusWire1),.bbusWire1(bbusWire1),.DselectWire1(DselectWire1),.ALUImmWire1(ALUImmWire1),.SWire1(SWire1),
  .CinWire1(CinWire1),.immBit1(immBit1),.lwSwFlag1(lwSwFlag1),.abusWire2(abusWire2),.bbusWire2(bbusWire2),.ALUImmWire2(ALUImmWire2),.CinWire2(CinWire2),
  .DselectWire2(DselectWire2),.immBit2(immBit2),.SWire2,.lwSwFlag2(lwSwFlag2),.setControlBits(setControlBits),.setControlBitsWire1(setControlBitsWire1),
  .branchControlBit(branchControlBit),.branchControlBitWire1(branchControlBitWire1),.NZVCSetBit(NZVCSetBit),.NZVCSetBitWire1(NZVCSetBitWire1),
  .shiftBit1(shiftBit1),.shiftBit2(shiftBit2),.shamt(shamt),.shamtWire1(shamtWire1),.DTAddrWire1(DTAddrWire1),.DTAddrWire2(DTAddrWire2),
  .MOVImmWire1(MOVImmWire1),.MOVImmWire2(MOVImmWire2),.movBit1(movBit1),.movBit2(movBit2),.moveImmShftAmt(moveImmShftAmt),.moveImmShftAmtWire1(moveImmShftAmtWire1));
  //PIPELINE_2_START
  //mux2
  //ALUImmWire2 for true, Bselet for false
  assign mux2Out = immBit2? ALUImmWire2: bbusWire2;
  //LEG_UPDATE: add mux5 for selecting the DTAddrWire
  assign mux5 = (lwSwFlag2 > 2'b00)? DTAddrWire2:mux2Out;
  assign mux6 = (movBit2)? MOVImmWire2:mux5;
  //make the ALU
  //module alu32 (d, Cout, V, a, b, Cin, S);
  alu32 literallyLogic(.d(dbusWire1),.a(abusWire2),.b(mux6),.Cin(CinWire2),.S(SWire2),.Cout(ALUCoutWire),.V(overflowWire));
  //wipe the dbus if it's an SLT or an SLE
  //zero result flag
  assign ZBit = (dbusWire1==0)? 1:0;
  //potential values for if the instruction is for SLT or SLE
  assign potentialSLTBit = (!ALUCoutWire && !ZBit)? 64'h0000000000000001:64'h0000000000000000;
  assign potentialSLEBit = (!ALUCoutWire || ZBit)? 64'h0000000000000001:64'h0000000000000000;
  //a determinate wire that uses SLT or SLE, assuming if not one, than the other
  //(a wire later decides if that always "lateer" choosen one is actually used
  //00 = nothing, 01 = SLT, 10 = SLE
  assign actualSLBit = (setControlBitsWire1 == 2'b01)? potentialSLTBit: potentialSLEBit;
  //the wire that is used for the new dbusWire, adds a check for if the result needs to be the SLT or not
  //SLE_MUX_TEST
  //LEG_UPDATE: hook into the SLE wire for the LSL-LSR commands
  //assign dbusWire1_5 = (setControlBitsWire1 > 2'b00)? actualSLBit:dbusWire1;
  assign potentialLSLResult = dbusWire1 << shamtWire1;
  assign potentialLSRResult = dbusWire1 >> shamtWire1;
  //assumes LSR if not LSL. won't apply it to dbus unless it's actually a shift command
  //2'b01 = LSL, 2'b10 = LSR
  assign actualLSResult = (shiftBit2 == 2'b10)? potentialLSRResult:potentialLSLResult;
  assign dbusWire1_5 = (shiftBit2 > 2'b00)? actualLSResult:dbusWire1;
  //LEG_UPDATE: apply the mov command to dbus
  assign dbusWire1_6 = (movBit2)? {dbusWire1_5 << moveImmShftAmtWire1}: dbusWire1_5;
  //LEG_UPDATE: if the NZVCSetBit is set, then set the NZVC values with the potential values
  assign potentialNBit = (dbusWire1[63] == 1'b1)? 1'b1:1'b0;
  assign potentialZBit = (ZBit)? 1'b1:1'b0;
  assign potentialVBit = (overflowWire)? 1'b1:1'b0;
  assign potentialCBit = (ALUCoutWire)? 1'b1:1'b0;
  assign NZVC[3] = (NZVCSetBitWire1)? potentialNBit:1'bz;//N (negative)
  assign NZVC[2] = (NZVCSetBitWire1)? potentialZBit:1'bz;//Z (zero)
  assign NZVC[1] = (NZVCSetBitWire1)? potentialVBit:1'bz;//V (overflow, signed)
  assign NZVC[0] = (NZVCSetBitWire1)? potentialCBit:1'bz;//C (carry)
  //PIPELINE_2_END
  //latch for pipeline 3(EX_MEM)
  pipeline_3_latch EX_MEME (.clk(clk),.dbusWire1(dbusWire1_6),.DselectWire2(DselectWire2),.bbusWire2(bbusWire2),.lwSwFlag2(lwSwFlag2),.dbusWire2(dbusWire2),
  .DselectWire3(DselectWire3),.bbusWire3(bbusWire3),.lwSwFlag3(lwSwFlag3),.branchControlBitWire1(branchControlBitWire1),.branchControlBitWire2(branchControlBitWire2));
  //PIPELINE_3_SRART
  //assign output values
  //LEG_UPDATE: if store, bbusWire3 has the data to be written
  //if load, 
  assign bbusWire3_5 = (lwSwFlag3==2'b01)? databus: bbusWire3;//2'b01 = load
  assign databus = (lwSwFlag3 == 2'b10)? bbusWire3: 32'hzzzzzzzz;//2'b10 = store
  assign daddrbus = dbusWire2;
  //PIPELINE_3_END
  //latch for pipeline 4(MEM_WB)
  pipeline_4_latch MEM_WB (.clk(clk),.dbusWire2(dbusWire2),.DselectWire3(DselectWire3),.bbusWire3(bbusWire3_5),.lwSwFlag3(lwSwFlag3),.dbusWire3(dbusWire3),.DselectWire4(DselectWire3_5),
  .bbusWire4(bbusWire4),.lwSwFlag4(lwSwFlag4),.branchControlBitWire2(branchControlBitWire2),.branchControlBitWire3(branchControlBitWire3));
  //PIPELINE_4_START
  //the mux for the data writeBack
  assign mux3Out = (lwSwFlag4 == 2'b01)? bbusWire4:dbusWire3;//2'b01 = load
  //disable the writeback if it's a store word OR if it's a beq branch
  //LEG_UPDATE: the address now is R31, 13'h80000000
  assign DselectWire4 = ((lwSwFlag4 == 2'b10) ||(branchControlBitWire3 > 3'b000))? 32'h80000000: DselectWire3_5;
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
    //else incriment
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
    //EDIT: this is delayed branching, other instructions can be put in place
    ibusWire = ibus;
    PCOut = PCIn;
  end
endmodule
//phase 2 pipeline latch(ID_EX)
module pipeline_2_latch(clk, abusWire1, bbusWire1, DselectWire1, ALUImmWire1, SWire1, CinWire1,immBit1,lwSwFlag1,
abusWire2,bbusWire2,ALUImmWire2,SWire2,CinWire2,DselectWire2,immBit2,lwSwFlag2,setControlBits,setControlBitsWire1,
branchControlBit,branchControlBitWire1,NZVCSetBit,NZVCSetBitWire1,shiftBit1,shiftBit2,shamt,shamtWire1,DTAddrWire1,
DTAddrWire2,MOVImmWire1,MOVImmWire2,movBit1,movBit2,moveImmShftAmt,moveImmShftAmtWire1);
  input clk, CinWire1,immBit1;
  input [63:0] abusWire1, bbusWire1, ALUImmWire1,DTAddrWire1,MOVImmWire1;
  input [31:0] DselectWire1;
  input [2:0] SWire1;
  input [1:0] lwSwFlag1;
  input [1:0] setControlBits;
  input [2:0] branchControlBit;
  input NZVCSetBit;
  input [1:0] shiftBit1;
  input [5:0] shamt,moveImmShftAmt;
  input movBit1;
  output CinWire2,immBit2;
  output [63:0] abusWire2, bbusWire2, ALUImmWire2,DTAddrWire2,MOVImmWire2;
  output [31:0] DselectWire2;
  output [2:0] SWire2;
  output [1:0] lwSwFlag2;
  output [1:0] setControlBitsWire1;
  output [2:0] branchControlBitWire1;
  output NZVCSetBitWire1;
  output [1:0] shiftBit2;
  output [5:0] shamtWire1,moveImmShftAmtWire1;
  output movBit2;
  reg CinWire2,immBit2;
  reg [63:0] abusWire2, bbusWire2, ALUImmWire2,DTAddrWire2,MOVImmWire2;
  reg [31:0] DselectWire2;
  reg [2:0] SWire2;
  reg [1:0] lwSwFlag2;
  reg [1:0] setControlBitsWire1;
  reg [2:0] branchControlBitWire1;
  reg NZVCSetBitWire1;
  reg [1:0] shiftBit2;
  reg [5:0] shamtWire1,moveImmShftAmtWire1;
  reg movBit2;
  always @(posedge clk) begin
    abusWire2 = abusWire1;
    bbusWire2 = bbusWire1;
    DselectWire2 = DselectWire1;
    ALUImmWire2 = ALUImmWire1;
    SWire2 = SWire1;
    CinWire2 = CinWire1;
    immBit2 = immBit1;
    lwSwFlag2 = lwSwFlag1;
    setControlBitsWire1 = setControlBits;
    branchControlBitWire1 = branchControlBit;
    NZVCSetBitWire1 = NZVCSetBit;
    shiftBit2 = shiftBit1;
    shamtWire1 = shamt;
    DTAddrWire2 = DTAddrWire1;
    MOVImmWire2 = MOVImmWire1;
    movBit2 = movBit1;
    moveImmShftAmtWire1 = moveImmShftAmt;
  end
endmodule
//phase 3 pipeliune latch(EX_MEM)
module pipeline_3_latch(clk, dbusWire1, DselectWire2, bbusWire2, lwSwFlag2, dbusWire2, DselectWire3,bbusWire3,lwSwFlag3,branchControlBitWire1,branchControlBitWire2);
  input clk;
  input [63:0] dbusWire1, bbusWire2;
  input [31:0] DselectWire2;
  input [1:0] lwSwFlag2;
  input [2:0] branchControlBitWire1;
  output [63:0] dbusWire2, bbusWire3;
  output [31:0] DselectWire3;
  output [1:0] lwSwFlag3;
  output [2:0] branchControlBitWire2;
  reg [63:0] dbusWire2, bbusWire3;
  reg [31:0] DselectWire3;
  reg [1:0] lwSwFlag3;
  reg [2:0] branchControlBitWire2;
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
  input [63:0] dbusWire2, bbusWire3;
  input [31:0] DselectWire3;
  input [1:0] lwSwFlag3;
  input [2:0] branchControlBitWire2;
  output [63:0] dbusWire3, bbusWire4;
  output [31:0] DselectWire4;
  output [1:0] lwSwFlag4;
  output [2:0] branchControlBitWire3;
  reg [63:0] dbusWire3, bbusWire4;
  reg [31:0] DselectWire4;
  reg [1:0] lwSwFlag4;
  reg [2:0] branchControlBitWire3;
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
  input [63:0] Bselect,//select the register index to read from to store into bbus
  input [63:0] Dselect,//select the register to write to from dbus
  input [63:0] dbus,//data in
  output [63:0] abus,//data out
  output [63:0] bbus,//data out
  input clk
  );
  assign abus = Aselect[31] ? 32'b0 : 32'bz;
  assign bbus = Bselect[31] ? 32'b0 : 32'bz;
  DNegflipFlop myFlips[30:0](//32 wide register
      .dbus(dbus),
      .abus(abus),
      .Dselect(Dselect[30:0]),
      .Bselect(Bselect[30:0]),
      .Aselect(Aselect[30:0]),
      .bbus(bbus),
      .clk(clk)
    );
  endmodule

module DNegflipFlop(dbus, abus, Dselect, Bselect, Aselect, bbus, clk);
  input [63:0] dbus;
  input Dselect;//the select write bit for this register
  input Bselect;//the select read bit for this register
  input Aselect;
  input clk;
  output [63:0] abus;
  output [63:0] bbus;
  wire wireclk;
  reg [63:0] data;
  
  assign wireclk = clk & Dselect;
  initial begin
  data = 64'h0000000000000000;
  end
  
  always @(negedge clk) begin
    if(Dselect) begin
      data = dbus;
    end
  end
  assign abus = Aselect? data : 64'hzzzzzzzzzzzzzzzz;
  assign bbus = Bselect? data : 64'hzzzzzzzzzzzzzzzz;
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
