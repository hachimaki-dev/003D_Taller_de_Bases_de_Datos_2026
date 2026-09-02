SELECT * FROM EVENTO;
SELECT * FROM EVENTO WHERE EVENTO_ID = 1;

UPDATE EVENTO SET ESTADO = 'VENTA' WHERE EVENTO_ID = 1;
commit;
--La básica
DECLARE
    e_evento_cancelado EXCEPTION;
    v_estado EVENTO.estado%TYPE;
BEGIN
    SELECT estado INTO v_estado
    FROM EVENTO
    WHERE EVENTO_ID = 1;

    IF v_estado = 'CANCELADO' THEN
        RAISE e_evento_cancelado;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Evento disponible para venta.');
EXCEPTION
    WHEN e_evento_cancelado THEN
        DBMS_OUTPUT.PUT_LINE('No se puede vender: el evento está cancelado.');
END;
/



--Raise app error
BEGIN
    IF condicion THEN
        RAISE_APPLICATION_ERROR(-20001,'Mensaje de error personalizado');
    END IF;
END;

/


 SELECT stock_disponible  
    FROM LOCALIDAD_EVENTO
    WHERE localidad_evento_id = 1;

--Rais app erro con logica
DECLARE
    v_stock LOCALIDAD_EVENTO.stock_disponible%TYPE;
BEGIN
    SELECT stock_disponible INTO v_stock
    FROM LOCALIDAD_EVENTO
    WHERE localidad_evento_id = 1;

    IF v_stock <= 0 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Sin stock: las entradas para esta localidad están agotadas.'
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE('Stock disponible: ' || v_stock);
END;
/

--Pragma exepc

DECLARE
    e_fk_violada EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_fk_violada, -2292);
    -- ORA-02292: integrity constraint violated - child record found
BEGIN
    DELETE FROM RECINTO
    WHERE nombre = 'Movistar Arena';
    -- Falla porque hay sectores y eventos asociados
EXCEPTION
    WHEN e_fk_violada THEN
        DBMS_OUTPUT.PUT_LINE('No se puede eliminar: tiene datos asociados.' || SQLERRM);
END;