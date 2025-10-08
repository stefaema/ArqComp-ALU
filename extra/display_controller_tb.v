`timescale 1ns / 1ps
//----------------------------------------------------------------------------------
// TESTBENCH: display_controller_tb
// DESCRIPTION:
//              Testbench para el modulo 'display_controller'.
//              Decodifica las salidas 'seg' y 'an'
//              para imprimir el contenido del display
//              directamente en la consola del simulador.
//----------------------------------------------------------------------------------

module display_controller_tb;

    // --- Constantes ---
    localparam CLK_PERIOD = 10; // Reloj de 100 MHz

    // --- Seniales de Interconexion ---
    reg clk;
    reg reset;
    reg [7:0] binary_in;

    wire [6:0] seg;
    wire [3:0] an;

    // --- Instancia del Modulo Bajo Prueba (DUT) ---
    display_controller uut (
        .clk(clk),
        .reset(reset),
        .binary_in(binary_in),
        .seg(seg),
        .an(an)
    );


    // --- Generador de Reloj ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end


    // --- Secuencia de Prueba Principal ---
    initial begin
        $display("--- Iniciando Simulacion del Display Controller ---");
        
        // 1. Aplicar Reset
        reset = 1;
        binary_in = 8'd0;
        #(CLK_PERIOD * 5); // Mantener el reset por 5 ciclos
        reset = 0;
        #(CLK_PERIOD);
        
        // 2. Probar una secuencia de valores
        test_value(8'd0, "Cero");
        test_value(8'd42, "Numero positivo de dos digitos");
        test_value(8'd127, "Maximo positivo");
        test_value(8'sb11111111, "Menos uno (-1)"); // 8'sb es 'signed binary'
        test_value(-99, "Numero negativo de dos digitos"); // 8'sd es 'signed decimal'
        test_value(-128, "Minimo negativo");
        test_value(8'd100, "Limite de centenas");

        $display("--- Simulacion Completada ---");
        $finish;
    end

    // Tarea para aplicar un valor y esperar un tiempo para que se vea
    task test_value;
        input [7:0] value;
        input [8*30:1] description;
        begin
            $display("\n>> Probando: %s (%d)", description, $signed(value));
            binary_in = value;
            #50_000_000; // Esperar 50ms de tiempo simulado
        end
    endtask


    //==============================================================================
    // LOGICA DE "LECTURA" DEL DISPLAY VIRTUAL 
    //==============================================================================

    reg [6:0] captured_patterns [3:0]; // Array para guardar el patron de cada digito
                                       // [3]: Signo, [2]: C, [1]: D, [0]: U

    // Proceso 1: Captura el patron de segmentos cuando un anodo esta activo
    always @(posedge clk) begin
        case (an)
            4'b1110: captured_patterns[0] <= seg; // Digito 0 (Unidades)
            4'b1101: captured_patterns[1] <= seg; // Digito 1 (Decenas)
            4'b1011: captured_patterns[2] <= seg; // Digito 2 (Centenas)
            4'b0111: captured_patterns[3] <= seg; // Digito 3 (Signo)
        endcase
    end

    // Proceso 2: Imprime el estado decodificado del display cada 10ms
    initial begin
        forever begin
            #10_000_000; // Esperar 10ms de tiempo simulado
            $display("Display: [ %c%c%c%c ]",
                seg_to_char(captured_patterns[3]),
                seg_to_char(captured_patterns[2]),
                seg_to_char(captured_patterns[1]),
                seg_to_char(captured_patterns[0])
            );
        end
    end

    // Funcion: Convierte un patron de 7 segmentos de vuelta a un caracter
    function [7:0] seg_to_char;
        input [6:0] pattern;
        begin
            case (pattern)
                // Patrones para anodo comun (activo en bajo)
                7'b1000000: seg_to_char = "0";
                7'b1111001: seg_to_char = "1";
                7'b0100100: seg_to_char = "2";
                7'b0110000: seg_to_char = "3";
                7'b0011001: seg_to_char = "4";
                7'b0010010: seg_to_char = "5";
                7'b0000010: seg_to_char = "6";
                7'b1111000: seg_to_char = "7";
                7'b0000000: seg_to_char = "8";
                7'b0010000: seg_to_char = "9";
                7'b0111111: seg_to_char = "-";     // Signo negativo
                7'b1111111: seg_to_char = " ";     // Digito apagado
                default:    seg_to_char = "?";     // Patron desconocido
            endcase
        end
    endfunction

endmodule
