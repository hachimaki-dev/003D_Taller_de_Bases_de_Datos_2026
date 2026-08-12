/* ============================================================
   SISTEMA DE VENTA DE ENTRADAS - ESTILO PUNTOTICKET
   ORACLE DATABASE 19c
   MODELO NORMALIZADO EN 3FN
   ============================================================ */


/* ============================================================
   LIMPIEZA DEL ESQUEMA
   Permite ejecutar nuevamente el script sin errores por tablas
   previamente existentes.
   ============================================================ */

BEGIN
    FOR T IN (
        SELECT TABLE_NAME
        FROM USER_TABLES
        WHERE TABLE_NAME IN (
            'LOG_ANULACIONES',
            'LOG_CAMBIO_PRECIO',
            'TICKET',
            'TRANSACCION_PAGO',
            'RESERVA_TEMPORAL',
            'CONVENIO_EVENTO',
            'CONVENIO_BANCO',
            'LOCALIDAD_EVENTO',
            'EVENTO',
            'ASIENTO',
            'SECTOR_RECINTO',
            'RECINTO',
            'ADMINISTRADOR',
            'PRODUCTORA',
            'CLIENTE'
        )
    ) LOOP
        EXECUTE IMMEDIATE
            'DROP TABLE ' || T.TABLE_NAME || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

/* ============================================================
   CLIENTE
   ============================================================ */

CREATE TABLE CLIENTE (
    cliente_id          NUMBER GENERATED ALWAYS AS IDENTITY,
    rut                 VARCHAR2(12) NOT NULL,
    nombre              VARCHAR2(80) NOT NULL,
    apellido             VARCHAR2(80) NOT NULL,
    email               VARCHAR2(150) NOT NULL,
    telefono             VARCHAR2(20),
    fecha_registro       TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    
    CONSTRAINT pk_cliente
        PRIMARY KEY (cliente_id),

    CONSTRAINT uk_cliente_rut
        UNIQUE (rut),

    CONSTRAINT uk_cliente_email
        UNIQUE (email),

    CONSTRAINT ck_cliente_email
        CHECK (INSTR(email, '@') > 1)
);


/* ============================================================
   PRODUCTORA
   ============================================================ */

CREATE TABLE PRODUCTORA (
    productora_id       NUMBER GENERATED ALWAYS AS IDENTITY,
    razon_social        VARCHAR2(150) NOT NULL,
    nombre_fantasia     VARCHAR2(120) NOT NULL,
    rut                 VARCHAR2(12) NOT NULL,
    email               VARCHAR2(150) NOT NULL,
    telefono            VARCHAR2(20),

    CONSTRAINT pk_productora
        PRIMARY KEY (productora_id),

    CONSTRAINT uk_productora_rut
        UNIQUE (rut),

    CONSTRAINT uk_productora_email
        UNIQUE (email)
);


/* ============================================================
   ADMINISTRADOR
   ============================================================ */

CREATE TABLE ADMINISTRADOR (
    administrador_id    NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR2(80) NOT NULL,
    apellido            VARCHAR2(80) NOT NULL,
    email               VARCHAR2(150) NOT NULL,
    password_hash       VARCHAR2(255) NOT NULL,
    activo              CHAR(1) DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_administrador
        PRIMARY KEY (administrador_id),

    CONSTRAINT uk_administrador_email
        UNIQUE (email),

    CONSTRAINT ck_administrador_activo
        CHECK (activo IN ('S', 'N'))
);


/* ============================================================
   RECINTO
   ============================================================ */

CREATE TABLE RECINTO (
    recinto_id          NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre              VARCHAR2(150) NOT NULL,
    direccion           VARCHAR2(200) NOT NULL,
    comuna              VARCHAR2(100) NOT NULL,
    ciudad              VARCHAR2(100) NOT NULL,
    capacidad_total     NUMBER NOT NULL,

    CONSTRAINT pk_recinto
        PRIMARY KEY (recinto_id),

    CONSTRAINT uk_recinto_nombre
        UNIQUE (nombre),

    CONSTRAINT ck_recinto_capacidad
        CHECK (capacidad_total > 0)
);


/* ============================================================
   SECTOR_RECINTO
   Un recinto posee múltiples sectores.
   Un sector puede ser numerado o no numerado.
   ============================================================ */

CREATE TABLE SECTOR_RECINTO (
    sector_id           NUMBER GENERATED ALWAYS AS IDENTITY,
    recinto_id          NUMBER NOT NULL,
    nombre              VARCHAR2(100) NOT NULL,
    capacidad_maxima    NUMBER NOT NULL,
    es_numerado         CHAR(1) DEFAULT 'N' NOT NULL,

    CONSTRAINT pk_sector_recinto
        PRIMARY KEY (sector_id),

    CONSTRAINT fk_sector_recinto
        FOREIGN KEY (recinto_id)
        REFERENCES RECINTO (recinto_id),

    CONSTRAINT uk_sector_recinto
        UNIQUE (recinto_id, nombre),

    CONSTRAINT ck_sector_capacidad
        CHECK (capacidad_maxima > 0),

    CONSTRAINT ck_sector_numerado
        CHECK (es_numerado IN ('S', 'N'))
);


/* ============================================================
   ASIENTO
   Solamente corresponde a sectores numerados.
   La restricción de que el sector sea numerado se controla
   mediante lógica de aplicación/trigger.
   ============================================================ */

CREATE TABLE ASIENTO (
    asiento_id          NUMBER GENERATED ALWAYS AS IDENTITY,
    sector_id           NUMBER NOT NULL,
    fila                VARCHAR2(10) NOT NULL,
    numero              NUMBER NOT NULL,

    CONSTRAINT pk_asiento
        PRIMARY KEY (asiento_id),

    CONSTRAINT fk_asiento_sector
        FOREIGN KEY (sector_id)
        REFERENCES SECTOR_RECINTO (sector_id),

    CONSTRAINT uk_asiento_sector
        UNIQUE (sector_id, fila, numero),

    CONSTRAINT ck_asiento_numero
        CHECK (numero > 0)
);


/* ============================================================
   EVENTO
   ============================================================ */

