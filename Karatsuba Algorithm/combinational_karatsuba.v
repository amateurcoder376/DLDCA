module CLA_4bit(a, b, cin, sum, cout);
    input [3:0] a;
    input [3:0] b;
    input cin;

    wire [3:0] g;
    wire [3:0] p;
    wire [4:0] carry;

    output [3:0] sum;
    output cout;

    assign carry[0] = cin; // connecting cin to the carry of 0
    assign cout = carry[4]; // connecting cout to the final

    generate
    genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            assign g[i] = a[i] & b[i];
            assign p[i] = a[i] ^ b[i];
        end
    endgenerate

    assign carry[1] = g[0] | cin & p[0];
    assign carry[2] = g[0] & p[1] | g[1] | cin & p[0] & p[1];
    assign carry[3] = g[0] & p[1] & p[2] | g[1] & p[2] | g[2] | cin & p[0] & p[1] & p[2];
    assign carry[4] = g[0] & p[1] & p[2] & p[3] | g[1] & p[2] & p[3] | g[2] & p[3] | g[3] | cin & p[0] & p[1] & p[2] & p[3];
    
    generate
    genvar j;
        for (j = 0; j < 4; j = j + 1) begin
            assign sum[j] = p[j] ^ carry[j];
        end
    endgenerate
    
endmodule


