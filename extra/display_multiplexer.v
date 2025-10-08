//----------------------------------------------------------------------------------
// MODULE: display_multiplexer
// DESCRIPTION:
//              Controlador para el display de 7 segmentos de la Basys3.
//              Esta configurado para un reloj de entrada de 100 MHz y una tasa de
//              refresco de ~200 Hz. No es parametrizable.
//----------------------------------------------------------------------------------

module display_multiplexer (
    input             clk,    // Reloj del sistema (asumido 100 MHz)
    input             reset,  // Reset asincrono

    input       [6:0] pattern_3, // Digito mas a la izquierda (signo)
    input       [6:0] pattern_2, // Digito de centenas
    input       [6:0] pattern_1, // Digito de decenas
    input       [6:0] pattern_0, // Digito de unidades

    output reg  [6:0] seg,    // Salida para los 7 segmentos (catodos)
    output reg  [3:0] an      // Salida para los 4 anodos (activo bajo)
);

    // Numero de ciclos de reloj para alcanzar ~200 Hz con un reloj de 100 MHz
    localparam COUNT_MAX = 125000;

    // Contador y estado del multiplexor
    reg [16:0] refresh_counter = 0;
    reg [1:0]  digit_selector = 0;

    // Logica de Estado (Secuencial): maneja contador y estado del multiplexor.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 0;
            digit_selector  <= 0;
        end else begin
            if (refresh_counter == COUNT_MAX - 1) begin // Cada 5 ms cambiamos de digito
                refresh_counter <= 0;
                digit_selector  <= digit_selector + 1;
            end else begin
                refresh_counter <= refresh_counter + 1;
            end
        end
    end

    // --- Logica de Salida (Combinacional): controla 'seg' y 'an'.
    always @(*) begin
        if (reset) begin
            // Durante el reset, apagamos el display.
            seg = 7'h7F; 
            an  = 4'hF;  
        end else begin
            // En operacion normal, multiplexamos la salida segun el estado del multiplexor.
            case (digit_selector)
                2'b00: begin // Digito 0 (Unidades)
                    seg = pattern_0;
                    an  = 4'b1110; // Activa AN0
                end
                2'b01: begin // Digito 1 (Decenas)
                    seg = pattern_1;
                    an  = 4'b1101; // Activa AN1
                end
                2'b10: begin // Digito 2 (Centenas)
                    seg = pattern_2;
                    an  = 4'b1011; // Activa AN2
                end
                2'b11: begin // Digito 3 (Signo)
                    seg = pattern_3;
                    an  = 4'b0111; // Activa AN3
                end
                default: begin // Caso de seguridad
                    seg = 7'h7F; // Apagado
                    an  = 4'hF;  // Apagado
                end
            endcase
        end
    end

endmodule
