

DECLARE 
    TYPE asientos_cine IS VARRAY(6) OF VARCHAR2(3);

    v_asientos asientos_cine := asientos_cine('A1', 'A2', 'A3', 'A4', 'A5');
BEGIN 
    DBMS_OUTPUT.PUT_LINE('Se le asigno el asiento N° ' || v_asientos(3) );
    null;
END;
/




--Hagamos uno de RUT

DECLARE 
    TYPE rut_clientes IS VARRAY(4) OF varchar2(12);

    v_rut_clientes rut_clientes := rut_clientes('18.256.356-6', '10.245.369-6', '5.235.487-6', '2.365.485-2');
BEGIN
    DBMS_OUTPUT.PUT_LINE( v_rut_clientes(2) );
    null; 
END;
/



--- Como se hace de manera procedural
DECLARE 
    TYPE rut_clientes IS VARRAY(4) OF varchar2(12);

    v_rut_clientes rut_clientes := rut_clientes();
BEGIN
    v_rut_clientes.EXTEND;
    v_rut_clientes(1) := '12.356.256-8';

    v_rut_clientes.EXTEND;
    v_rut_clientes(2) := '12-789.099-6';

    v_rut_clientes.EXTEND;
    v_rut_clientes(3) := '14-799.222-6';

    v_rut_clientes.EXTEND;
    v_rut_clientes(4) := '11-333.111-8';

    DBMS_OUTPUT.PUT_LINE( v_rut_clientes(1) );
    DBMS_OUTPUT.PUT_LINE( v_rut_clientes(2) );
    DBMS_OUTPUT.PUT_LINE( v_rut_clientes(3) );
    DBMS_OUTPUT.PUT_LINE( v_rut_clientes(4) );
    null; 
END;
/