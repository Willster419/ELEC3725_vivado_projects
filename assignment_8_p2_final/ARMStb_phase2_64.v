//phase 2: testing basic op codes with the n,z,c flags, 64bit
`timescale 1ns/10ps
module ARMStb();

reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:23];
wire [63:0] iaddrbus;
reg  [63:0] iaddrbusout[0:23];
wire [31:0] dselect;
reg  [31:0] dselectout[0:23];
wire [63:0] dbus;
reg  [63:0] dbusout[0:23];
reg         clk, reset;
reg         clkd;
reg [63:0] dontcare;
reg [31:0] dontcare_addr;
reg [24*8:1] iname[0:23];
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
parameter R0          = 5'b00000;
parameter R0_dselect  = 32'b00000000000000000000000000000001;

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
parameter zeroSham = 6'b000000;

ARMS dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.dbus(dbus),.dselect(dselect));

initial begin

dontcare = 64'hx;
dontcare_addr = 32'hx;

//phase 1: testing basic op commands and instruction bus
//* ADDI, R20, R31, #AAA
iname[0]  = "ADDI, R20, R31, #AAA";//testing addi, result in R20 = 00000AAA
iaddrbusout[0] = 64'h00000000;
//            opcode rm/ALUImm    rn        rd...
instrbusin[0]={ADDI, 12'hAAA,     R31,      R20};
dselectout[0] = R20_dselect;
dbusout[0] = 64'h00000AAA;

//* ADDI, R31, R23, #002
iname[1]  = "ADDI, R31, R23, #002";//testing addi on R31, result in R31 = 00000000
iaddrbusout[1] = 64'h00000004;
//            opcode rm/ALUImm    rn        rd...
instrbusin[1]={ADDI, 12'h002,     R23,      R31};
dselectout[1] = R31_dselect;
dbusout[1] = dontcare;

//* ADDI, R0,  R23, #002
iname[2]  = "ADDI, R0,  R23, #002";//testing addi on R0, result in R0 = 00000002
iaddrbusout[2] = 64'h00000008;
//            opcode rm/ALUImm    rn        rd...
instrbusin[2]={ADDI, 12'h002,     R23,      R0};
dselectout[2] = R0_dselect;
dbusout[2] = 64'h00000002;

//* ORRI, R21, R24, #001
iname[3]  = "ORRI, R21, R24, #001";//testing ori, result in R21 = 00000001
iaddrbusout[3] = 64'h0000000C;
//            opcode rm/ALUImm    rn        rd...
instrbusin[3]={ORRI, 12'h001,     R24,      R21};
dselectout[3] = R21_dselect;
dbusout[3] = 64'h00000001;

//* EORI, R22, R20, #000
iname[4]  = "EORI, R22, R20, #000";//testing xori, result in R22 = 00000AAA
iaddrbusout[4] = 64'h00000010;
//            opcode rm/ALUImm    rn        rd...
instrbusin[4]={EORI, 12'h000,     R20,      R22};
dselectout[4] = R22_dselect;
dbusout[4] = 64'h00000AAA;

//* ANDI, R23, R0,  #003
iname[5]  = "ANDI, R23, R0,  #003";//testing andi, result in R23 = 00000002
iaddrbusout[5] = 64'h00000014;
//            opcode rm/ALUImm    rn        rd...
instrbusin[5]={ANDI, 12'h003,     R0,       R23};
dselectout[5] = R23_dselect;
dbusout[5] = 64'h00000002;

//* SUBI, R24, R20, #00A
iname[6]  = "SUBI, R24, R20, #00A";//testing subi, result in R24 = 00000AA0
iaddrbusout[6] = 64'h00000018;
//            opcode rm/ALUImm    rn        rd...
instrbusin[6]={SUBI, 12'h00A,     R20,      R24};
dselectout[6] = R24_dselect;
dbusout[6] = 64'h00000AA0;

//  op,   rd,  rn,  rm
//* ADD,  R25, R20, R0
iname[7]  = "ADD,  R25, R20, R0";//testing add, result in R25 = 00000AAC
iaddrbusout[7] = 64'h0000001C;
//             op,  rm, shamt,    rn,  rd
instrbusin[7]={ADD, R0, zeroSham, R20, R25};
dselectout[7] = R25_dselect;
dbusout[7] = 64'h00000AAC;

//  op,   rd,  rn,  rm
//* AND,  R26, R20, R22
iname[8]  = "AND,  R26, R20, R22";//testing and, result in R26 = 00000AAA
iaddrbusout[8] = 64'h00000020;
//             op,  rm,  shamt,    rn,  rd
instrbusin[8]={AND, R22, zeroSham, R20, R26};
dselectout[8] = R26_dselect;
dbusout[8] = 64'h00000AAA;

//  op,   rd,  rn,  rm
//* XOR,  R27, R23, R21
iname[9]  = "EOR,  R27, R23, R21";//testing xor, result in R27 = 00000003
iaddrbusout[9] = 64'h00000024;
//             op,  rm,  shamt,    rn,  rd
instrbusin[9]={EOR, R21, zeroSham, R23, R27};
dselectout[9] = R27_dselect;
dbusout[9] = 64'h00000003;

//  op,   rd,  rn,  rm
//* OR,   R28, R25, R23
iname[10] = "ORR,  R28, R25, R23";//testing or, result in R28 = 00000AAE
iaddrbusout[10] = 64'h00000028;
//              op,  rm,  shamt,    rn,  rd
instrbusin[10]={ORR, R23, zeroSham, R25, R28};
dselectout[10] = R28_dselect;
dbusout[10] = 64'h00000AAE;

//  op,   rd,  rn,  rm
//* SUB,  R29, R20, R22
iname[11] = "SUB,  R29, R20, R22";//testing sub, result in R29 = 00000000
iaddrbusout[11] = 64'h0000002C;
//              op,  rm,  shamt,    rn,  rd
instrbusin[11]={SUB, R22, zeroSham, R20, R29};
dselectout[11] = R29_dselect;
dbusout[11] = 64'h00000000;

//  op,   rd,  rn,  aluImm
//* ADDI, R30, R31, #000
iname[12] = "ADDI, R30, R31, #000";//testing addi on R31, result in R30 = 00000000
iaddrbusout[12] = 64'h00000030;
//             opcode rm/ALUImm    rn        rd...
instrbusin[12]={ADDI, 12'h000,     R31,      R30};
dselectout[12] = R30_dselect;
dbusout[12] = 64'h00000000;

//phase 2: testing basic op codes with the n,z,c flags
//  op,   rd,  rn,  aluImm
//* SUBIS,R20, R0,  #003
iname[13] = "SUBIS,R20, R0,  #003";//testing subis, n flag, result in R20 = FFFFFFFF
iaddrbusout[13] = 64'h00000034;
//            opcode rm/ALUImm    rn        rd...
instrbusin[13] = {SUBIS, 12'h003, R0, R20};
dselectout[13] = dontcare;
dbusout[13] = dontcare;

//  op,   rd,  rn,  rm
//* SUBS, R21, R25, R28
iname[14] = "SUBS, R21, R25, R28";//testing subs, n flag, result in R21 = FFFFFFFE
iaddrbusout[14] = 64'h00000038;
//             op,  rm, shamt,    rn,  rd
instrbusin[14] = {SUBS, R28, zeroSham, R25, R21};
dselectout[14] = dontcare;
dbusout[14] = dontcare;

//  op,   rd,  rn,  aluImm
//* ADDIS,R22, R31, #000
iname[15] = "ADDIS,R22, R31, #000";//testing addis, z flag, result in R22 = 00000000
iaddrbusout[15] = 64'h0000003C;
//            opcode rm/ALUImm    rn        rd...
instrbusin[15] = {ADDIS, 12'h000, R31, R22};
dselectout[15] = dontcare;
dbusout[15] = dontcare;

//  op,   rd,  rn,  rm
//* ADDS  R23, R20, R23
iname[16] = "ADDS  R23, R20, R23";//testing adds, c flag, result in R23 = 00000001
iaddrbusout[16] = 64'h00000040;
//             op,  rm, shamt,    rn,  rd
instrbusin[16] = {ADDS, R23, zeroSham, R20, R23};
dselectout[16] = dontcare;
dbusout[16] = dontcare;

//  op,   rd,  rn,  aluImm
//* ANDIS,R24, R20, #002
iname[17] = "ANDIS,R24, R20, #002";//testing andis, reseting n,z flags to low, result in R24 = 00000002
iaddrbusout[17] = 64'h00000044;
//            opcode rm/ALUImm    rn        rd...
instrbusin[17] = {ANDIS, 12'h002, R20, R24};
dselectout[17] = dontcare;
dbusout[17] = dontcare;

//  op,   rd,  rn,  rm
//* ANDS, R25, R21, R20
iname[18] = "ANDS, R25, R21, R20";//testing ands, n flag, result in R25 = FFFFFFFE
iaddrbusout[18] = 64'h00000048;
//             op,  rm, shamt,    rn,  rd
instrbusin[18] = {ANDS, R20, zeroSham, R21, R25};
dselectout[18] = dontcare;
dbusout[18] = dontcare;

//* NOP
iaddrbusout[19] = 64'h0000004C;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[19] = 32'b00000000000000000000000000000000;
dselectout[19] = dontcare_addr;
dbusout[19] = dontcare;

//* NOP
iaddrbusout[20] = 64'h00000050;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[20] = 32'b00000000000000000000000000000000;
dselectout[20] = dontcare_addr;
dbusout[20] = dontcare;

//* NOP
iaddrbusout[21] = 64'h00000054;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[21] = 32'b00000000000000000000000000000000;
dselectout[21] = dontcare_addr;
dbusout[21] = dontcare;

//* NOP
iaddrbusout[22] = 64'h00000058;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[22] = 32'b00000000000000000000000000000000;
dselectout[22] = dontcare_addr;
dbusout[22] = dontcare;

//* NOP
iaddrbusout[23] = 64'h0000005C;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[23] = 32'b00000000000000000000000000000000;
dselectout[23] = dontcare_addr;
dbusout[23] = dontcare;


ntests = 24;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
//assign databus = clkd ? 32'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  //databusk = 32'bz;

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

for (k=0; k<= 23; k=k+1) begin
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
    if ( (k >= 4) && (dselectout[k-4] !== dontcare_addr) ) begin
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
    $display("-----SIMULATION INCONCLUSIVE - CHECK YOUR NZVC BIT(S) IN THE SCOPE------");
end

endmodule
