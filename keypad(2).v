module keypad (
	input clk,
	output reg [3:0] colunas,
	input [3:0] linhas,
	output reg [3:0] number,
	output reg pressed
);

reg [31:0] counter = 0;
parameter cycle = 500000;
reg [1:0] state = 0;

always @ (posedge clk) begin
	if (counter < cycle) begin 
		if (~pressed) counter <= counter + 1;
		else begin
			counter <= 0;
		end
	end
	else begin
		counter <= 0;
		state <= state + 1;
	end
	
	case (state) 
		0: colunas <= 4'b0111;
		1: colunas <= 4'b1011;
		2: colunas <= 4'b1101;
		3: colunas <= 4'b1110;
	endcase
end

always @ (posedge clk) begin
	if (~&linhas) begin
		pressed <= 1;
		
		if (~colunas[0]) begin
			if (~linhas[0]) number <= 4'd1;
			else if (~linhas[1]) number <= 4'd4;
			else if (~linhas[2]) number <= 4'd7;
			else if (~linhas[3]) number <= 4'd14;
		end
		else if (~colunas[1]) begin
			if (~linhas[0]) number <= 4'd2;
			else if (~linhas[1]) number <= 4'd5;
			else if (~linhas[2]) number <= 4'd8;
			else if (~linhas[3]) number <= 4'd0;
		end
		else if (~colunas[2]) begin
			if (~linhas[0]) number <= 4'd3;
			else if (~linhas[1]) number <= 4'd6;
			else if (~linhas[2]) number <= 4'd9;
			else if (~linhas[3]) number <= 4'd15;
		end
		else if (~colunas[3]) begin
			if (~linhas[0]) number <= 4'd10;
			else if (~linhas[1]) number <= 4'd11;
			else if (~linhas[2]) number <= 4'd12;
			else if (~linhas[3]) number <= 4'd13;
		end
	end
	else begin
		pressed <= 0;
	end
end
endmodule
