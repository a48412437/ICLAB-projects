module HD(
	code_word1,
	code_word2,
	out_n
);
input  [6:0]code_word1, code_word2;
output reg signed[5:0] out_n;
wire [2:0] pos_1, pos_2;
wire opt_1, opt_2;
reg [6:0] new_code_word1, new_code_word2;
wire signed[3:0] c1, c2;
wire [1:0] opt;


LOCATE locate_1 (.code_word(code_word1),.pos(pos_1),.opt(opt_1));
LOCATE locate_2 (.code_word(code_word2),.pos(pos_2),.opt(opt_2));

// update code 1
always @(*) begin
	case (pos_1)
		3'b000: begin
			new_code_word1 = {code_word1[6:1],!(code_word1[0])};
		end 
		3'b001: begin
			new_code_word1 = {code_word1[6:2],!(code_word1[1]),code_word1[0]};
		end
		3'b010: begin
			new_code_word1 = {code_word1[6:3],!(code_word1[2]),code_word1[1:0]};
		end
		3'b011: begin
			new_code_word1 = {code_word1[6:4],!(code_word1[3]),code_word1[2:0]};
		end
		default:   // if p is wrong, update is no need  
			new_code_word1 = code_word1;
	endcase
end

always @(*) begin
	case (pos_2)
		3'b000: begin
			new_code_word2 = {code_word2[6:1],!(code_word2[0])};
		end 
		3'b001: begin
			new_code_word2 = {code_word2[6:2],!(code_word2[1]),code_word2[0]};
		end
		3'b010: begin
			new_code_word2 = {code_word2[6:3],!(code_word2[2]),code_word2[1:0]};
		end
		3'b011: begin
			new_code_word2 = {code_word2[6:4],!(code_word2[3]),code_word2[2:0]};
		end
		default: 
			new_code_word2 = code_word2;
	endcase
end

// assign c1 c2 opt
assign c1 = new_code_word1[3:0];
assign c2 = new_code_word2[3:0];
assign opt = {opt_1, opt_2};

// calculate result, selected by opt
always @(*) begin
	case (opt)
		2'b00:begin
			out_n = (c1<<1) + c2;
		end 
		2'b01:begin
			out_n = (c1<<1) - c2;
		end
		2'b10:begin
			out_n = c1 - (c2<<1);
		end
		2'b11:begin
			out_n = c1 + (c2<<1);
		end
		default:
			out_n = 0; 
	endcase
end

endmodule



// bit - wise ''xor'' to  find position
// find the error location
module LOCATE(
	code_word,
	pos,
	opt
	);
input [6:0] code_word;
output reg [2:0] pos; //the wrong bit position
output reg opt; // the wrong bit is 0/1
wire p1, p2, p3;

assign p1 = ^{code_word[6], code_word[3], code_word[2], code_word[1]};
assign p2 = ^{code_word[5], code_word[3], code_word[2], code_word[0]};
assign p3 = ^{code_word[4], code_word[3], code_word[1], code_word[0]};


// find the wrong position
always @(*) begin
	if (p1 && p2 && p3) begin // x1 wrong
		pos = 3'b011;
	end
	else if (p1 && p2) begin // x2 wrong 
		pos = 3'b010;
	end
	else if (p1 && p3) begin // x3 wrong 
		pos = 3'b001;
	end
	else if (p2 && p3) begin // x4 wrong
		pos = 3'b000;
	end
	else if (p1) begin   // p may be wrong
		pos = 3'b110;
	end
	else if (p2) begin
		pos = 3'b101;
	end
	else if (p3) begin
		pos = 3'b100;
	end
	else begin
		pos = 3'd0;
	end
end


// do the opt 
always @(*) begin
	case (pos)
		3'b000: begin
			opt = code_word[0];
		end 
		3'b001: begin
			opt = code_word[1];
		end
		3'b010: begin
			opt = code_word[2];
		end
		3'b011: begin
			opt = code_word[3];
		end
		3'b100: begin
			opt = code_word[4];
		end
		3'b101: begin
			opt = code_word[5];
		end
		3'b110: begin
			opt = code_word[6];
		end
		default: 
			opt = 1'b0;
	endcase
end

endmodule
