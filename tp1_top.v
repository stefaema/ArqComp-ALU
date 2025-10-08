//----------------------------------------------------------------------------------
// MODULE: tp1_top
// DESCRIPTION:
//              Modulo principal que integra los registros de entrada, la ALU y el controlador
//              del display para una placa de desarrollo Basys 3.
//----------------------------------------------------------------------------------

module tp1_top #(
    parameter DATA_WIDTH = 8
) (
    // Entradas de la Placa
    input  wire CLK100MHZ,
    input  wire [15:0] SW,
    input  wire BTN_UP,
    input  wire BTN_LEFT,
    input  wire BTN_RIGHT,
    input  wire BTN_DOWN,

    output wire [15:0] LED,

    // Salidas al Display de 7 Segmentos
    output wire [6:0] seg,
    output wire [3:0] an
);

    // --- Seniales Internas para Interconexion ---

    // Salidas de los registros
    wire [DATA_WIDTH-1:0] dato_A_out;
    wire [DATA_WIDTH-1:0] dato_B_out;
    wire [5:0]            op_code_out;

    // Salidas de la ALU
    wire [DATA_WIDTH-1:0] alu_result;
    wire                  overflow_flag;
    wire                  zero_flag;


    // --- 1. Instanciacion de los Registros de Entrada ---

    // Registro para el Operando A
    register #(
        .WIDTH(DATA_WIDTH)
    ) reg_A_inst (
        .clk(CLK100MHZ),
        .reset(BTN_UP),
        .load_en(BTN_LEFT),
        .data_in(SW[DATA_WIDTH-1:0]),
        .data_out(dato_A_out)
    );

    // Registro para el Operando B
    register #(
        .WIDTH(DATA_WIDTH)
    ) reg_B_inst (
        .clk(CLK100MHZ),
        .reset(BTN_UP),
        .load_en(BTN_RIGHT),
        .data_in(SW[DATA_WIDTH-1:0]),
        .data_out(dato_B_out)
    );

    // Registro para el Codigo de Operacion
    register #(
        .WIDTH(6) // El codigo de operacion es de 6 bits
    ) reg_Op_inst (
        .clk(CLK100MHZ),
        .reset(BTN_UP),
        .load_en(BTN_DOWN),
        .data_in(SW[5:0]),
        .data_out(op_code_out)
    );

    // --- 2. Instanciacion de la ALU ---

    simple_alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_inst (
        .A(dato_A_out),
        .B(dato_B_out),
        .Op(op_code_out),
        .Result(alu_result),
        .Overflow(overflow_flag),
        .Zero(zero_flag)
    );

    // --- 3. Instanciacion del Controlador del Display. No es parametrizable en ancho. Asume width=8 ---

    display_controller display_inst (
        .clk(CLK100MHZ),
        .reset(BTN_UP),
        .binary_in(alu_result),
        .seg(seg),
        .an(an)
    );
    
    assign LED[DATA_WIDTH-1:0] = alu_result;            // LEDs 0-7 muestran el resultado
    assign LED[15] = overflow_flag;                     // LED 15 muestra el flag de Overflow
    assign LED[14] = zero_flag;                         // LED 14 muestra el flag de Zero
    assign LED[13:DATA_WIDTH] = 6'b000000;              // Apagar los LEDs restantes
endmodule
