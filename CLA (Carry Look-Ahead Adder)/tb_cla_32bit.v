`timescale 1ns/1ps

module tb_cla_32bit;

parameter N = 32;     /*Change this to 16 if you want to test CLA 16-bit*/

// declare your signals as reg or wire
reg [N-1:0] a;
reg [N-1:0] b;
wire [N-1:0] sum;
wire cout;
wire Pout;
wire Gout;
reg [0:0] cin;

reg [30:0] temp1; // for avoiding overflow
reg [30:0] temp2;


reg [N-1:0] expected_out;

always @(temp1 or temp2) begin
    expected_out = temp1 + temp2;
end


CLA_32bit hi(.a(a), .b(b), .cin(1'b0), .sum(sum), .cout(cout), .Pout(Pout), .Gout(Gout));


initial begin
    temp1 = $random; temp2 = $random; 
    a = temp1; b = temp2; cin = 0; #10
    $monitor("a = %d, b = %d, out = %d, expected out = %d, overflow = %b", a, b, sum, expected_out, cout);

    temp1 = $random; temp2 = $random; 
    a = temp1; b = temp2; cin = 0; #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2; cin = 0; #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2; cin = 0; #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2; cin = 0; #10
    
    temp1 = $random; temp2 = $random;
    a = temp1; b = temp2; cin = 0; #10
    $finish;

end

initial begin
    $dumpfile("cla_32bit.vcd");
    $dumpvars(0, tb_cla_32bit);
end

endmodule
