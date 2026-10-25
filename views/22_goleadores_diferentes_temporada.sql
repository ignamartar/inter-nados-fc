CREATE OR REPLACE VIEW goleadores_diferentes_temporada AS

WITH goles_por_jugador AS (

    SELECT
        p.id_temporada,
        e.id_jugador,
        COUNT(*) AS goles

    FROM evento_partido e

    JOIN partido p
        ON p.id_partido = e.id_partido

    WHERE e.tipo_evento = 'Gol'
      AND e.es_autogol IS NOT TRUE
      AND e.id_jugador IS NOT NULL
      AND p.id_local = 1
      AND p.estado = 'Jugado'

    GROUP BY
        p.id_temporada,
        e.id_jugador

),

resumen_goleadores AS (

    SELECT
        id_temporada,

        COUNT(*) AS goleadores_diferentes,

        SUM(goles) AS goles_jugadores,

        MAX(goles) AS maximo_goles_jugador

    FROM goles_por_jugador

    GROUP BY id_temporada

)

SELECT
    t.id_temporada,
    t.anio AS temporada,

    COALESCE(
        rg.goleadores_diferentes, 0
    ) AS goleadores_diferentes,

    COALESCE(
        rg.goles_jugadores, 0
    ) AS goles_jugadores,

    ect.gf AS goles_equipo,

    ROUND(
        COALESCE(rg.goles_jugadores, 0)::numeric
        * 100 / NULLIF(ect.gf, 0),
        2
    ) AS porcentaje_goles_jugadores,

    COALESCE(
        rg.maximo_goles_jugador, 0
    ) AS maximo_goles_jugador

FROM estadisticas_club_temporada ect

JOIN temporada t
    ON t.id_temporada = ect.id_temporada

LEFT JOIN resumen_goleadores rg
    ON rg.id_temporada = ect.id_temporada;