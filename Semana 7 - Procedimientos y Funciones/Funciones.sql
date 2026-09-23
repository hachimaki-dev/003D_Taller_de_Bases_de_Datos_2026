CREATE OR REPLACE FUNCTION calcular_cuadrado(
    p_numero IN NUMBER
) return NUMBER 
AS 
    v_resultado NUMBER;
BEGIN 
        v_resultado := p_numero * p_numero;
        return v_resultado;
end calcular_cuadrado;
/


SELECT CALCULAR_CUADRADO(5) AS CUADRADO_DE_UN_NUMERO FROM DUAL;

DECLARE 
    v_resultado NUMBER;
BEGIN
    v_resultado := CALCULAR_CUADRADO(14);

    DBMS_OUTPUT.PUT_LINE('El cuadrado es: ' || v_resultado);
END;
/





SELECT DESCUENTO_PORCENTAJE  FROM CONVENIO_BANCO WHERE CONVENIO_BANCO_ID = 4 AND ACTIVO = 'S';


CREATE OR REPLACE FUNCTION descuento_cliente_banco(
    p_id_banco NUMBER,
    p_monto_bruto_entrada NUMBER
) RETURN NUMBER 
IS 
    v_porcentaje_descuento NUMBER;
    v_precio_final_entrada NUMBER;
BEGIN 
    SELECT DESCUENTO_PORCENTAJE INTO v_porcentaje_descuento FROM CONVENIO_BANCO where CONVENIO_BANCO_ID = p_id_banco AND ACTIVO = 'S' ;

    v_precio_final_entrada :=  p_monto_bruto_entrada -  ( p_monto_bruto_entrada * v_porcentaje_descuento  ) / 100;

    return v_precio_final_entrada;
END descuento_cliente_banco;
/


SELECT DESCUENTO_CLIENTE_BANCO(1, 100000) AS MONTO_REAL_ENTRADA FROM DUAL;