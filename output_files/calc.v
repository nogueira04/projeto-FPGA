module seven_seg (in1, in2, curr_state, clock, result, A, B, C, D, X, Y);

output reg[9:0] result;
output reg[1:0] curr_state;

input in1;
input in2;

input clock, A, B, C, D, X , Y;
parameter soma = 0, sub = 1, mult = 2, receberinput1 = 3 , receberinput2 = 4;

    always @(*) begin
    
        case (curr_state)
            receberinput1: begin
            // recebe input do keypad
            end
            receberinput2: begin
            //recebe input2 do keypad
            end
            soma: begin
            result = in1 + in2;
            end
            
            sub: begin
            result = in2 - in1;
            end
            
            mult: begin
            result = in1 * in2;
            end
        
        endcase
    
    end

    always @ (posedge clock) begin //MAQUINA DE ESTADOS
        case (curr_state)
            soma: begin
                if (A == 1) begin 
                    curr_state <= soma; 
                end
                //if(D == 1) desligar display
            end
            
            sub: begin
                if (B == 1) begin
                    curr_state <= sub;
                end
                //if(D == 1) desligar display
            end
            
            mult: begin
                if (C == 1) begin 
                    curr_state <= mult;
                end  
                //if(D == 1) desligar display
            end
            receberinput1: begin
                if(X == 1) begin
                    curr_state <= receberinput1;
                end
            end
            receberinput2: begin
                if(Y == 1) begin
                    curr_state <= receberinput2;
                end
            end
        endcase
    
    end

endmodule