module CLA_4bit_P_G(a, b, cin, sum, P, G);
    
    input wire [3:0] a;
    input wire [3:0] b;
    input wire cin;
    
    wire [3:0] g;
    wire [3:0] p;


    output wire [3:0] sum;
    
    wire cout;

    output wire P;
    output wire G;

    
    CLA_4bit cla(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    generate
    genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            assign g[i] = a[i] & b[i];
            assign p[i] = a[i] ^ b[i];
        end
    endgenerate

    assign P = p[0] & p[1] & p[2] & p[3];
    assign G = cout;

endmodule


module half_adder(a, b, S, cout);
input a;
input b;
output S;
output cout;

assign S = a ^ b;

assign cout = a & b;

endmodule




module full_adder(a, b, cin, S, cout);
input a;
input b;
input cin;

output S;
output cout;


assign S = a ^ b ^ cin;

assign cout = a & b | b & cin | cin & a;
    
endmodule



module rca_Nbit #(parameter N = 32) (a, b, cin, out, cout);

input [N-1:0] a;
input [N-1:0] b;
output [N-1:0] out;
wire [N:0] carry;

input cin;


output cout;
wire cout;

assign carry[0] = cin;
assign cout = carry[N];


generate 
    genvar i;
    for(i = 0; i < N; i = i + 1) begin
        full_adder f(a[i], b[i], carry[i], out[i], carry[i+1]);
    end
endgenerate




endmodule

module karatsuba_16(X,Y,Z);

input [15:0] X;
input [15:0] Y;

output [31:0] Z;

wire [7:0] ha, la, hb, lb;

assign ha = X[15:8];
assign la = X[7:0];
assign hb = Y[15:8];
assign lb = Y[7:0];

wire [15:0] z0, z1, z2;

wire [7:0] sum1, sum2;
wire [7:0] overflow1, overflow2;
wire Pout, Gout;

rca_Nbit #(8) rca1(.a(ha), .b(la), .cin(1'b0), .out(sum1), .cout(carry1));
rca_Nbit #(8) rca2(.a(lb), .b(hb), .cin(1'b0), .out(sum2), .cout(carry2));

assign overflow1[0] = carry1;
assign overflow1[1] = carry1;
assign overflow1[2] = carry1;
assign overflow1[3] = carry1;
assign overflow1[4] = carry1;
assign overflow1[5] = carry1;
assign overflow1[6] = carry1;
assign overflow1[7] = carry1;

assign overflow2[1] = carry2;
assign overflow2[0] = carry2;
assign overflow2[2] = carry2;
assign overflow2[3] = carry2;
assign overflow2[4] = carry2;
assign overflow2[5] = carry2;
assign overflow2[6] = carry2;
assign overflow2[7] = carry2;


karatsuba_8 k2a(la, lb, z0);
karatsuba_8 k2c(sum1, sum2, z1);
karatsuba_8 k2b(ha, hb, z2);

wire [31:0] of1, of2, of3;
assign of1[31:16] = 16'b0000000000000000;
assign of1[15:8] = overflow1 & sum2;
assign of1[7:0] = 8'b00000000;

assign of2[31:16] = 16'b0000000000000000;
assign of2[15:8] = overflow2 & sum1;
assign of2[7:0] = 8'b00000000;

assign of3[31:17] = 15'b000000000000000;
assign of3[16:16] = overflow1 & overflow2;
assign of3[15:0] = 16'b0000000000000000;

wire [31:0] overflow_sum, z1_after_overflow, dut1, dut2;
wire t2;

rca_Nbit #(32) rca3(.a(of1), .b(of2), .cin(1'b0), .out(dut1), .cout(t2));
rca_Nbit #(32) rca4(.a(dut1), .b(of3), .cin(1'b0), .out(overflow_sum), .cout(t2));
rca_Nbit #(32) rca6(.a(overflow_sum), .b({16'b0000000000000000, z1}), .cin(1'b0), .out(z1_after_overflow), .cout(t2));



wire [31:0] t0, t1;

rca_Nbit #(32) rca7(.a(z1_after_overflow), .b(~{16'b0000000000000000, z0}), .cin(1'b1), .out(t0), .cout(t2));
rca_Nbit #(32) rca8(.a(t0), .b(~{16'b0000000000000000, z2}), .cin(1'b1), .out(t1), .cout(t2));

wire [31:0] const_term, first_term, second_term;

assign const_term = z0;
assign first_term[31:8] = t1; //the final z1
assign first_term[7:0] = 8'b00000000;
assign second_term[15:0] = 16'b0000000000000000;
assign second_term[31:16] = z2;

wire [31:0] temp;
rca_Nbit #(32) rca9(.a(first_term), .b(const_term), .cin(1'b0), .out(temp), .cout(t2));
rca_Nbit #(32) rca10(.a(temp), .b(second_term), .cin(1'b0), .out(Z), .cout(t2));


endmodule


module karatsuba_8(a,b,out);

input [7:0] a;
input [7:0] b;

output [15:0] out;

wire [3:0] ha, la, hb, lb;

assign ha = a[7:4];
assign la = a[3:0];
assign hb = b[7:4];
assign lb = b[3:0];

wire [7:0] z0, z1, z2;

wire [3:0] sum1, sum2;
wire [3:0] overflow1, overflow2;
wire Pout, Gout;

rca_Nbit #(4) rca1(.a(ha), .b(la), .cin(1'b0), .out(sum1), .cout(carry1));
rca_Nbit #(4) rca2(.a(lb), .b(hb), .cin(1'b0), .out(sum2), .cout(carry2));

assign overflow1[0] = carry1;
assign overflow1[1] = carry1;
assign overflow1[2] = carry1;
assign overflow1[3] = carry1;

assign overflow2[1] = carry2;
assign overflow2[0] = carry2;
assign overflow2[2] = carry2;
assign overflow2[3] = carry2;


karatsuba_4 k2a(la, lb, z0);
karatsuba_4 k2c(sum1, sum2, z1);
karatsuba_4 k2b(ha, hb, z2);

wire [15:0] of1, of2, of3;
assign of1[15:8] = 8'b00000000;
assign of1[7:4] = overflow1 & sum2;
assign of1[3:0] = 4'b0000;

assign of2[15:8] = 8'b00000000;
assign of2[7:4] = overflow2 & sum1;
assign of2[3:0] = 4'b0000;

assign of3[15:9] = 7'b0000000;
assign of3[8:8] = overflow1 & overflow2;
assign of3[7:0] = 8'b00000000;

wire [15:0] overflow_sum, z1_after_overflow, dut1, dut2;
wire t2;

rca_Nbit #(16) rca3(.a(of1), .b(of2), .cin(1'b0), .out(dut1), .cout(t2));
rca_Nbit #(16) rca4(.a(dut1), .b(of3), .cin(1'b0), .out(overflow_sum), .cout(t2));
rca_Nbit #(16) rca6(.a(overflow_sum), .b({8'b00000000, z1}), .cin(1'b0), .out(z1_after_overflow), .cout(t2));



wire [15:0] t0, t1;

rca_Nbit #(16) rca7(.a(z1_after_overflow), .b(~{8'b00000000, z0}), .cin(1'b1), .out(t0), .cout(t2));
rca_Nbit #(16) rca8(.a(t0), .b(~{8'b00000000, z2}), .cin(1'b1), .out(t1), .cout(t2));

wire [15:0] const_term, first_term, second_term;

assign const_term = z0;
assign first_term[15:4] = t1; //the final z1
assign first_term[3:0] = 4'b0000;
assign second_term[7:0] = 8'b00000000;
assign second_term[15:8] = z2;

wire [15:0] temp;
rca_Nbit #(16) rca9(.a(first_term), .b(const_term), .cin(1'b0), .out(temp), .cout(t2));
rca_Nbit #(16) rca10(.a(temp), .b(second_term), .cin(1'b0), .out(out), .cout(t2));


endmodule


module karatsuba_4(a,b,out);

input [3:0] a;
input [3:0] b;

output [7:0] out;

wire [1:0] ha, la, hb, lb;

assign ha = a[3:2];
assign la = a[1:0];
assign hb = b[3:2];
assign lb = b[1:0];

wire [3:0] z0, z1, z2;

wire [1:0] sum1, sum2;
wire [1:0] overflow1, overflow2;
wire Pout, Gout;

rca_Nbit #(2) rca1(.a(ha), .b(la), .cin(1'b0), .out(sum1), .cout(carry1));
rca_Nbit #(2) rca2(.a(lb), .b(hb), .cin(1'b0), .out(sum2), .cout(carry2));

assign overflow1[0] = carry1;
assign overflow1[1] = carry1;
assign overflow2[1] = carry2;
assign overflow2[0] = carry2;


karatsuba_2 k2a(la, lb, z0);
karatsuba_2 k2c(sum1, sum2, z1);
karatsuba_2 k2b(ha, hb, z2);

wire [7:0] of1, of2, of3;
assign of1[7:4] = 4'b00;
assign of1[3:2] = overflow1 & sum2[1:0];
assign of1[1:0] = 2'b00;

assign of2[7:4] = 4'b00;
assign of2[3:2] = overflow2 & sum1[1:0];
assign of2[1:0] = 2'b00;

assign of3[7:5] = 4'b00;
assign of3[4:4] = overflow1 & overflow2;
assign of3[3:0] = 4'b0000;

wire [7:0] overflow_sum, z1_after_overflow, dut1, dut2;
wire t2;

rca_Nbit #(8) rca3(.a(of1), .b(of2), .cin(1'b0), .out(dut1), .cout(t2));
rca_Nbit #(8) rca4(.a(dut1), .b(of3), .cin(1'b0), .out(overflow_sum), .cout(t2));
rca_Nbit #(8) rca6(.a(overflow_sum), .b({4'b0000, z1}), .cin(1'b0), .out(z1_after_overflow), .cout(t2));



wire [7:0] t0, t1;

rca_Nbit #(8) rca7(.a(z1_after_overflow), .b(~{4'b0000, z0}), .cin(1'b1), .out(t0), .cout(t2));
rca_Nbit #(8) rca8(.a(t0), .b(~{4'b0000, z2}), .cin(1'b1), .out(t1), .cout(t2));

wire [7:0] const_term, first_term, second_term;

assign const_term = z0;
assign first_term[7:2] = t1; //the final z1
assign first_term[1:0] = 2'b00;
assign second_term[3:0] = 4'b0000;
assign second_term[7:4] = z2;

wire [7:0] temp;
rca_Nbit #(8) rca9(.a(first_term), .b(const_term), .cin(1'b0), .out(temp), .cout(t2));
rca_Nbit #(8) rca10(.a(temp), .b(second_term), .cin(1'b0), .out(out), .cout(t2));


endmodule


module karatsuba_2(a,b,out);

input [1:0] a;
input [1:0] b;

output [3:0] out;

wire ha, la, hb, lb;

assign ha = a[1];
assign la = a[0];
assign hb = b[1];
assign lb = b[0];

wire [3:0] z0, z1, z2;

wire [3:0] sum1, sum2;
wire overflow1, overflow2, dum1, dum2;
wire Pout, Gout;

CLA_4bit cla2(.a({3'b0,ha}), .b({3'b0,la}), .cin(1'b0), .sum(sum1), .cout(dum1));
CLA_4bit cla1(.a({3'b0,lb}), .b({3'b0,hb}), .cin(1'b0), .sum(sum2), .cout(dum2));

assign overflow1 = sum1[1];
assign overflow2 = sum2[1];

karatsuba_1 k1a(la, lb, z0);
karatsuba_1 k1c(sum1[0], sum2[0], z1);
karatsuba_1 k1b(ha, hb, z2);

wire [3:0] of1,of2, of3;

assign of1[3:1] = overflow1 & sum2[0];
assign of1[0:0] = 0;
assign of2[3:1] = overflow2 & sum1[0];
assign of2[0:0] = 0;
assign of3[3:2] = overflow1 & overflow2;
assign of3[1:0] = 0;

wire [3:0] overflow_sum, z1_after_overflow, dut1, dut2;
wire t2;

CLA_4bit cla3(.a(of1), .b(of2), .cin(1'b0), .sum(dut1), .cout(t2));
CLA_4bit cla4(.a(dut1), .b(of3), .cin(1'b0), .sum(overflow_sum), .cout(t2));
CLA_4bit cla6(.a(overflow_sum), .b(z1), .cin(1'b0), .sum(z1_after_overflow), .cout(t2));



wire [3:0] t0, t1;

CLA_4bit cla7(.a(z1_after_overflow), .b(~z0), .cin(1'b1), .sum(t0), .cout(t2));
CLA_4bit cla8(.a(t0), .b(~z2), .cin(1'b1), .sum(t1), .cout(t2));

wire [3:0] const_term, first_term, second_term;

assign const_term = z0;
assign first_term[3:1] = t1;
assign first_term[0] = 0;
assign second_term[1:0] = 0;
assign second_term[3:2] = z2;

wire [3:0] temp;
CLA_4bit cla9(.a(first_term), .b(const_term), .cin(1'b0), .sum(temp), .cout(t2));
CLA_4bit cla10(.a(temp), .b(second_term), .cin(1'b0), .sum(out), .cout(t2));


endmodule


module karatsuba_1(a,b,out);

input [0:0] a,b;
output [3:0] out;

assign out = a & b;


endmodule