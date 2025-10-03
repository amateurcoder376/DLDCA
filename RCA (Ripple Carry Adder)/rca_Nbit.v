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





