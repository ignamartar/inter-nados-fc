CREATE OR REPLACE VIEW disciplina_jugadores AS

WITH partidos_tarjetas AS (

    SELECT
        e.id_jugador,

        COUNT(DISTINCT e.id_partido) FILTER (
            WHERE e.tipo_evento = 'Amarilla'
        ) AS partidos_con_amarilla,

        COUNT(DISTINCT e.id_partido) FILTER (
            WHERE e.tipo_evento = 'Roja'
        ) AS partidos_con_roja,

        COUNT(DISTINCT e.id_partido) FILTER (
            WHERE e.tipo_evento IN ('Amarilla', 'Roja')
        ) AS partidos_con_tarjeta

    FROM evento_partido e

    JOIN partido p
        ON p.id_partido = e.id_partido

    WHERE e.tipo_evento IN ('Amarilla', 'Roja')
      AND e.id_jugador IS NOT NULL
      AND p.id_local = 1
      AND p.estado = 'Jugado'

    GROUP BY e.id_jugador

)

SELECT
    ej.id_jugador,
    ej.jugador,

    ej.partidos,
    ej.amarillas,
    ej.rojas,

    (ej.amarillas + ej.rojas) AS total_tarjetas,

    COALESCE(pt.partidos_con_amarilla, 0)
        AS partidos_con_amarilla,

    COALESCE(pt.partidos_con_roja, 0)
        AS partidos_con_roja,

    COALESCE(pt.partidos_con_tarjeta, 0)
        AS partidos_con_tarjeta,

    ROUND(
        COALESCE(pt.partidos_con_tarjeta, 0)::numeric * 100
        / NULLIF(ej.partidos, 0),
        2
    ) AS porcentaje_partidos_con_tarjeta,

    ROUND(
        ej.amarillas::numeric * 10
        / NULLIF(ej.partidos, 0),
        2
    ) AS amarillas_cada_10_partidos,

    ROUND(
        ej.rojas::numeric * 10
        / NULLIF(ej.partidos, 0),
        2
    ) AS rojas_cada_10_partidos,

    ROUND(
        (ej.amarillas + ej.rojas)::numeric * 10
        / NULLIF(ej.partidos, 0),
        2
    ) AS tarjetas_cada_10_partidos

FROM estadisticas_jugadores ej

LEFT JOIN partidos_tarjetas pt
    ON pt.id_jugador = ej.id_jugador;