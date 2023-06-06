-- 1. Clientes
-- Definición de objeto para la tabla Clientes
CREATE TYPE Cliente_obj AS OBJECT (
  id_cliente INT,
  nombre VARCHAR2(100),
  direccion VARCHAR2(200),
  numero_cuenta VARCHAR2(50),
  detalles VARCHAR2(200),

  -- Método para obtener los datos del cliente
  MEMBER FUNCTION datos_cliente RETURN VARCHAR2
);

INSERT INTO Clientes VALUES (1, 'Estudios Pantalla Plateada', 'Calle Principal 123', '1234567890', 'Este cliente trabaja en televisión.');
INSERT INTO Clientes VALUES (2, 'Atrezzo Estelar', 'Calle del Olmo 45', '0987654321', 'Este cliente necesita eficacia y rapidez.');
INSERT INTO Clientes VALUES (3, 'Producciones CineMágico', 'Avenida del Roble 78', '9876543210', 'Este cliente busca atrezzo original y creativo.');
INSERT INTO Clientes VALUES (4, 'Films de Fantasía S.A.', 'Calle del Pino 31', '5678901234', 'Este cliente necesita decorados y atrezzo realistas.');
INSERT INTO Clientes VALUES (5, 'Soluciones VestuarioCine', 'Calle del Cedro 87', '4321098765', 'Este cliente requiere un amplio catálogo de opciones de vestuario para cine y televisión.');

-- Tabla Clientes basada en el objeto Cliente
CREATE TABLE Clientes OF Cliente_obj (
  PRIMARY KEY (id_cliente)
);

-- Implementación método para obtener los datos del cliente
CREATE OR REPLACE TYPE BODY Cliente_obj AS
  MEMBER FUNCTION datos_cliente RETURN VARCHAR2 IS
  BEGIN
    RETURN 'Cliente: Nombre: ' || nombre || ' / Dirección: ' || direccion ||  '/ Número de cuenta: ' || numero_cuenta;
  END;
END;

-- Ejemplo de uso del método en una consulta
SELECT c.datos_cliente() AS datos
FROM Clientes c;

-- 2. Productos
-- Definición de objeto para la tabla Productos
CREATE TYPE Producto_obj AS OBJECT (
  id_producto INT,
  nombre VARCHAR2(100),
  descripcion VARCHAR2(200),
  disponibilidad CHAR(1),
  tamaño INT,

  -- Método para obtener los datos del producto
  MEMBER FUNCTION datos_producto RETURN VARCHAR2
);

-- Tabla Productos basada en el objeto Producto
CREATE TABLE Productos OF Producto_obj (
  PRIMARY KEY (id_producto)
);

INSERT INTO Productos VALUES (1, 'Sillón Chesterfield', 'Un elegante sillón de cuero de estilo clásico, perfecto para ambientar escenas de época.', 'S', 10);
INSERT INTO Productos VALUES (2, 'Maleta Vintage', 'Una maleta antigua de aspecto retro, ideal para viajes en el tiempo o escenarios de época.', 'N', 5);
INSERT INTO Productos VALUES (3, 'Teléfono de Dial', 'Un teléfono de disco auténtico de los años 70, ideal para ambientar escenas de nostalgia o detectivescas.', 'S', 8);
INSERT INTO Productos VALUES (4, 'Reloj de Péndulo', 'Un reloj de péndulo clásico que añade un toque de elegancia y sofisticación a cualquier decorado.', 'S', 12);
INSERT INTO Productos VALUES (5, 'Candelabro Gótico', 'Un candelabro imponente con diseño gótico, perfecto para escenas de misterio y suspense.', 'N', 7);

-- Implementación método para obtener los datos del producto
CREATE OR REPLACE TYPE BODY Producto_obj AS
  MEMBER FUNCTION datos_producto RETURN VARCHAR2 IS
  BEGIN
    RETURN 'Producto: Nombre: ' || nombre || ' / Descripción: ' || descripcion || ' / Disponibilidad: ' || disponibilidad ;
  END;
END;

SELECT p.datos_producto() AS datos
FROM Productos p;

