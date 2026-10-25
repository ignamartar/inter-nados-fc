CREATE OR REPLACE VIEW trayectoria_jugadores AS

WITH participaciones AS (

    SELECT DISTINCT
        j.id_jugador,
        j.nombre || ' ' || j.apellido AS jugador,
        p.id_partido,
        p.fecha,
        p.id_temporada,
        t.anio

    FROM jugador j

    JOIN participacion_partido pp
        ON pp.id_jugador = j.id_jugador

    JOIN partido p
        ON p.id_partido = pp.id_partido

    JOIN temporada t
        ON t.id_temporada = p.id_temporada

    WHERE p.id_local = 1

),

temporadas_jugador AS (

    SELECT DISTINCT
        id_jugador,
        anio

    FROM participaciones

),

temporadas_ordenadas AS (

    SELECT
        id_jugador,
        anio,

        LAG(anio) OVER (
            PARTITION BY id_jugador
            ORDER BY anio
        ) AS anio_anterior

    FROM temporadas_jugador

),

inicios_etapa AS (

    SELECT
        id_jugador,
        anio,

        CASE
            WHEN anio_anterior IS NULL
              OR anio - anio_anterior > 1
            THEN 1
            ELSE 0
        END AS nueva_etapa

    FROM temporadas_ordenadas

),

etapas_numeradas AS (

    SELECT
        id_jugador,
        anio,

        SUM(nueva_etapa) OVER (
            PARTITION BY id_jugador
            ORDER BY anio
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS numero_etapa

    FROM inicios_etapa

),

partidos_con_etapa AS (

    SELECT
        p.*,
        e.numero_etapa

    FROM participaciones p

    JOIN etapas_numeradas e
        ON e.id_jugador = p.id_jugador
       AND e.anio = p.anio

),

duracion_etapas AS (

    SELECT
        id_jugador,
        numero_etapa,

        MIN(fecha) AS fecha_inicio_etapa,
        MAX(fecha) AS fecha_fin_etapa,

        MAX(fecha) - MIN(fecha) AS dias_etapa

    FROM partidos_con_etapa

    GROUP BY
        id_jugador,
        numero_etapa

),

resumen_etapas AS (

    SELECT
        id_jugador,

        SUM(dias_etapa)::integer AS dias_activos,

        COUNT(*) AS cantidad_etapas

    FROM duracion_etapas

    GROUP BY id_jugador

),

resumen_jugadores AS (

    SELECT
        id_jugador,
        jugador,

        MIN(fecha) AS fecha_debut,
        MAX(fecha) AS fecha_ultimo_partido,

        COUNT(DISTINCT id_partido) AS partidos,

        COUNT(DISTINCT id_temporada)
            AS temporadas_disputadas,

        MIN(anio) AS primera_temporada,
        MAX(anio) AS ultima_temporada,

        MAX(fecha) - MIN(fecha)
            AS dias_desde_debut,

        STRING_AGG(
            DISTINCT anio::text,
            ', '
            ORDER BY anio::text
        ) AS temporadas

    FROM participaciones

    GROUP BY
        id_jugador,
        jugador

)

SELECT
    r.id_jugador,
    r.jugador,

    r.fecha_debut,
    r.fecha_ultimo_partido,

    r.partidos,
    r.temporadas_disputadas,

    r.primera_temporada,
    r.ultima_temporada,

    e.dias_activos AS dias_trayectoria,

    r.temporadas,

    e.cantidad_etapas,

    r.dias_desde_debut

FROM resumen_jugadores r

JOIN resumen_etapas e
    ON e.id_jugador = r.id_jugador;