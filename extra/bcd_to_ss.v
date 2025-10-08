//----------------------------------------------------------------------------------
// MODULE: bcd_to_ss (BCD to Seven Segment)
// DESCRIPTION:
//              Modulo combinacional que convierte tres digitos BCD y una senial de
//              negativo en cuatro patrones de 7 segmentos. Esta diseniado para displays
//              de anodo comun (activo bajo), donde un '0' enciende un segmento.
//----------------------------------------------------------------------------------

module bcd_to_ss (
    input        negative,       // Senial de signo (1 = negativo)
    input  [3:0] bcd_hundreds,   // Digito BCD centenas
    input  [3:0] bcd_tens,       // Digito BCD decenas
    input  [3:0] bcd_units,      // Digito BCD unidades
    
    output [6:0] pattern_sign,     // Para el digito mas a la izquierda (AN3)
    output [6:0] pattern_hundreds, // Para el digito de centenas (AN2)
    output [6:0] pattern_tens,     // Para el digito de decenas (AN1)
    output [6:0] pattern_units     // Para el digito de unidades (AN0)
);

    // Convierte un digito BCD de 4 bits al patron de 7 segmentos correspondiente.
    function [6:0] get_pattern;
        input [3:0] bcd_digit;
        begin
            case (bcd_digit)
                //    (0=ON, 1=OFF)       gfedcba 
                4'h0: get_pattern    = 7'b1000000; // 0
                4'h1: get_pattern    = 7'b1111001; // 1
                4'h2: get_pattern    = 7'b0100100; // 2
                4'h3: get_pattern    = 7'b0110000; // 3
                4'h4: get_pattern    = 7'b0011001; // 4
                4'h5: get_pattern    = 7'b0010010; // 5
                4'h6: get_pattern    = 7'b0000010; // 6
                4'h7: get_pattern    = 7'b1111000; // 7
                4'h8: get_pattern    = 7'b0000000; // 8
                4'h9: get_pattern    = 7'b0010000; // 9
                default: get_pattern = 7'b1111111; // OFF
            endcase
        end
    endfunction

    // 1. Digito del Signo:
    assign pattern_sign = negative ? 7'b0111111 : 7'b1111111;

    // 2. Digitos Numericos:
    assign pattern_hundreds = get_pattern(bcd_hundreds);
    assign pattern_tens     = get_pattern(bcd_tens);
    assign pattern_units    = get_pattern(bcd_units);

endmodule