-- 3. Pedidos
-- Definición de objeto Pedido
CREATE OR REPLACE TYPE Pedido_obj AS OBJECT (
  id_pedido INT,
  cliente REF Cliente_obj,
  direccion_entrega VARCHAR2(200),
  fecha_pedido DATE,
  fecha_devolucion DATE,

  -- Método para obtener los datos del pedido
  MEMBER FUNCTION datos_pedido RETURN VARCHAR2
);

-- Tabla pedidos
CREATE TABLE Pedidos OF Pedido_obj (
  PRIMARY KEY (id_pedido),
  FOREIGN KEY (cliente) REFERENCES Clientes
);

-- INSERT INTO Pedidos
INSERT INTO Pedidos VALUES (1, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 1), 'Calle Principal 123', SYSDATE, SYSDATE+7);
INSERT INTO Pedidos VALUES (2, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 2), 'Calle del Olmo 456', SYSDATE, SYSDATE+5);
INSERT INTO Pedidos VALUES (3, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 3), 'Avenida del Roble 789', SYSDATE, SYSDATE+3);
INSERT INTO Pedidos VALUES (4, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 4), 'Calle del Pino 321', SYSDATE, SYSDATE+2);
INSERT INTO Pedidos VALUES (5, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 5), 'Calle del Cedro 987', SYSDATE, SYSDATE+10);
INSERT INTO Pedidos VALUES (6, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 5), 'Calle del Cubo 987', SYSDATE, SYSDATE+10);
INSERT INTO Pedidos VALUES (7, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 2), 'Calle del Alce 987', SYSDATE, SYSDATE+10);


-- Implementación del método para obtener los datos del pedido
CREATE OR REPLACE TYPE BODY Pedido_obj AS
  MEMBER FUNCTION datos_pedido RETURN VARCHAR2 IS
    v_cliente Cliente_obj;
  BEGIN
    SELECT DEREF(cliente) INTO v_cliente FROM dual;
    RETURN 'Pedido, Cliente: ' || v_cliente.datos_cliente() || ', Dirección de entrega: ' || direccion_entrega;
  END;
END;

-- Ejemplo de uso del método en una consulta
SELECT p.datos_pedido() AS datos
FROM Pedidos p;

-- 4. Alquileres
-- Definición de objeto Alquiler
CREATE TYPE Alquiler_obj AS OBJECT (
  pedido REF Pedido_obj,
  producto REF Producto_obj,

  -- Método para obtener los datos del alquiler
  MEMBER FUNCTION datos_alquiler RETURN VARCHAR2
);

-- Tabla Alquileres
CREATE TABLE Alquileres OF Alquiler_obj (
  FOREIGN KEY (pedido) REFERENCES Pedidos,
  FOREIGN KEY (producto) REFERENCES Productos
);

-- INSERT INTO Alquileres
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 1), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 1));
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 2), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 2));
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 3), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 3));
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 4), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 4));
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 5), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 5));
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 6), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 2));
INSERT INTO Alquileres VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 7), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 1));


-- Implementación del método para obtener los datos del alquiler
CREATE OR REPLACE TYPE BODY Alquiler_obj AS
  MEMBER FUNCTION datos_alquiler RETURN VARCHAR2 IS
    v_pedido Pedido_obj;
    v_producto Producto_obj;
  BEGIN
    SELECT DEREF(pedido) INTO v_pedido FROM dual;
    SELECT DEREF(producto) INTO v_producto FROM dual;
    RETURN 'Alquiler: Pedido: ' || v_pedido.datos_pedido() || ', Producto: ' || v_producto.datos_producto();
  END;
END;

-- Ejemplo de uso del método en una consulta
SELECT a.datos_alquiler() AS datos
FROM Alquileres a;

-- 5. Facturas
-- Objeto Facturas
CREATE TYPE Factura_obj AS OBJECT (
  id_factura INT,
  pedido REF Pedido_obj,
  fecha_factura DATE,
  importe FLOAT,

  -- Método para obtener los datos de la factura
  MEMBER FUNCTION detalle_factura RETURN VARCHAR2
);

-- Tabla Facturas
CREATE TABLE Facturas OF Factura_obj (
  PRIMARY KEY (id_factura),
  FOREIGN KEY (pedido) REFERENCES Pedidos
);

