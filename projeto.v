module projeto (sec_out, milsec_out, curr_state, clock, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
					 colunas, linhas, number, pressed, ledA, ledB, ledC, ledD, negative_led);
					 
//segundos e decisegundos					 
output reg[9:0] sec_out;
output reg[3:0] milsec_out;



//ajuste de clock
reg[31:0] pulsos;
reg[31:0] pulsos_aux;

//estado atual
output reg[1:0] curr_state;

//display de 7 segmentos
output reg[6:0] HEX7;
output reg[6:0] HEX6;
output reg[6:0] HEX5;
output reg[6:0] HEX4;
output reg[6:0] HEX3;
output reg[6:0] HEX2;
output reg[6:0] HEX1;
output reg[6:0] HEX0;

//keypad
output reg [3:0] colunas;
input [3:0] linhas;
output reg [3:0] number;
output reg pressed;

parameter frequence = 50000000;
parameter delay_debounce = frequence / 10;

reg[31:0] pulsos_debounce = 0;
reg[31:0] pulsos_debounce_aux = 0;

//flags
reg A = 0;
reg B = 0;
reg C = 0;
reg D = 0;
reg calcMode = 0;
reg soma_flag = 0;
reg sub_flag = 0;
reg mult_flag = 0;
reg negative_flag = 0;

reg [1:0] currInput;
reg [1:0] curr_state_calc;
reg [6:0] ln1;
reg [6:0] ln2;
reg [3:0] dezena1, dezena2;
reg [3:0] unidade1, unidade2;
reg [31:0] result;

output reg ledA;
output reg ledB;
output reg ledC;
output reg ledD;
output reg negative_led;


input clock;

parameter reset = 0, contar = 1, pausar = 2, parar = 3;
parameter input0 = 0, input1 = 1, input2 = 2, input3 = 3;
parameter soma = 1, sub = 2, mult = 3;

initial begin 
	pressed = 0;
	curr_state = parar;
	currInput = input0;
end

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
			
		end
		
		contar: begin
			pulsos <= pulsos + 1;
			pulsos_aux <= pulsos_aux + 1;
		
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

		end
		
		pausar: begin
		
			pulsos <= pulsos + 1;
			pulsos_aux <= pulsos_aux + 1;
		
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
			

		end
		
		parar: begin
		
			
		end
	
	endcase
	
end

always @ (posedge clock) begin

	
	case (curr_state)
		reset: begin
			if (B == 1) begin
				curr_state <= contar;
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
	if (soma_flag) curr_state_calc <= soma;
	else if (sub_flag) curr_state_calc <= sub;
	else if (mult_flag) curr_state_calc <= mult;
	else curr_state_calc <= 0;
end

