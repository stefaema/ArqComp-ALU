//----------------------------------------------------------------------------------
// MODULE: display_controller
// DESCRIPTION:
//              Modulo de alto nivel que integra un conversor de binario a BCD,
//              un decodificador de BCD a 7 segmentos y un multiplexor para
//              controlar un display de 4 digitos.
//----------------------------------------------------------------------------------

module display_controller (
    input        clk,          // Reloj del sistema (100 MHz)
    input        reset,        // Reset asincrono
    input  [7:0] binary_in,    // Numero de 8 bits con signo a mostrar
    output [6:0] seg,          // Salida para los segmentos del display
    output [3:0] an            // Salida para los anodos del display
);

    // --- Seniales internas para la interconexion de los modulos ---
    wire       negative;
    wire [3:0] bcd_hundreds;
    wire [3:0] bcd_tens;
    wire [3:0] bcd_units;

    wire [6:0] pattern_sign;
    wire [6:0] pattern_hundreds;
    wire [6:0] pattern_tens;
    wire [6:0] pattern_units;


    // --- Instanciacion de los tres modulos (cajas negras) ---

    // 1. Convierte el numero binario de entrada a sus digitos BCD y signo.
    number_formatter u_formatter (
        .binary_in    (binary_in),
        .negative     (negative),
        .bcd_hundreds (bcd_hundreds),
        .bcd_tens     (bcd_tens),
        .bcd_units    (bcd_units)
    );

    // 2. Convierte los digitos BCD y el signo a patrones de 7 segmentos.
    bcd_to_ss u_decoder (
        .negative       (negative),
        .bcd_hundreds   (bcd_hundreds),
        .bcd_tens       (bcd_tens),
        .bcd_units      (bcd_units),
        .pattern_sign     (pattern_sign),
        .pattern_hundreds (pattern_hundreds),
        .pattern_tens     (pattern_tens),
        .pattern_units    (pattern_units)
    );

    // 3. Gestiona el refresco del display, mostrando cada digito secuencialmente.
    display_multiplexer u_mux (
        .clk       (clk),
        .reset     (reset),
        .pattern_3 (pattern_sign),
        .pattern_2 (pattern_hundreds),
        .pattern_1 (pattern_tens),
        .pattern_0 (pattern_units),
        .seg       (seg),
        .an        (an)
    );

endmodule