-- INSERT INTO Facturas
INSERT INTO Facturas (id_factura, pedido, fecha_factura, importe)
VALUES (1, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 1), SYSDATE, 100.00);
INSERT INTO Facturas (id_factura, pedido, fecha_factura, importe)
VALUES (2, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 2), SYSDATE, 150.50);
INSERT INTO Facturas (id_factura, pedido, fecha_factura, importe)
VALUES (3, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 3), SYSDATE, 200.00);
INSERT INTO Facturas (id_factura, pedido, fecha_factura, importe)
VALUES (4, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 4), SYSDATE, 120.75);
INSERT INTO Facturas (id_factura, pedido, fecha_factura, importe)
VALUES (5, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 5), SYSDATE, 180.25);

-- Implementación del método para obtener los datos de la factura
CREATE OR REPLACE TYPE BODY Factura_obj AS
  MEMBER FUNCTION detalle_factura RETURN VARCHAR2 IS
    v_pedido Pedido_obj;
  BEGIN
    SELECT DEREF(pedido) INTO v_pedido FROM dual;
    RETURN 'Factura: ID: ' || id_factura || ', Pedido: ' || v_pedido.datos_pedido() || ' / Fecha: ' || TO_CHAR(fecha_factura, 'DD-MON-YYYY') || ' / Importe: ' || importe;
  END;
END;

-- Ejemplo de uso del método en una consulta
SELECT f.detalle_factura() AS datos
FROM Facturas f;

-- 6. Entregas
-- Objeto Entregas
CREATE TYPE Entrega_obj AS OBJECT (
  id_entrega INT,
  pedido REF Pedido_obj,
  fecha_entrega DATE,
  matricula VARCHAR2(100),
  transportista VARCHAR2(100),
  detalles VARCHAR2(200),

  -- Método para obtener los datos de la entrega
  MEMBER FUNCTION datos_entrega RETURN VARCHAR2
);

-- Tabla Entregas
CREATE TABLE Entregas OF Entrega_obj (
  PRIMARY KEY (id_entrega),
  FOREIGN KEY (pedido) REFERENCES Pedidos
);

-- INSERT INTO Entregas
INSERT INTO Entregas (id_entrega, pedido, fecha_entrega, matricula, transportista, detalles)
VALUES (1, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 1), SYSDATE + 1, 'ABC123', 'Transportista 1', 'Entrega programada para el set de filmación "Aventuras en la Selva".');

INSERT INTO Entregas (id_entrega, pedido, fecha_entrega, matricula, transportista, detalles)
VALUES (2, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 2), SYSDATE + 2, 'DEF456', 'Transportista 2', 'Entrega urgente para el rodaje de la película de acción "Explosión Final".');

INSERT INTO Entregas (id_entrega, pedido, fecha_entrega, matricula, transportista, detalles)
VALUES (3, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 3), SYSDATE + 3, 'GHI789', 'Transportista 3', 'Entrega especial de atrezzo para el escenario de la obra de teatro "Sueños de Shakespeare".');

INSERT INTO Entregas (id_entrega, pedido, fecha_entrega, matricula, transportista, detalles)
VALUES (4, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 4), SYSDATE + 4, 'JKL012', 'Transportista 4', 'Entrega programada para el set de grabación de la serie de televisión "Misterios Sin Resolver".');

INSERT INTO Entregas (id_entrega, pedido, fecha_entrega, matricula, transportista, detalles)
VALUES (5, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 5), SYSDATE + 5, 'MNO345', 'Transportista 5', 'Entrega de vestuario para el rodaje de la película histórica "El Tiempo Dorado".');


-- Implementación del método para obtener los datos de la entrega
CREATE OR REPLACE TYPE BODY Entrega_obj AS
  MEMBER FUNCTION datos_entrega RETURN VARCHAR2 IS
    v_pedido Pedido_obj;
  BEGIN
    SELECT DEREF(pedido) INTO v_pedido FROM dual;
    RETURN 'Entrega: ID: ' || id_entrega || ', Pedido: ' || v_pedido.datos_pedido() || ' / Fecha: ' || TO_CHAR(fecha_entrega, 'DD-MON-YYYY') || ' / Matrícula: ' || matricula || ' / Transportista: ' || transportista || ' / Detalles: ' || detalles;
  END;
