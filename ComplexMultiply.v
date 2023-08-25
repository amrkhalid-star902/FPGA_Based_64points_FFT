`timescale 1ns / 1ps



module ComplexMultiply(
    
    In1_real,
    In1_img,
    In2_real,
    In2_img,
    Out_real,
    Out_img
    
);

    parameter WIDTH = 16;
    
    input  signed [WIDTH-1 : 0] In1_real , In1_img;
    input  signed [WIDTH-1 : 0] In2_real , In2_img;
    output signed [WIDTH-1 : 0] Out_real , Out_img;
    
    //Temporary variables to hold intermediate variables
    
    wire signed [2*WIDTH-1 : 0] temp1 , temp2 , temp3 , temp4;
    wire signed [WIDTH-1 : 0]   temp_scaled1 , temp_scaled2 , temp_scaled3 , temp_scaled4;
    
    // Signed Multiplication
    
    assign temp1 = In1_real * In2_real;
    assign temp2 = In1_real * In2_img;
    assign temp3 = In1_img  * In2_real;
    assign temp4 = In1_img  * In2_img;
    
    // Scaling
    
    assign temp_scaled1 = temp1 >>> (WIDTH - 1);
    assign temp_scaled2 = temp2 >>> (WIDTH - 1); 
    assign temp_scaled3 = temp3 >>> (WIDTH - 1);
    assign temp_scaled4 = temp4 >>> (WIDTH - 1);
    
    //Final values
    assign Out_real = temp_scaled1 - temp_scaled4;    //minus sign because j^2 = -1
    assign Out_img  = temp_scaled2 + temp_scaled3;
    
endmodule
