
--Este es con entrada
CREATE OR REPLACE PROCEDURE registrar_cliente(
    p_rut IN VARCHAR2,
    p_nombre IN VARCHAR2,
    p_apellido IN VARCHAR2,
    p_email IN VARCHAR2,
    p_telefono varchar2
) 
AS 

BEGIN 
    INSERT INTO CLIENTE(RUT, NOMBRE, APELLIDO, EMAIL, TELEFONO) 
    VALUES (p_rut, p_nombre, p_apellido, p_email, p_telefono);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cliente ' || p_nombre || ' registrado');
END registrar_cliente;
/




--salida.
--Obtener los datos de un cliente en cocreto

CREATE OR REPLACE PROCEDURE datos_cliente(
    p_cliente_id IN NUMBER,
    p_nombre OUT VARCHAR2,
    p_apellido OUT VARCHAR2,
    p_email OUT VARCHAR2,
    p_telefono OUT VARCHAR2
) 
IS

BEGIN 
    SELECT nombre, apellido, email, telefono INTO p_nombre, p_apellido, p_email, p_telefono FROM CLIENTE WHERE CLIENTE_ID = p_cliente_id;
END datos_cliente;
/