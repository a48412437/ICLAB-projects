//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : PATTERN.v
//   	Module Name : PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL_TOP
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE_TOP
    `define CYCLE_TIME 60.0
`endif

module PATTERN (
    // Output signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // Input signals
    out_valid, out_Rx, out_Ry
);

//================================================================
//   parameters & integers
//================================================================
integer SEED = 128;
integer pat_num;
integer cycle, total_cycle;
integer input_file, output_file;
integer pat_count,pat_no;
integer i,j;
integer out_cycle;

integer delay_cycle;


// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk, rst_n, in_valid;
output reg [5:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
input out_valid;
input [5:0] out_Rx, out_Ry;

//================================================================
//    wires % registers
//================================================================
reg [5:0] golden_x, golden_y;
reg [5:0] in_b;
reg [5:0] prime_tmp,qx,qy,px,py,a_tmp;
//================================================================
//    clock
//================================================================
always #(`CYCLE_TIME/2.0) clk = ~clk;
initial clk = 0;

initial begin
	rst_n = 1'b1;
	in_valid = 1'b0;

    in_Px = 6'dx;
    in_Py = 6'dx;
    in_Qx = 6'dx;
    in_Qy = 6'dx;
    in_prime = 6'dx;
    in_a = 6'dx;

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
        $fscanf(input_file, "%d\n", pat_count);
        $fscanf(output_file, "%d\n", pat_count);

		input_task;
        get_output_task;
		cycle = 0;
        wait_out_valid_task;
        check_ans_task;
        
		
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", pat_count ,cycle);
		total_cycle = total_cycle + cycle;
	end
    display_pass;
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

		if (golden_x !== out_Rx || golden_y !== out_Ry) begin
			$display ("*********************************************************************");
            $display ("*       prime is %d , P is : (%d,%d) , Q is : (%d,%d) , a is %d      *",prime_tmp,px,py,qx,qy,a_tmp);
			$display ("*        answer should be : (%d,%d) , your answer is : (%d,%d)       *",golden_x,golden_y,out_Rx,out_Ry);
			$display ("*********************************************************************");  
			@(negedge clk);
			$finish; 	
		end
		out_cycle = out_cycle + 1;
		@(negedge clk);

	end
end
endtask


task input_task;
begin
    delay_cycle = $urandom_range(4,2);
    repeat(delay_cycle) @(negedge clk);

    in_valid = 1'b1;
    $fscanf(input_file, "%b\n", in_prime);
    $fscanf(input_file, "%b\n", in_Qx);
    $fscanf(input_file, "%b\n", in_Qy);
    $fscanf(input_file, "%b\n", in_Px);
    $fscanf(input_file, "%b\n", in_Py);
    $fscanf(input_file, "%b\n", in_a);
    $fscanf(input_file, "%b\n", in_b);

    prime_tmp = in_prime;
    qx = in_Qx;
    qy = in_Qy;
    px = in_Px;
    py = in_Py;
    a_tmp = in_a;

    @(negedge clk);
    in_valid = 1'b0;

    in_Px = 6'dx;
    in_Py = 6'dx;
    in_Qx = 6'dx;
    in_Qy = 6'dx;
    in_prime = 6'dx;
    in_a = 6'dx;

end
endtask

task get_output_task;
begin
    $fscanf(output_file, "%b\n", golden_x);
    $fscanf(output_file, "%b\n", golden_y);
end
endtask

task wait_out_valid_task; begin
	
	while(out_valid !== 1) begin
		cycle = cycle + 1 ;
		if(cycle == 1001) begin
            $display ("*********************************************************************");
            $display ("*                Latency is limited in 1000 cycles                   *");
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
        $finish;
end
endtask




task reset_task ; begin
	
	#(20);
	rst_n = 1'b0;
	#(20);

	if (out_Rx!==0 || out_valid!==0 || out_Ry!==0) begin
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