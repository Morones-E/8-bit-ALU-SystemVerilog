//==================================================
//Mi primera ALU 20/10/2026 
//Diseño por Diego Morones
//==================================================

module ALU(
    input logic [7:0] a,b, //operandos
    input logic [1:0] operador, //input de operación
    input logic reset,clk, enable, //inputs para logica secuencial
    output logic [8:0] m_result,  //output master
    output logic signed_mode, n, c, z //flags
);

logic[8:0] result_suma,result_and,result_or;
logic signed [8:0] result_resta; //output de resta con signo
logic n_next, c_next, z_next;

always_comb begin
    result_suma = 1'b0;
    result_resta = 1'b0;
    result_and = 1'b0;
    result_or = 1'b0;
    n_next = 1'b0;
    c_next = 1'b0;
    z_next = 1'b0;

    case (operador)
        2'b00: begin result_suma = {1'b0,a} + {1'b0,b}; //suma
          c_next = result_suma[8];
            z_next = result_suma == 0;
             end
        2'b01: begin result_resta =  {1'b0,a} - {1'b0,b}; //resta
            n_next =  result_resta[8];
            c_next = a>=b;
            z_next = result_resta == 0;
        end
        2'b10 : begin result_and = {1'b0, a & b}; //and bit a bit
                z_next = result_and == 0;
                end
        2'b11 : begin result_or = {1'b0, a | b}; //or bit a bit
                z_next = result_or == 0;
                end
    endcase
end

always_ff@(posedge clk) begin
    if (reset) begin
        m_result <= 9'd0; //resultado default del main output
        signed_mode <= 1'b0;
        c <= 1'b0;
        z <= 1'b0;
        n <= 1'b0;
    end
    else if (enable) begin
        case (operador) // seleccionando el resultado que se va al master
            2'b00: begin m_result <= result_suma;
                 signed_mode <= 1'b0;
                 end
            2'b01: begin m_result <= result_resta;
                 signed_mode <= 1'b1;
                 end
            2'b10 : begin m_result <= result_and;
                 signed_mode <= 1'b0;
                 end
            2'b11 : begin m_result <=  result_or;
                 signed_mode <= 1'b0;
                 end
            
       endcase
        z <= z_next;
        c <= c_next;
        n <= n_next;
    end
    
end
endmodule