END;

-- Ejemplo de uso del método en una consulta
SELECT e.datos_entrega() AS datos
FROM Entregas e;

-- 7. Recogidas
-- Objeto Recogidas
CREATE TYPE Recogida_obj AS OBJECT (
  id_recogida INT,
  pedido REF Pedido_obj,
  fecha_recogida DATE,
  matricula VARCHAR2(100),
  transportista VARCHAR2(100),
  detalles VARCHAR2(200),

  -- Método para obtener los datos de la recogida
  MEMBER FUNCTION datos_recogida RETURN VARCHAR2
);

-- Tabla Recogidas
CREATE TABLE Recogidas OF Recogida_obj (
  PRIMARY KEY (id_recogida),
  FOREIGN KEY (pedido) REFERENCES Pedidos
);


-- INSERT INTO Recogidas
INSERT INTO Recogidas (id_recogida, pedido, fecha_recogida, matricula, transportista, detalles)
VALUES (1, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 1), SYSDATE + 6, 'PQR678', 'Transportista 6', 'Recogida en la dirección principal');

INSERT INTO Recogidas (id_recogida, pedido, fecha_recogida, matricula, transportista, detalles)
VALUES (2, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 2), SYSDATE + 7, 'STU901', 'Transportista 7', 'Recogida en la dirección de la sucursal');

INSERT INTO Recogidas (id_recogida, pedido, fecha_recogida, matricula, transportista, detalles)
VALUES (3, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 3), SYSDATE + 8, 'VWX234', 'Transportista 8', 'Recogida en la dirección residencial');

INSERT INTO Recogidas (id_recogida, pedido, fecha_recogida, matricula, transportista, detalles)
VALUES (4, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 4), SYSDATE + 9, 'YZA567', 'Transportista 9', 'Recogida en la dirección comercial');

INSERT INTO Recogidas (id_recogida, pedido, fecha_recogida, matricula, transportista, detalles)
VALUES (5, (SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 5), SYSDATE + 10, 'BCD890', 'Transportista 10', 'Recogida en la dirección de entrega alternativa');


-- Implementación del método para obtener los datos de la recogida
CREATE OR REPLACE TYPE BODY Recogida_obj AS
  MEMBER FUNCTION datos_recogida RETURN VARCHAR2 IS
    v_pedido Pedido_obj;
  BEGIN
    SELECT DEREF(pedido) INTO v_pedido FROM dual;
    RETURN 'Recogida: ID: ' || id_recogida || ', Pedido: ' || v_pedido.datos_pedido() || ' / Fecha: ' || TO_CHAR(fecha_recogida, 'DD-MON-YYYY') || ' / Matrícula: ' || matricula || ' / Transportista: ' || transportista || ' / Detalles: ' || detalles;
  END;
END;

-- Ejemplo de uso del método en una consulta
SELECT r.datos_recogida() AS datos
FROM Recogidas r;

-- SELECTS

-- Obtener todos los productos disponibles:
SELECT p.id_producto, p.nombre, p.descripcion, p.tamaño
FROM Productos p
WHERE p.disponibilidad = 'S';

-- Obtener todos los pedidos junto con los datos del cliente y la dirección de entrega:
SELECT p.id_pedido, c.nombre AS nombre_cliente, c.direccion AS direccion_entrega
FROM Pedidos p
JOIN Clientes c ON p.cliente = REF(c);

-- Obtener todos los clientes con los datos de los mismos.
SELECT c.id_cliente, c.nombre, c.direccion, c.numero_cuenta, c.detalles
FROM Clientes c;

-- Obtener todas las facturas junto con los datos del pedido y el importe:
SELECT f.id_factura, p.id_pedido, p.cliente.nombre AS nombre_cliente, p.direccion_entrega, p.fecha_pedido, f.importe, f.fecha_factura
FROM Facturas f
JOIN Pedidos p ON f.pedido = REF(p);

-- Obtener el promedio del importe de las facturas:
SELECT AVG(importe) AS promedio_importe
FROM Facturas;

