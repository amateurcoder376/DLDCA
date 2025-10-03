module tb();

reg [31:0] a;
reg [31:0] b;
wire [31:0] out;
wire cout;
reg cin;

rca_Nbit #(32) h(a, b, cin, out, cout);

initial begin
    $monitor("a = %d, b = %d, out = %d, cin = %b, cout = %b", a, b, out, cin, cout);
    a = 3; b = 4; cin = 0; #10
    a = 11; b = 5; cin = 0; #10
    $finish;
end
initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0,tb);
end

endmodule