CREATE TABLE EVENTO (
    evento_id           NUMBER GENERATED ALWAYS AS IDENTITY,
    productora_id       NUMBER NOT NULL,
    recinto_id          NUMBER NOT NULL,
    nombre              VARCHAR2(200) NOT NULL,
    descripcion         VARCHAR2(500),
    fecha_evento        DATE NOT NULL,
    fecha_apertura      DATE,
    estado              VARCHAR2(20) DEFAULT 'PROGRAMADO' NOT NULL,

    CONSTRAINT pk_evento
        PRIMARY KEY (evento_id),

    CONSTRAINT fk_evento_productora
        FOREIGN KEY (productora_id)
        REFERENCES PRODUCTORA (productora_id),

    CONSTRAINT fk_evento_recinto
        FOREIGN KEY (recinto_id)
        REFERENCES RECINTO (recinto_id),

    CONSTRAINT ck_evento_estado
        CHECK (
            estado IN (
                'PROGRAMADO',
                'VENTA',
                'AGOTADO',
                'REALIZADO',
                'CANCELADO'
            )
        ),

    CONSTRAINT ck_evento_fechas
        CHECK (
            fecha_apertura IS NULL
            OR fecha_apertura < fecha_evento
        )
);


/* ============================================================
   LOCALIDAD_EVENTO
   Relaciona un evento con un sector específico del recinto.
   ============================================================ */

CREATE TABLE LOCALIDAD_EVENTO (
    localidad_evento_id NUMBER GENERATED ALWAYS AS IDENTITY,
    evento_id           NUMBER NOT NULL,
    sector_id           NUMBER NOT NULL,
    nombre_localidad    VARCHAR2(100) NOT NULL,
    precio              NUMBER(12,2) NOT NULL,
    stock_disponible    NUMBER NOT NULL,

    CONSTRAINT pk_localidad_evento
        PRIMARY KEY (localidad_evento_id),

    CONSTRAINT fk_localidad_evento
        FOREIGN KEY (evento_id)
        REFERENCES EVENTO (evento_id),

    CONSTRAINT fk_localidad_sector
        FOREIGN KEY (sector_id)
        REFERENCES SECTOR_RECINTO (sector_id),

    CONSTRAINT uk_localidad_evento_sector
        UNIQUE (evento_id, sector_id),

    CONSTRAINT ck_localidad_precio
        CHECK (precio > 0),

    CONSTRAINT ck_localidad_stock
        CHECK (stock_disponible >= 0)
);


/* ============================================================
   CONVENIO_BANCO
   ============================================================ */

CREATE TABLE CONVENIO_BANCO (
    convenio_banco_id   NUMBER GENERATED ALWAYS AS IDENTITY,
    banco               VARCHAR2(100) NOT NULL,
    nombre_convenio     VARCHAR2(150) NOT NULL,
    descuento_porcentaje NUMBER(5,2) NOT NULL,
    activo              CHAR(1) DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_convenio_banco
        PRIMARY KEY (convenio_banco_id),

    CONSTRAINT uk_convenio_banco
        UNIQUE (banco, nombre_convenio),

    CONSTRAINT ck_convenio_descuento
        CHECK (
            descuento_porcentaje >= 0
            AND descuento_porcentaje <= 100
        ),

    CONSTRAINT ck_convenio_activo
        CHECK (activo IN ('S', 'N'))
);


/* ============================================================
   CONVENIO_EVENTO
   Relación entre eventos y convenios bancarios.
   Permite que un convenio pueda utilizarse en múltiples eventos.
   ============================================================ */

CREATE TABLE CONVENIO_EVENTO (
    convenio_evento_id  NUMBER GENERATED ALWAYS AS IDENTITY,
    convenio_banco_id   NUMBER NOT NULL,
    evento_id           NUMBER NOT NULL,
    fecha_inicio        DATE NOT NULL,
    fecha_termino       DATE NOT NULL,

    CONSTRAINT pk_convenio_evento
        PRIMARY KEY (convenio_evento_id),

    CONSTRAINT fk_convenio_evento_banco
        FOREIGN KEY (convenio_banco_id)
        REFERENCES CONVENIO_BANCO (convenio_banco_id),

    CONSTRAINT fk_convenio_evento_evento
        FOREIGN KEY (evento_id)
        REFERENCES EVENTO (evento_id),

    CONSTRAINT uk_convenio_evento
        UNIQUE (convenio_banco_id, evento_id),

    CONSTRAINT ck_convenio_evento_fechas
        CHECK (fecha_termino >= fecha_inicio)
);


/* ============================================================
   RESERVA_TEMPORAL
   Bloquea temporalmente un asiento o un cupo de localidad.
   
   asiento_id:
       NO NULL -> localidad numerada.
       NULL    -> localidad no numerada.
   ============================================================ */

CREATE TABLE RESERVA_TEMPORAL (
    reserva_id          NUMBER GENERATED ALWAYS AS IDENTITY,
    cliente_id          NUMBER NOT NULL,
    localidad_evento_id NUMBER NOT NULL,
    asiento_id          NUMBER,
    fecha_reserva       TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_expiracion    TIMESTAMP NOT NULL,
    estado              VARCHAR2(20) DEFAULT 'ACTIVA' NOT NULL,

    CONSTRAINT pk_reserva_temporal
        PRIMARY KEY (reserva_id),

    CONSTRAINT fk_reserva_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES CLIENTE (cliente_id),

    CONSTRAINT fk_reserva_localidad
        FOREIGN KEY (localidad_evento_id)
        REFERENCES LOCALIDAD_EVENTO (localidad_evento_id),

    CONSTRAINT fk_reserva_asiento
        FOREIGN KEY (asiento_id)
        REFERENCES ASIENTO (asiento_id),

    CONSTRAINT ck_reserva_estado
        CHECK (
            estado IN (
                'ACTIVA',
                'EXPIRADA',
                'CONVERTIDA',
                'CANCELADA'
            )
        ),

    CONSTRAINT ck_reserva_fechas
        CHECK (fecha_expiracion > fecha_reserva)
);


/* ============================================================
   TRANSACCION_PAGO
   ============================================================ */