always @ (posedge clock) begin
	if (calcMode) begin
	
		HEX3 <= 7'b1111111;
		HEX2 <= 7'b1111111;
		HEX1 <= 7'b1111111;
		HEX0 <= 7'b1111111;
		
		case (currInput)
			input0: begin
				HEX7 <= HEX(number);
				dezena1 <= number;
				ledA <= 1;
				ledB <= 0;
				ledC <= 0;
				ledD <= 0;
			end
			
			input1: begin
				HEX6 <= HEX(number);
				unidade1 <= number;
				ledA <= 0;
				ledB <= 1;
				ledC <= 0;
				ledD <= 0;
			end
			
			input2: begin
				HEX5 <= HEX(number);
				dezena2 <= number;
				ledA <= 0;
				ledB <= 0;
				ledC <= 1;
				ledD <= 0;
			end
			
			input3: begin
				HEX4 <= HEX(number);
				unidade2 <= number;
				ledA <= 0;
				ledB <= 0;
				ledC <= 0;
				ledD <= 1;
			end
		endcase
		
		ln1 <= unidade1 + (dezena1 * 10);
		ln2 <= unidade2 + (dezena2 * 10);
		
		case (curr_state_calc) 
			soma: begin
				result <= ln1 + ln2;
			end
	
			sub: begin
				if (ln1 > ln2) result <= ln1 - ln2;
				else begin
					result <= ln2 - ln1;
					negative_flag <= 1;
				end
			end
			
			mult: begin
				result <= ln1 * ln2;
			end
		endcase
		
		negative_flag <= 0;
		
		if (result != 0) begin
			HEX3 <= HEX(result / 1000);
			HEX2 <= HEX(((result % 1000)/100));
			HEX1 <= HEX((result % 100) / 10);
			HEX0 <= HEX(result % 10);
			
			if (ln2 > ln1 && sub_flag) negative_led <= 1;
			else negative_led <= 0;
		end else begin
			HEX3 <= HEX(0);
			HEX2 <= HEX(0);
			HEX1 <= HEX(0);
			HEX0 <= HEX(0);
		end

	end else begin
		
		// zera informações da calculadora após volta para o cronometro
		HEX7 <= 7'b1111111;
		HEX6 <= 7'b1111111;
		HEX5 <= 7'b1111111;
		HEX4 <= 7'b1111111;
		ledA <= 0;
		ledB <= 0;
		ledC <= 0;
		ledD <= 0;
		ln1 <= 0;
		ln1 <= 0;
		dezena1 <= 0;
		unidade1 <= 0;
		dezena2 <= 0;
		unidade2 <= 0;
		result <= 0;
		
		
		case (curr_state) 
			reset: begin	
				// zera display cronometro
				HEX3 <= HEX(4'b0000);
				HEX2 <= HEX(4'b0000);
				HEX1 <= HEX(4'b0000);
				HEX0 <= HEX(4'b0000);
			end
			
			default: begin
				// atualiza display
				HEX3 <= HEX(sec_out / 100);
				HEX2 <= HEX(((sec_out % 100)/10));
				HEX1 <= HEX(sec_out % 10);
				HEX0 <= HEX(milsec_out);
			end
		endcase
	end
end


always @ (posedge clock) begin

	if (pulsos_debounce < delay_debounce) begin
		pulsos_debounce <= pulsos_debounce + 1;
	end else begin
		pulsos_debounce <= 0;
		
		case (pulsos_debounce_aux)
			0: colunas <= 4'b0111;
			1: colunas <= 4'b1011;
			2: colunas <= 4'b1101;
			3: colunas <= 4'b1110;
		endcase
		
		
		if (pulsos_debounce_aux >= 3) pulsos_debounce_aux <= 0;
		else pulsos_debounce_aux <= pulsos_debounce_aux + 1;
		
		if (~&linhas) begin
			
			if (~colunas[0]) begin
				if (~linhas[0]) number <= 4'd1;
				else if (~linhas[1]) number <= 4'd4;
				else if (~linhas[2]) number <= 4'd7;
				else if (~linhas[3]) calcMode <= 1;
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
				else if (~linhas[3]) begin
					if (currInput >= 3) currInput <= 0;
					else currInput <= currInput + 1;
				end
			end
			else if (~colunas[3]) begin
				if (~linhas[0]) begin
					A <= 1;
					B <= 0;
					C <= 0;
					D <= 0;
					
					if (calcMode) begin
						soma_flag <= 1;
						sub_flag <= 0;
						mult_flag <= 0;
					end
				end else if (~linhas[1]) begin
					A <= 0;
					B <= 1;
					C <= 0;
					D <= 0;
					
					if (calcMode) begin
						soma_flag <= 0;
						sub_flag <= 1;
						mult_flag <= 0;
					end
				end else if (~linhas[2]) begin
					A <= 0;
					B <= 0;
					C <= 1;
					D <= 0;
					
					if (calcMode) begin
						soma_flag <= 0;
						sub_flag <= 0;
						mult_flag <= 1;
					end
				end else if (~linhas[3]) begin
					if (~calcMode) begin
						A <= 0;
						B <= 0;
						C <= 0;
						D <= 1;
					end else calcMode <= 0;
				end
			end
		end
		
	
	end
	
	
end

endmodule