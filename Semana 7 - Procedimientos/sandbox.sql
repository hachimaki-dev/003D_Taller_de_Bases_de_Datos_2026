

--Bloque anonimo
DECLARE

BEGIN
    registrar_cliente('11.325.259-6', 'Mario', 'Vargas', 'mvargas@gmail.com', null);
END;
/



DROP PROCEDURE registrar_cliente;



DECLARE
    v_nombre CLIENTE.NOMBRE%TYPE;
    v_apellido CLIENTE.APELLIDO%TYPE;
    v_email CLIENTE.EMAIL%TYPE;
    v_telefono CLIENTE.TELEFONO%TYPE;

BEGIN

    DATOS_CLIENTE(6, v_nombre, v_apellido, v_email, v_telefono);

    DBMS_OUTPUT.PUT_LINE('Los datos del cliente son: ' || v_nombre || ' ' || v_apellido || ' ' || v_email || ' ' || v_telefono);

END;
/