CREATE TABLE TRANSACCION_PAGO (
    transaccion_id      NUMBER GENERATED ALWAYS AS IDENTITY,
    reserva_id          NUMBER NOT NULL,
    convenio_banco_id   NUMBER,
    fecha_transaccion   TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    monto_bruto         NUMBER(12,2) NOT NULL,
    descuento           NUMBER(12,2) DEFAULT 0 NOT NULL,
    monto_final         NUMBER(12,2) NOT NULL,
    metodo_pago         VARCHAR2(30) NOT NULL,
    codigo_autorizacion VARCHAR2(50),
    estado              VARCHAR2(20) DEFAULT 'PENDIENTE' NOT NULL,

    CONSTRAINT pk_transaccion_pago
        PRIMARY KEY (transaccion_id),

    CONSTRAINT fk_pago_reserva
        FOREIGN KEY (reserva_id)
        REFERENCES RESERVA_TEMPORAL (reserva_id),

    CONSTRAINT fk_pago_convenio
        FOREIGN KEY (convenio_banco_id)
        REFERENCES CONVENIO_BANCO (convenio_banco_id),

    CONSTRAINT ck_pago_monto_bruto
        CHECK (monto_bruto > 0),

    CONSTRAINT ck_pago_descuento
        CHECK (descuento >= 0),

    CONSTRAINT ck_pago_monto_final
        CHECK (monto_final > 0),

    CONSTRAINT ck_pago_montos
        CHECK (monto_final = monto_bruto - descuento),

    CONSTRAINT ck_pago_metodo
        CHECK (
            metodo_pago IN (
                'TARJETA_CREDITO',
                'TARJETA_DEBITO',
                'TRANSFERENCIA',
                'WEBPAY'
            )
        ),

    CONSTRAINT ck_pago_estado
        CHECK (
            estado IN (
                'PENDIENTE',
                'APROBADO',
                'RECHAZADO'
            )
        )
);


/* ============================================================
   TICKET
   Entrada final emitida.
   ============================================================ */

CREATE TABLE TICKET (
    ticket_id           NUMBER GENERATED ALWAYS AS IDENTITY,
    transaccion_id      NUMBER NOT NULL,
    reserva_id          NUMBER NOT NULL,
    codigo_ticket       VARCHAR2(50) NOT NULL,
    fecha_emision       TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    precio_pagado       NUMBER(12,2) NOT NULL,
    estado              VARCHAR2(20) DEFAULT 'EMITIDO' NOT NULL,

    CONSTRAINT pk_ticket
        PRIMARY KEY (ticket_id),

    CONSTRAINT fk_ticket_transaccion
        FOREIGN KEY (transaccion_id)
        REFERENCES TRANSACCION_PAGO (transaccion_id),

    CONSTRAINT fk_ticket_reserva
        FOREIGN KEY (reserva_id)
        REFERENCES RESERVA_TEMPORAL (reserva_id),

    CONSTRAINT uk_ticket_codigo
        UNIQUE (codigo_ticket),

    CONSTRAINT uk_ticket_transaccion
        UNIQUE (transaccion_id),

    CONSTRAINT ck_ticket_precio
        CHECK (precio_pagado > 0),

    CONSTRAINT ck_ticket_estado
        CHECK (
            estado IN (
                'EMITIDO',
                'USADO',
                'ANULADO'
            )
        )
);


/* ============================================================
   LOG_CAMBIO_PRECIO
   Tabla preparada para auditoría mediante trigger.
   ============================================================ */

CREATE TABLE LOG_CAMBIO_PRECIO (
    log_precio_id       NUMBER GENERATED ALWAYS AS IDENTITY,
    localidad_evento_id NUMBER NOT NULL,
    precio_anterior     NUMBER(12,2) NOT NULL,
    precio_nuevo        NUMBER(12,2) NOT NULL,
    fecha_cambio        TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    administrador_id    NUMBER,

    CONSTRAINT pk_log_cambio_precio
        PRIMARY KEY (log_precio_id),

    CONSTRAINT fk_log_precio_localidad
        FOREIGN KEY (localidad_evento_id)
        REFERENCES LOCALIDAD_EVENTO (localidad_evento_id),

    CONSTRAINT fk_log_precio_admin
        FOREIGN KEY (administrador_id)
        REFERENCES ADMINISTRADOR (administrador_id),

    CONSTRAINT ck_log_precio_anterior
        CHECK (precio_anterior > 0),

    CONSTRAINT ck_log_precio_nuevo
        CHECK (precio_nuevo > 0),

    CONSTRAINT ck_log_precio_diferente
        CHECK (precio_anterior <> precio_nuevo)
);


/* ============================================================
   LOG_ANULACIONES
   Tabla preparada para auditoría mediante trigger.
   ============================================================ */

CREATE TABLE LOG_ANULACIONES (
    log_anulacion_id    NUMBER GENERATED ALWAYS AS IDENTITY,
    ticket_id           NUMBER,
    transaccion_id      NUMBER,
    reserva_id          NUMBER,
    administrador_id    NUMBER,
    motivo              VARCHAR2(500) NOT NULL,
    fecha_anulacion     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_log_anulaciones
        PRIMARY KEY (log_anulacion_id),

    CONSTRAINT fk_log_anulacion_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES TICKET (ticket_id),

    CONSTRAINT fk_log_anulacion_transaccion
        FOREIGN KEY (transaccion_id)
        REFERENCES TRANSACCION_PAGO (transaccion_id),

    CONSTRAINT fk_log_anulacion_reserva
        FOREIGN KEY (reserva_id)
        REFERENCES RESERVA_TEMPORAL (reserva_id),

    CONSTRAINT fk_log_anulacion_admin
        FOREIGN KEY (administrador_id)
        REFERENCES ADMINISTRADOR (administrador_id)
);


/* ============================================================
   ÍNDICES PARA FOREIGN KEYS
   ============================================================ */

CREATE INDEX idx_sector_recinto
    ON SECTOR_RECINTO (recinto_id);

CREATE INDEX idx_asiento_sector
    ON ASIENTO (sector_id);

