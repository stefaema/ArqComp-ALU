//----------------------------------------------------------------------------------
// MODULE: number_formatter
// DESCRIPTION:
//              Convierte un numero de 8 bits con signo a tres digitos BCD
//              usando el algoritmo "Shift-and-Add-3" (Double Dabble) para
//              una implementacion de hardware optima.
//----------------------------------------------------------------------------------

module number_formatter (
    input  [7:0] binary_in,      // Numero de entrada de 8 bits con signo
    output       negative,       // Bit que indica si el numero es negativo
    output [3:0] bcd_hundreds,  // Digito BCD para las centenas
    output [3:0] bcd_tens,      // Digito BCD para las decenas
    output [3:0] bcd_units      // Digito BCD para las unidades
);


    wire [7:0] abs_value;
    assign negative = binary_in[7];
    assign abs_value = negative ? (~binary_in + 1'b1) : binary_in;

    // --- Implementacion del algoritmo "Double Dabble" ---
    // Se necesitan 8 etapas de correccion y desplazamiento para un input de 8 bits.
    // Usamos wires para representar el flujo de datos a traves de cada etapa.
    // Formato del bus intermedio: {centenas, decenas, unidades, resto_binario}

    // Etapa 0 (Entrada inicial)
    wire [19:0] stage0_shifted = {12'd0, abs_value}; // {BCD_H, BCD_T, BCD_U, BIN}

    // Wires para las etapas intermedias
    wire [19:0] stage1_corrected, stage1_shifted;
    wire [19:0] stage2_corrected, stage2_shifted;
    wire [19:0] stage3_corrected, stage3_shifted;
    wire [19:0] stage4_corrected, stage4_shifted;
    wire [19:0] stage5_corrected, stage5_shifted;
    wire [19:0] stage6_corrected, stage6_shifted;
    wire [19:0] stage7_corrected, stage7_shifted;
    wire [19:0] stage8_corrected;

    // Funcion para la correccion "Add-3". Se reutilizara en cada etapa.
    // Si el digito BCD es > 4, se le suma 3.
    function [3:0] correct_bcd;
        input [3:0] digit;
        correct_bcd = (digit > 4) ? digit + 3 : digit;
    endfunction

    // Etapa 1
    assign stage1_corrected = {correct_bcd(stage0_shifted[19:16]), correct_bcd(stage0_shifted[15:12]), correct_bcd(stage0_shifted[11:8]), stage0_shifted[7:0]};
    assign stage1_shifted = stage1_corrected << 1;

    // Etapa 2
    assign stage2_corrected = {correct_bcd(stage1_shifted[19:16]), correct_bcd(stage1_shifted[15:12]), correct_bcd(stage1_shifted[11:8]), stage1_shifted[7:0]};
    assign stage2_shifted = stage2_corrected << 1;

    // Etapa 3
    assign stage3_corrected = {correct_bcd(stage2_shifted[19:16]), correct_bcd(stage2_shifted[15:12]), correct_bcd(stage2_shifted[11:8]), stage2_shifted[7:0]};
    assign stage3_shifted = stage3_corrected << 1;

    // Etapa 4
    assign stage4_corrected = {correct_bcd(stage3_shifted[19:16]), correct_bcd(stage3_shifted[15:12]), correct_bcd(stage3_shifted[11:8]), stage3_shifted[7:0]};
    assign stage4_shifted = stage4_corrected << 1;

    // Etapa 5
    assign stage5_corrected = {correct_bcd(stage4_shifted[19:16]), correct_bcd(stage4_shifted[15:12]), correct_bcd(stage4_shifted[11:8]), stage4_shifted[7:0]};
    assign stage5_shifted = stage5_corrected << 1;

    // Etapa 6
    assign stage6_corrected = {correct_bcd(stage5_shifted[19:16]), correct_bcd(stage5_shifted[15:12]), correct_bcd(stage5_shifted[11:8]), stage5_shifted[7:0]};
    assign stage6_shifted = stage6_corrected << 1;

    // Etapa 7
    assign stage7_corrected = {correct_bcd(stage6_shifted[19:16]), correct_bcd(stage6_shifted[15:12]), correct_bcd(stage6_shifted[11:8]), stage6_shifted[7:0]};
    assign stage7_shifted = stage7_corrected << 1;
    
    // Etapa 8 (ultima correccion y desplazamiento)
    assign stage8_corrected = {correct_bcd(stage7_shifted[19:16]), correct_bcd(stage7_shifted[15:12]), correct_bcd(stage7_shifted[11:8]), stage7_shifted[7:0]};
    // El ultimo desplazamiento no es necesario ya que solo nos interesan los bits BCD

    // Asignacion final del resultado BCD
    assign bcd_hundreds = stage8_corrected[19:16];
    assign bcd_tens     = stage8_corrected[15:12];
    assign bcd_units    = stage8_corrected[11:8];

endmodule
