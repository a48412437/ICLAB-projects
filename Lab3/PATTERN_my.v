
`ifdef RTL
    `define CYCLE_TIME 15.0
`endif
`ifdef GATE
    `define CYCLE_TIME 15.0
`endif

module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid1,
	in_valid2,
	in,
	in_data,
    // Input signals
    out_valid1,
	out_valid2,
    out,
	out_data
);

// ************* Input & Output Declaration ******************

output reg clk, rst_n, in_valid1, in_valid2;
output reg [1:0] in;
output reg [8:0] in_data;
input out_valid1, out_valid2;
input [2:0] out;
input [8:0] out_data;


// ************ parameter & integer ********************
integer input_file , output_file;
integer PATNUM ,patcount;
integer i,j;
integer gap;
integer cycle , total_cycle;
integer hostage_num , hostage_cnt;
integer a,b;
integer out_data_cycle;
integer out_data_cycle_constrain;



integer seed=64;

parameter right = 3'd0;
parameter down = 3'd1;
parameter left = 3'd2;
parameter up = 3'd3;
parameter stall = 3'd4;

parameter wall = 2'd0;
parameter path = 2'd1;
parameter trap = 2'd2;
parameter hostage = 2'd3;



// *************** wire & reg *******************

reg [1:0] maze [19:1][19:1]; // maze
reg [4:0] player_x , player_y; // 1-19 , 1~19 , initial at (2,2)
reg [2:0] past_dic;

reg [3:0] password_down;
reg [3:0] password_upper;
reg password_sign;
reg [8:0] password;

reg signed [8:0] password_reg [3:0];                                          // if no hostage or hostagge num < 4 , password and oud in pattern is 0
reg [8:0] temp;
reg [8:0] out_data_golden [3:0]; // right answer of out data           // if no hostage or hostagge num < 4 , password and oud in pattern is 0
reg signed [8:0] q,w,e,r;
reg signed [8:0] half_temp;
reg [8:0] max , min;

wire xy18 = (player_x=='d18 && player_y=='d18);

// ************* clock ***************
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;





// ****************** initial ************************

initial begin
    
    rst_n = 1'b1;                // initial all input
    in_valid1 = 1'b0;
    in_valid2 = 1'b0;
    in = 'bx;
    in_data = 'bx;
    player_x = 'd2;
    player_y = 'd2;
    total_cycle = 0;

    

    force clk = 0; // force clk is 0 , need release after reset.
    reset_task;

    input_file = $fopen ("../00_TESTBED/input.txt","r");
    //output_file = $fopen ("../00_TESTBED/output.txt","r"); // maybe no need , can check by ALG

    @(negedge clk);

    PATNUM = 500; // pattern number

    for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin // do pattern iteration
        
        cycle = 0; // initial cycle
        player_x = 'd2; // initial the player location
        player_y = 'd2;
        hostage_num = 0;
        hostage_cnt = 0;

        for(i=0;i<4;i=i+1) password_reg[i] = 'd0; // initial password reg

        input_maze;
        wait_out_valid2;
        

        

        wait_out_valid1;
        calculate_right_answer;
        check_out_data;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycle);



        total_cycle = total_cycle + cycle;
    end
    repeat(3) @(negedge clk);
	display_pass;
    $finish;
	$fclose(input_file);



end



// ****************** TASK **************************
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
    
    #(20); rst_n = 0;
    #(20); 
    // spec 3 , check if all signal is reset

    if ((out_valid1 !== 0) || (out_valid2 !== 0) || (out !== 0) || (out_data !== 0)) begin
        $display ("*********************************************************************");
        $display ("*                        SPEC 3 IS FAIL!                            *");
        $display ("*               Output signal should be 0 after reset               *");
        $display ("*********************************************************************");
        #(200);
        $finish;
    end

    #(20); rst_n = 1;
    #(6); release clk;

end endtask


task input_maze ; begin
    
    gap = $urandom_range(2,4); // wait 2~4 neg clk
    repeat (gap) @(negedge clk);

    in_valid1 = 1'b1;

    if ((out_valid1===1) || (out_valid2===1)) begin //SPEC 5
        $display ("*********************************************************************");
        $display ("*                        SPEC 5 IS FAIL!                            *");
        $display ("*Out_valid1 or out_valid2 should not be high when in_valid1 is high *");
        $display ("*********************************************************************"); 
        @(negedge clk);
        $finish;          
    end

    
    for (i=1;i<20;i=i+1) begin
        for (j=1;j<20;j=j+1) begin
            maze[i][j] = wall;
        end
    end

    for (j=2;j<19;j=j+1) begin
        for (i=2;i<19;i=i+1) begin
            b = $fscanf (input_file , "%d" , maze[i][j]); 
        end
    end


    for (j=2;j<19;j=j+1) begin
        for (i=2;i<19;i=i+1) begin
            if (maze [i][j] === hostage ) hostage_num = hostage_num + 1;
            in = maze[i][j];
            @(negedge clk);
        end
    end
    in_valid1 = 1'b0;
    in = 'bx;

    /*$display("\n");
    for(j=1;j<20;j=j+1) begin
        $display("\n");
        for (i=1;i<20;i=i+1) begin
            $write ("%d " ,maze[i][j]);
        end
    end*/