CREATE INDEX idx_evento_productora
    ON EVENTO (productora_id);

CREATE INDEX idx_evento_recinto
    ON EVENTO (recinto_id);

CREATE INDEX idx_localidad_evento
    ON LOCALIDAD_EVENTO (evento_id);

CREATE INDEX idx_localidad_sector
    ON LOCALIDAD_EVENTO (sector_id);

CREATE INDEX idx_convenio_evento_banco
    ON CONVENIO_EVENTO (convenio_banco_id);

CREATE INDEX idx_convenio_evento_evento
    ON CONVENIO_EVENTO (evento_id);

CREATE INDEX idx_reserva_cliente
    ON RESERVA_TEMPORAL (cliente_id);

CREATE INDEX idx_reserva_localidad
    ON RESERVA_TEMPORAL (localidad_evento_id);

CREATE INDEX idx_reserva_asiento
    ON RESERVA_TEMPORAL (asiento_id);

CREATE INDEX idx_pago_reserva
    ON TRANSACCION_PAGO (reserva_id);

CREATE INDEX idx_pago_convenio
    ON TRANSACCION_PAGO (convenio_banco_id);

CREATE INDEX idx_ticket_reserva
    ON TICKET (reserva_id);


/* ============================================================
   DATOS: PRODUCTORAS
   ============================================================ */

INSERT INTO PRODUCTORA
    (razon_social, nombre_fantasia, rut, email, telefono)
VALUES
    (
        'Bizarro Producciones SpA',
        'Bizarro Live Entertainment',
        '76.123.456-7',
        'contacto@bizarro.cl',
        '+56991234567'
    );

INSERT INTO PRODUCTORA
    (razon_social, nombre_fantasia, rut, email, telefono)
VALUES
    (
        'Lotus Producciones SpA',
        'Lotus',
        '77.234.567-8',
        'contacto@lotusproducciones.cl',
        '+56992345678'
    );

INSERT INTO PRODUCTORA
    (razon_social, nombre_fantasia, rut, email, telefono)
VALUES
    (
        'DG Medios y Espectáculos SpA',
        'DG Medios',
        '78.345.678-9',
        'contacto@dgmedios.com',
        '+56993456789'
    );


/* ============================================================
   DATOS: ADMINISTRADORES
   ============================================================ */

INSERT INTO ADMINISTRADOR
    (nombre, apellido, email, password_hash)
VALUES
    (
        'Camila',
        'Fuentes',
        'camila.fuentes@puntoticket-demo.cl',
        'HASH_DEMO_ADMIN_001'
    );

INSERT INTO ADMINISTRADOR
    (nombre, apellido, email, password_hash)
VALUES
    (
        'Matías',
        'Rojas',
        'matias.rojas@puntoticket-demo.cl',
        'HASH_DEMO_ADMIN_002'
    );


/* ============================================================
   DATOS: CLIENTES
   ============================================================ */

INSERT INTO CLIENTE
    (rut, nombre, apellido, email, telefono)
VALUES
    (
        '19.456.789-1',
        'Valentina',
        'Soto',
        'valentina.soto@gmail.com',
        '+56987654321'
    );

INSERT INTO CLIENTE
    (rut, nombre, apellido, email, telefono)
VALUES
    (
        '18.234.567-2',
        'Diego',
        'Morales',
        'diego.morales@gmail.com',
        '+56988765432'
    );

INSERT INTO CLIENTE
    (rut, nombre, apellido, email, telefono)
VALUES
    (
        '20.345.678-3',
        'Antonia',
        'Pérez',
        'antonia.perez@gmail.com',
        '+56989876543'
    );

INSERT INTO CLIENTE
    (rut, nombre, apellido, email, telefono)
VALUES
    (
        '17.567.890-4',
        'Sebastián',
        'Vargas',
        'sebastian.vargas@gmail.com',
        '+56980987654'
    );

INSERT INTO CLIENTE
    (rut, nombre, apellido, email, telefono)
VALUES
    (
        '21.678.901-5',
        'Fernanda',
        'Castillo',
        'fernanda.castillo@gmail.com',
        '+56981234567'
    );


/* ============================================================
   DATOS: RECINTOS
   ============================================================ */

INSERT INTO RECINTO
    (nombre, direccion, comuna, ciudad, capacidad_total)
VALUES
    (
        'Movistar Arena',
        'Av. Beauchef 1204',
        'Santiago',
        'Santiago',
        15000
    );

INSERT INTO RECINTO
    (nombre, direccion, comuna, ciudad, capacidad_total)
VALUES
    (
        'Estadio Nacional',
        'Av. Grecia 2001',
        'Ñuñoa',
        'Santiago',
        48500
    );

INSERT INTO RECINTO
    (nombre, direccion, comuna, ciudad, capacidad_total)
VALUES
    (
        'Arena Puerto Montt',
        'Avenida Presidente Ibáñez 600',
        'Puerto Montt',
        'Puerto Montt',
        5000
    );


/* ============================================================
   DATOS: SECTORES
   6 sectores en total.
   ============================================================ */

INSERT INTO SECTOR_RECINTO
    (recinto_id, nombre, capacidad_maxima, es_numerado)
VALUES
    (
        (SELECT recinto_id FROM RECINTO WHERE nombre = 'Movistar Arena'),
        'Platea Baja',
        5000,
        'S'
    );

INSERT INTO SECTOR_RECINTO
    (recinto_id, nombre, capacidad_maxima, es_numerado)
VALUES
    (
        (SELECT recinto_id FROM RECINTO WHERE nombre = 'Movistar Arena'),
        'Cancha General',
        7000,
        'N'
    );

INSERT INTO SECTOR_RECINTO
    (recinto_id, nombre, capacidad_maxima, es_numerado)
VALUES
    (
        (SELECT recinto_id FROM RECINTO WHERE nombre = 'Estadio Nacional'),
        'Cancha',
        20000,
        'N'
    );

INSERT INTO SECTOR_RECINTO
    (recinto_id, nombre, capacidad_maxima, es_numerado)
VALUES
    (
        (SELECT recinto_id FROM RECINTO WHERE nombre = 'Estadio Nacional'),
        'Tribuna Andes',
        10000,
        'S'
    );

