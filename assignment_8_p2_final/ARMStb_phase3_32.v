//phase 3: testing LSL, LSR, 32bit
`timescale 1ns/10ps
module ARMStb();

reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:29];
wire [31:0] iaddrbus, dselect;
reg  [31:0] iaddrbusout[0:29], dselectout[0:29];
wire [31:0] dbus;
reg  [31:0] databusk, dbusout[0:29];
reg         clk, reset;
reg         clkd;
reg [31:0] dontcare;
reg [24*8:1] iname[0:29];
integer error, k, ntests;

//all   opcode parameters to be used
parameter ADD    = 11'b10001011000;
parameter ADDI   = 10'b1001000100;
parameter ADDIS  = 10'b1011000100;
parameter ADDS   = 11'b10101011000;
parameter AND    = 11'b10001010000;
parameter ANDI   = 10'b1001001000;
parameter ANDIS  = 10'b1111001000;
parameter ANDS   = 11'b11101010000;
parameter CBNZ   =  8'b10110101;
parameter CBZ    =  8'b10110100;
parameter EOR    = 11'b11001010000;
parameter EORI   = 10'b1101001000;
parameter LDUR   = 11'b11111000010;
parameter LSL    = 11'b11010011011;
parameter LSR    = 11'b11010011010;
parameter MOVZ   =  9'b110100101;
parameter ORR    = 11'b10101010000;
parameter ORRI   = 10'b1011001000;
parameter STUR   = 11'b11111000000;
parameter SUB    = 11'b11001011000;
parameter SUBI   = 10'b1101000100;
parameter SUBIS  = 10'b1111000100;
parameter SUBS   = 11'b11101011000;
parameter B      =  6'b000101;
parameter B_EQ   =  8'b01010101;
parameter B_NE   =  8'b01010110;
parameter B_LT   =  8'b01010111;
parameter B_GT   =  8'b01011000;

//register parameters
parameter R0          = 5'b00000;
parameter R0_dselect  = 32'b00000000000000000000000000000001;

parameter R18         = 5'b10010;
parameter R18_dselect = 32'b00000000000001000000000000000000;

parameter R19         = 5'b10011;
parameter R19_dselect = 32'b00000000000010000000000000000000;

parameter R20         = 5'b10100;
parameter R20_dselect = 32'b00000000000100000000000000000000;

parameter R21         = 5'b10101;
parameter R21_dselect = 32'b00000000001000000000000000000000;

parameter R22         = 5'b10110;
parameter R22_dselect = 32'b00000000010000000000000000000000;

parameter R23         = 5'b10111;
parameter R23_dselect = 32'b00000000100000000000000000000000;

parameter R24         = 5'b11000;
parameter R24_dselect = 32'b00000001000000000000000000000000;

parameter R25         = 5'b11001;
parameter R25_dselect = 32'b00000010000000000000000000000000;

parameter R26         = 5'b11010;
parameter R26_dselect = 32'b00000100000000000000000000000000;

parameter R27         = 5'b11011;
parameter R27_dselect = 32'b00001000000000000000000000000000;

parameter R28         = 5'b11100;
parameter R28_dselect = 32'b00010000000000000000000000000000;

parameter R29         = 5'b11101;
parameter R29_dselect = 32'b00100000000000000000000000000000;

parameter R30         = 5'b11110;
parameter R30_dselect = 32'b01000000000000000000000000000000;

parameter R31         = 5'b11111;
parameter R31_dselect = 32'b10000000000000000000000000000000;


//other parameterz to be used
parameter zeroSham   = 6'b000000;
parameter RX         = 5'b11111;
parameter oneShamt   = 6'b000001;
parameter twoShamt   = 6'b000010;
parameter threeShamt = 6'b000011;
parameter eightShamt = 6'b001000;

ARMS dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.dbus(dbus),.dselect(dselect));

initial begin
dontcare = 32'hx;


//phase 1: testing basic op commands and instruction bus
//* ADDI, R20, R31, #AAA
iname[0]  = "ADDI, R20, R31, #AAA";//testing addi, result in R20 = 00000AAA
iaddrbusout[0] = 32'h00000000;
//            opcode rm/ALUImm    rn        rd...
instrbusin[0]={ADDI, 12'hAAA,     R31,      R20};
dselectout[0] = R20_dselect;
dbusout[0] = 32'h00000AAA;

//* ADDI, R31, R23, #002
iname[1]  = "ADDI, R31, R23, #002";//testing addi on R31, result in R31 = 00000000
iaddrbusout[1] = 32'h00000004;
//            opcode rm/ALUImm    rn        rd...
instrbusin[1]={ADDI, 12'h002,     R23,      R31};
dselectout[1] = R31_dselect;
dbusout[1] = dontcare;

//* ADDI, R0,  R23, #002
iname[2]  = "ADDI, R0,  R23, #002";//testing addi on R0, result in R0 = 00000002
iaddrbusout[2] = 32'h00000008;
//            opcode rm/ALUImm    rn        rd...
instrbusin[2]={ADDI, 12'h002,     R23,      R0};
dselectout[2] = R0_dselect;
dbusout[2] = 32'h00000002;

//* ORRI, R21, R24, #001
iname[3]  = "ORRI, R21, R24, #001";//testing ori, result in R21 = 00000001
iaddrbusout[3] = 32'h0000000C;
//            opcode rm/ALUImm    rn        rd...
instrbusin[3]={ORRI, 12'h001,     R24,      R21};
dselectout[3] = R21_dselect;
dbusout[3] = 32'h00000001;

//* EORI, R22, R20, #000
iname[4]  = "EORI, R22, R20, #000";//testing xori, result in R22 = 00000AAA
iaddrbusout[4] = 32'h00000010;
//            opcode rm/ALUImm    rn        rd...
instrbusin[4]={EORI, 12'h000,     R20,      R22};
dselectout[4] = R22_dselect;
dbusout[4] = 32'h00000AAA;

//* ANDI, R23, R0,  #003
iname[5]  = "ANDI, R23, R0,  #003";//testing andi, result in R23 = 00000002
iaddrbusout[5] = 32'h00000014;
//            opcode rm/ALUImm    rn        rd...
instrbusin[5]={ANDI, 12'h003,     R0,       R23};
dselectout[5] = R23_dselect;
dbusout[5] = 32'h00000002;

//* SUBI, R24, R20, #00A
iname[6]  = "SUBI, R24, R20, #00A";//testing subi, result in R24 = 00000AA0
iaddrbusout[6] = 32'h00000018;
//            opcode rm/ALUImm    rn        rd...
instrbusin[6]={SUBI, 12'h00A,     R20,      R24};
dselectout[6] = R24_dselect;
dbusout[6] = 32'h00000AA0;

//  op,   rd,  rn,  rm
//* ADD,  R25, R20, R0
iname[7]  = "ADD,  R25, R20, R0";//testing add, result in R25 = 00000AAC
iaddrbusout[7] = 32'h0000001C;
//             op,  rm, shamt,    rn,  rd
instrbusin[7]={ADD, R0, zeroSham, R20, R25};
dselectout[7] = R25_dselect;
dbusout[7] = 32'h00000AAC;

//  op,   rd,  rn,  rm
//* AND,  R26, R20, R22
iname[8]  = "AND,  R26, R20, R22";//testing and, result in R26 = 00000AAA
iaddrbusout[8] = 32'h00000020;
//             op,  rm,  shamt,    rn,  rd
instrbusin[8]={AND, R22, zeroSham, R20, R26};
dselectout[8] = R26_dselect;
dbusout[8] = 32'h00000AAA;

//  op,   rd,  rn,  rm
//* XOR,  R27, R23, R21
iname[9]  = "EOR,  R27, R23, R21";//testing xor, result in R27 = 00000003
iaddrbusout[9] = 32'h00000024;
//             op,  rm,  shamt,    rn,  rd
instrbusin[9]={EOR, R21, zeroSham, R23, R27};
dselectout[9] = R27_dselect;
dbusout[9] = 32'h00000003;

//  op,   rd,  rn,  rm
//* OR,   R28, R25, R23
iname[10] = "ORR,  R28, R25, R23";//testing or, result in R28 = 00000AAE
iaddrbusout[10] = 32'h00000028;
//              op,  rm,  shamt,    rn,  rd
instrbusin[10]={ORR, R23, zeroSham, R25, R28};
dselectout[10] = R28_dselect;
dbusout[10] = 32'h00000AAE;

//  op,   rd,  rn,  rm
//* SUB,  R29, R20, R22
iname[11] = "SUB,  R29, R20, R22";//testing sub, result in R29 = 00000000
iaddrbusout[11] = 32'h0000002C;
//              op,  rm,  shamt,    rn,  rd
instrbusin[11]={SUB, R22, zeroSham, R20, R29};
dselectout[11] = R29_dselect;
dbusout[11] = 32'h00000000;

//  op,   rd,  rn,  aluImm
//* ADDI, R30, R31, #000
iname[12] = "ADDI, R30, R31, #000";//testing addi on R31, result in R30 = 00000000
iaddrbusout[12] = 32'h00000030;
//             opcode rm/ALUImm    rn        rd...
instrbusin[12]={ADDI, 12'h000,     R31,      R30};
dselectout[12] = R30_dselect;
dbusout[12] = 32'h00000000;


//phase 2: testing basic op codes with the n,z,c flags
//  op,   rd,  rn,  aluImm
//* SUBIS,R20, R0,  #003
iname[13] = "SUBIS,R20, R0,  #003";//testing subis, n flag, result in R20 = FFFFFFFF
iaddrbusout[13] = 32'h00000034;
//            opcode rm/ALUImm    rn        rd...
instrbusin[13] = {SUBIS, 12'h003, R0, R20};
dselectout[13] = dontcare;
dbusout[13] = dontcare;

//  op,   rd,  rn,  rm
//* SUBS, R21, R25, R28
iname[14] = "SUBS, R21, R25, R28";//testing subs, n flag, result in R21 = FFFFFFFE
iaddrbusout[14] = 32'h00000038;
//             op,  rm, shamt,    rn,  rd
instrbusin[14] = {SUBS, R28, zeroSham, R25, R21};
dselectout[14] = dontcare;
dbusout[14] = dontcare;

//  op,   rd,  rn,  aluImm
//* ADDIS,R22, R31, #000
iname[15] = "ADDIS,R22, R31, #000";//testing addis, z flag, result in R22 = 00000000
iaddrbusout[15] = 32'h0000003C;
//            opcode rm/ALUImm    rn        rd...
instrbusin[15] = {ADDIS, 12'h000, R31, R22};
dselectout[15] = dontcare;
dbusout[15] = dontcare;

//  op,   rd,  rn,  rm
//* ADDS  R23, R20, R23
iname[16] = "ADDS  R23, R20, R23";//testing adds, c flag, result in R23 = 00000001
iaddrbusout[16] = 32'h00000040;
//             op,  rm, shamt,    rn,  rd
instrbusin[16] = {ADDS, R23, zeroSham, R20, R23};
dselectout[16] = dontcare;
dbusout[16] = dontcare;

//  op,   rd,  rn,  aluImm
//* ANDIS,R24, R20, #002
iname[17] = "ANDIS,R24, R20, #002";//testing andis, reseting n,z flags to low, result in R24 = 00000002
iaddrbusout[17] = 32'h00000044;
//            opcode rm/ALUImm    rn        rd...
instrbusin[17] = {ANDIS, 12'h002, R20, R24};
dselectout[17] = dontcare;
dbusout[17] = dontcare;

//  op,   rd,  rn,  rm
//* ANDS, R25, R21, R20
iname[18] = "ANDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFE
iaddrbusout[18] = 32'h00000048;
//             op,  rm, shamt,    rn,  rd
instrbusin[18] = {ANDS, R20, zeroSham, R21, R25};
dselectout[18] = dontcare;
dbusout[18] = dontcare;

//phase 3: testing LSL, LSR
//setting up the register R20 for a test of the LSL
//                op,   rd,  rn,  rm
iname[19]       ="ADDI, R20, R31, #007";//setting up for left shift, result in R20 = 0000000000000007
iaddrbusout[19] = 64'h0000004C;
//                opcode rm/ALUImm rn   rd
instrbusin[19]  ={ADDI,  12'h007,  R31, R20};
dselectout[19] = R20_dselect;
dbusout[19]  = 64'h00000007;

//                op,   rd,  rn,  rm
iname[20]       ="ADDI, R21, R31, #700";//setting up for right shift, n flag, result in R21 = 0000000000000700
iaddrbusout[20] = 64'h00000050;
//                opcode rm/ALUImm rn   rd
instrbusin[20]  ={ADDI,  12'h700,  R31, R21};
dselectout[20] = R21_dselect;
dbusout[20]  = 64'h00000700;

//                op,   rd,  rn,  rm
iname[21]       ="AND,  R19, R31, R31";//delay, result in R19 = 0000000000000000
iaddrbusout[21] = 64'h00000054;
//                op,   rm,  shamt,    rn,  rd
instrbusin[21]  ={AND, R31,  zeroSham, R31, R19};
dselectout[21] = R19_dselect;
dbusout[21]  = 64'h00000000;

//                op,   rd,  rn,  rm
iname[22]       ="AND,  R18, R31, R31";//delay, result in R18 = 0000000000000000
iaddrbusout[22] = 64'h00000058;
//                op,   rm,  shamt,    rn,  rd
instrbusin[22]  ={AND, R31,  zeroSham, R31, R18};
dselectout[22] = R18_dselect;
dbusout[22]  = 64'h00000000;

//                op,  rd,  rn,  rm
iname[23]       ="LSL, R20, R20, 2";//testing left shift, result in R20 = 0000000000000700
iaddrbusout[23] = 64'h0000005C;
//                op,  rm, shamt,      rn,  rd
instrbusin[23]  ={LSL, RX, eightShamt, R20, R20};
dselectout[23] = R20_dselect;
dbusout[23]  = 64'h00000700;

//                op,  rd,  rn,  rm
iname[24]       ="LSR, R21, R21, 2";//testing right shift, result in R21 = 0000000000000007
iaddrbusout[24] = 64'h00000060;
//                op,  rm, shamt,      rn,  rd
instrbusin[24]  ={LSR, RX, eightShamt, R21, R21};
dselectout[24] = R21_dselect;
dbusout[24]  = 64'h00000007;


//finishing up
iname[25] =    "NOP";//nada
iaddrbusout[25] = 64'h00000064;
instrbusin[25]  = 64'b0;
dselectout[25] = dontcare;
dbusout[25]  = dontcare;

iname[26] =    "NOP";//nada
iaddrbusout[26] = 64'h00000068;
instrbusin[26]  = 64'b0;
dselectout[26] = dontcare;
dbusout[26]  = dontcare;

iname[27] =    "NOP";//nada
iaddrbusout[27] = 64'h0000006C;
instrbusin[27]  = 64'b0;
dselectout[27] = dontcare;
dbusout[27]  = dontcare;

iname[28] =    "NOP";//nada
iaddrbusout[28] = 64'h00000070;
instrbusin[28]  = 64'b0;
dselectout[28] = dontcare;
dbusout[28]  = dontcare;

iname[29] =    "NOP";//nada
iaddrbusout[29] = 64'h00000074;
instrbusin[29]  = 64'b0;
dselectout[29] = dontcare;
dbusout[29]  = dontcare;


//remember to set k down below to ntests - 1
ntests = 30;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
//assign databus = clkd ? 64'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  //databusk = 64'bz;

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

for (k=0; k<= 29; k=k+1) begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd=1;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    reset = 0;
    $display ("reset=%b", reset);


    //set dbus and dselect data data for 4th previous instruction
    if (k >=4)
      //databusk = databusin[k-4];

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
    $display ("  instrbus=%b%b%b%b%b for instruction %d: %s", instrbus[31:26], instrbus[25:21], instrbus[20:16], instrbus[15:11], instrbus[10:0], k, iname[k]);

    //check writeback data address from 4th previous instruction
    if ( (k >= 4) && (dselectout[k-4] !== dontcare) ) begin
      $display ("  Testing writeback data address for instruction %d:", k-4);
      $display ("  %s", iname[k-4]);
      $display ("    Your dselect =    %b", dselect);
      $display ("    Correct dselect = %b", dselectout[k-4]);
      if (dselectout[k-4] !== dselect) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //check writeback data from 4th previous instruction
    if ( (k >= 4) && (dbusout[k-4] !== dontcare) ) begin
      $display ("  Testing writeback data for instruction %d:", k-4);
      $display ("  %s", iname[k-4]);
      $display ("    Your dbus =    %b", dbus);
      $display ("    Correct dbus = %b", dbusout[k-4]);
      if (dbusout[k-4] !== dbus) begin
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
