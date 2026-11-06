`timescale 1ns/1ps

module ALU_tb;

    // 1. Señales de entrada
    logic [7:0] a, b;
    logic [1:0] operador;
    logic reset, clk, enable;
    logic [7:0] random_a, random_b;
    logic [1:0] random_op;

    // 2. Señales de salida
    logic [8:0] m_result;
    logic signed_mode, n, z, c;

    // 3. Conexiones
    ALU dut (
        .a(a),
        .b(b),
        .n(n),
        .z(z),
        .c(c),
        .operador(operador),
        .reset(reset),
        .clk(clk),
        .m_result(m_result),
        .signed_mode(signed_mode),
        .enable(enable)
    );

    //4. declaracion de integers
    integer i,j, k, pass_test, fail_test, total_test;
    integer random_test, seed, dummy_seed, r;
    logic [12:0] resultado_esperado;
    logic [12:0] resultado_obtenido;

    //5. inicializacion de datos
    initial begin
        total_test = 0;
        pass_test = 0;
        fail_test = 0;
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //6. Pruebas
    initial begin

    //0.1 se aplica reset
        reset = 1'b1;
        a = 8'd0;
        b = 8'd0;
        operador = 2'b00;
        enable = 1'b0;
    @(posedge clk);
    @(negedge clk);

    //primera prueba: suma
        reset = 1'b0;
        a = 8'd10;
        b = 8'd20;
        operador = 2'b00;
        enable = 1'b1;
    @(posedge clk);
    #1;
        if (m_result == 9'd30&& n == 1'b0 && c == 1'b0 && z == 1'b0 && signed_mode == 1'b0)
            $display("PASS_1:1 10 + 20 = %0d", m_result);
        else
            $error("FAIL: esperado 30, obtenido %0d", m_result);
    
    // Segunda prueba: resta negativa
    @(negedge clk);
        a = 8'd3;
        b = 8'd5;
        operador = 2'b01;
    @(posedge clk);
    #1;
        if (m_result == 9'd510 && signed_mode == 1'b1 && c == 1'b0 && n == 1'b1 && z == 1'b0)
            $display("PASS_2:1: 3 - 5 = -2");
        else
            $error("FAIL: resta; resultado=%0d, signed_mode=%b",m_result, signed_mode);

    //tercera prueba, suma con acarreo
    @(negedge clk);
        a = 8'd255;
        b = 8'd1;
        operador = 2'b00;
    @(posedge clk);
    #1;
        if(m_result == 9'd256 && signed_mode == 1'b0 && c == 1'b1 && n == 1'b0 && z == 1'b0)
            $display("PASS_3:1: 255 + 1 = 256");
        else    
            $error("ERROR");

    //cuarta prueba, compuerta and
    @(negedge clk);
        a = 8'b01001101;
        b = 8'b10110010;
        operador = 2'b10;
    @(posedge clk);
    #1;
        if(m_result == 9'b000000000 && signed_mode == 1'b0 && c == 1'b0 && n == 1'b0 && z == 1'b1)
            $display("PASS_4:1: 01001101 & 10110010 = 00000000");
        else 
            $error("ERROR: and; resultado=%0d, signed_mode=%b", m_result, signed_mode);

    //quinta prueba, compuerta or
    @(negedge clk);
        a = 8'b01001101;
        b = 8'b10110010;
        operador = 2'b11;
    @(posedge clk);
    #1;
        if(m_result == 9'b011111111 && signed_mode == 1'b0 && c == 1'b0 && n == 1'b0 && z == 1'b0)
            $display("PASS_5:1: 01001101 | 10110010 = 11111111");
        else 
            $error("ERROR: OR; resultado=%0d, signed_mode=%b", m_result, signed_mode);

     //sexta prueba, reloj
    @(negedge clk);
        a = 8'd10;
        b = 8'd20;
        operador = 2'b00;
    @(posedge clk);
    #1;
        if(m_result == 9'd30 && signed_mode == 1'b0)
            $display("PASS_6:1, 10+20=30");
        else
            $error("ERROR: comb; resultado=%0d, signed_mode=%b", m_result, signed_mode);

    //6:2 mantener el valor
    @(negedge clk);
        a = 8'd100;
        b = 8'd80;
        operador = 2'b0;
    #1;
        if(m_result == 9'd30 && signed_mode == 1'b0)
            $display("PASS_6:2, 10+20=30, se mantiene el valor");
        else
            $error("ERROR: comb; resultado=%0d, signed_mode=%b", m_result, signed_mode);

    //6:3 actualizar valor
    @(posedge clk);
    #1;
        if(m_result == 9'd180 && signed_mode == 1'b0)
            $display("PASS_6:3, 100+80=180, se actualiza el valor");
        else
            $error("ERROR: secuencial; resultado=%0d, signed_mode=%b", m_result, signed_mode);

    //6:4 reset
    #1;
        reset = 1'b1;
    @(negedge clk);
    @(posedge clk);
    #1;
        if(m_result == 9'd0 && signed_mode == 1'b0 && z == 1'b0 && c == 1'b0 && n == 1'b0)
            $display("PASS_6:4, reset funcionando");
        else
            $error("ERROR: reset; resultado=%0d, signed_mode=%b", m_result, signed_mode);
        reset = 1'b0;

    //6:5 final
    @(negedge clk);
    @(posedge clk);
    #1;
        if(m_result == 9'd180 && signed_mode == 1'b0)
            $display("PASS_6:5, 100+80=180, vuelve la suma");
        else
            $error("ERROR: secuencial; resultado=%0d, signed_mode=%b", m_result, signed_mode);


    //7:1 aritmetica
    @(negedge clk);
        a = 8'd0;
        b = 8'd1;
        operador = 2'b01;
    @(posedge clk);
    #1;
        if(m_result == 9'd511 && signed_mode == 1'b1 && c == 1'b0 && n == 1'b1)
            $display("PASS_7:1, 0-1=-1");
        else 
            $error("ERROR: aritmetico; resultado=%0d, signed_mode=%b", m_result, signed_mode);

    //(8:1 resta negativa)
    @(negedge clk);
        a = 8'd0;
        b = 8'd1;
        operador = 2'b01;
    @(posedge clk);
    #1;
        if (m_result == 9'd511 && signed_mode == 1'b1 && c == 1'b0 && n == 1'b1 && z == 1'b0)
            $display("PASS: flags para 0 - 1");
        else
            $error("FAIL: 0-1: result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    // 8:2 comprobar 0
    @(negedge clk);
        a = 8'd5;
        b = 8'd5;
        operador = 2'b01;
        enable = 1'b1;
    @(posedge clk);
    #1;
        if (m_result == 9'd0 && c == 1'b1 && n == 1'b0 && z == 1'b1)
            $display("PASS: flags para 5 - 5");
        else
            $error("FAIL: 5-5: result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    // 9:0 enable
    @(negedge clk);
        a = 8'd156;
        b = 8'd202;
        operador = 2'b00;
        enable = 1'b0;
        reset = 1'b1;
    @(posedge clk);
    #1;
        reset = 1'b0;
        if (m_result == 9'd0 && c == 1'b0 && n == 1'b0 && z == 1'b0)
            $display("PASS_9:0 reset");
        else
            $error("ERROR secuencial");

    // 9:1 enable.1
    #1;
        enable = 1'b1;
    @(posedge clk);
    #1;
        if (m_result == 9'd358 && c == 1'b1 && n == 1'b0 && z == 1'b0)
            $display("PASS_9:1, enable funcionando");
        else 
            $error("FAIL:_):1: result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    // 9:2 combinacional
    @(negedge clk);
        enable = 1'b0;
        a = 8'd255;
    @(posedge clk);
    #1;
        enable = 1'b1;
        if (m_result == 9'd358 && c == 1'b1 && n == 1'b0 && z == 1'b0)
            $display("PASS_9:2, parte combinacional funcionando");
        else 
            $error("FAIL:_):1: result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    //9:3
    @(negedge clk);
        b = 8'd5;
    #1;
        enable = 1'b0;
    #1;
        enable = 1'b1;
    @(posedge clk);
    #1;
        if (m_result == 9'd260 && c == 1'b1 && n == 1'b0 && z == 1'b0)
            $display("PASS_9:2, parte 9:3");
        else 
            $error("FAIL:_):1: result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    // prueba 9:4 reset y enable
    @(negedge clk);
        enable = 1'b1;
        reset = 1'b1;
        a = 8'd3;
        b = 8'd5;
        operador = 2'b01;
    @(posedge clk);
    #1;
        if (m_result == 9'd0 && c == 1'b0 && n == 1'b0 && z == 1'b0)
            $display("PASS_9:4 reset con prioridad");
        else
            $error("ERROR de reset result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    //prueba 9:5 quito reset
    @(negedge clk);
        reset = 1'b0;
    @(posedge clk);
    #1;
        if (m_result == 9'd510 && c == 1'b0 && n == 1'b1 && z == 1'b0)
            $display("PASS_9:5 resta y banderas actualizadas");
        else
            $error("ERROR de actualizacion result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    //prueba 9:6 registros en el tiempo
    @(posedge clk);
    @(negedge clk);
        enable = 1'b0;
        a = 8'd200;
        b = 8'd100;
        operador = 2'b00;
    @(posedge clk);
    @(negedge clk);
    @(posedge clk);
    @(negedge clk);
    @(posedge clk);
    @(negedge clk);
    @(posedge clk);
    #1;
        if (m_result == 9'd510 && c == 1'b0 && n == 1'b1 && z == 1'b0 && signed_mode == 1'b1)
            $display("PASS_9:6 resta y banderas guardadas");
        else
            $error("ERROR de dato result=%b C=%b N=%b Z=%b",m_result, c, n, z);

    //task operacion
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1)begin
                for (k = 0; k < 4;k = k + 1)begin
                resultado_esperado = reference_model(i, j, k);
                test_operations(i, j, k, resultado_esperado);   //conexion con universal task
                end
            end
        end

    //random_testing
        random_test = 1000;
        seed = 32'd12345;
        dummy_seed = $urandom(seed);

        for (r = 0; r < random_test; r = r + 1) begin

            random_a = $urandom_range(0,255);
            random_b = $urandom_range(0,255);
            random_op = $urandom_range(0,3);
                if (r < 10)
                    $display("RANDOM %0d: A=%0d B=%0d OP=%b",r, random_a, random_b, random_op);

            resultado_esperado = reference_model(random_a, random_b, random_op);
            test_operations(random_a, random_b, random_op, resultado_esperado);                   //conexion con universal task

        end

    //random_testing suma
        random_test = 1000;
        random_op = 2'b00;

        for (r = 0; r < random_test; r = r + 1) begin

            random_a = $urandom_range(1,255);
            random_b = 255;
                if (r < 10)
                    $display("RANDOM %0d: A=%0d B=%0d OP=%b",r, random_a, random_b, random_op);

            resultado_esperado = reference_model(random_a, random_b, random_op);
            test_operations(random_a, random_b, random_op, resultado_esperado);

        end

    //random_testing resta negativa
        random_test = 1000;
        random_op = 2'b01;

        for (r = 0; r < random_test; r = r + 1) begin

            random_a = $urandom_range(0,254);
            random_b = $urandom_range(random_a+1,255);
                if (r < 10)
                    $display("RANDOM %0d: A=%0d B=%0d OP=%b",r, random_a, random_b, random_op);

            resultado_esperado = reference_model(random_a, random_b, random_op);
            test_operations(random_a, random_b, random_op, resultado_esperado);

        end

    //random_testing resta = 0
        random_test = 1000;
        random_op = 2'b01;

        for (r = 0; r < random_test; r = r + 1) begin

            random_a = $urandom_range(0,255);
            random_b = random_a;
                if (r < 10)
                    $display("RANDOM %0d: A=%0d B=%0d OP=%b",r, random_a, random_b, random_op);

            resultado_esperado = reference_model(random_a, random_b, random_op);
            test_operations(random_a, random_b, random_op, resultado_esperado);

        end

    //random_testing and = 0
        random_test = 1000;
        random_op = 2'b10;

        for (r = 0; r < random_test; r = r + 1) begin

            random_a = $urandom_range(0,255);
            random_b = ~random_a;
                if (r < 10)
                    $display("RANDOM %0d: A=%0d B=%0d OP=%b",r, random_a, random_b, random_op);

            resultado_esperado = reference_model(random_a, random_b, random_op);
            test_operations(random_a, random_b, random_op, resultado_esperado);

        end

    //random_testing or = 255
        random_test = 1000;
        random_op = 2'b11;

        for (r = 0; r < random_test; r = r + 1) begin

            random_a = $urandom_range(0,255);
            random_b = ~random_a;
                if (r < 10)
                    $display("RANDOM %0d: A=%0d B=%0d OP=%b",r, random_a, random_b, random_op);

            resultado_esperado = reference_model(random_a, random_b, random_op);
            test_operations(random_a, random_b, random_op, resultado_esperado);

        end
        $display ("Passed test =%d\nFailed test =%d\nTotal test =%d"
                    ,pass_test,fail_test,total_test);   
//fin de initial
//    $finish;
$stop;
end




//task universal
task test_operations(
input logic [7:0] a_test,b_test,
input logic [1:0] op_test,
input logic [12:0] esperado
);
begin 
    @(negedge clk);
        a = a_test;
        b = b_test;
        operador = op_test;
        enable  = 1'b1;
    @(posedge clk);
    #1;
    resultado_obtenido = {z, c, n, signed_mode, m_result};
    scoreboard(esperado, resultado_obtenido);
end
endtask

// ASERTIONS

//p_reset
property p_reset;
    @(posedge clk)
    reset |=> (m_result == 0 && signed_mode == 0 && c == 0 && n == 0 && z == 0);
endproperty

assert property (p_reset)
    else begin
    fail_test = fail_test + 1;
    $error("reset fallando");
    end

//p_enable
property p_enable;
    @(posedge clk)
    (!reset && enable) |=> (m_result == $past(expected_comb[8:0]) && signed_mode == $past(expected_comb[9]) && n == $past(expected_comb[10]) && c == $past(expected_comb[11]) && z == $past(expected_comb[12]));
endproperty

assert property (p_enable) 
    else begin
    fail_test = fail_test + 1;
    $error("enable fallando");
    end

//p_save
property p_save;
    @(posedge clk)
    (!reset && !enable) |=> (m_result == $past(m_result) && signed_mode == $past(signed_mode) && n == $past(n) && c == $past(c) && z == $past(z));
endproperty

assert property (p_save) 
    else begin
    fail_test = fail_test + 1;
    $error("save fallando");
    end

//prioridad
property p_prioridad;
    @(posedge clk)
    (reset && enable) |=> (m_result == 0 && signed_mode == 0 && c == 0 && n == 0 && z == 0);
endproperty

assert property (p_prioridad) 
    else begin
    fail_test = fail_test + 1;
    $error("prioridad fallando");
    end

//SCOREBOARD
task scoreboard(
    input logic [12:0] esperado, obtenido
    );
    begin
    total_test = total_test + 1;
        if (obtenido === esperado)
            begin
                pass_test = pass_test + 1;
            end
        else
            begin
                fail_test = fail_test +1;
                $error("FAIL: esperado=%0b, obtenido=%0b",esperado, obtenido);
            end
    end
endtask

//funcion
function automatic logic [12:0] reference_model(
    input logic [7:0] a,b,
    input logic [1:0] op
);
    //señales intermedias
    logic [12:0] build;
    logic [8:0] expected_result;
    logic expected_signed_mode, expected_n, expected_c, expected_z;

    begin
    //iniciando variables en 0
        build = 13'd0;
        expected_result = 9'd0;
        expected_signed_mode = 1'b0;
        expected_n = 1'b0;
        expected_c = 1'b0;
        expected_z = 1'b0;

    //operaciones
    case (op)
        //suma
        2'b00: begin 
            expected_result = {1'b0,a} + {1'b0,b};
            expected_c = expected_result[8];
            expected_z = (expected_result == 0);
            expected_n = 0;
            expected_signed_mode = 0;
        end

        //resta
        2'b01: begin
            expected_result = {1'b0,a} - {1'b0,b};
            expected_c = a >= b;
            expected_n = b > a;
            expected_z = (a == b);
            expected_signed_mode = 1'b1;
        end

        //and
        2'b10: begin
            expected_result = {1'b0,(a & b)};
            expected_c = 1'b0;
            expected_n = 1'b0;
            expected_z = (expected_result == 1'b0);
            expected_signed_mode = 1'b0;
        end

        //or
        2'b11: begin
            expected_result = {1'b0,(a | b)};
            expected_c = 1'b0;
            expected_n = 1'b0;
            expected_z = (expected_result == 1'b0);
            expected_signed_mode = 1'b0;
        end
    endcase

    //calculo de salida
        build[8:0] = expected_result;
        build[9] = expected_signed_mode;
        build[10] = expected_n;
        build[11] = expected_c;
        build[12] = expected_z;
        reference_model = build;
    end

endfunction

//declaracion de expected_comb
    logic [12:0] expected_comb;

    always_comb begin
        expected_comb = reference_model(a, b, operador);
    end


endmodule