INSERT INTO SECTOR_RECINTO
    (recinto_id, nombre, capacidad_maxima, es_numerado)
VALUES
    (
        (SELECT recinto_id FROM RECINTO WHERE nombre = 'Arena Puerto Montt'),
        'Platea',
        2500,
        'S'
    );

INSERT INTO SECTOR_RECINTO
    (recinto_id, nombre, capacidad_maxima, es_numerado)
VALUES
    (
        (SELECT recinto_id FROM RECINTO WHERE nombre = 'Arena Puerto Montt'),
        'General',
        2500,
        'N'
    );


/* ============================================================
   DATOS: ASIENTOS
   30 asientos de prueba.
   
   10 para Movistar Arena - Platea Baja
   10 para Estadio Nacional - Tribuna Andes
   10 para Arena Puerto Montt - Platea
   ============================================================ */

INSERT INTO ASIENTO (sector_id, fila, numero)
SELECT sector_id, 'A', LEVEL
FROM SECTOR_RECINTO
WHERE nombre = 'Platea Baja'
  AND recinto_id = (
      SELECT recinto_id
      FROM RECINTO
      WHERE nombre = 'Movistar Arena'
  )
CONNECT BY LEVEL <= 10
   AND PRIOR sector_id = sector_id
   AND PRIOR SYS_GUID() IS NOT NULL;

INSERT INTO ASIENTO (sector_id, fila, numero)
SELECT sector_id, 'A', LEVEL
FROM SECTOR_RECINTO
WHERE nombre = 'Tribuna Andes'
  AND recinto_id = (
      SELECT recinto_id
      FROM RECINTO
      WHERE nombre = 'Estadio Nacional'
  )
CONNECT BY LEVEL <= 10
   AND PRIOR sector_id = sector_id
   AND PRIOR SYS_GUID() IS NOT NULL;

INSERT INTO ASIENTO (sector_id, fila, numero)
SELECT sector_id, 'A', LEVEL
FROM SECTOR_RECINTO
WHERE nombre = 'Platea'
  AND recinto_id = (
      SELECT recinto_id
      FROM RECINTO
      WHERE nombre = 'Arena Puerto Montt'
  )
CONNECT BY LEVEL <= 10
   AND PRIOR sector_id = sector_id
   AND PRIOR SYS_GUID() IS NOT NULL;


/* ============================================================
   DATOS: EVENTOS
   ============================================================ */

INSERT INTO EVENTO
    (
        productora_id,
        recinto_id,
        nombre,
        descripcion,
        fecha_evento,
        fecha_apertura,
        estado
    )
VALUES
    (
        (
            SELECT productora_id
            FROM PRODUCTORA
            WHERE nombre_fantasia = 'Bizarro Live Entertainment'
        ),
        (
            SELECT recinto_id
            FROM RECINTO
            WHERE nombre = 'Movistar Arena'
        ),
        'Bad Bunny - World''s Hottest Tour',
        'Show urbano internacional en Santiago.',
        TO_DATE('2026-11-15 21:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-08-20 12:00', 'YYYY-MM-DD HH24:MI'),
        'VENTA'
    );

INSERT INTO EVENTO
    (
        productora_id,
        recinto_id,
        nombre,
        descripcion,
        fecha_evento,
        fecha_apertura,
        estado
    )
VALUES
    (
        (
            SELECT productora_id
            FROM PRODUCTORA
            WHERE nombre_fantasia = 'Lotus'
        ),
        (
            SELECT recinto_id
            FROM RECINTO
            WHERE nombre = 'Estadio Nacional'
        ),
        'Lollapalooza Chile',
        'Festival internacional de música en Santiago.',
        TO_DATE('2027-03-20 12:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-09-01 12:00', 'YYYY-MM-DD HH24:MI'),
        'PROGRAMADO'
    );

INSERT INTO EVENTO
    (
        productora_id,
        recinto_id,
        nombre,
        descripcion,
        fecha_evento,
        fecha_apertura,
        estado
    )
VALUES
    (
        (
            SELECT productora_id
            FROM PRODUCTORA
            WHERE nombre_fantasia = 'DG Medios'
        ),
        (
            SELECT recinto_id
            FROM RECINTO
            WHERE nombre = 'Arena Puerto Montt'
        ),
        'Cris MJ - Tour 2026',
        'Presentación en vivo del artista urbano chileno.',
        TO_DATE('2026-12-05 21:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-08-25 12:00', 'YYYY-MM-DD HH24:MI'),
        'VENTA'
    );


/* ============================================================
   DATOS: LOCALIDADES DE EVENTOS
   ============================================================ */

INSERT INTO LOCALIDAD_EVENTO
    (
        evento_id,
        sector_id,
        nombre_localidad,
        precio,
        stock_disponible
    )
VALUES
    (
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Bad Bunny - World''s Hottest Tour'
        ),
        (
            SELECT sector_id
            FROM SECTOR_RECINTO
            WHERE nombre = 'Platea Baja'
              AND recinto_id = (
                  SELECT recinto_id
                  FROM RECINTO
                  WHERE nombre = 'Movistar Arena'
              )
        ),
        'Platea Baja',
        149900,
        4990
    );

INSERT INTO LOCALIDAD_EVENTO
    (
        evento_id,
        sector_id,
        nombre_localidad,
        precio,
        stock_disponible
    )
VALUES
    (
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Bad Bunny - World''s Hottest Tour'
        ),
        (
            SELECT sector_id
            FROM SECTOR_RECINTO
            WHERE nombre = 'Cancha General'
              AND recinto_id = (
                  SELECT recinto_id
                  FROM RECINTO
                  WHERE nombre = 'Movistar Arena'
              )
        ),
        'Cancha General',
        89900,
        6998
    );

INSERT INTO LOCALIDAD_EVENTO
    (
        evento_id,
        sector_id,
        nombre_localidad,
        precio,
        stock_disponible
    )
