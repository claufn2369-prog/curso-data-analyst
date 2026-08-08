USE Ventas_Tech_DB;
GO
 
-- ---------------------------------------------------------
-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- ---------------------------------------------------------
SELECT
    MONTH(fecha_venta)                         AS mes,
    SUM(cantidad * precio_unitario)             AS total_facturado,
    COUNT(*)                                    AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)             AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
 
-- ---------------------------------------------------------
-- Consulta 2: Ranking de productos (Top 5 por facturación)
-- ---------------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad)                               AS unidades_vendidas,
    SUM(cantidad * precio_unitario)             AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
 
-- ---------------------------------------------------------
-- Consulta 3: Clientes recurrentes (más de un pedido)
-- ---------------------------------------------------------
SELECT
    id_cliente,
    COUNT(*)                                    AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)             AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
 
-- ---------------------------------------------------------
-- Consulta 4: Meses por encima / por debajo del promedio mensual
-- ---------------------------------------------------------
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)                      AS mes,
        SUM(cantidad * precio_unitario)          AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_mensual)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_mensual
ORDER BY mes;
 
-- ---------------------------------------------------------
-- Hallazgos (basados en los datos actuales de Ventas_Tech_DB)
-- ---------------------------------------------------------
-- 1) Con los datos actuales, todas las ventas se concentran en marzo
--    de 2024 (10 pedidos, $6.444 facturados, ticket promedio $644,40).
--    Al no haber otros meses cargados, la Consulta 4 no puede mostrar
--    variación real; se necesitan más períodos para que el análisis
-- 2) El producto 1 (Laptop Pro 15) concentra $3.600 de los $6.444
--    totales -> cerca del 56% de la facturación, a pesar de haberse
--    vendido en solo 3 unidades. Es el producto de mayor ticket unitario.
-- 3) Los 5 clientes registrados hicieron exactamente 2 pedidos cada
--    uno -> el 100% de la cartera actual es "recurrente" según el
--    criterio de la consigna (>1 pedido). El cliente 5 (Laura Torres)
--    es el que más gastó en total: $2.100.