-- Obtener los datos de las entregas junto con los datos de los pedidos y clientes asociados:
SELECT e.id_entrega, p.id_pedido, p.direccion_entrega, p.fecha_pedido, c.nombre AS nombre_cliente, e.fecha_entrega, e.matricula, e.transportista
FROM Entregas e
JOIN Pedidos p ON e.pedido = REF(p)
JOIN Clientes c ON p.cliente = REF(c);

-- Obtener los datos de las recogidas junto con los datos de los pedidos y clientes asociados:
SELECT r.id_recogida, p.id_pedido, p.direccion_entrega, p.fecha_pedido, c.nombre AS nombre_cliente, r.fecha_recogida, r.matricula, r.transportista
FROM Recogidas r
JOIN Pedidos p ON r.pedido = REF(p)
JOIN Clientes c ON p.cliente = REF(c);

-- Obtener el total de importes facturados por cliente y el número de facturas emitidas: (Buscar la explicación a este SELECT)
SELECT c.nombre AS nombre_cliente, COUNT(f.id_factura) AS numero_facturas, SUM(f.importe) AS total_importe
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.cliente.id_cliente
LEFT JOIN Facturas f ON p.id_pedido = f.pedido.id_pedido
GROUP BY c.nombre;

-- Obtener el número total de pedidos realizados por un cliente específico
SELECT c.nombre AS nombre_cliente, COUNT(p.id_pedido) AS total_pedidos
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.cliente.id_cliente
WHERE c.id_cliente = 4
GROUP BY c.nombre;

-- Obtener el detalle de un pedido junto con el importe total de la factura correspondiente
SELECT p.id_pedido, p.cliente.nombre AS nombre_cliente, p.direccion_entrega, p.fecha_pedido, f.importe
FROM Pedidos p
JOIN Facturas f ON p.id_pedido = f.pedido.id_pedido
WHERE p.id_pedido = 3;

-- Obtener el cliente con el gasto total más alto: (Buscar explicación)
SELECT c.id_cliente, c.nombre, SUM(f.importe) AS gasto_total
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.cliente.id_cliente
JOIN Facturas f ON p.id_pedido = f.pedido.id_pedido
GROUP BY c.id_cliente, c.nombre
ORDER BY gasto_total DESC
FETCH FIRST 1 ROWS ONLY;

-- Obtener el producto más alquilado:
SELECT p.id_producto, p.nombre, COUNT(*) AS total_alquileres
FROM Productos p
JOIN Alquileres a ON p.id_producto = a.producto.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY total_alquileres DESC
FETCH FIRST 1 ROWS ONLY;

-- Obtener los productos con más alquileres ordenados
SELECT p.id_producto, p.nombre, COUNT(*) AS total_alquileres
FROM Productos p
JOIN Alquileres a ON p.id_producto = a.producto.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY total_alquileres DESC;

-- Obtener los clientes en orden descendente según el total gastado.
SELECT c.nombre AS nombre_cliente, SUM(f.importe) AS total_gastado
FROM Clientes c
INNER JOIN Pedidos p ON c.id_cliente = p.cliente.id_cliente
INNER JOIN Facturas f ON p.id_pedido = f.pedido.id_pedido
GROUP BY c.nombre
ORDER BY SUM(f.importe) DESC;

-- Obtener el nombre y la cuenta bancaria de los clientes que tienen pedidos asociados
SELECT c.nombre, c.numero_cuenta
FROM Clientes c
WHERE c.id_cliente IN (SELECT p.cliente.id_cliente FROM Pedidos p);

-- Obtener los clientes junto con la información de las facturas correspondientes, ordenados por nombre de cliente
SELECT c.nombre, c.numero_cuenta, f.id_factura, f.fecha_factura, f.importe
FROM Clientes c
INNER JOIN Facturas f ON c.id_cliente = f.pedido.cliente.id_cliente
ORDER BY c.nombre;

-- Obtener el detalle de los pedidos realizados por un cliente en particular
SELECT c.nombre AS NOMBRE_CLIENTE, p.datos_pedido() AS detalle_pedido
FROM Pedidos p
INNER JOIN Clientes c ON p.cliente.id_cliente = c.id_cliente
WHERE c.id_cliente = 2;

