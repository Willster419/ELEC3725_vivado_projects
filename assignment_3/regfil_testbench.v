//-----------Declaring time units used in the test module-----------------//
`timescale 1ns/10ps
module regfil_testbench();

//------------------ Ports Declaration-----------------//
reg [31:0] Aselect, Bselect, Dselect;
reg [31:0] dbus;
wire [31:0] abus,bbus;
reg clk;
reg [31:0] dontcare, ref_abus[0:31], ref_bbus[0:31], stm_dbus[0:31], stm_asel[0:31], stm_bsel[0:31], stm_dsel[0:31]; 
integer error,  i, k, ntests;


//----------- Design under test declaration ----------//

regfile dut(.Aselect(Aselect), .Bselect(Bselect), .Dselect(Dselect), .abus(abus), .bbus(bbus), .dbus(dbus), .clk(clk));

   
     				 	 
  //---------------EXPECTED VALUES------------------//	          	          //----------------------INPUTS TO REGISTER-------------------//
 		       	

initial begin

stm_dsel[0] = 32'h02000000; stm_dbus[0] = 32'h76543210;  
ref_abus[0] = 32'h76543210;  ref_bbus[0] = 32'h00000000;  stm_asel[0] = 32'h02000000; stm_bsel[0] = 32'h00000001;  

stm_dsel[1] = 32'h00001000; stm_dbus[1] = 32'hF4820000;
ref_abus[1] = 32'hF4820000;  ref_bbus[1] = 32'h76543210;  stm_asel[1] = 32'h00001000; stm_bsel[1] = 32'h02000000;

stm_dsel[2] = 32'h00000001; stm_dbus[2] = 32'h00001111;  
ref_abus[2] = 32'h00000000;  ref_bbus[2] = 32'h76543210;  stm_asel[2] = 32'h00000001; stm_bsel[2] = 32'h02000000;

stm_dsel[3] = 32'h00000040; stm_dbus[3] = 32'h80876263;
ref_abus[3] = 32'hF4820000;  ref_bbus[3] = 32'h80876263;  stm_asel[3] = 32'h00001000; stm_bsel[3] = 32'h00000040;

stm_dsel[4] = 32'h00040000; stm_dbus[4] = 32'h10101010;
ref_abus[4] = 32'h10101010;  ref_bbus[4] = 32'h10101010;  stm_asel[4] = 32'h00040000; stm_bsel[4] = 32'h00040000;

stm_dsel[5] = 32'h80000000; stm_dbus[5] = 32'h33333333;
ref_abus[5] = 32'hF4820000; ref_bbus[5] = 32'h76543210;   stm_asel[5] = 32'h00001000; stm_bsel[5] = 32'h02000000;

stm_dsel[6] = 32'h00000800; stm_dbus[6] = 32'h000062DE;
ref_abus[6] = 32'h000062DE; ref_bbus[6] = 32'h33333333;	  stm_asel[6] = 32'h00000800; stm_bsel[6] = 32'h80000000;
  
stm_dsel[7] = 32'h00800000; stm_dbus[7] = 32'h83848586;  
ref_abus[7] = 32'h80876263; ref_bbus[7] = 32'h00000000;	  stm_asel[7] = 32'h00000040; stm_bsel[7] = 32'h00000001;

stm_dsel[8] = 32'h00000010; stm_dbus[8] = 32'h80000000;  
ref_abus[8] = 32'h00000000; ref_bbus[8] = 32'h83848586;	  stm_asel[8] = 32'h00000001; stm_bsel[8] = 32'h00800000;

stm_dsel[9] = 32'h04000000; stm_dbus[9] = 32'hFFFFCCCC; 
ref_abus[9] = 32'hFFFFCCCC; ref_bbus[9] = 32'h80000000;	  stm_asel[9] = 32'h04000000; stm_bsel[9] = 32'h00000010;

stm_dsel[10] = 32'h00004000; stm_dbus[10] = 32'hF393F393; 
ref_abus[10] = 32'h76543210; ref_bbus[10] = 32'h10101010;   stm_asel[10] = 32'h02000000; stm_bsel[10] = 32'h00040000;

stm_dsel[11] = 32'h00000020; stm_dbus[11] = 32'h0FEFEFEF;
ref_abus[11] = 32'h0FEFEFEF; ref_bbus[11] = 32'hF393F393;   stm_asel[11] = 32'h00000020; stm_bsel[11] = 32'h00004000;
 
stm_dsel[12] = 32'h20000000; stm_dbus[12] = 32'h09876543;  
ref_abus[12] = 32'h33333333; ref_bbus[12] = 32'hFFFFCCCC;   stm_asel[12] = 32'h80000000; stm_bsel[12] = 32'h04000000;

stm_dsel[13] = 32'h01000000; stm_dbus[13] = 32'h01234567;
ref_abus[13] = 32'h000062DE; ref_bbus[13] = 32'h0FEFEFEF;   stm_asel[13] = 32'h00000800; stm_bsel[13] = 32'h00000020;

stm_dsel[14] = 32'h00200000; stm_dbus[14] = 32'h00000008;
ref_abus[14] = 32'h09876543; ref_bbus[14] = 32'h01234567;   stm_asel[14] = 32'h20000000; stm_bsel[14] = 32'h01000000;

stm_dsel[15] = 32'h00000100; stm_dbus[15] = 32'hFFFF0000;
ref_abus[15] = 32'h80876263; ref_bbus[15] = 32'h00000008;   stm_asel[15] = 32'h00000040; stm_bsel[15] = 32'h00200000;

stm_dsel[16] = 32'h00000008; stm_dbus[16] = 32'hFFFFFFFF;
ref_abus[16] = 32'hFFFFFFFF; ref_bbus[16] = 32'hFFFF0000;   stm_asel[16] = 32'h00000008; stm_bsel[16] = 32'h00000100;

stm_dsel[17] = 32'h00010000; stm_dbus[17] = 32'h0000FEAB;
ref_abus[17] = 32'h83848586; ref_bbus[17] = 32'hFFFFFFFF;   stm_asel[17] = 32'h00800000; stm_bsel[17] = 32'h00000008;

stm_dsel[18] = 32'h10000000; stm_dbus[18] = 32'h50600000;
ref_abus[18] = 32'h0000FEAB; ref_bbus[18] = 32'h50600000;   stm_asel[18] = 32'h00010000; stm_bsel[18] = 32'h10000000;

stm_dsel[19] = 32'h00020000; stm_dbus[19] = 32'h88887777;
ref_abus[19] = 32'h88887777; ref_bbus[19] = 32'h00000000;   stm_asel[19] = 32'h00020000; stm_bsel[19] = 32'h00000001;

stm_dsel[20] = 32'h00080000; stm_dbus[20] = 32'hF0E0D0C0;
ref_abus[20] = 32'h00000000; ref_bbus[20] = 32'h00000000;   stm_asel[20] = 32'h00000001; stm_bsel[20] = 32'h00000001;

stm_dsel[21] = 32'h00008000; stm_dbus[21] = 32'hAAAAAAAA;
ref_abus[21] = 32'h88887777; ref_bbus[21] = 32'hF0E0D0C0;   stm_asel[21] = 32'h00020000; stm_bsel[21] = 32'h00080000;

stm_dsel[22] = 32'h40000000; stm_dbus[22] = 32'hFDFEFFFF;
ref_abus[22] = 32'hFDFEFFFF; ref_bbus[22] = 32'hAAAAAAAA;   stm_asel[22] = 32'h40000000; stm_bsel[22] = 32'h00008000;

stm_dsel[23] = 32'h00100000; stm_dbus[23] = 32'hCCCCFFFF;
ref_abus[23] = 32'h00000000; ref_bbus[23] = 32'h00000000;   stm_asel[23] = 32'h00000001; stm_bsel[23] = 32'h00000001;

stm_dsel[24] = 32'h00000002; stm_dbus[24] = 32'hF0F0F0F0;
ref_abus[24] = 32'hF0F0F0F0; ref_bbus[24] = 32'hCCCCFFFF;   stm_asel[24] = 32'h00000002; stm_bsel[24] = 32'h00100000;

stm_dsel[25] = 32'h00000400; stm_dbus[25] = 32'hAAAAFFFF;
ref_abus[25] = 32'hCCCCFFFF; ref_bbus[25] = 32'hF0F0F0F0;   stm_asel[25] = 32'h00100000; stm_bsel[25] = 32'h00000002;

stm_dsel[26] = 32'h08000000; stm_dbus[26] = 32'hDDDDECFA;
ref_abus[26] = 32'hDDDDECFA; ref_bbus[26] = 32'hAAAAFFFF;   stm_asel[26] = 32'h08000000; stm_bsel[26] = 32'h00000400;

stm_dsel[27] = 32'h00000004; stm_dbus[27] = 32'h66666666;  
ref_abus[27] = 32'hFDFEFFFF; ref_bbus[27] = 32'hF0F0F0F0;   stm_asel[27] = 32'h40000000; stm_bsel[27] = 32'h00000002;
  
stm_dsel[28] = 32'h00000080; stm_dbus[28] = 32'h0999FFFF;  
ref_abus[28] = 32'h66666666; ref_bbus[28] = 32'hDDDDECFA;   stm_asel[28] = 32'h00000004; stm_bsel[28] = 32'h08000000;

stm_dsel[29] = 32'h00000200; stm_dbus[29] = 32'hEEEABDCE;
ref_abus[29] = 32'hF393F393; ref_bbus[29] = 32'hFFFFFFFF;   stm_asel[29] = 32'h00004000; stm_bsel[29] = 32'h00000008;

stm_dsel[30] = 32'h00002000; stm_dbus[30] = 32'h80808080;
ref_abus[30] = 32'h0999FFFF; ref_bbus[30] = 32'hEEEABDCE;   stm_asel[30] = 32'h00000080; stm_bsel[30] = 32'h00000200;

stm_dsel[31] = 32'h00400000; stm_dbus[31] = 32'hABCDEF90;
ref_abus[31] = 32'hABCDEF90; ref_bbus[31] = 32'h80808080;   stm_asel[31] = 32'h00400000; stm_bsel[31] = 32'h00002000;

dontcare = 32'hx;
ntests = 32;
 

$timeformat(-9,1,"ns",12); 


 
end


initial begin
    error = 0;
    clk = 0;
	 #25 ;
	 
    for (k=0; k<= 31; k=k+1)
    begin
     
     $display("ASSIGNING VALUE TO THE DBUS AND SELECTING DSEL REGISTER TO WRITE VALUE OF DBUS");
     
     clk = 1;
     Dselect = stm_dsel[k];
     dbus = stm_dbus[k];
     $display ("Time=%t \n clk =%b \n Dselect=%b \n dbus=%b \n",$realtime, clk, Dselect, dbus);
     
     #25

     $display("TEST READ OPERATION");

     clk = 0;  
     Aselect = stm_asel[k]; Bselect = stm_bsel[k];
     $display ("Time=%t \n clk =%b \n Aselect=%b \n Bselect=%b \n",$realtime, clk, Aselect, Bselect);
     
     #20
          	
     $display ("Time=%t \n clk =%b \n your abus=%b \n correct abus=%b \n your bbus=%b \n correct bbus=%b \n  ",$realtime, clk, abus, ref_abus[k], bbus, ref_bbus[k]);
 
 
     if  ( ( (ref_bbus[k] !== bbus) && (ref_bbus[k] !== dontcare) ) || ( (ref_abus[k] !== abus) && (ref_abus[k+1] !== dontcare) ) )
 
     begin
       $display ("-------------ERROR. A Mismatch Has Occured-----------");
       error = error + 1;
     end
     $display("END TEST READ OPERATION");
	  
	  #5 ;
  
 end
 
   if ( error !== 0)
    begin 
       $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
       $display(" No. Of Errors = %d", error);
    end

  if ( error == 0) 
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

    
end
         
        
endmodule