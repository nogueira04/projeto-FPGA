module projeto (sec_out, milsec_out, curr_state, clock, HEX3, HEX2, HEX1, HEX0,
					 colunas, linhas, number, pressed, ledA, ledB, ledC, ledD);

//segundos e decisegundos					 
output reg[9:0] sec_out;
output reg[3:0] milsec_out;

//ajuste de clock
reg[31:0] pulsos;
reg[31:0] pulsos_aux;

//estado atual
output reg[1:0] curr_state;

//display de 7 segmentos
output reg[6:0] HEX3;
output reg[6:0] HEX2;
output reg[6:0] HEX1;
output reg[6:0] HEX0;

//keypad
output reg [3:0] colunas;
input [3:0] linhas;
output reg [3:0] number;
output reg pressed;

reg [31:0] counter = 0;
parameter cycle = 500000;
reg [1:0] state = 0;

//flags
reg A;
reg B;
reg C;
reg D;

output reg ledA;
output reg ledB;
output reg ledC;
output reg ledD;


input clock;

parameter reset = 0, contar = 1, pausar = 2, parar = 3;

function [6:0] HEX (input [3:0] n); begin
	case(n)
		4'b0000: HEX=7'b1000000;
		4'b0001: HEX=7'b1111001;
		4'b0010: HEX=7'b0100100;
		4'b0011: HEX=7'b0110000;
		4'b0100: HEX=7'b0011001;
		4'b0101: HEX=7'b0010010;
		4'b0110: HEX=7'b0000010;
		4'b0111: HEX=7'b1111000;
		4'b1000: HEX=7'b0000000;
		4'b1001: HEX=7'b0011000;
	endcase
end
endfunction

always @(posedge clock) begin
	//quando atinge 999.9s
	if (sec_out == 999 && milsec_out == 9) begin
		sec_out <= 0;
		milsec_out <= 0;
	end
	
	case (curr_state)
		
		reset: begin
			sec_out <= 0; milsec_out <= 0; pulsos <= 0; pulsos_aux <= 0;
			
			HEX3 <= HEX(4'b0000);
			HEX2 <= HEX(4'b0000);
			HEX1 <= HEX(4'b0000);
			HEX0 <= HEX(4'b0000);
			
			ledA <= 1;
			ledB <= 0;
			ledC <= 0;
			ledD <= 0;
		end
		
		contar: begin
			pulsos <= pulsos + 1;
			pulsos_aux <= pulsos_aux + 1;
			
			//display de 7 segmentos
			HEX3 <= HEX(sec_out / 100);
			HEX2 <= HEX(((sec_out % 100)/10));
			HEX1 <= HEX(sec_out % 10);
			HEX0 <= HEX(milsec_out);
			
			//contagem
			if(pulsos_aux == 5000000)begin
				pulsos_aux <= 0;
				if(milsec_out == 9) begin
					milsec_out <= 0;
				end else milsec_out <= milsec_out + 1'b1;
			end
			
			if(pulsos == 50000000) begin
				sec_out <= sec_out + 1'b1;
				pulsos <= 0;
			end
			
			//auxiliares para checar maquina de estado
			ledA <= 0;
			ledB <= 1;
			ledC <= 0;
			ledD <= 0;
		end
		
		pausar: begin
		
		//contagem
		if(pulsos_aux == 5000000)begin
				pulsos_aux <= 0;
				if(milsec_out == 9) begin
					milsec_out <= 0;
				end else milsec_out <= milsec_out + 1'b1;
		end
			
		if(pulsos == 50000000) begin
			sec_out <= sec_out + 1'b1;
			pulsos <= 0;
		end
		
		//auxiliares para checar maquina de estado
		ledA <= 0;
		ledB <= 0;
		ledC <= 1;
		ledD <= 0;
		end
		
		parar: begin
		
			
		//auxiliares para checar maquina de estado
			ledA <= 0;
			ledB <= 0;
			ledC <= 0;
			ledD <= 1;
		end
	
	endcase
	
end

always @ (posedge clock) begin

	
	case (curr_state)
		reset: begin
			if (B == 1) begin
				curr_state <= contar;
			end else if (A == 1) begin
				curr_state <= reset;
			end else if (C == 1) begin
				curr_state <= pausar;
			end else if (D == 1) curr_state <= parar;
			
		end
		
		contar: begin
			if (A == 1) begin
				curr_state <= reset;
			end else if (C == 1) begin
				curr_state <= pausar;
			end else if (D == 1) begin
				curr_state <= parar;
			end
		end
		
		pausar: begin
			if (A == 1) begin
				curr_state <= reset;
			end else if (B == 1) begin
				curr_state <= contar;
			end else if (D == 1) begin
				curr_state <= parar;
			end
		end
			
		parar: begin
			if (B == 1) begin
				curr_state <= contar;
			end
		end
	endcase

end

always @ (posedge clock) begin
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

always @ (posedge clock) begin
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
			if (~linhas[0]) begin
				A <= 1;
				B <= 0;
				C <= 0;
				D <= 0;
			end else if (~linhas[1]) begin
				A <= 0;
				B <= 1;
				C <= 0;
				D <= 0;
			end else if (~linhas[2]) begin
				A <= 0;
				B <= 0;
				C <= 1;
				D <= 0;
			end else if (~linhas[3]) begin
				A <= 0;
				B <= 0;
				C <= 0;
				D <= 1;
			end
		end
	end
	else begin
		pressed <= 0;
	end
end

endmodule