VALUES
    (
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Lollapalooza Chile'
        ),
        (
            SELECT sector_id
            FROM SECTOR_RECINTO
            WHERE nombre = 'Cancha'
              AND recinto_id = (
                  SELECT recinto_id
                  FROM RECINTO
                  WHERE nombre = 'Estadio Nacional'
              )
        ),
        'Cancha',
        129900,
        19995
    );

INSERT INTO LOCALIDAD_EVENTO
    (
        evento_id,
        sector_id,
        nombre_localidad,
        precio,
        stock_disponible
    )
VALUES
    (
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Lollapalooza Chile'
        ),
        (
            SELECT sector_id
            FROM SECTOR_RECINTO
            WHERE nombre = 'Tribuna Andes'
              AND recinto_id = (
                  SELECT recinto_id
                  FROM RECINTO
                  WHERE nombre = 'Estadio Nacional'
              )
        ),
        'Tribuna Andes',
        79900,
        9997
    );

INSERT INTO LOCALIDAD_EVENTO
    (
        evento_id,
        sector_id,
        nombre_localidad,
        precio,
        stock_disponible
    )
VALUES
    (
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Cris MJ - Tour 2026'
        ),
        (
            SELECT sector_id
            FROM SECTOR_RECINTO
            WHERE nombre = 'Platea'
              AND recinto_id = (
                  SELECT recinto_id
                  FROM RECINTO
                  WHERE nombre = 'Arena Puerto Montt'
              )
        ),
        'Platea',
        69900,
        2498
    );

INSERT INTO LOCALIDAD_EVENTO
    (
        evento_id,
        sector_id,
        nombre_localidad,
        precio,
        stock_disponible
    )
VALUES
    (
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Cris MJ - Tour 2026'
        ),
        (
            SELECT sector_id
            FROM SECTOR_RECINTO
            WHERE nombre = 'General'
              AND recinto_id = (
                  SELECT recinto_id
                  FROM RECINTO
                  WHERE nombre = 'Arena Puerto Montt'
              )
        ),
        'General',
        49900,
        2499
    );


/* ============================================================
   DATOS: CONVENIOS BANCARIOS
   ============================================================ */

INSERT INTO CONVENIO_BANCO
    (
        banco,
        nombre_convenio,
        descuento_porcentaje,
        activo
    )
VALUES
    (
        'Banco de Chile',
        'Venta Anticipada Banco de Chile',
        20,
        'S'
    );

INSERT INTO CONVENIO_BANCO
    (
        banco,
        nombre_convenio,
        descuento_porcentaje,
        activo
    )
VALUES
    (
        'Bci',
        'Beneficio Bci Clientes',
        15,
        'S'
    );

INSERT INTO CONVENIO_BANCO
    (
        banco,
        nombre_convenio,
        descuento_porcentaje,
        activo
    )
VALUES
    (
        'Santander',
        'Santander Preventa',
        10,
        'S'
    );

INSERT INTO CONVENIO_BANCO
    (
        banco,
        nombre_convenio,
        descuento_porcentaje,
        activo
    )
VALUES
    (
        'BancoEstado',
        'Beneficio BancoEstado',
        5,
        'S'
    );


/* ============================================================
   DATOS: CONVENIOS POR EVENTO
   ============================================================ */

INSERT INTO CONVENIO_EVENTO
    (
        convenio_banco_id,
        evento_id,
        fecha_inicio,
        fecha_termino
    )
VALUES
    (
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'Banco de Chile'
        ),
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Bad Bunny - World''s Hottest Tour'
        ),
        TO_DATE('2026-08-20', 'YYYY-MM-DD'),
        TO_DATE('2026-08-22', 'YYYY-MM-DD')
    );

INSERT INTO CONVENIO_EVENTO
    (
        convenio_banco_id,
        evento_id,
        fecha_inicio,
        fecha_termino
    )
VALUES
    (
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'Bci'
        ),
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Lollapalooza Chile'
        ),
        TO_DATE('2026-09-01', 'YYYY-MM-DD'),
        TO_DATE('2026-09-05', 'YYYY-MM-DD')
    );

INSERT INTO CONVENIO_EVENTO
    (
        convenio_banco_id,
        evento_id,
        fecha_inicio,
        fecha_termino
    )
VALUES
    (
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'Santander'
        ),
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Cris MJ - Tour 2026'
        ),
        TO_DATE('2026-08-25', 'YYYY-MM-DD'),
        TO_DATE('2026-08-28', 'YYYY-MM-DD')
    );

INSERT INTO CONVENIO_EVENTO
    (
        convenio_banco_id,
        evento_id,
        fecha_inicio,
        fecha_termino
    )
VALUES
    (
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'BancoEstado'
        ),
        (
            SELECT evento_id
            FROM EVENTO
            WHERE nombre = 'Cris MJ - Tour 2026'
        ),
        TO_DATE('2026-08-25', 'YYYY-MM-DD'),
        TO_DATE('2026-08-27', 'YYYY-MM-DD')
    );


/* ============================================================
   RESERVAS TEMPORALES
   ============================================================ */

/* Reserva 1: Bad Bunny - asiento 1 */
INSERT INTO RESERVA_TEMPORAL
    (
        cliente_id,
        localidad_evento_id,
        asiento_id,
        fecha_reserva,
        fecha_expiracion,
        estado
    )
VALUES
    (
        (
            SELECT cliente_id
            FROM CLIENTE
            WHERE email = 'valentina.soto@gmail.com'
        ),
        (
            SELECT localidad_evento_id
            FROM LOCALIDAD_EVENTO LE
            JOIN EVENTO E
              ON E.evento_id = LE.evento_id
            WHERE E.nombre = 'Bad Bunny - World''s Hottest Tour'
              AND LE.nombre_localidad = 'Platea Baja'
        ),
        (
            SELECT A.asiento_id
            FROM ASIENTO A
            JOIN SECTOR_RECINTO S
              ON S.sector_id = A.sector_id
            JOIN RECINTO R
              ON R.recinto_id = S.recinto_id
            WHERE S.nombre = 'Platea Baja'
              AND R.nombre = 'Movistar Arena'
              AND A.fila = 'A'
              AND A.numero = 1
        ),
        TIMESTAMP '2026-08-10 18:00:00',
        TIMESTAMP '2026-08-10 18:15:00',
        'CONVERTIDA'
    );


