//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_IP.v
//   Module Name : RSA_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module RSA_IP #(parameter WIDTH = 3) (
    // Input signals
    IN_P, IN_Q, IN_E,
    // Output signals
    OUT_N, OUT_D
);

// ===============================================================
// Declaration
// ===============================================================
input  [WIDTH-1:0]   IN_P, IN_Q;
input  [WIDTH*2-1:0] IN_E;
output [WIDTH*2-1:0] OUT_N, OUT_D;



// ===============================================================
// Soft IP DESIGN
// ===============================================================



genvar i;
generate
    assign OUT_N = IN_P * IN_Q;
    wire [WIDTH*2-1:0] old_r_ori , r_ori;

    assign old_r_ori = (IN_P - 1)*(IN_Q - 1);
    assign r_ori = IN_E;


    for (i=0;i<(WIDTH*2);i=i+1) begin : loop
        
        wire [WIDTH*2-1:0] quotient;
        wire [WIDTH*2-1:0] old_r;
        wire [WIDTH*2-1:0] rem;
        wire signed [WIDTH*2:0] old_s , s;

        if (i==0)begin
            assign old_r = old_r_ori;
            assign rem = r_ori;
            assign old_s = 0;
            assign s = 1;
            assign quotient = old_r_ori/r_ori;
        end
        else begin
            assign old_r = loop[i-1].rem;
            assign rem = loop[i-1].old_r - (loop[i-1].quotient * loop[i-1].rem);
            assign old_s = (loop[i-1].rem == 0)?loop[i-1].old_s:loop[i-1].s;
            assign s = loop[i-1].old_s - (loop[i-1].quotient * loop[i-1].s);
            assign quotient = (rem==0)?0:old_r/rem;
        end     



    end

    assign OUT_D = (loop[(WIDTH*2)-1].old_s>0)? loop[(WIDTH*2)-1].old_s : loop[(WIDTH*2)-1].old_s + old_r_ori;

endgenerate


endmodule