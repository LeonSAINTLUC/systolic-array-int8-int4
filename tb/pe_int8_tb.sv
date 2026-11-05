`timescale 1ns / 1ps

module pe_int8_tb  #(
    parameter int DATA_W = 8,
    parameter int ACC_W  = 32
);

// Internal net declaration
logic clock_s;
logic signed [DATA_W-1:0] ai_s;
logic signed [DATA_W-1:0] bi_s;
logic signed [DATA_W-1:0] ao_s;
logic signed [DATA_W-1:0] bo_s;
logic signed [ACC_W-1:0] acc_s;

localparam logic signed [DATA_W-1:0] MARKER = {1'b1, {(DATA_W-1){1'b0}}};

//DUT : component instanciation
pe_int8 #(.DATA_W(DATA_W), .ACC_W(ACC_W)) DUT (
.clock_i(clock_s),
.a_i(ai_s),
.b_i(bi_s),
.a_o(ao_s),
.b_o(bo_s),
.acc_o(acc_s)
);

//clock generation
initial begin
    clock_s = 1'b0;
    forever #5 clock_s = ~clock_s;
end

// variables du modèle de référence
longint exp_acc = 0;  // expected accumulation
longint exp_out = 0;  // expected output
bit     started = 0;  // 1 after the first marker
int     errors  = 0;  // number of errors

task automatic step(input signed [DATA_W-1:0] a, input signed [DATA_W-1:0] b);
    // 1. Apply inputs before the rising edge of the clock
    @(negedge clock_s);
    ai_s = a;
    bi_s = b;

    // 2. Wait for the rising edge of the clock and a small delay to let outputs stabilize
    @(posedge clock_s);
    #1;

    // 3. Update the expected output based on the inputs and the previous state
    if (a == MARKER) begin
        exp_out = exp_acc;
        exp_acc = 0;
        started = 1;
    end else begin
        exp_acc += a * b;
    end

    // 4. Check the outputs against the expected values
    if (ao_s !== a) begin
        $display("ERROR t=%0t : a_o=%0d, expected %0d", $time, ao_s, a);
        errors++;
    end
    if (bo_s !== b) begin
        $display("ERROR t=%0t : b_o=%0d, expected %0d", $time, bo_s, b);
        errors++;
    end
    if (started && longint'(acc_s) !== exp_out) begin
        $display("ERROR t=%0t : acc_o=%0d, expected %0d", $time, acc_s, exp_out);
        errors++;
    end
endtask


// stimuli
initial begin

    $dumpfile("pe_int8_tb.vcd");
    $dumpvars(0, pe_int8_tb);

    // Test 1: reset
    step(90, -60);
    step(MARKER, 50);
    step(50, 70);
    step(MARKER, -40); 

    // Test 2: limit value

    step(127, 127);step(MARKER, 0);

    step(-127, 127);step(MARKER, 0);

    step(127, -127);step(MARKER, 0);

    step(-127, -127);step(MARKER, 0);step(MARKER, 0);


    //Test 3: accumulation test
    for(int k=0;k<576;k++)  begin         // K=576
        step(127, 127);
    end //result should be 127*127*576 = 9 290 304
        step(MARKER, 0);

    //Recap
    if (errors == 0) $display("\n--------------\n    PASS\n--------------\n");
   else             $display("\n------------------------\n    FAIL : %0d error(s)\n------------------------\n", errors);
   $finish;
end

endmodule : pe_int8_tb
