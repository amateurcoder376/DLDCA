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


module lookahead_carry_unit_16_bit(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);

    input P0, G0, P1, G1, P2, G2, P3, G3, cin;
    output C4, C8, C12, C16, GF, PF;
    
    assign C4 = G0 | P0 & cin;
    assign C8 = G1 | P1 & C4;
    assign C12 = G2 | P2 & C8;
    assign C16 = G3 | P3 & C12;

    assign PF = P0 & P1 & P2 & P3;
    assign GF = C16;




endmodule

module CLA_16bit(a, b, cin, sum, cout, Pout, Gout);
    
    input [15:0] a;
    input [15:0] b;
    input cin;

    wire P0, G0, P1, G1, P2, G2, P3, G3;
    wire C4, C8, C12, C16;

    output cout;
    output Pout;
    output Gout;    
    output wire [15:0] sum;

    assign cout = C16;



    CLA_4bit_P_G m1(a[3:0],b[3:0], cin, sum[3:0], P0, G0);

    lookahead_carry_unit_16_bit l1(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);


    CLA_4bit_P_G m2(a[7:4],b[7:4], C4, sum[7:4], P1, G1);

    lookahead_carry_unit_16_bit l2(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);


    CLA_4bit_P_G m3(a[11:8],b[11:8], C8, sum[11:8], P2, G2);

    lookahead_carry_unit_16_bit l3(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);


    CLA_4bit_P_G m4(a[15:12],b[15:12], C12, sum[15:12], P3, G3);

    lookahead_carry_unit_16_bit l4(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);

    assign Pout = PF;
    assign Gout = GF;


endmodule


module CLA_32bit(a, b, cin, sum, cout, Pout, Gout);

input [31:0] a;
input [31:0] b;
input cin;

wire temp1, temp2;
wire C16, C32;
wire P0, P1, G0, G1;

output [31:0] sum;
output cout;
output Pout;
output Gout;

CLA_16bit a1(.a(a[15:0]), .b(b[15:0]), .cin(cin), .sum(sum[15:0]), .cout(temp1), .Pout(P0), .Gout(G0));
lookahead_carry_unit_32_bit l5(P0, G0, P1, G1, cin, C16, C32, Gout, Pout);

CLA_16bit a2(.a(a[31:16]), .b(b[31:16]), .cin(C16), .sum(sum[31:16]), .cout(temp2), .Pout(P1), .Gout(G1));
lookahead_carry_unit_32_bit l6(P0, G0, P1, G1, cin, C16, C32, Gout, Pout);

assign cout = C32;


endmodule

module lookahead_carry_unit_32_bit (P0, G0, P1, G1, cin, C16, C32, GF, PF);

input P0, G0, P1, G1, cin;

output C16, C32, GF, PF;

assign C16 = G0 | P0 & cin;
assign C32 = G1 | P1 & C16;

assign PF = P0 & P1;
assign GF = C32;

endmodule

