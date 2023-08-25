`timescale 1ns / 1ps


module Butterfly(
    
    x0_real,
    x0_img,
    x1_real,
    x1_img,
    y0_real,
    y0_img,
    y1_real,
    y1_img
    
);
    
    parameter WIDTH = 16;
    parameter RH    = 0;   //Round Half Up
    
    input signed [WIDTH-1 : 0] x0_real , x0_img;
    input signed [WIDTH-1 : 0] x1_real , x1_img;
    input signed [WIDTH-1 : 0] y0_real , y0_img;
    input signed [WIDTH-1 : 0] y1_real , y1_img;
    
    wire signed [WIDTH : 0] add_real , add_img;  //Extra bit in case of overflow
    wire signed [WIDTH : 0] diff_real , diff_img;
    
    //X0 = x0 + x1
    //X1 = x0 - x1
    //Add / Difference
    assign add_real  = x0_real + x1_real;
    assign add_img   = x0_img  + x1_img;
    assign diff_real = x0_real - x1_real;
    assign diff_img  = x0_img  - x1_img;
    
    //Right shift operation is done to prevent overflow and to maintain appropriate scaling.
    //The rounding value (RH) is added before the right-shift to ensure correct rounding behavior.
    assign y0_real = (add_real  + RH) >>> 1;
    assign y0_img  = (add_img   + RH) >>> 1;
    assign y1_real = (diff_real + RH) >>> 1;
    assign y1_img  = (diff_img  + RH) >>> 1;
    
endmodule
