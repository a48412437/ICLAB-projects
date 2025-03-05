//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      (C) Copyright NCTU OASIS Lab      
//            All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2022 ICLAB fall Course
//   Lab05			: SRAM, Matrix Multiplication with Systolic Array
//   Author         : Jia Fu-Tsao (jiafutsao.ee10g@nctu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//   Release version : v1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
	`timescale 1ns/10ps
	`include "MMT.v"
	`define CYCLE_TIME 20.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "MMT_SYN.v"
	`define CYCLE_TIME 20.0
`endif

module PATTERN(
// output signals
    clk,
    rst_n,
    in_valid,
	in_valid2,
    matrix,
	matrix_size,
    matrix_idx,
    mode,
// input signals
    out_valid,
    out_value
);
//================================================================
//   parameters & integers
//================================================================
integer SEED = 128;
integer pat_num;
integer cycle, total_cycle, pat_cycle;
integer input_file, output_file;
integer pat_count,pat_no;
integer id;
integer i,j;
integer out_cycle;
integer in_matrix_no, total_matrix_cycle, in_matrix_cycle;
integer delay_in2,delay_in1;
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg 		  clk, rst_n, in_valid, in_valid2;
output reg [7:0] matrix;
output reg [1:0]  matrix_size,mode;
output reg [4:0]  matrix_idx;

input 				out_valid;
input signed [49:0] out_value;
//================================================================
//    wires % registers
//================================================================
reg signed [49:0] golden_out;
//================================================================
//    clock
//================================================================
always #(`CYCLE_TIME/2.0) clk = ~clk;
initial clk = 0;
//================================================================
//    initial
//================================================================
initial begin
	rst_n = 1'b1;
	in_valid = 1'b0;
	in_valid2 = 1'b0;
    matrix = 8'dx;
    matrix_size = 2'dx;
    mode = 2'dx;
    matrix_idx = 5'dx;

    total_cycle = 0;

	force clk = 0;
	reset_task;

	input_file = $fopen("./input.txt", "r");
    output_file = $fopen("./output.txt", "r");

	$fscanf(input_file, "%d\n", pat_num);
    $fscanf(output_file, "%d\n", pat_num);
	$display("*****************************************");
	$display("        tatal input pattern : %d         ", pat_num);
	$display("*****************************************");
    

	for (pat_count=0;pat_count<pat_num;pat_count=pat_count+1) begin
		input_matrix_task;
		pat_cycle = 0;
        for (id=0;id<10;id=id+1) begin
            input_id_task;
            get_output_task;
            cycle = 0;
            wait_out_valid_task;
            pat_cycle = pat_cycle + cycle;
            check_ans_task;
        end
		
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", pat_count ,pat_cycle);
		total_cycle = total_cycle + pat_cycle;
	end
end

// =========================
// task
// =========================

task check_ans_task;
begin
	out_cycle = 0;
	while (out_valid === 1'b1) begin
		if (out_cycle == 1) begin
            $display ("*********************************************************************");
            $display ("*     Out_valid should maintain corresponding cycle ,1 cycles      *");
            $display ("*********************************************************************"); 
            $finish; 
		end

		if (out_value !== golden_out) begin
			$display ("*********************************************************************");
			$display ("*           answer should be : %h , your answer is : %h             *",golden_out,out_value);
			$display ("*********************************************************************");  
			@(negedge clk);
			$finish; 	
		end
		out_cycle = out_cycle + 1;
		@(negedge clk);

	end
end
endtask



task get_output_task;
begin
    $fscanf(output_file, "%b\n", golden_out);
end
endtask

task input_id_task;
begin
    if (id == 0) delay_in2 = $urandom(SEED)% 3 + 1;
    else delay_in2 = $urandom(SEED)% 5 + 1;

    repeat(delay_in2) @(negedge clk);
    $fscanf(input_file,"%b ",mode);
    for (i=0;i<3;i=i+1) begin
        if (i != 0) mode = 2'dx;
        in_valid2 = 1'b1;
        $fscanf(input_file,"%b ",matrix_idx);
        @(negedge clk);
    end
    in_valid2 = 1'b0;
    $fscanf(input_file, "\n");
    matrix_idx = 5'dx;
end
endtask

task input_matrix_task;
begin
    delay_in1 = $urandom(SEED)% 10 + 1;
    repeat(3) @(negedge clk);
    // read patno.
	$fscanf(input_file, "%d\n",pat_no);
    $fscanf(output_file, "%d\n", pat_no);
    // read mat_size
    $fscanf(input_file, "%d\n", matrix_size);
    case (matrix_size)
        0: total_matrix_cycle = 4;
        1: total_matrix_cycle = 16;
        2: total_matrix_cycle = 64;
        3: total_matrix_cycle = 256;
        default: total_matrix_cycle = 0;
    endcase
    for (in_matrix_no=0;in_matrix_no<32;in_matrix_no=in_matrix_no+1) begin
        in_valid = 1'b1;
        if (in_matrix_no != 0) matrix_size = 'dx;
        for (in_matrix_cycle=0;in_matrix_cycle<total_matrix_cycle;in_matrix_cycle=in_matrix_cycle+1) begin
            if (in_matrix_cycle != 0) matrix_size = 'dx;
            $fscanf(input_file, "%b ", matrix);
            @(negedge clk);
        end
        $fscanf(input_file, "\n");
    end
    in_valid = 1'b0;
    matrix = 8'dx;
end
endtask


task wait_out_valid_task; begin
	
	while(out_valid !== 1) begin
		cycle = cycle + 1 ;
		if(cycle == 10001) begin
            $display ("*********************************************************************");
            $display ("*                Latency is limited in 10000 cycles                   *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish; 
		end
		@(negedge clk);
	end


end endtask

task display_pass;
begin
        $display ("*********************************************************************");
        $display ("*                      Congratulations !!                           *");
        $display ("*                   You pass all pattern !!!                        *");
        $display ("*                       total cycle : %d                            *",total_cycle);
        $display ("*********************************************************************");
end
endtask



task reset_task ; begin
	
	#(20);
	rst_n = 1'b0;
	#(20);

	if (out_value!==0 || out_valid!==0) begin
        $display ("*********************************************************************");
        $display ("*               Output signal should be 0 after reset               *");
        $display ("*********************************************************************");
        #(200);
        $finish;
    end
	#(20); rst_n = 1'b1;
	#(10); release clk;

end endtask
endmodule