end endtask

task wait_out_valid2 ; begin
    
    while (out_valid2 === 0 ) begin

        if (cycle == 3000) begin
            $display ("*********************************************************************");
            $display ("*                        SPEC 6 IS FAIL!                            *");
            $display ("*                Latency is limited in 3000 cycles                  *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish;                          
        end

        cycle = cycle + 1;
        @(negedge clk); 
    end
    maze_walking;

end endtask

task maze_walking ; begin
    
    while (out_valid2 === 1 ) begin  // when output the direction
        
        if (cycle == 3000) begin
            $display ("*********************************************************************");
            $display ("*                        SPEC 6 IS FAIL!                            *");
            $display ("*                Latency is limited in 3000 cycles                  *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish;                          
        end

        if (out_valid1 === 1) begin //SPEC 5
            $display ("*********************************************************************");
            $display ("*                        SPEC 5 IS FAIL!                            *");
            $display ("*  Out_valid1 and out_valid2 should not be high at the same time    *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish;                 
        end
        cycle = cycle + 1;

        if (past_dic !== stall) begin
            if (maze[player_x][player_y] === trap) begin
                if (out !== stall) begin  // SPEC 7 , NOT STALL at the trap
                    $display ("*********************************************************************");
                    $display ("*                        SPEC 7 IS FAIL!                            *");
                    $display ("*              out need to 'stall' a cycle at the trap              *");
                    $display ("*********************************************************************");
                    @(negedge clk);
                    $finish;
                end
            end
        end

        if (out_data !== 0) begin // SPEC 7 , out_data not 0
            $display ("*********************************************************************");
            $display ("*                        SPEC 7 IS FAIL!                            *");
            $display ("*               out_data should be 0 when out diliver               *");
            $display ("*********************************************************************");
            @(negedge clk);
            $finish;
        end

        case (out)
            left: begin
                player_x = player_x - 1;
                if (maze[player_x][player_y] === wall) display_hit_wall;  // the player hit the wall
                past_dic = left;
            end 
            right: begin
                player_x = player_x + 1;
                if (maze[player_x][player_y] === wall) display_hit_wall; // the player hit the wall
                past_dic = right;
            end
            up: begin
                player_y = player_y - 1;
                if (maze[player_x][player_y] === wall) display_hit_wall; // the player hit the wall
                past_dic = up;
            end
            down: begin
                player_y = player_y + 1;
                if (maze[player_x][player_y] === wall) display_hit_wall; // the player hit the wall
                past_dic = down;
            end
            stall: begin // player don't move
                past_dic = stall;
            end
            //default: 
        endcase  // the player hit the wall


    @(negedge clk);
    end 

    if (out !== 0) begin
        $display ("*********************************************************************");
        $display ("*                        SPEC 4 IS FAIL!                            *");
        $display ("*        Out should be reset after out_valid2 is pulled dow         *");
        $display ("*********************************************************************"); 
        @(negedge clk);
        $finish;  
    end
    check_location;
end endtask


task check_location ; begin

    if (maze[player_x][player_y] === hostage) begin
        give_password;
        maze[player_x][player_y] = path; // hostage is found , set to path
    end
    else if (xy18) begin
        check_find_all_hostage;
    end
    else begin
        $display ("*********************************************************************");
        $display ("*                        SPEC 8 IS FAIL!                            *");
        $display ("*Location should be the exit or hostage when pull down the out_valid2*");
        $display ("*********************************************************************"); 
        @(negedge clk);
        $finish;          
    end

end endtask

task give_password ; begin
    
    gap = $urandom_range(2,4);
    repeat(gap) @(negedge clk); // wait 2~4 cycle to give password
    password_upper =  $urandom_range(3,12);
    password_down =  $urandom_range(3,12);
    password_sign = $urandom_range(0,1);
    password = {password_sign , password_upper , password_down};
 
    
    in_valid2 = 1;
    if ((out_valid1===1) || (out_valid2===1)) begin //SPEC 5
        $display ("*********************************************************************");
        $display ("*                        SPEC 5 IS FAIL!                            *");
        $display ("*Out_valid1 or out_valid2 should not be high when in_valid2 is high *");
        $display ("*********************************************************************"); 
        @(negedge clk);
        $finish;          
    end    
    in_data = {password_sign , password_upper , password_down};
    password_reg [hostage_cnt] = password;
    hostage_cnt = hostage_cnt + 1;
    maze[player_x][player_y] = 1;

    @(negedge clk);
    in_valid2 = 0;
    in_data = 'dx;
    wait_out_valid2;


end endtask

task check_find_all_hostage ; begin
    
    for (i=2;i<19;i=i+1) begin
        for (j=2;j<19;j=j+1) begin
            if (maze[i][j] === hostage) display_still_have_hostage;
        end
    end


end endtask


task calculate_right_answer ; begin
    
    case (hostage_num)
        0: begin   // out one cycle 0
            for (i=0;i<4;i=i+1) begin
                out_data_golden [i] = 'd0;
            end
        end
        1: begin  // out one cycle password
            out_data_golden[0] = password_reg[0];
            for (i=1;i<4;i=i+4) begin
                out_data_golden [i] = 'd0;
            end 
        end
        2: begin
            
            q = (password_reg[0]>password_reg[1])?password_reg[0]:password_reg[1]; //sorting
            w = (password_reg[0]>password_reg[1])?password_reg[1]:password_reg[0];
            
            q[7:0] = excess_3_convert(q[7:4]) * 10 + excess_3_convert(q[3:0]);
            w[7:0] = excess_3_convert(w[7:4]) * 10 + excess_3_convert(w[3:0]);
            
            if (q[8]) begin
                q = {1'b0 , q[7:0]};
                q = ~q + 9'd1;
            end

            if (w[8]) begin
                w = {1'b0 , w[7:0]};
                w = ~w + 9'd1;
            end

            half_temp = (($signed(q) + $signed(w))/2);
            q = $signed(q) - half_temp;
            w = $signed(w) - half_temp;

            out_data_golden[0] = q;
            out_data_golden[1] = w;
            
            for (i=2;i<4;i=i+1) begin
                out_data_golden [i] = 9'd0;
            end

        end
        3: begin  //sorting + sub + cumulation
            
            for(i=0;i<2;i=i+1)  
            begin
                for(j=0;j<2-i;j=j+1)
                begin
                    if(password_reg[j]<password_reg[j+1])
                    begin
                        temp=password_reg[j];
                        password_reg[j]=password_reg[j+1];
                        password_reg[j+1]=temp;
                    end
                end
            end

            half_temp =(($signed(password_reg[0]) + $signed(password_reg[2]))/2); 
            q = password_reg[0] - half_temp;            
            w = password_reg[1] - half_temp;            
            e = password_reg[2] - half_temp;  

            q = q;
            w = ($signed(q)*2+$signed(w)*1)/3;
            e = ($signed(w)*2+$signed(e)*1)/3;

            out_data_golden[0] = q;
            out_data_golden[1] = w;
            out_data_golden[2] = e;
            out_data_golden[3] = 'd0;           


        end
        4:  begin  // sorting + excess-3 + sub + cumulation
            
            for(i=0;i<3;i=i+1)  //sorting
            begin
                for(j=0;j<3-i;j=j+1)
                begin
                    if(password_reg[j]<password_reg[j+1])
                    begin
                        temp=password_reg[j];
                        password_reg[j]=password_reg[j+1];
                        password_reg[j+1]=temp;
                    end
                end
            end
            
            q = password_reg[0];
            w = password_reg[1];
            e = password_reg[2];
            r = password_reg[3];



            q[7:0] = excess_3_convert(q[7:4]) * 10 + excess_3_convert(q[3:0]);
            w[7:0] = excess_3_convert(w[7:4]) * 10 + excess_3_convert(w[3:0]);
            e[7:0] = excess_3_convert(e[7:4]) * 10 + excess_3_convert(e[3:0]);
            r[7:0] = excess_3_convert(r[7:4]) * 10 + excess_3_convert(r[3:0]);


            if (q[8]) begin
                q = {1'b0 , q[7:0]};
                q = ~q + 9'd1;
            end
            if (w[8]) begin
                w = {1'b0 , w[7:0]};
                w = ~w + 9'd1;
            end
            if (e[8]) begin
                e = {1'b0 , e[7:0]};
                e = ~e + 9'd1;
            end
            if (r[8]) begin
                r = {1'b0 , r[7:0]};
                r = ~r + 9'd1;
            end

           

            max = 9'b100000000;
            max = ($signed(q)>$signed(max))?q:max;
            max = ($signed(w)>$signed(max))?w:max;
            max = ($signed(e)>$signed(max))?e:max;
            max = ($signed(r)>$signed(max))?r:max;
            
            min = 9'b011111111;
            min = ($signed(q)<$signed(min))?q:min;
            min = ($signed(w)<$signed(min))?w:min;
            min = ($signed(e)<$signed(min))?e:min;
            min = ($signed(r)<$signed(min))?r:min;

            half_temp = ($signed(max) + $signed(min))/2;

            q = $signed(q) - $signed(half_temp);
            w = $signed(w) - $signed(half_temp);
            e = $signed(e) - $signed(half_temp);
            r = $signed(r) - $signed(half_temp);



            q = q;
            w = ($signed(q)*2 + $signed(w)) /3;
            e = ($signed(w)*2 + $signed(e)) /3;
            r = ($signed(e)*2 + $signed(r)) /3;


            out_data_golden [0] = q;
            out_data_golden [1] = w;
            out_data_golden [2] = e;
            out_data_golden [3] = r;

        end
        default: begin
            $display("WARRING : hostage number wrong more than 4 !!");
            @(negedge clk);
            $finish; 
        end
    endcase

end endtask

function [3:0] excess_3_convert;
    input [3:0] a;
    begin
        case (a)
            4'b0011: excess_3_convert = 4'b0000;
            4'b0100: excess_3_convert = 4'b0001;
            4'b0101: excess_3_convert = 4'b0010; 
            4'b0110: excess_3_convert = 4'b0011; 
            4'b0111: excess_3_convert = 4'b0100; 
            4'b1000: excess_3_convert = 4'b0101; 
            4'b1001: excess_3_convert = 4'b0110; 
            4'b1010: excess_3_convert = 4'b0111;
            4'b1011: excess_3_convert = 4'b1000;
            4'b1100: excess_3_convert = 4'b1001;

            default: excess_3_convert = 4'b1111; // wrong
        endcase
    end
    
endfunction


task wait_out_valid1 ; begin
    
    while (out_valid1 === 0) begin
        if (cycle == 3000) begin
            $display ("*********************************************************************");
            $display ("*                        SPEC 6 IS FAIL!                            *");
            $display ("*                Latency is limited in 3000 cycles                  *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish;                          
        end        
        cycle = cycle + 1 ;
        @(negedge clk);

    end

end endtask

task check_out_data ; begin
    out_data_cycle = 0;
    case (hostage_num)
        0: out_data_cycle_constrain = 1;
        1: out_data_cycle_constrain = 1;
        2: out_data_cycle_constrain = 2;
        3: out_data_cycle_constrain = 3;
        4: out_data_cycle_constrain = 4;
    endcase
    
    while (out_valid1 === 1) begin
        

        if (out_valid2 === 1) begin //SPEC 5
            $display ("*********************************************************************");
            $display ("*                        SPEC 5 IS FAIL!                            *");
            $display ("*  Out_valid1 and out_valid2 should not be high at the same time    *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish;                 
        end

        if (out_data_cycle === out_data_cycle_constrain ) begin  //SPEC 9
            $display ("*********************************************************************");
            $display ("*                        SPEC 9 IS FAIL!                            *");
            $display ("*          Out_valid1 should maintain corresponding cycle           *");
            $display ("*********************************************************************"); 
            @(negedge clk);
            $finish;             
        end

        
        if(out_data !== out_data_golden[out_data_cycle]) begin //SPEC 10
            $display ("*********************************************************************");
            $display ("*                        SPEC 10 IS FAIL!                           *");
            $display ("*           answer should be : %d , your answer is : %d             *",out_data_golden[out_data_cycle],out_data);
            $display ("*********************************************************************");  
            @(negedge clk);
            $finish;           
        end
       

        out_data_cycle = out_data_cycle + 1;
        @(negedge clk);
    end

    if (out_data !== 0) begin
        $display ("**********************************************************************");
        $display ("*                        SPEC 11 IS FAIL!                            *");
        $display ("*      Out_data should be reset after out_valid is pulled down       *");
        $display ("**********************************************************************"); 
        @(negedge clk);
        $finish;  
    end
end endtask

task display_still_have_hostage ; begin
    
    $display ("*********************************************************************");
    $display ("*                        SPEC 8 IS FAIL!                            *");
    $display ("*                 Still have hostage not be rescue                  *");
    $display ("*********************************************************************");
    @(negedge clk);
    $finish;  

end endtask



task display_hit_wall ; begin
    
    $display ("*********************************************************************");
    $display ("*                        SPEC 7 IS FAIL!                            *");
    $display ("*                     The player hit the wall                       *");
    $display ("*********************************************************************");
    @(negedge clk);
    $finish;    

end endtask


/*task display_maez_and_player ; begin // in pattern display the maze and player location
    
end endtask*/



endmodule