`timescale 1ns/10ps
module ARMStb();

reg  [63:0] instrbus;
reg  [63:0] instrbusin[0:23];
wire [63:0] iaddrbus, daddrbus;
reg  [63:0] iaddrbusout[0:23], daddrbusout[0:23];
wire [63:0] databus;
reg  [63:0] databusk, databusin[0:23], databusout[0:23];
reg         clk, reset;
reg         clkd;

reg [63:0] dontcare;
reg [24*8:1] iname[0:23];
integer error, k, ntests;
//aluImm is 12 bits
//all opcode parameters to be used
parameter ADD    = 11'b10001011000;
parameter ADDI   = 10'b1001000100;
parameter ADDIS  = 10'b1011000100;
parameter ADDS   = 11'b10101011000;
parameter AND    = 11'b10001010000;
parameter ANDI   = 10'b1001001000;
parameter ANDIS  = 10'b1111001000;
parameter ANDS   = 11'b11101010000;
//CBNZ
//CBZ
parameter EOR    = 11'b11001010000;
parameter EORI   = 10'b1101001000;
//LDUR
//parameter LW    = 'b;
//LSL
//LSR
//MOVZ
parameter ORR    = 11'b10101010000;
parameter ORRI   = 10'b1011001000;
//STUR
//parameter SW    = 'b;
parameter SUB    = 11'b11001011000;
parameter SUBI   = 10'b1101000100;
parameter SUBIS  = 10'b1111000100;
parameter SUBS   = 11'b11101011000;
//B
//parameter B.EQ    = 'b;
//parameter B.NE    = 'b;
//parameter SLT    = 'b;
//parameter SLE    = 'b

//register parameters
parameter R0  = 5'b00000;
parameter R20 = 5'b10100;
parameter R21 = 5'b10101;
parameter R22 = 5'b10110;
parameter R23 = 5'b10111;
parameter R24 = 5'b11000;
parameter R25 = 5'b11001;
parameter R26 = 5'b11010;
parameter R27 = 5'b11011;
parameter R28 = 5'b11100;
parameter R29 = 5'b11101;
parameter R30 = 5'b11110;
parameter R31 = 5'b11111;

//other parameterz to be used
parameter zeroSham = 6'b000000;

ARMS dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
// This test file runs the following program.
//aluImm is only 12 bits long!
//all register entries should be set to 0 at the beginning
//phase 1: testing basic op commands
iname[0]  = "ADDI, R20, R31, #AAA";//testing addi, result in R20 = 00000AAA
iname[1]  = "ADDI, R31, R23, #002";//testing addi on R31, result in R31 = 00000000
iname[2]  = "ADDI, R0,  R23, #002";//testing addi on R0, result in R0 = 00000002
iname[3]  = "ORRI, R21, R24, #001";//testing ori, result in R21 = 00000001
iname[4]  = "EORI, R22, R20, #000";//testing xori, result in R22 = 00000AAA
iname[5]  = "ANDI, R23, R0,  #003";//testing andi, result in R23 = 00000002
iname[6]  = "SUBI, R24, R20, #00A";//testing subi, result in R24 = 00000AA0
iname[7]  = "ADD,  R25, R20, R0";//testing add, result in R25 = 00000AAC
iname[8]  = "AND,  R26, R20, R22";//testing and, result in R26 = 00000AAA
iname[9]  = "EOR,  R27, R23, R21";//testing xor, result in R27 = 00000003
iname[10] = "ORR,  R28, R25, R23";//testing or, result in R28 = 00000AAE
iname[11] = "SUB,  R29, R20, R22";//testing sub, result in R29 = 00000000
iname[12] = "ADDI, R30, R31, #000";//testing addi on R31, result in R30 = 00000000
//phase 2: testing basic op codes with the set flags
iname[13] = "SUBIS,R20, R0,  #003";//testing subis, n flag, result in R20 = FFFFFFFF
iname[14] = "SUBS, R21, R25, R28";//testing subs, n flag, result in R21 = FFFFFFFE
iname[15] = "ADDIS,R22, R31, #000";//testing addis, z flag, result in R22 = 00000000
iname[16] = "ADDS  R23, R20, R23";//testing adds, c flag, result in R23 = 00000001
iname[17] = "ANDIS,R24, R20, #002";//testing andis, reseting n,z flags to low, result in R24 = 00000002
iname[18] = "ANDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFE
//TODO: impliment shift so i can test the v flag
/*iname[14] = "NOP";//nada
iname[15] = "NOP";//nada
iname[16] = "NOP";//nada
iname[17] = "NOP";//nada*/

iname[19] = "NOP";//nada
iname[20] = "NOP";//nada
iname[21] = "NOP";//nada
iname[22] = "NOP";//nada
iname[23] = "NOP";//nada

dontcare = 63'hx;

//* ADDI, R20, R31, #AAA
iaddrbusout[0] = 63'h00000000;
//            opcode rm/ALUImm    rn        rd...
instrbusin[0]={ADDI, 12'hAAA, R31, R20};
daddrbusout[0] = dontcare;
databusin[0] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

//* ADDI, R31, R23, #002
iaddrbusout[1] = 63'h00000004;
//            opcode rm/ALUImm    rn        rd...
instrbusin[1]={ADDI, 12'h002, R23, R31};
daddrbusout[1] = dontcare;
databusin[1] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1] = dontcare;

//* ADDI, R0,  R23, #002
iaddrbusout[2] = 63'h00000008;
//            opcode rm/ALUImm    rn        rd...
instrbusin[2]={ADDI, 12'h002, R23, R0};
daddrbusout[2] = dontcare;
databusin[2] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2] = dontcare;

//* ORRI, R21, R24, #001
iaddrbusout[3] = 63'h0000000C;
//            opcode rm/ALUImm    rn        rd...
instrbusin[3]={ORRI, 12'h001, R24, R21};
daddrbusout[3] = 63'hFFFFFFFF;
databusin[3] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[3] = dontcare;

//* EORI, R22, R20, #000
iaddrbusout[4] = 63'h00000010;
//            opcode rm/ALUImm    rn        rd...
instrbusin[4]={EORI, 12'h000, R20, R22};
daddrbusout[4] = 63'h00000001;
databusin[4] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[4] = dontcare;

//* ANDI, R23, R0,  #003
iaddrbusout[5] = 63'h00000014;
//            opcode rm/ALUImm    rn        rd...
instrbusin[5]={ANDI, 12'h003, R0, R23};
daddrbusout[5] = 63'h00001002;
databusin[5] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[5] = 63'hFFFFFFFF;

//* SUBI, R24, R20, #00A
iaddrbusout[6] = 63'h00000018;
//            opcode rm/ALUImm    rn        rd...
instrbusin[6]={SUBI, 12'h00A, R20, R24};
daddrbusout[6] = 63'h00000002;
databusin[6] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 63'h00000001;

//  op,   rd,  rn,  rm
//* ADD,  R25, R20, R0
iaddrbusout[7] = 63'h0000001C;
//             op,  rm, shamt,    rn,  rd
instrbusin[7]={ADD, R0, zeroSham, R20, R25};
daddrbusout[7] = dontcare;
databusin[7] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = dontcare;

//  op,   rd,  rn,  rm
//* AND,  R26, R20, R22
iaddrbusout[8] = 63'h00000020;
//             op,  rm, shamt,    rn,  rd
instrbusin[8]={AND, R22, zeroSham, R20, R26};
daddrbusout[8] = dontcare;
databusin[8] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

//  op,   rd,  rn,  rm
//* XOR,  R27, R23, R21
iaddrbusout[9] = 63'h00000024;
//             op,  rm, shamt,    rn,  rd
instrbusin[9]={EOR, R21, zeroSham, R23, R27};
daddrbusout[9] = dontcare;
databusin[9] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

//  op,   rd,  rn,  rm
//* OR,   R28, R25, R23
iaddrbusout[10] = 63'h0000002C;
//             op,  rm, shamt,    rn,  rd
instrbusin[10]={ORR, R23, zeroSham, R25, R28};
daddrbusout[10] = dontcare;
databusin[10] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

//  op,   rd,  rn,  rm
//* SUB,  R29, R20, R22
iaddrbusout[11] = 63'h00000030;
//             op,  rm, shamt,    rn,  rd
instrbusin[11]={SUB, R22, zeroSham, R20, R29};
daddrbusout[11] = dontcare;
databusin[11] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

//  op,   rd,  rn,  aluImm
//* ADDI, R30, R31, #000
iaddrbusout[12] = 63'h00000034;
//            opcode rm/ALUImm    rn        rd...
instrbusin[12]={ADDI, 12'h000, R31, R30};
daddrbusout[12] = dontcare;
databusin[12] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

//  op,   rd,  rn,  aluImm
//* SUBIS,R20, R0,  #003
iaddrbusout[13] = 63'h00000038;
//            opcode rm/ALUImm    rn        rd...
instrbusin[13] = {SUBIS, 12'h003, R0, R20};
daddrbusout[13] = dontcare;
databusin[13] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = dontcare;

//  op,   rd,  rn,  rm
//* SUBS, R21, R25, R28
iaddrbusout[14] = 63'h0000003C;
//             op,  rm, shamt,    rn,  rd
instrbusin[14] = {SUBS, R28, zeroSham, R25, R21};
daddrbusout[14] = dontcare;
databusin[14] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

//  op,   rd,  rn,  aluImm
//* ADDIS,R22, R31, #000
iaddrbusout[15] = 63'h00000040;
//            opcode rm/ALUImm    rn        rd...
instrbusin[15] = {ADDIS, 12'h000, R31, R22};
daddrbusout[15] = dontcare;
databusin[15] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] = dontcare;

//  op,   rd,  rn,  rm
//* ADDS  R23, R20, R23
iaddrbusout[16] = 63'h00000044;
//             op,  rm, shamt,    rn,  rd
instrbusin[16] = {ADDS, R23, zeroSham, R20, R23};
daddrbusout[16] = dontcare;
databusin[16] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16] = dontcare;

//  op,   rd,  rn,  aluImm
//* ANDIS,R24, R20, #002
iaddrbusout[17] = 63'h00000048;
//            opcode rm/ALUImm    rn        rd...
instrbusin[17] = {ANDIS, 12'h002, R20, R24};
daddrbusout[17] = dontcare;
databusin[17] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = dontcare;

//  op,   rd,  rn,  rm
//* ANDS, R25, R21, R20
iaddrbusout[18] = 63'h00000048;
//             op,  rm, shamt,    rn,  rd
instrbusin[18] = {ANDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[18] = dontcare;

//* NOP
iaddrbusout[19] = 63'h00000048;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[19] = 63'b00000000000000000000000000000000;
daddrbusout[19] = dontcare;
databusin[19] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[19] = dontcare;

//* NOP
iaddrbusout[20] = 63'h00000048;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[20] = 63'b00000000000000000000000000000000;
daddrbusout[20] = dontcare;
databusin[20] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[20] = dontcare;

//* NOP
iaddrbusout[21] = 63'h00000048;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[21] = 63'b00000000000000000000000000000000;
daddrbusout[21] = dontcare;
databusin[21] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[21] = dontcare;

//* NOP
iaddrbusout[22] = 63'h00000048;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[22] = 63'b00000000000000000000000000000000;
daddrbusout[22] = dontcare;
databusin[22] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[22] = dontcare;

//* NOP
iaddrbusout[23] = 63'h00000048;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[23] = 63'b00000000000000000000000000000000;
daddrbusout[23] = dontcare;
databusin[23] = 63'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[23] = dontcare;


//this number will be inacurate for a while(the number below)
// (no. instructions) + (no. loads) + 2*(no. stores) = 35 + 2 + 2*7 = 51
ntests = 24;//?

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 63'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 63'bz;

  //extended reset to set up PC MUX
  reset = 1;
  $display ("reset=%b", reset);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5

  clk=1;
  clkd=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  $display ("Time=%t\n  clk=%b", $realtime, clk);

for (k=0; k<= 26; k=k+1) begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd=1;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    reset = 0;
    $display ("reset=%b", reset);


    //set load data for 3rd previous instruction
    if (k >=3)
      databusk = databusin[k-3];

    //check PC for this instruction
    if (k >= 0) begin
      $display ("  Testing PC for instruction %d", k);
      $display ("    Your iaddrbus =    %b", iaddrbus);
      $display ("    Correct iaddrbus = %b", iaddrbusout[k]);
      if (iaddrbusout[k] !== iaddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //put next instruction on ibus
    instrbus=instrbusin[k];
    $display ("  instrbus=%b %b %b %b %b for instruction %d: %s", instrbus[31:26], instrbus[25:21], instrbus[20:16], instrbus[15:11], instrbus[10:0], k, iname[k]);

    //check data address from 3rd previous instruction
    if ( (k >= 3) && (daddrbusout[k-3] !== dontcare) ) begin
      $display ("  Testing data address for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your daddrbus =    %b", daddrbus);
      $display ("    Correct daddrbus = %b", daddrbusout[k-3]);
      if (daddrbusout[k-3] !== daddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //check store data from 3rd previous instruction
    if ( (k >= 3) && (databusout[k-3] !== dontcare) ) begin
      $display ("  Testing store data for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your databus =    %b", databus);
      $display ("    Correct databus = %b", databusout[k-3]);
      if (databusout[k-3] !== databus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    clk = 0;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd = 0;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
  end

  if ( error !== 0) begin
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
    $display(" No. Of Errors = %d", error);
  end
  if ( error == 0)
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");
end

endmodule
