//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      (C) Copyright Optimum Application-Specific Integrated System Laboratory
//      All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : PATTERN_IP.v
//   	Module Name : PATTERN_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE
    `define CYCLE_TIME 60.0
`endif

module PATTERN_IP #(parameter IP_WIDTH = 6) (
    // Output signals
    IN_1, IN_2,
    // Input signals
    OUT_INV
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg [IP_WIDTH-1:0] IN_1, IN_2;
input  [IP_WIDTH-1:0] OUT_INV;

reg [IP_WIDTH-1:0] golden_out;

integer pat_num, pat_count;
integer input_file, output_file;
//================================================================
// clock
//================================================================
reg clk;
real	CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;


initial begin
    
    IN_1 = 'dx;
    IN_2 = 'dx;
    repeat(1) @(negedge clk);

    case (IP_WIDTH)
        5: begin
            input_file = $fopen("./input_ip_5.txt", "r");
            output_file = $fopen("./output_ip_5.txt", "r");
        end
        6: begin
            input_file = $fopen("./input_ip_6.txt", "r");
            output_file = $fopen("./output_ip_6.txt", "r");
        end
        7: begin
            input_file = $fopen("./input_ip_7.txt", "r");
            output_file = $fopen("./output_ip_7.txt", "r");
        end
        default: begin
            $display("WIDTH wrong...");
            $finish;
        end
    endcase

    $fscanf(input_file, "%d\n", pat_num);
    $fscanf(output_file, "%d\n", pat_num);

	$display("*****************************************");
	$display("        tatal input pattern : %d         ", pat_num);
	$display("*****************************************");

    for (pat_count=0;pat_count<pat_num;pat_count=pat_count+1) begin
        $fscanf(input_file, "%d ", IN_1);
        $fscanf(input_file, "%d\n", IN_2);
        $fscanf(output_file, "%d\n", golden_out);
        repeat(1) @(negedge clk);
        check_ans_task;
        repeat(3) @(negedge clk);
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles:%3d\033[m", pat_count,0);
    end
    display_pass;

end
// =========================
// task
// =========================
task check_ans_task;
begin
    if (OUT_INV !== golden_out) begin
        $display ("*********************************************************************");
        $display ("*           answer should be : %d , your answer is : %d             *",golden_out,OUT_INV);
        $display ("*                     IN_1 : %d , IN_2 : %d                         *",IN_1,IN_2);
        $display ("*********************************************************************");  
        $finish; 	
    end
end
endtask

task display_pass;
begin
        $display ("*********************************************************************");
        $display ("*                      Congratulations !!                           *");
        $display ("*                   You pass all pattern !!!                        *");
        // $display ("*                       total cycle : %d                            *",total_cycle);
        $display ("*********************************************************************");
        $finish;
end
endtask

endmodule