-- Obtener el nombre de los productos alquilados por cada cliente
SELECT c.nombre, p.nombre AS producto_alquilado
FROM Clientes c
INNER JOIN Pedidos pe ON c.id_cliente = pe.cliente.id_cliente
INNER JOIN Alquileres a ON pe.id_pedido = a.pedido.id_pedido
INNER JOIN Productos p ON a.producto.id_producto = p.id_producto;

-- Obtener la información completa del pedido, con diferentes detalles
SELECT p.id_pedido, c.nombre AS nombre_cliente, pr.nombre AS nombre_producto, p.direccion_entrega, c.numero_cuenta, c.detalles, p.fecha_pedido, p.fecha_devolucion, f.importe
FROM Pedidos p
INNER JOIN Clientes c ON p.cliente.id_cliente = c.id_cliente
INNER JOIN Alquileres a ON p.id_pedido = a.pedido.id_pedido
INNER JOIN Productos pr ON a.producto.id_producto = pr.id_producto
INNER JOIN Facturas f ON p.id_pedido = f.pedido.id_pedido;

-- Obtener los datos del pedido con los detalles del producto, la entrega y la recogida correspondientes:
SELECT p.id_pedido, c.nombre AS nombre_cliente, pr.nombre AS nombre_producto, pr.descripcion AS descripcion_producto,
       e.fecha_entrega, e.matricula AS matricula_entrega, e.transportista AS transportista_entrega,
       r.fecha_recogida, r.matricula AS matricula_recogida, r.transportista AS transportista_recogida
FROM Pedidos p
INNER JOIN Clientes c ON p.cliente.id_cliente = c.id_cliente
INNER JOIN Alquileres a ON p.id_pedido = a.pedido.id_pedido
INNER JOIN Productos pr ON a.producto.id_producto = pr.id_producto
LEFT JOIN Entregas e ON p.id_pedido = e.pedido.id_pedido
LEFT JOIN Recogidas r ON p.id_pedido = r.pedido.id_pedido;

-- Obtener los datos y detalles de pedidos, entregas y recogidas
SELECT p.id_pedido, c.nombre AS nombre_cliente, p.fecha_pedido,
       e.fecha_entrega, e.matricula AS matricula_entrega, e.detalles AS DETALLES_ENTREGA,
       r.fecha_recogida, r.matricula AS matricula_recogida, r.detalles AS DETALLES_RECOGIDA
FROM Pedidos p
JOIN Clientes c ON p.cliente.id_cliente = c.id_cliente
LEFT JOIN Entregas e ON p.id_pedido = DEREF(e.pedido).id_pedido
LEFT JOIN Recogidas r ON p.id_pedido = DEREF(r.pedido).id_pedido;

-- PLAN DE PRUEBAS - INSERTAR UN NUEVO PEDIDO COMPLETO

-- Insertar un nuevo cliente
INSERT INTO Clientes (id_cliente, nombre, direccion, numero_cuenta, detalles)
VALUES (23, 'Jane Smith', '789 Oak Avenue', '987654321', 'Cliente VIP');

-- Insertar un nuevo pedido
INSERT INTO Pedidos (id_pedido, cliente, direccion_entrega, fecha_pedido, fecha_devolucion)
VALUES (23, (SELECT REF(c) FROM Clientes c WHERE c.id_cliente = 3), '987 Maple Street', SYSDATE, SYSDATE + 10);

-- Insertar un nuevo alquiler
INSERT INTO Alquileres (pedido, producto)
VALUES ((SELECT REF(p) FROM Pedidos p WHERE p.id_pedido = 3), (SELECT REF(pr) FROM Productos pr WHERE pr.id_producto = 2));

SELECT c.id_cliente, c.nombre, c.direccion, c.numero_cuenta, c.detalles
FROM Clientes c;

-- PLAN DE PRUEBAS 2
-- Cambiar el registro de detalles en la tabla Recogidas
UPDATE Recogidas
SET detalles = 'La recogida se llevó a cabo de manera satisfactoria.'
WHERE id_recogida = 2;

SELECT r.id_recogida, p.id_pedido, p.cliente.nombre AS nombre_cliente, p.direccion_entrega, r.fecha_recogida, r.matricula, r.transportista, r.detalles
FROM Recogidas r
JOIN Pedidos p ON r.pedido = REF(p);