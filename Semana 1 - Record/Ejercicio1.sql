--Una plataforma de venta de entradas necesita generar un resumen de una transacción. Para una transacción determinada se necesita conocer el nombre del cliente, el monto bruto de la compra, el descuento aplicado, el monto final pagado y el estado del pago.
SELECT * FROM TRANSACCION_PAGO;
SELECT * FROM RESERVA_TEMPORAL;
SELECT c.NOMBRE, rt.ESTADO as ESTADO_DE_LA_RESERVA, tp.ESTADO AS ESTADO_DE_PAGO, tp.MONTO_BRUTO, tp.DESCUENTO, tp.MONTO_FINAL  FROM CLIENTE c
JOIN RESERVA_TEMPORAL rt ON rt.CLIENTE_ID = c.CLIENTE_ID
JOIN TRANSACCION_PAGO tp ON tp.RESERVA_ID = rt.RESERVA_ID
WHERE c.CLIENTE_ID = 1;


DECLARE 
    TYPE boleta_cliente IS RECORD(
        nombre_cliente CLIENTE.NOMBRE%TYPE,
        estado_reserva RESERVA_TEMPORAL.ESTADO%TYPE,
        estado_pago TRANSACCION_PAGO.ESTADO%TYPE,
        monto_bruto TRANSACCION_PAGO.MONTO_BRUTO%TYPE,
        descuento_monto TRANSACCION_PAGO.DESCUENTO%TYPE,
        monto_final TRANSACCION_PAGO.MONTO_FINAL%TYPE
    );

    v_boleta boleta_cliente;
BEGIN

    SELECT c.NOMBRE, rt.ESTADO as ESTADO_DE_LA_RESERVA, tp.ESTADO AS ESTADO_DE_PAGO, tp.MONTO_BRUTO, tp.DESCUENTO, tp.MONTO_FINAL INTO v_boleta.nombre_cliente, v_boleta.estado_reserva, v_boleta.estado_pago, v_boleta.monto_bruto, v_boleta.descuento_monto , v_boleta.monto_final FROM CLIENTE c
    JOIN RESERVA_TEMPORAL rt ON rt.CLIENTE_ID = c.CLIENTE_ID
    JOIN TRANSACCION_PAGO tp ON tp.RESERVA_ID = rt.RESERVA_ID
    WHERE c.CLIENTE_ID = 1;

    DBMS_OUTPUT.PUT_LINE('***** PUNTO TICKET DUOCUC EL MEJOR *****');
    DBMS_OUTPUT.PUT_LINE('||||| NOMBRE DEL CLIENTE   |||||' || v_boleta.nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('||||| ESTADO DE LA RESERVA |||||' || v_boleta.estado_reserva);
    DBMS_OUTPUT.PUT_LINE('||||| ESTADO DEL PAGO      |||||' || v_boleta.estado_pago);
    DBMS_OUTPUT.PUT_LINE('||||| MONTO BRUTO          |||||' || v_boleta.monto_bruto);
    DBMS_OUTPUT.PUT_LINE('||||| DESCUENTO TOTAL      |||||' || v_boleta.descuento_monto);
    DBMS_OUTPUT.PUT_LINE('||||| MONTO FINAL          |||||' || v_boleta.monto_final);
    DBMS_OUTPUT.PUT_LINE('***** ADIOS c: *****');
END;