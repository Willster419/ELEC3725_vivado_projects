`timescale 1ns/10ps
module ARMStb();

reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:14];
wire [31:0] iaddrbus, daddrbus;
reg  [31:0] iaddrbusout[0:14], daddrbusout[0:14];
wire [31:0] databus;
reg  [31:0] databusk, databusin[0:14], databusout[0:14];
reg         clk, reset;
reg         clkd;

reg [31:0] dontcare;
reg [24*8:1] iname[0:14];
integer error, k, ntests;
//aluImm is 12 bits
//all opcode parameters to be used
parameter ADD    = 11'b10001011000;
parameter ADDI   = 10'b1001000100;
//parameter ADDI    = 'b;
//parameter ADDI    = 'b;
parameter AND    = 11'b10001010000;
parameter ANDI   = 10'b1001001000;
//parameter ANDI    = 'b;
//parameter ANDI    = 'b;
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
//parameter SUBI    = 'b;
//parameter SUBI    = 'b;
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
iname[13] = "NOP";//nada
iname[14] = "NOP";//nada
iname[15] = "NOP";//nada
iname[16] = "NOP";//nada
iname[17] = "NOP";//nada

dontcare = 32'hx;

//* ADDI, R20, R31, #AAA
iaddrbusout[0] = 32'h00000000;
//            opcode rm/ALUImm    rn        rd...
instrbusin[0]={ADDI, 12'hAAA, R31, R20};
daddrbusout[0] = dontcare;
databusin[0] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

//* ADDI, R31, R23, #002
iaddrbusout[1] = 32'h00000004;
//            opcode rm/ALUImm    rn        rd...
instrbusin[1]={ADDI, 12'h002, R23, R31};
daddrbusout[1] = dontcare;
databusin[1] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1] = dontcare;

//* ADDI, R0,  R23, #002
iaddrbusout[2] = 32'h00000008;
//            opcode rm/ALUImm    rn        rd...
instrbusin[2]={ADDI, 12'h002, R23, R0};
daddrbusout[2] = dontcare;
databusin[2] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2] = dontcare;

//* ORRI, R21, R24, #001
iaddrbusout[3] = 32'h0000000C;
//            opcode rm/ALUImm    rn        rd...
instrbusin[3]={ORRI, 12'h001, R24, R21};
daddrbusout[3] = 32'hFFFFFFFF;
databusin[3] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[3] = dontcare;

//* EORI, R22, R20, #000
iaddrbusout[4] = 32'h00000010;
//            opcode rm/ALUImm    rn        rd...
instrbusin[4]={EORI, 12'h000, R20, R22};
daddrbusout[4] = 32'h00000001;
databusin[4] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[4] = dontcare;

//* ANDI, R23, R0,  #003
iaddrbusout[5] = 32'h00000014;
//            opcode rm/ALUImm    rn        rd...
instrbusin[5]={ANDI, 12'h003, R0, R23};
daddrbusout[5] = 32'h00001002;
databusin[5] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[5] = 32'hFFFFFFFF;

//* SUBI, R24, R20, #00A
iaddrbusout[6] = 32'h00000018;
//            opcode rm/ALUImm    rn        rd...
instrbusin[6]={SUBI, 12'h00A, R20, R24};
daddrbusout[6] = 32'h00000002;
databusin[6] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 32'h00000001;

//  op,   rd,  rn,  rm
//* ADD,  R25, R20, R0
iaddrbusout[7] = 32'h0000001C;
//             op,  rm, shamt,    rn,  rd
instrbusin[7]={ADD, R0, zeroSham, R20, R25};
daddrbusout[7] = dontcare;
databusin[7] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = dontcare;

//  op,   rd,  rn,  rm
//* AND,  R26, R20, R22
iaddrbusout[8] = 32'h00000020;
//             op,  rm, shamt,    rn,  rd
instrbusin[8]={AND, R22, zeroSham, R20, R26};
daddrbusout[8] = dontcare;
databusin[8] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

//  op,   rd,  rn,  rm
//* XOR,  R27, R23, R21
iaddrbusout[9] = 32'h00000024;
//             op,  rm, shamt,    rn,  rd
instrbusin[9]={EOR, R21, zeroSham, R23, R27};
daddrbusout[9] = dontcare;
databusin[9] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

//  op,   rd,  rn,  rm
//* OR,   R28, R25, R23
iaddrbusout[10] = 32'h0000002C;
//             op,  rm, shamt,    rn,  rd
instrbusin[10]={ORR, R23, zeroSham, R25, R28};
daddrbusout[10] = dontcare;
databusin[10] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

//  op,   rd,  rn,  rm
//* SUB,  R29, R20, R22
iaddrbusout[11] = 32'h00000030;
//             op,  rm, shamt,    rn,  rd
instrbusin[11]={SUB, R22, zeroSham, R20, R29};
daddrbusout[11] = dontcare;
databusin[11] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

//  op,   rd,  rn,  aluImm
//* ADDI, R30, R31, #000
iaddrbusout[12] = 32'h00000034;
//            opcode rm/ALUImm    rn        rd...
instrbusin[12]={ADDI, 12'h000, R31, R30};
daddrbusout[12] = dontcare;
databusin[12] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

//* NOP
iaddrbusout[13] = 32'h00000038;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[13] = 32'b00000000000000000000000000000000;
daddrbusout[13] = dontcare;
databusin[13] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = dontcare;

//* NOP
iaddrbusout[14] = 32'h0000003C;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[14] = 32'b00000000000000000000000000000000;
daddrbusout[14] = dontcare;
databusin[14] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

//* NOP
iaddrbusout[15] = 32'h00000040;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[15] = 32'b00000000000000000000000000000000;
daddrbusout[15] = dontcare;
databusin[15] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] = dontcare;

//* NOP
iaddrbusout[16] = 32'h00000044;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[16] = 32'b00000000000000000000000000000000;
daddrbusout[16] = dontcare;
databusin[16] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16] = dontcare;

//* NOP
iaddrbusout[17] = 32'h00000048;
//                   oooooosssssdddddiiiiiiiiiiiiiiii
instrbusin[17] = 32'b00000000000000000000000000000000;
daddrbusout[17] = dontcare;
databusin[17] = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = dontcare;


//this number will be inacurate for a while(the number below)
// (no. instructions) + (no. loads) + 2*(no. stores) = 35 + 2 + 2*7 = 51
ntests = 17;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 32'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 32'bz;

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

for (k=0; k<= 20; k=k+1) begin
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
