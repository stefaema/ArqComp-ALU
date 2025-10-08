`timescale 1ns / 1ps
//----------------------------------------------------------------------------------
// TESTBENCH: register_tb
// DESCRIPTION:
//              Testbench para el modulo 'register'.
//              Verifica el comportamiento de reset, carga y mantenimiento del valor.
//----------------------------------------------------------------------------------

module register_tb;
    
    // --- 1. Definición de Parámetros y Señales del TB ---
    parameter WIDTH = 8;
    reg clk = 0;        
    reg reset = 1;      
    reg load_en = 0;
    reg [WIDTH-1:0] data_in = 0;
    wire [WIDTH-1:0] data_out; 
    
    parameter CLK_PERIOD = 10; // 10 ns (100 MHz)

    // --- Instanciación del Módulo Bajo Prueba (DUT) ---
    register #(.WIDTH(WIDTH)) DUT (
        .clk(clk),
        .reset(reset),
        .load_en(load_en),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // --- 2. Generación del Clock ---
    always #(CLK_PERIOD/2) clk = ~clk;

    // --- 3. Bloque de Estímulo y Reporte ---
    initial begin
        $display("---------------------------------------------------------------------------------------");
        $display("--- INICIO DE PRUEBAS DEL REGISTRO SINCRONO CON ENABLE (WIDTH=%0d) ---", WIDTH);
        $display("---------------------------------------------------------------------------------------");
        
        // 3.1. PRUEBA DE RESET (Asíncrono)
        $display("T=%0t (ns): INICIO. Reset Activo. Data_in=%h", $time, data_in);
        data_in = 8'hAA;    // Poner un valor conocido en data_in
        #CLK_PERIOD;        // Esperar un ciclo completo (asegurar que el reset hizo efecto)
        
        $display("T=%0t (ns): Verificando RESET. Salida es %h, DEBERIA ser 00", $time, data_out);
        if (data_out != 8'h00) $display(">>> ERROR: FALLO en RESET. Valor: %h", data_out);
        
        reset = 0;
        $display("T=%0t (ns): Accion: RESET Desactivado. Carga Habilitada para el siguiente flanco.", $time);
        $display("---------------------------------------------------------------------------------------");


        // 3.2. PRUEBA DE CARGA 1 (Dato: 8'h55)
        data_in = 8'h55;
        load_en = 1;        
        $display("T=%0t (ns): Entrada ha cambiado a %h y Carga Habilitada.", $time, data_in);

        #CLK_PERIOD;        // Esperar un ciclo (data_out debe cargar '55' en el flanco de subida)
        
        $display("T=%0t (ns): Verificando CARGA 1. Salida es %h, DEBERIA ser 55", $time, data_out);
        if (data_out != 8'h55) $display(">>> ERROR: FALLO en CARGA 1. Valor: %h", data_out);
        $display("---------------------------------------------------------------------------------------");


        // 3.3. PRUEBA DE HOLD (Mantener - Dato de entrada cambia a 8'hFF)
        load_en = 0;        
        data_in = 8'hFF;     
        $display("T=%0t (ns): Accion: Carga Deshabilitada. Entrada ha cambiado a %h (para probar Hold).", $time, data_in);
        
        #(CLK_PERIOD * 3);    // Esperar 3 ciclos
        
        $display("T=%0t (ns): Verificando HOLD. Salida es %h, DEBERIA seguir siendo 55", $time, data_out);
        if (data_out != 8'h55) $display(">>> ERROR: FALLO en HOLD. Valor: %h", data_out);
        $display("---------------------------------------------------------------------------------------");


        // 3.4. PRUEBA DE CARGA 2 (Dato: 8'hA3)
        data_in = 8'hA3;     
        load_en = 1;        
        $display("T=%0t (ns): Entrada ha cambiado a %h y Carga Habilitada.", $time, data_in);

        #CLK_PERIOD;        // Esperar un ciclo (data_out debe cargar 'A3')
        
        $display("T=%0t (ns): Verificando CARGA 2. Salida es %h, DEBERIA ser a3", $time, data_out);
        if (data_out != 8'hA3) $display(">>> ERROR: FALLO en CARGA 2. Valor: %h", data_out);
        
        $display("---------------------------------------------------------------------------------------");
        $display(">>> FIN DE PRUEBAS. Si no hubo errores, el disenio es correcto.");
        #(CLK_PERIOD * 2);
        $finish; 
    end

endmodule
