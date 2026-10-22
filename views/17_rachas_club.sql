CREATE OR REPLACE VIEW rachas_club AS

WITH partidos_ordenados AS (

    SELECT
        id_partido,
        fecha,
        resultado,
        estado,
        goles_inter_nados,

        ROW_NUMBER() OVER (
            ORDER BY fecha, id_partido
        ) AS orden

    FROM historial_partidos

),

tipos_racha AS (

    SELECT
        p.*,
        r.tipo_racha,

        CASE
            WHEN r.tipo_racha = 'Victorias consecutivas'
                THEN p.resultado = 'Victoria'

            WHEN r.tipo_racha = 'Partidos invictos'
                THEN p.resultado IN ('Victoria', 'Empate')

            WHEN r.tipo_racha = 'Derrotas consecutivas'
                THEN p.resultado = 'Derrota'

            WHEN r.tipo_racha = 'Partidos marcando goles'
                THEN p.estado = 'Jugado'
                     AND p.goles_inter_nados > 0
        END AS cumple

    FROM partidos_ordenados p

    CROSS JOIN (
        VALUES
            ('Victorias consecutivas'),
            ('Partidos invictos'),
            ('Derrotas consecutivas'),
            ('Partidos marcando goles')
    ) AS r(tipo_racha)

),

grupos AS (

    SELECT
        *,

        SUM(
            CASE WHEN cumple THEN 0 ELSE 1 END
        ) OVER (
            PARTITION BY tipo_racha
            ORDER BY orden
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS grupo_racha

    FROM tipos_racha

)

SELECT
    tipo_racha,

    COUNT(*) AS partidos_consecutivos,

    MIN(fecha) AS fecha_inicio,
    MAX(fecha) AS fecha_fin,

    (ARRAY_AGG(id_partido ORDER BY orden ASC))[1]
        AS id_partido_inicio,

    (ARRAY_AGG(id_partido ORDER BY orden DESC))[1]
        AS id_partido_fin,

    BOOL_OR(
        orden = (
            SELECT MAX(orden)
            FROM partidos_ordenados
        )
    ) AS racha_vigente

FROM grupos

WHERE cumple

GROUP BY
    tipo_racha,
    grupo_racha;