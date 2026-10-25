CREATE OR REPLACE VIEW partidos_con_gol_jugador AS

WITH partidos_goleadores AS (

    SELECT
        e.id_jugador,
        COUNT(DISTINCT e.id_partido) AS partidos_con_gol

    FROM evento_partido e

    JOIN partido p
        ON p.id_partido = e.id_partido

    WHERE e.tipo_evento = 'Gol'
      AND e.es_autogol IS NOT TRUE
      AND e.id_jugador IS NOT NULL
      AND p.id_local = 1
      AND p.estado = 'Jugado'

    GROUP BY e.id_jugador

)

SELECT
    ej.id_jugador,
    ej.jugador,

    ej.partidos,

    COALESCE(pg.partidos_con_gol, 0)
        AS partidos_con_gol,

    ej.goles,

    ej.partidos - COALESCE(pg.partidos_con_gol, 0)
        AS partidos_sin_gol,

    ROUND(
        COALESCE(pg.partidos_con_gol, 0)::numeric * 100
        / NULLIF(ej.partidos, 0),
        2
    ) AS porcentaje_partidos_con_gol,

    ROUND(
        ej.goles::numeric
        / NULLIF(pg.partidos_con_gol, 0),
        2
    ) AS goles_por_partido_con_gol

FROM estadisticas_jugadores ej

LEFT JOIN partidos_goleadores pg
    ON pg.id_jugador = ej.id_jugador;