/* Reserva 2: Bad Bunny - asiento 2 */
INSERT INTO RESERVA_TEMPORAL
    (
        cliente_id,
        localidad_evento_id,
        asiento_id,
        fecha_reserva,
        fecha_expiracion,
        estado
    )
VALUES
    (
        (
            SELECT cliente_id
            FROM CLIENTE
            WHERE email = 'diego.morales@gmail.com'
        ),
        (
            SELECT localidad_evento_id
            FROM LOCALIDAD_EVENTO LE
            JOIN EVENTO E
              ON E.evento_id = LE.evento_id
            WHERE E.nombre = 'Bad Bunny - World''s Hottest Tour'
              AND LE.nombre_localidad = 'Platea Baja'
        ),
        (
            SELECT A.asiento_id
            FROM ASIENTO A
            JOIN SECTOR_RECINTO S
              ON S.sector_id = A.sector_id
            JOIN RECINTO R
              ON R.recinto_id = S.recinto_id
            WHERE S.nombre = 'Platea Baja'
              AND R.nombre = 'Movistar Arena'
              AND A.fila = 'A'
              AND A.numero = 2
        ),
        TIMESTAMP '2026-08-10 18:10:00',
        TIMESTAMP '2026-08-10 18:25:00',
        'CONVERTIDA'
    );


/* Reserva 3: Lollapalooza - entrada general */
INSERT INTO RESERVA_TEMPORAL
    (
        cliente_id,
        localidad_evento_id,
        asiento_id,
        fecha_reserva,
        fecha_expiracion,
        estado
    )
VALUES
    (
        (
            SELECT cliente_id
            FROM CLIENTE
            WHERE email = 'antonia.perez@gmail.com'
        ),
        (
            SELECT localidad_evento_id
            FROM LOCALIDAD_EVENTO LE
            JOIN EVENTO E
              ON E.evento_id = LE.evento_id
            WHERE E.nombre = 'Lollapalooza Chile'
              AND LE.nombre_localidad = 'Cancha'
        ),
        NULL,
        TIMESTAMP '2026-08-10 18:20:00',
        TIMESTAMP '2026-08-10 18:35:00',
        'CONVERTIDA'
    );


/* Reserva 4: Cris MJ - asiento 1 */
INSERT INTO RESERVA_TEMPORAL
    (
        cliente_id,
        localidad_evento_id,
        asiento_id,
        fecha_reserva,
        fecha_expiracion,
        estado
    )
VALUES
    (
        (
            SELECT cliente_id
            FROM CLIENTE
            WHERE email = 'sebastian.vargas@gmail.com'
        ),
        (
            SELECT localidad_evento_id
            FROM LOCALIDAD_EVENTO LE
            JOIN EVENTO E
              ON E.evento_id = LE.evento_id
            WHERE E.nombre = 'Cris MJ - Tour 2026'
              AND LE.nombre_localidad = 'Platea'
        ),
        (
            SELECT A.asiento_id
            FROM ASIENTO A
            JOIN SECTOR_RECINTO S
              ON S.sector_id = A.sector_id
            JOIN RECINTO R
              ON R.recinto_id = S.recinto_id
            WHERE S.nombre = 'Platea'
              AND R.nombre = 'Arena Puerto Montt'
              AND A.fila = 'A'
              AND A.numero = 1
        ),
        TIMESTAMP '2026-08-10 18:30:00',
        TIMESTAMP '2026-08-10 18:45:00',
        'CONVERTIDA'
    );


/* Reserva 5: Pago rechazado */
INSERT INTO RESERVA_TEMPORAL
    (
        cliente_id,
        localidad_evento_id,
        asiento_id,
        fecha_reserva,
        fecha_expiracion,
        estado
    )
VALUES
    (
        (
            SELECT cliente_id
            FROM CLIENTE
            WHERE email = 'fernanda.castillo@gmail.com'
        ),
        (
            SELECT localidad_evento_id
            FROM LOCALIDAD_EVENTO LE
            JOIN EVENTO E
              ON E.evento_id = LE.evento_id
            WHERE E.nombre = 'Cris MJ - Tour 2026'
              AND LE.nombre_localidad = 'General'
        ),
        NULL,
        TIMESTAMP '2026-08-10 19:00:00',
        TIMESTAMP '2026-08-10 19:15:00',
        'CANCELADA'
    );


/* ============================================================
   TRANSACCIONES DE PAGO
   ============================================================ */

/* Pago aprobado con Banco de Chile: 20% descuento */
INSERT INTO TRANSACCION_PAGO
    (
        reserva_id,
        convenio_banco_id,
        fecha_transaccion,
        monto_bruto,
        descuento,
        monto_final,
        metodo_pago,
        codigo_autorizacion,
        estado
    )
VALUES
    (
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'valentina.soto@gmail.com'
        ),
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'Banco de Chile'
        ),
        TIMESTAMP '2026-08-10 18:05:00',
        149900,
        29980,
        119920,
        'TARJETA_CREDITO',
        'AUTH-CL-000001',
        'APROBADO'
    );


/* Pago aprobado sin convenio */
INSERT INTO TRANSACCION_PAGO
    (
        reserva_id,
        convenio_banco_id,
        fecha_transaccion,
        monto_bruto,
        descuento,
        monto_final,
        metodo_pago,
        codigo_autorizacion,
        estado
    )
VALUES
    (
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'diego.morales@gmail.com'
        ),
        NULL,
        TIMESTAMP '2026-08-10 18:15:00',
        149900,
        0,
        149900,
        'WEBPAY',
        'AUTH-CL-000002',
        'APROBADO'
    );


/* Pago aprobado con Bci */
INSERT INTO TRANSACCION_PAGO
    (
        reserva_id,
        convenio_banco_id,
        fecha_transaccion,
        monto_bruto,
        descuento,
        monto_final,
        metodo_pago,
        codigo_autorizacion,
        estado
    )
