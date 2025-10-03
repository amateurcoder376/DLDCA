`timescale 1ns/1ps

module tb_combinational_karatsuba;

parameter N = 16;
parameter N2 = 32;
reg [N-1:0] a;
reg [N-1:0] b;

wire [N2-1:0] out;
wire overflow;


reg [N-1:0] temp1;
reg [N-1:0] temp2;

reg [N2-1:0] expected_out;

always @(temp1 or temp2) begin
    expected_out = temp1 * temp2;
end

// declare your signals as reg or wire

initial begin

// write the stimuli conditions
temp1 = $random; temp2 = $random; #5
    a = temp1; b = temp2;  #10

$monitor("a = %d, b = %d, out = %d, expected_out = %d", a, b, out, expected_out);

    temp1 = $random; temp2 = $random; 
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random; 
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2;  #10
    // a = 8967296; b = 890;  #10

$finish;

end

karatsuba_16 dut (.X(a), .Y(b), .Z(out));

initial begin
    $dumpfile("combinational_karatsuba.vcd");
    $dumpvars(0, tb_combinational_karatsuba);
end

endmodule

