//----------------------------------------------------------------------------------
// TESTBENCH: simple_alu_tb
// DESCRIPTION:
//              Test bench para el modulo simple_alu.
//----------------------------------------------------------------------------------

`timescale 1ns / 1ps

module simple_alu_tb;

    // Parametros del DUT
    localparam DATA_WIDTH = 8;
    
    // Codigos de Operacion (copiados del DUT)
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;
    localparam OP_XOR = 6'b100110;
    localparam OP_SRA = 6'b000011;
    localparam OP_SRL = 6'b000010;
    localparam OP_NOR = 6'b100111;

    // Senales de Entradas (reg)
    reg [DATA_WIDTH-1:0] A;
    reg [DATA_WIDTH-1:0] B;
    reg [5:0]            Op;

    // Senales de Salida (wire)
    wire [DATA_WIDTH-1:0] Result; 
    wire                  Overflow;
    wire                  Zero;

    // Variable para el contador de pruebas
    reg [31:0] test_id_counter;

    // Instanciacion del DUT (Device Under Test)
    simple_alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .A(A),
        .B(B),
        .Op(Op),
        .Result(Result),
        .Overflow(Overflow),
        .Zero(Zero)
    );
    
    // Tarea para ejecutar una prueba y mostrar el resultado
    task run_test;
        input [DATA_WIDTH-1:0] A_in;
        input [DATA_WIDTH-1:0] B_in;
        input [5:0] Op_in;
        input [DATA_WIDTH-1:0] Result_exp;
        input                  Overflow_exp;
        input                  Zero_exp;
        
        reg [48*8:0] Op_name; // Suficientemente ancho para almacenar el string de operacion
        
        begin
            // Asignar entradas
            A = A_in;
            B = B_in;
            Op = Op_in;
            
            #10; // Esperar un tiempo para la propagacion de la logica combinacional
            
            // Incrementar contador de prueba
            test_id_counter = test_id_counter + 1;

            // Determinar el nombre de la operacion para el display
            case (Op_in)
                OP_ADD: Op_name = "ADD";
                OP_SUB: Op_name = "SUB";
                OP_AND: Op_name = "AND";
                OP_OR:  Op_name = "OR";
                OP_XOR: Op_name = "XOR";
                OP_SRA: Op_name = "SRA";
                OP_SRL: Op_name = "SRL";
                OP_NOR: Op_name = "NOR";
                default: Op_name = "DEFAULT_INVALIDA";
            endcase

            $display("----------------------------------------------------------------------------------");
            
            // Verificacion del resultado
            if (Result === Result_exp && Overflow === Overflow_exp && Zero === Zero_exp) begin
                $display("SUCCESS [%0d]: Prueba de %s superada.", test_id_counter, Op_name);
            end else begin
                $display("FAILURE [%0d]: Prueba de %s fallida.", test_id_counter, Op_name);
            end
            
            $display("Se realizo la operacion %s (A=0x%h, B=0x%h).", Op_name, A_in, B_in);
            $display("Resultado DUT: Result=0x%h, Overflow=%b, Zero=%b", Result, Overflow, Zero);
            $display("Resultado ESP: Result=0x%h, Overflow=%b, Zero=%b", Result_exp, Overflow_exp, Zero_exp);
            
            $display("----------------------------------------------------------------------------------");
        end
    endtask

    // Secuencia de pruebas
    initial begin
        test_id_counter = 0;
        $display("Inicio de la simulacion del simple_alu (DATA_WIDTH=%0d).", DATA_WIDTH);

        // Inicializacion de entradas
        A = 0;
        B = 0;
        Op = 0;
        #10;

        // ----------------------------------------------------------------
        // 1. OP_ADD: Suma (8-bit en complemento a dos)
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_ADD (Suma)");
        $display("==================================================================================");

        // Test 1: Happy Path: 5 + 10 = 15. Exp_R=0x0F, Exp_O=0, Exp_Z=0.
        run_test(8'h05, 8'h0A, OP_ADD, 8'h0F, 1'b0, 1'b0); 

        // Test 2: Borde 1: Overflow Positivo (127 + 1 = 128 (negativo)). Exp_R=0x80, Exp_O=1, Exp_Z=0.
        run_test(8'h7F, 8'h01, OP_ADD, 8'h80, 1'b1, 1'b0); 

        // Test 3: Borde 2: Overflow Negativo (-128 + -1 = -129 (positivo)). Exp_R=0x7F, Exp_O=1, Exp_Z=0.
        run_test(8'h80, 8'hFF, OP_ADD, 8'h7F, 1'b1, 1'b0); 

        // Test 4: Borde 3: Resultado Cero (5 + (-5) = 0). Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'h05, 8'hFB, OP_ADD, 8'h00, 1'b0, 1'b1); 


        // ----------------------------------------------------------------
        // 2. OP_SUB: Resta (A - B)
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_SUB (Resta)");
        $display("==================================================================================");

        // Test 5: Happy Path: 10 - 5 = 5. Exp_R=0x05, Exp_O=0, Exp_Z=0.
        run_test(8'h0A, 8'h05, OP_SUB, 8'h05, 1'b0, 1'b0); 

        // Test 6: Borde 1: Overflow Positivo (127 - (-1) = 128 (negativo)). Exp_R=0x80, Exp_O=1, Exp_Z=0.
        run_test(8'h7F, 8'hFF, OP_SUB, 8'h80, 1'b1, 1'b0); 

        // Test 7: Borde 2: Overflow Negativo (-128 - 1 = -129 (positivo)). Exp_R=0x7F, Exp_O=1, Exp_Z=0.
        run_test(8'h80, 8'h01, OP_SUB, 8'h7F, 1'b1, 1'b0); 

        // Test 8: Borde 3: Resultado Cero (5 - 5 = 0). Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'h05, 8'h05, OP_SUB, 8'h00, 1'b0, 1'b1); 


        // ----------------------------------------------------------------
        // 3. OP_AND: AND Logico
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_AND (AND Logico)");
        $display("==================================================================================");

        // Test 9: Happy Path: 0xAA & 0x55 = 0x00. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'hAA, 8'h55, OP_AND, 8'h00, 1'b0, 1'b1);

        // Test 10: Borde 1: Max value. 0xFF & 0xFF = 0xFF. Exp_R=0xFF, Exp_O=0, Exp_Z=0.
        run_test(8'hFF, 8'hFF, OP_AND, 8'hFF, 1'b0, 1'b0);

        // Test 11: Borde 2: Zero. 0xAA & 0x00 = 0x00. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'hAA, 8'h00, OP_AND, 8'h00, 1'b0, 1'b1);


        // ----------------------------------------------------------------
        // 4. OP_OR: OR Logico
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_OR (OR Logico)");
        $display("==================================================================================");

        // Test 12: Happy Path: 0xAA | 0x55 = 0xFF. Exp_R=0xFF, Exp_O=0, Exp_Z=0.
        run_test(8'hAA, 8'h55, OP_OR, 8'hFF, 1'b0, 1'b0);

        // Test 13: Borde 1: All ones. 0xFF | 0xFF = 0xFF. Exp_R=0xFF, Exp_O=0, Exp_Z=0.
        run_test(8'hFF, 8'hFF, OP_OR, 8'hFF, 1'b0, 1'b0);

        // Test 14: Borde 2: Zero. 0x00 | 0x00 = 0x00. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'h00, 8'h00, OP_OR, 8'h00, 1'b0, 1'b1);


        // ----------------------------------------------------------------
        // 5. OP_XOR: XOR Logico
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_XOR (XOR Logico)");
        $display("==================================================================================");

        // Test 15: Happy Path: 0xAA ^ 0x5A = 0xF0. Exp_R=0xF0, Exp_O=0, Exp_Z=0.
        run_test(8'hAA, 8'h5A, OP_XOR, 8'hF0, 1'b0, 1'b0);

        // Test 16: Borde 1: All ones. 0xFF ^ 0xFF = 0x00. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'hFF, 8'hFF, OP_XOR, 8'h00, 1'b0, 1'b1);

        // Test 17: Borde 2: Identity. 0xAA ^ 0x00 = 0xAA. Exp_R=0xAA, Exp_O=0, Exp_Z=0.
        run_test(8'hAA, 8'h00, OP_XOR, 8'hAA, 1'b0, 1'b0);


        // ----------------------------------------------------------------
        // 6. OP_NOR: NOR Logico
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_NOR (NOR Logico)");
        $display("==================================================================================");

        // Test 18: Happy Path: ~(0xAA | 0x55) = ~0xFF = 0x00. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'hAA, 8'h55, OP_NOR, 8'h00, 1'b0, 1'b1);

        // Test 19: Borde 1: Zero. ~(0x00 | 0x00) = ~0x00 = 0xFF. Exp_R=0xFF, Exp_O=0, Exp_Z=0.
        run_test(8'h00, 8'h00, OP_NOR, 8'hFF, 1'b0, 1'b0);

        // Test 20: Borde 2: All ones. ~(0xFF | 0xFF) = ~0xFF = 0x00. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'hFF, 8'hFF, OP_NOR, 8'h00, 1'b0, 1'b1);


        // ----------------------------------------------------------------
        // 7. OP_SRL: Shift Right Logical (A >> 1)
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_SRL (Shift Right Logical)");
        $display("==================================================================================");

        // Test 21: Happy Path: 0xA5 (10100101) >> 1 = 0x52 (01010010). Exp_R=0x52, Exp_O=0, Exp_Z=0.
        run_test(8'hA5, 8'h00, OP_SRL, 8'h52, 1'b0, 1'b0);

        // Test 22: Borde 1: LSB lost (0x01 >> 1 = 0x00). Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'h01, 8'h00, OP_SRL, 8'h00, 1'b0, 1'b1);

        // Test 23: Borde 2: MSB is one (0x80 >> 1 = 0x40). Exp_R=0x40, Exp_O=0, Exp_Z=0.
        run_test(8'h80, 8'h00, OP_SRL, 8'h40, 1'b0, 1'b0);


        // ----------------------------------------------------------------
        // 8. OP_SRA: Shift Right Arithmetic
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: OP_SRA (Shift Right Arithmetic)");
        $display("==================================================================================");

        // Test 24: Happy Path Positivo: 0x2A (00101010) >> 1 = 0x15 (00010101). Exp_R=0x15, Exp_O=0, Exp_Z=0.
        run_test(8'h2A, 8'h00, OP_SRA, 8'h15, 1'b0, 1'b0);

        // Test 25: Borde 1 Negativo: 0x8A (10001010) >> 1 = 0xC5 (11000101). Exp_R=0xC5, Exp_O=0, Exp_Z=0.
        run_test(8'h8A, 8'h00, OP_SRA, 8'hC5, 1'b0, 1'b0);

        // Test 26: Borde 2 Max Negativo: 0x80 (10000000) >> 1 = 0xC0 (11000000). Exp_R=0xC0, Exp_O=0, Exp_Z=0.
        run_test(8'h80, 8'h00, OP_SRA, 8'hC0, 1'b0, 1'b0);
        
        // ----------------------------------------------------------------
        // 9. Default/Operacion No Valida
        // ----------------------------------------------------------------
        $display("\n==================================================================================");
        $display("SECCION: Operacion No Valida");
        $display("==================================================================================");

        // Test 27: Op Invalida: 6'b000001. El DUT deberia devolver Result=0. Exp_R=0x00, Exp_O=0, Exp_Z=1.
        run_test(8'hAA, 8'h55, 6'b000001, 8'h00, 1'b0, 1'b1);
        
        $display("\nSimulacion Finalizada.");
        $finish;
    end

endmodule