VALUES
    (
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'antonia.perez@gmail.com'
        ),
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'Bci'
        ),
        TIMESTAMP '2026-08-10 18:25:00',
        129900,
        19485,
        110415,
        'TARJETA_DEBITO',
        'AUTH-CL-000003',
        'APROBADO'
    );


/* Pago aprobado con Santander */
INSERT INTO TRANSACCION_PAGO
    (
        reserva_id,
        convenio_banco_id,
        fecha_transaccion,
        monto_bruto,
        descuento,
        monto_final,
        metodo_pago,
        codigo_autorizacion,
        estado
    )
VALUES
    (
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'sebastian.vargas@gmail.com'
        ),
        (
            SELECT convenio_banco_id
            FROM CONVENIO_BANCO
            WHERE banco = 'Santander'
        ),
        TIMESTAMP '2026-08-10 18:35:00',
        69900,
        6990,
        62910,
        'WEBPAY',
        'AUTH-CL-000004',
        'APROBADO'
    );


/* Pago rechazado */
INSERT INTO TRANSACCION_PAGO
    (
        reserva_id,
        convenio_banco_id,
        fecha_transaccion,
        monto_bruto,
        descuento,
        monto_final,
        metodo_pago,
        codigo_autorizacion,
        estado
    )
VALUES
    (
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'fernanda.castillo@gmail.com'
        ),
        NULL,
        TIMESTAMP '2026-08-10 19:05:00',
        49900,
        0,
        49900,
        'TARJETA_CREDITO',
        NULL,
        'RECHAZADO'
    );


/* ============================================================
   TICKETS EMITIDOS
   ============================================================ */

INSERT INTO TICKET
    (
        transaccion_id,
        reserva_id,
        codigo_ticket,
        fecha_emision,
        precio_pagado,
        estado
    )
VALUES
    (
        (
            SELECT P.transaccion_id
            FROM TRANSACCION_PAGO P
            JOIN RESERVA_TEMPORAL R
              ON R.reserva_id = P.reserva_id
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'valentina.soto@gmail.com'
              AND P.estado = 'APROBADO'
        ),
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'valentina.soto@gmail.com'
        ),
        'TKT-BB-2026-000001',
        TIMESTAMP '2026-08-10 18:06:00',
        119920,
        'EMITIDO'
    );


INSERT INTO TICKET
    (
        transaccion_id,
        reserva_id,
        codigo_ticket,
        fecha_emision,
        precio_pagado,
        estado
    )
VALUES
    (
        (
            SELECT P.transaccion_id
            FROM TRANSACCION_PAGO P
            JOIN RESERVA_TEMPORAL R
              ON R.reserva_id = P.reserva_id
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'diego.morales@gmail.com'
              AND P.estado = 'APROBADO'
        ),
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'diego.morales@gmail.com'
        ),
        'TKT-BB-2026-000002',
        TIMESTAMP '2026-08-10 18:16:00',
        149900,
        'EMITIDO'
    );


INSERT INTO TICKET
    (
        transaccion_id,
        reserva_id,
        codigo_ticket,
        fecha_emision,
        precio_pagado,
        estado
    )
VALUES
    (
        (
            SELECT P.transaccion_id
            FROM TRANSACCION_PAGO P
            JOIN RESERVA_TEMPORAL R
              ON R.reserva_id = P.reserva_id
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'antonia.perez@gmail.com'
              AND P.estado = 'APROBADO'
        ),
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'antonia.perez@gmail.com'
        ),
        'TKT-LOL-2027-000001',
        TIMESTAMP '2026-08-10 18:26:00',
        110415,
        'EMITIDO'
    );


INSERT INTO TICKET
    (
        transaccion_id,
        reserva_id,
        codigo_ticket,
        fecha_emision,
        precio_pagado,
        estado
    )
VALUES
    (
        (
            SELECT P.transaccion_id
            FROM TRANSACCION_PAGO P
            JOIN RESERVA_TEMPORAL R
              ON R.reserva_id = P.reserva_id
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'sebastian.vargas@gmail.com'
              AND P.estado = 'APROBADO'
        ),
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'sebastian.vargas@gmail.com'
        ),
        'TKT-CRIS-2026-000001',
        TIMESTAMP '2026-08-10 18:36:00',
        62910,
        'EMITIDO'
    );


/* ============================================================
   AUDITORÍA DE EJEMPLO
   ============================================================ */

INSERT INTO LOG_CAMBIO_PRECIO
    (
        localidad_evento_id,
        precio_anterior,
        precio_nuevo,
        fecha_cambio,
        administrador_id
    )
VALUES
    (
        (
            SELECT LE.localidad_evento_id
            FROM LOCALIDAD_EVENTO LE
            JOIN EVENTO E
              ON E.evento_id = LE.evento_id
            WHERE E.nombre = 'Cris MJ - Tour 2026'
              AND LE.nombre_localidad = 'General'
        ),
        45900,
        49900,
        TIMESTAMP '2026-08-10 10:30:00',
        (
            SELECT administrador_id
            FROM ADMINISTRADOR
            WHERE email = 'camila.fuentes@puntoticket-demo.cl'
        )
    );


INSERT INTO LOG_ANULACIONES
    (
        ticket_id,
        transaccion_id,
        reserva_id,
        administrador_id,
        motivo,
        fecha_anulacion
    )
VALUES
    (
        NULL,
        (
            SELECT P.transaccion_id
            FROM TRANSACCION_PAGO P
            JOIN RESERVA_TEMPORAL R
              ON R.reserva_id = P.reserva_id
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'fernanda.castillo@gmail.com'
              AND P.estado = 'RECHAZADO'
        ),
        (
            SELECT R.reserva_id
            FROM RESERVA_TEMPORAL R
            JOIN CLIENTE C
              ON C.cliente_id = R.cliente_id
            WHERE C.email = 'fernanda.castillo@gmail.com'
        ),
        (
            SELECT administrador_id
            FROM ADMINISTRADOR
            WHERE email = 'matias.rojas@puntoticket-demo.cl'
        ),
        'Pago rechazado durante el proceso de compra.',
        TIMESTAMP '2026-08-10 19:06:00'
    );


/* ============================================================
   COMMIT FINAL
   ============================================================ */

COMMIT;
