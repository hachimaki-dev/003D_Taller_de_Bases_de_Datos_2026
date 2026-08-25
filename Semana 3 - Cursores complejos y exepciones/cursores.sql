
--Tenemos que entender cual es la data que queremos consultar

SELECT * FROM CLIENTE;

DECLARE 
    CURSOR c_clientes IS 
        SELECT * FROM CLIENTE;

    v_contador NUMBER := 1;
BEGIN
    FOR por_cada_cliente in c_clientes LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre' || por_cada_cliente.NOMBRE);
        DBMS_OUTPUT.PUT_LINE('Vuelta numero : ' || v_contador);
        v_contador := v_contador + 1;
    END LOOP;
    null;
END;
/




SELECT * FROM RESERVA_TEMPORAL;

 SELECT c.NOMBRE, rt.ESTADO as ESTADO_DE_LA_RESERVA, tp.ESTADO AS ESTADO_DE_PAGO, tp.MONTO_BRUTO, tp.DESCUENTO, tp.MONTO_FINAL  FROM CLIENTE c
        JOIN RESERVA_TEMPORAL rt ON rt.CLIENTE_ID = c.CLIENTE_ID
        JOIN TRANSACCION_PAGO tp ON tp.RESERVA_ID = rt.RESERVA_ID;

DECLARE 
    CURSOR c_tp_aprobadas IS 
        SELECT c.NOMBRE, rt.ESTADO as ESTADO_DE_LA_RESERVA, tp.ESTADO AS ESTADO_DE_PAGO, tp.MONTO_BRUTO, tp.DESCUENTO, tp.MONTO_FINAL  FROM CLIENTE c
        JOIN RESERVA_TEMPORAL rt ON rt.CLIENTE_ID = c.CLIENTE_ID
        JOIN TRANSACCION_PAGO tp ON tp.RESERVA_ID = rt.RESERVA_ID
        WHERE tp.ESTADO = 'RECHAZADO';

BEGIN
    FOR v_fila IN c_tp_aprobadas LOOP
        DBMS_OUTPUT.PUT_LINE('*******INFORME TRANSACCIONES APROBADAS*****');
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_fila.NOMBRE);
        DBMS_OUTPUT.PUT_LINE('Monto Bruto: ' || v_fila.MONTO_BRUTO);
        DBMS_OUTPUT.PUT_LINE('DESCUENTO: ' || v_fila.DESCUENTO);
        DBMS_OUTPUT.PUT_LINE('Monto Final: ' || v_fila.MONTO_FINAL);
    END LOOP;

    null;
END;
/




SELECT * FROM CLIENTE;
--Cursor con parametros
DECLARE
    CURSOR c_clientes_por_apellido(p_apellido VARCHAR2) IS
        SELECT
            cliente_id, nombre,apellido,email
        FROM CLIENTE
        WHERE apellido = p_apellido;
BEGIN
    FOR un_cliente IN c_clientes_por_apellido('Vargas')
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            un_cliente.nombre
        );
    END LOOP;
END;
/

SELECT * FROM CLIENTE;
--Insertemos 3 vargas
INSERT INTO CLIENTE(RUT, NOMBRE, APELLIDO, EMAIL, TELEFONO, FECHA_REGISTRO)
    VALUES('44.444.444-4', 'Maria', 'Vargas', 'mvargass@gmail.com', '+56955555555', SYSTIMESTAMP);

    INSERT INTO CLIENTE(RUT, NOMBRE, APELLIDO, EMAIL, TELEFONO, FECHA_REGISTRO)
    VALUES('22.222.222-2', 'Matias', 'Vargas', 'mvargas@gmail.com', '+56966666666', SYSTIMESTAMP);

    INSERT INTO CLIENTE(RUT, NOMBRE, APELLIDO, EMAIL, TELEFONO, FECHA_REGISTRO)
    VALUES('11.111.111-1', 'Dieguito', 'Vargas', 'dvargas@gmail.com', '+56922222222',  SYSTIMESTAMP);


    SELECT * FROM CLIENTE;

    COMMIT;