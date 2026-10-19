-- =========================================================
-- CONSULTA 1: Ventas con información descriptiva
-- Objetivo: obtener una fila por venta para analizarla en Power BI.
-- =========================================================
SELECT
    v.fecha_venta AS fecha,
    c.id_cliente AS identificacion_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p
    ON v.id_producto = p.id_producto
INNER JOIN categorias cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

-- Hallazgo: permite analizar la facturación por fecha, cliente y categoría,
-- identificando qué productos contribuyen más a los ingresos.

-- =========================================================
-- CONSULTA 2: Clientes sin ventas
-- Objetivo: identificar clientes registrados que nunca compraron.
-- =========================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL
ORDER BY c.nombre;

-- Hallazgo: aparecieron [N] clientes sin compras registradas.
-- CRM: permite detectar contactos que necesitan seguimiento para convertirlos en compradores.


-- =========================================================
-- CONSULTA 3: Productos sin ventas
-- Objetivo: identificar productos del catálogo que no se vendieron.
-- =========================================================

SELECT
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL
ORDER BY p.nombre_producto;

-- Hallazgo: aparecieron [N] productos sin ventas registradas.
-- Producto: revisar la demanda, el precio y las acciones comerciales
-- antes de decidir si se mantienen estos artículos en el catálogo.

-- =========================================================
-- CONSULTA 4: Consolidado por canal de origen (UNION ALL)
-- Objetivo: comparar los importes de ventas de dos períodos.
-- El canal se genera como un literal; no se busca en una tabla.
-- =========================================================

SELECT
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(total_venta) AS importe_total
FROM (
    SELECT
        'Periodo 2025' AS canal,
        cantidad * precio_unitario AS total_venta
    FROM ventas
    WHERE fecha_venta >= DATE '2025-01-01'
      AND fecha_venta < DATE '2026-01-01'

    UNION ALL

    SELECT
        'Periodo 2026' AS canal,
        cantidad * precio_unitario AS total_venta
    FROM ventas
    WHERE fecha_venta >= DATE '2026-01-01'
      AND fecha_venta < DATE '2027-01-01'
) AS consolidado
GROUP BY canal
ORDER BY canal;

-- Hallazgo:el resultado compara el importe y la cantidad de ventas 
-- de ambos períodos, permitiendo identificar cuál generó mayor facturación.


