
SELECT EMAIL FROM CLIENTE where RUT = '11.111.111-1';
SELECT EMAIL FROM CLIENTE;

--No data found
DECLARE 
    v_email CLIENTE.EMAIL%TYPE;
BEGIN 
    SELECT EMAIL INTO v_email FROM CLIENTE where RUT = '11.111.111-1';
    DBMS_OUTPUT.PUT_LINE('El email es: ' || v_email);

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe datos para el cliente que intenta consultar');
END;
/


SELECT EMAIL FROM CLIENTE where RUT = '11.111.111-1';
SELECT EMAIL FROM CLIENTE;

--Demasiadas filas
DECLARE 
    v_email CLIENTE.EMAIL%TYPE;
BEGIN 
    SELECT EMAIL INTO v_email FROM CLIENTE;
    DBMS_OUTPUT.PUT_LINE('El email es: ' || v_email);

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe datos para el cliente que intenta consultar');
    
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Este bloque esta preparado para guardar una sola fila.' || CHR(1) || 'c:');
        DBMS_OUTPUT.PUT_LINE('Si desea guardar mas de una, por favor use un CURSOR');
END;
/


--División por cero
DECLARE
    v_resultado NUMBER;
    v_des NUMBER := 0;
BEGIN

    v_resultado := 100 / v_des ;
    DBMS_OUTPUT.PUT_LINE(v_resultado);
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Error: no se puede dividir por cero.');
END;
/


INSERT INTO CLIENTE (rut, nombre, apellido, email)
    VALUES ('19.456.789-1', 'Pepito', 'Soto', 'psoto@gmail.com');


SELECT * FROM CLIENTE WHERE RUT = '19.456.789-1';
--Cuando un valor rompe criterio de unicidad
BEGIN
    INSERT INTO CLIENTE (rut, nombre, apellido, email)
    VALUES ('19.456.789-1', 'Pepito', 'Soto', 'psoto@gmail.com');
    -- El RUT '19.456.789-1' ya existe (Valentina Soto)
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: el RUT ya está registrado.');
END;
/

--Error de valor
DECLARE
    v_texto VARCHAR2(5);
BEGIN
    v_texto := 'Este texto es demasiado largo';
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: el valor excede el tamaño de la variable.');
END;
/

DECLARE
    v_num NUMBER;
BEGIN
    v_num := TO_NUMBER('abc');
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: no se pudo convertir a número.' || SQLERRM);
END;
/