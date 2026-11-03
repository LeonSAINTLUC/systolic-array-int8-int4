`timescale 1ns / 1ps

module pe_int8 #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32
)(
    input  logic clock_i,
    input  logic signed [DATA_W-1:0] a_i,
    input  logic signed [DATA_W-1:0] b_i,
    output logic signed [DATA_W-1:0] a_o,
    output logic signed [DATA_W-1:0] b_o,
    output logic signed [ACC_W-1:0]  acc_o
);

logic signed [ACC_W-1:0] acc_s;
localparam logic signed [DATA_W-1:0] MARKER = {1'b1, {(DATA_W-1){1'b0}}};

always_ff @(posedge clock_i) begin
    if (a_i==MARKER) begin
        acc_o <= acc_s;
        acc_s <= '0;
    end else begin
        acc_s <= acc_s + a_i * b_i;
    end
    a_o <= a_i;
    b_o <= b_i;
end

endmodule : pe_int8