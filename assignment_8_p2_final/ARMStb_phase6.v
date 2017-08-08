`timescale 1ns/10ps
module ARMStb();

reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:50];
wire [63:0] iaddrbus, daddrbus;
reg  [63:0] iaddrbusout[0:50], daddrbusout[0:50];
wire [63:0] databus;
reg  [63:0] databusk, databusin[0:50], databusout[0:50];
reg         clk, reset;
reg         clkd;
reg [63:0] dontcare;
reg [24*8:1] iname[0:50];
integer error, k, ntests;

//all opcode parameters to be used
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
parameter R0  = 5'b00000;
parameter R15 = 5'b01111;
parameter R16 = 5'b10000;
parameter R17 = 5'b10001;
parameter R18 = 5'b10010;
parameter R19 = 5'b10011;
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
parameter zeroSham   = 6'b000000;
parameter RX         = 5'b11111;
parameter oneShamt   = 6'b000001;
parameter twoShamt   = 6'b000010;
parameter threeShamt = 6'b000011;
parameter eightShamt = 6'b001000;

ARMS dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
dontcare = 64'hx;


//phase 1: testing basic op commands
//                op,   rd,  rn,  rm
iname[0]        ="ADDI, R20, R31, #AAA";//testing addi, result in R20 = 0000000000000AAA
iaddrbusout[0]  = 64'h00000000;
//                opcode rm/ALUImm rn   rd
instrbusin[0]   ={ADDI,  12'hAAA,  R31, R20};
daddrbusout[0]  = dontcare;
databusin[0]    = 64'bz;
databusout[0]   = dontcare;

//                op,   rd,  rn,  rm
iname[1]        ="ADDI, R31, R23, #002";//testing addi on R31, result in R31 = 0000000000000000
iaddrbusout[1]  = 64'h00000004;
//                opcode rm/ALUImm rn   rd
instrbusin[1]   ={ADDI,  12'h002,  R23, R31};
daddrbusout[1]  = dontcare;
databusin[1]    = 64'bz;
databusout[1]   = dontcare;

//                op,   rd,  rn,  rm
iname[2]        ="ADDI, R0,  R23, #002";//testing addi on R0, result in R0 = 0000000000000002
iaddrbusout[2]  = 64'h00000008;
//                opcode rm/ALUImm rn   rd
instrbusin[2]   ={ADDI,  12'h002,  R23, R0};
daddrbusout[2]  = dontcare;
databusin[2]    = 64'bz;
databusout[2]   = dontcare;

//                op,   rd,  rn,  rm
iname[3]        ="ORRI, R21, R24, #001";//testing ori, result in R21 = 0000000000000001
iaddrbusout[3]  = 64'h0000000C;
//                opcode rm/ALUImm rn   rd
instrbusin[3]   ={ORRI,  12'h001,  R24, R21};
daddrbusout[3]  = dontcare;
databusin[3]    = 64'bz;
databusout[3]   = dontcare;

//                op,   rd,  rn,  rm
iname[4]        ="EORI, R22, R20, #000";//testing xori, result in R22 = 0000000000000AAA
iaddrbusout[4]  = 64'h00000010;
//                opcode rm/ALUImm rn   rd
instrbusin[4]   ={EORI,  12'h000,  R20, R22};
daddrbusout[4]  = dontcare;
databusin[4]    = 64'bz;
databusout[4]   = dontcare;

//                op,   rd,  rn,  rm
iname[5]        ="ANDI, R23, R0,  #003";//testing andi, result in R23 = 0000000000000002
iaddrbusout[5]  = 64'h00000014;
//                opcode rm/ALUImm rn   rd
instrbusin[5]   ={ANDI,  12'h003,  R0, R23};
daddrbusout[5]  = dontcare;
databusin[5]    = 64'bz;
databusout[5]   = dontcare;

//                op,   rd,  rn,  rm
iname[6]        ="SUBI, R24, R20, #00A";//testing subi, result in R24 = 0000000000000AA0
iaddrbusout[6]  = 64'h00000018;
//                opcode rm/ALUImm rn   rd
instrbusin[6]   ={SUBI,  12'h00A,  R20, R24};
daddrbusout[6]  = dontcare;
databusin[6]    = 64'bz;
databusout[6]   = dontcare;

//                op,   rd,  rn,  rm
iname[7]        ="ADD,  R25, R20, R0";//testing add, result in R25 = 0000000000000AAC
iaddrbusout[7]  = 64'h0000001C;
//                op,  rm, shamt,    rn,  rd
instrbusin[7]   ={ADD, R0, zeroSham, R20, R25};
daddrbusout[7]  = dontcare;
databusin[7]    = 64'bz;
databusout[7]   = dontcare;

//                op,   rd,  rn,  rm
iname[8]        ="AND,  R26, R20, R22";//testing and, result in R26 = 0000000000000AAA
iaddrbusout[8]  = 64'h00000020;
//                op,  rm,  shamt,    rn,  rd
instrbusin[8]   ={AND, R22, zeroSham, R20, R26};
daddrbusout[8]  = dontcare;
databusin[8]    = 64'bz;
databusout[8]   = dontcare;

//                op,   rd,  rn,  rm
iname[9]        ="EOR,  R27, R23, R21";//testing xor, result in R27 = 0000000000000003
iaddrbusout[9]  = 64'h00000024;
//                op,  rm,  shamt,    rn,  rd
instrbusin[9]   ={EOR, R21, zeroSham, R23, R27};
daddrbusout[9]  = dontcare;
databusin[9]    = 64'bz;
databusout[9]   = dontcare;

//                op,   rd,  rn,  rm
iname[10]       ="ORR,  R28, R25, R23";//testing or, result in R28 = 0000000000000AAE
iaddrbusout[10] = 64'h00000028;
//                op,  rm,  shamt,    rn,  rd
instrbusin[10]  ={ORR, R23, zeroSham, R25, R28};
daddrbusout[10] = dontcare;
databusin[10]   = 64'bz;
databusout[10]  = dontcare;

//                op,   rd,  rn,  rm
iname[11]       ="SUB,  R29, R20, R22";//testing sub, result in R29 = 0000000000000000
iaddrbusout[11] = 64'h0000002C;
//                op,  rm,  shamt,    rn,  rd
instrbusin[11]  ={SUB, R22, zeroSham, R20, R29};
daddrbusout[11] = dontcare;
databusin[11]   = 64'bz;
databusout[11]  = dontcare;

//                op,   rd,  rn,  aluImm
iname[12]       ="ADDI, R30, R31, #000";//testing addi on R31, result in R30 = 0000000000000000
iaddrbusout[12] = 64'h00000030;
//                opcode rm/ALUImm rn   rd
instrbusin[12]  ={ADDI,  12'h000,  R31, R30};
daddrbusout[12] = dontcare;
databusin[12]   = 64'bz;
databusout[12]  = dontcare;


//phase 2: testing basic op codes with the set flags
//                op,   rd,  rn,  aluImm
iname[13]       ="SUBIS,R20, R0,  #003";//testing subis, n flag, result in R20 = FFFFFFFFFFFFFFFF
iaddrbusout[13] = 64'h00000034;
//                opcode rm/ALUImm rn   rd
instrbusin[13]  ={SUBIS, 12'h003,  R0, R20};
daddrbusout[13] = dontcare;
databusin[13]   = 64'bz;
databusout[13]  = dontcare;

//                op,   rd,  rn,  rm
iname[14]       ="SUBS, R21, R25, R28";//testing subs, n flag, result in R21 = FFFFFFFFFFFFFFFE
iaddrbusout[14] = 64'h00000038;
//                op,  rm, shamt,    rn,  rd
instrbusin[14]  ={SUBS,R28,zeroSham, R25, R21};
daddrbusout[14] = dontcare;
databusin[14]   = 64'bz;
databusout[14]  = dontcare;

//                op,   rd,  rn,  aluImm
iname[15]       ="ADDIS,R22, R31, #000";//testing addis, z flag, result in R22 = 0000000000000000
iaddrbusout[15] = 64'h0000003C;
//                opcode rm/ALUImm rn   rd
instrbusin[15]  ={ADDIS, 12'h000,  R31, R22};
daddrbusout[15] = dontcare;
databusin[15]   = 64'bz;
databusout[15]  = dontcare;

//                op,   rd,  rn,  rm
iname[16]       ="ADDS  R23, R20, R23";//testing adds, c flag, result in R23 = 0000000000000001
iaddrbusout[16] = 64'h00000040;
//                op,  rm, shamt,    rn,  rd
instrbusin[16]  ={ADDS,R23,zeroSham, R20, R23};
daddrbusout[16] = dontcare;
databusin[16]   = 64'bz;
databusout[16]  = dontcare;

//                op,   rd,  rn,  aluImm
iname[17]       ="ANDIS,R24, R20, #002";//testing andis, reseting n,z flags to low, result in R24 = 0000000000000002
iaddrbusout[17] = 64'h00000044;
//                opcode rm/ALUImm rn   rd
instrbusin[17]  ={ANDIS, 12'h002,  R20, R24};
daddrbusout[17] = dontcare;
databusin[17]   = 64'bz;
databusout[17]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ANDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ANDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;


//phase 3: testing LSL, LSR
//setting up the register R20 for a test of the LSL
//                op,   rd,  rn,  rm
iname[19]       ="ADDI, R20, R31, #007";//setting up for left shift, result in R20 = 0000000000000007
iaddrbusout[19] = 64'h0000004C;
//                opcode rm/ALUImm rn   rd
instrbusin[19]  ={ADDI,  12'h007,  R31, R20};
daddrbusout[19] = dontcare;
databusin[19]   = 64'bz;
databusout[19]  = dontcare;

//                op,   rd,  rn,  rm
iname[20]       ="ADDI, R21, R31, #700";//setting up for right shift, n flag, result in R21 = 0000000000000700
iaddrbusout[20] = 64'h00000050;
//                opcode rm/ALUImm rn   rd
instrbusin[20]  ={ADDI,  12'h700,  R31, R21};
daddrbusout[20] = dontcare;
databusin[20]   = 64'bz;
databusout[20]  = dontcare;

//                op,   rd,  rn,  rm
iname[21]       ="AND,  R19, R31, R31";//delay, result in R19 = 0000000000000000
iaddrbusout[21] = 64'h00000054;
//                op,   rm,  shamt,    rn,  rd
instrbusin[21]  ={AND, R31,  zeroSham, R31, R19};
daddrbusout[21] = dontcare;
databusin[21]   = 64'bz;
databusout[21]  = dontcare;

//                op,   rd,  rn,  rm
iname[22]       ="AND,  R18, R31, R31";//delay, result in R18 = 0000000000000000
iaddrbusout[22] = 64'h00000058;
//                op,   rm,  shamt,    rn,  rd
instrbusin[22]  ={AND, R31,  zeroSham, R31, R18};
daddrbusout[22] = dontcare;
databusin[22]   = 64'bz;
databusout[22]  = dontcare;

//                op,  rd,  rn,  rm
iname[23]       ="LSL, R20, R20, 2";//testing left shift, result in R20 = 0000000000000700
iaddrbusout[23] = 64'h0000005C;
//                op,  rm, shamt,      rn,  rd
instrbusin[23]  ={LSL, RX, eightShamt, R20, R20};
daddrbusout[23] = dontcare;
databusin[23]   = 64'bz;
databusout[23]  = dontcare;

//                op,  rd,  rn,  rm
iname[24]       ="LSR, R21, R21, 2";//testing right shift, result in R21 = 0000000000000007
iaddrbusout[24] = 64'h00000060;
//                op,  rm, shamt,      rn,  rd
instrbusin[24]  ={LSR, RX, eightShamt, R21, R21};
daddrbusout[24] = dontcare;
databusin[24]   = 64'bz;
databusout[24]  = dontcare;


//phase 4: testing load and store and overflow bit
//                op,   rt,  rn,  DT_adr
iname[25]       ="LDUR, R22, R31, #1";//testing load, result in R22 = 42069 (from memory,databusin) [yes, really]
iaddrbusout[25] = 64'h00000064;
//                op,   DT_ADDR,      ?,     rn,  rt
instrbusin[25]  ={LDUR, 9'b000000001, 2'b00, R31, R22};
daddrbusout[25] = 64'h0000000000000001;//used for LDUR
databusin[25]   = 64'h0000000000042069;//used for LDUR
databusout[25]  = dontcare;

//                op,   rn,  DT_adr, rt
iname[26]       ="STUR, R23, #068,   R24";//testing story, result for databusout in R24 = 0000000000000002 (to memory)
//address is calculated from imm or 68, and R23, which is currently 1
iaddrbusout[26] = 64'h00000068;
//                op,   DT_ADDR,      ?,     rn,  rt
instrbusin[26]  ={STUR, 9'b001101000, 2'b00, R23, R24};
daddrbusout[26] = 64'h0000000000000069;//used for STUR
databusin[26]   = 64'bz;
databusout[26]  = 64'h0000000000000002;//used for STUR

//                op,   rd,  rn,  rm
iname[27]       ="AND,  R19, R31, R31";//delay, result in R19 = 0000000000000000
iaddrbusout[27] = 64'h0000006C;
//                op,   rm,  shamt,    rn,  rd
instrbusin[27]  ={AND, R31,  zeroSham, R31, R19};
daddrbusout[27] = dontcare;
databusin[27]   = 64'bz;
databusout[27]  = dontcare;

//                op,   rd,  rn,  rm
iname[28]       ="AND,  R18, R31, R31";//delay, result in R18 = 0000000000000000
iaddrbusout[28] = 64'h00000070;
//                op,   rm,  shamt,    rn,  rd
instrbusin[28]  ={AND, R31,  zeroSham, R31, R19};
daddrbusout[28] = dontcare;
databusin[28]   = 64'bz;
databusout[28]  = dontcare;

//                op,   rd,  rn,  rm
iname[29]       ="AND,  R17, R31, R31";//delay, result in R17 = 0000000000000000
iaddrbusout[29] = 64'h00000074;
//                op,   rm,  shamt,    rn,  rd
instrbusin[29]  ={AND, R31,  zeroSham, R31, R19};
daddrbusout[29] = dontcare;
databusin[29]   = 64'bz;
databusout[29]  = dontcare;


//phase 5: testing B branch
//                op,  BR_address
iname[30]       ="B,   #EA";//testing branch, calculated branch address should be
// (64'h0000000000000078 + 64'h000000000000003A8 = 64'h0000000000000420)
iaddrbusout[30] = 64'h00000078;
//                op,  BR_address
instrbusin[30]  ={B,   26'b00000000000000000011101010};
daddrbusout[30] = dontcare;
databusin[30]   = 64'bz;
databusout[30]  = dontcare;

//                op,   rd,  rn,  rm
iname[31]       ="AND,  R19, R31, R31";//delay, result in R19 = 0000000000000000
iaddrbusout[31] = 64'h0000007C;
//                op,   rm,  shamt,    rn,  rd
instrbusin[31]  ={AND, R31,  zeroSham, R31, R19};
daddrbusout[31] = dontcare;
databusin[31]   = 64'bz;
databusout[31]  = dontcare;

//                op,  rd,  rn,  rm
iname[32]       ="ADD, R20, R21, R20";//testing branch address result in R20 = 0000000000000707
iaddrbusout[32] = 64'h00000420;
//                op,  rm,   shamt,    rn,  rd
instrbusin[32]  ={ADD, R20,  zeroSham, R21, R20};
daddrbusout[32] = dontcare;
databusin[32]   = 64'bz;
databusout[32]  = dontcare;


//phase 6: testing B.EQ and B.NE branch
//                op,   rd,  rn,  rm
iname[33]        ="ADDI, R21, R31, #AAA";//testing addi, result in R21 = 0000000000000AAA
iaddrbusout[33]  = 64'h00000424;
//                opcode rm/ALUImm rn   rd
instrbusin[33]   ={ADDI,  12'hAAA,  R31, R21};
daddrbusout[33]  = dontcare;
databusin[33]    = 64'bz;
databusout[33]   = dontcare;

//                op,   rd,  rn,  rm
iname[34]        ="ADDI, R22, R31, #AAA";//testing addi, result in R22 = 0000000000000AAA
iaddrbusout[34]  = 64'h00000428;
//                opcode rm/ALUImm rn   rd
instrbusin[34]   ={ADDI,  12'hAAA,  R31, R22};
daddrbusout[34]  = dontcare;
databusin[34]    = 64'bz;
databusout[34]   = dontcare;

//ADDIS for FAKE BRANCH
//                op,   rd,  rn,  aluImm
iname[35]       ="ADDIS,R31, R31, #420";//testing fake branch, this should NOT set the Z high
iaddrbusout[35] = 64'h0000042C;
//                opcode rm/ALUImm rn   rd
instrbusin[35]  ={ADDIS, 12'h420,  R31, R31};
daddrbusout[35] = dontcare;
databusin[35]   = 64'bz;
databusout[35]  = dontcare;

//FAKE BRANCH
//                op,   COND_addr, rt
iname[36]       ="B_EQ, #69420,    RX";//testing to NOT take the branch, Z should be LOW
iaddrbusout[36] = 64'h00000430;
//                op,   COND_addr,               rt
instrbusin[36]  ={B_EQ, 19'b1101001010000100000, RX};
daddrbusout[36] = dontcare;
databusin[36]   = 64'bz;
databusout[36]  = dontcare;

iname[37] =    "NOP";//nada
iaddrbusout[37] = 64'h00000434;
instrbusin[37]  = 64'b0;
daddrbusout[37] = dontcare;
databusin[37]   = 64'bz;
databusout[37]  = dontcare;

//use SUBS for branch test
//                op,   rd,  rn,  rm
iname[38]       ="SUBS, R31, R21, R22";//set z flag for BEQ,
iaddrbusout[38] = 64'h00000438;
//                op,   rm,   shamt,    rn,  rd
instrbusin[38]  ={SUBS, R22,  zeroSham, R21, R31};
daddrbusout[38] = dontcare;
databusin[38]   = 64'bz;
databusout[38]  = dontcare;

//real branch for B.EQ (I have the best branches)
//                op,   COND_addr,  rt
iname[39]       ="B_EQ, #69,        RX";//take the branch to instruction count ?
iaddrbusout[39] = 64'h0000043C;
//                op,   COND_addr,               rt
instrbusin[39]  ={B_EQ, 19'b0000000000001101001, RX};
//19'b
daddrbusout[39] = dontcare;
databusin[39]   = 64'bz;
databusout[39]  = dontcare;

iname[40] =    "NOP";//nada
iaddrbusout[40] = 64'h00000440;
instrbusin[40]  = 64'b0;
daddrbusout[40] = dontcare;
databusin[40]   = 64'bz;
databusout[40]  = dontcare;

iname[41] =    "NOP";//nada
iaddrbusout[41] = 64'h000005E0;
instrbusin[41]  = 64'b0;
daddrbusout[41] = dontcare;
databusin[41]   = 64'bz;
databusout[41]  = dontcare;

//use SUBS for branch test
//                op,   rd,  rn,  rm
iname[42]       ="SUBS, R31, R21, R20";//set z flag of NOT for BNE
iaddrbusout[42] = 64'h000005E4;
//                op,   rm,   shamt,    rn,  rd
instrbusin[42]  ={SUBS, R20,  zeroSham, R21, R31};
daddrbusout[42] = dontcare;
databusin[42]   = 64'bz;
databusout[42]  = dontcare;

//test B.NE
//                op,   COND_addr,  rt
iname[43]       ="B_NE, #96,        RX";//take the branch to instruction count 840
iaddrbusout[43] = 64'h000005E8;
//                op,   COND_addr,               rt
instrbusin[43]  ={B_NE, 19'b0000000000010010110, RX};
daddrbusout[43] = dontcare;
databusin[43]   = 64'bz;
databusout[43]  = dontcare;

iname[44] =    "NOP";//nada
iaddrbusout[44] = 64'h000005EC;
instrbusin[44]  = 64'b0;
daddrbusout[44] = dontcare;
databusin[44]   = 64'bz;
databusout[44]  = dontcare;

iname[45] =    "NOP";//nada
iaddrbusout[45] = 64'h00000840;
instrbusin[45]  = 64'b0;
daddrbusout[45] = dontcare;
databusin[45]   = 64'bz;
databusout[45]  = dontcare;

/*
//phase 7: testing B.LT and B.GE branch
//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//phase 8: testing CBNZ and CBZ branch
//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;


//phase 9: testing MOVEZ
//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;

//                op,   rd,  rn,  rm
iname[18]       ="ADDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFFFFFFFFFE
iaddrbusout[18] = 64'h00000048;
//                op,   rm,  shamt,    rn,  rd
instrbusin[18]  ={ADDS, R20, zeroSham, R21, R25};
daddrbusout[18] = dontcare;
databusin[18]   = 64'bz;
databusout[18]  = dontcare;
*/

//finishing up
iname[46] =    "NOP";//nada
iaddrbusout[46] = 64'h00000844;
instrbusin[46]  = 64'b0;
daddrbusout[46] = dontcare;
databusin[46]   = 64'bz;
databusout[46]  = dontcare;

iname[47] =    "NOP";//nada
iaddrbusout[47] = 64'h00000848;
instrbusin[47]  = 64'b0;
daddrbusout[47] = dontcare;
databusin[47]   = 64'bz;
databusout[47]  = dontcare;

iname[48] =    "NOP";//nada
iaddrbusout[48] = 64'h0000084C;
instrbusin[48]  = 64'b0;
daddrbusout[48] = dontcare;
databusin[48]   = 64'bz;
databusout[48]  = dontcare;

iname[49] =    "NOP";//nada
iaddrbusout[49] = 64'h00000850;
instrbusin[49]  = 64'b0;
daddrbusout[49] = dontcare;
databusin[49]   = 64'bz;
databusout[49]  = dontcare;

iname[50] =    "NOP";//nada
iaddrbusout[50] = 64'h00000854;
instrbusin[50]  = 64'b0;
daddrbusout[50] = dontcare;
databusin[50]   = 64'bz;
databusout[50]  = dontcare;


//this number will be inacurate for a while(the number below)
//also remember to set k down below to ntests - 1
// (no. instructions) + (no. loads) + 2*(no. stores) = 35 + 2 + 2*7 = 51
ntests = 51;//?

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 64'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 64'bz;

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

for (k=0; k<= 50; k=k+1) begin
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
