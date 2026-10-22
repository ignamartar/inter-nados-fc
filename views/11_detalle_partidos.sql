CREATE OR REPLACE VIEW detalle_partidos AS

WITH planteles AS (

    SELECT
        pp.id_partido,

        STRING_AGG(
            j.nombre || ' ' || j.apellido,
            ', '
            ORDER BY j.apellido, j.nombre
        ) AS jugadores

    FROM participacion_partido pp

    JOIN jugador j
        ON j.id_jugador = pp.id_jugador

    GROUP BY pp.id_partido

),

eventos AS (

    SELECT
        e.id_partido,

        STRING_AGG(
            CASE
                WHEN e.tipo_evento = 'Gol'
                 AND e.es_autogol IS TRUE
                THEN 'Gol en contra'

                WHEN e.tipo_evento = 'Gol'
                THEN
                    COALESCE(
                        g.nombre || ' ' || g.apellido,
                        'Goleador no registrado'
                    )
                    ||
                    COALESCE(
                        ' (Asist: ' ||
                        a.nombre || ' ' || a.apellido ||
                        ')',
                        ''
                    )
            END,
            ', '
        ) FILTER (
            WHERE e.tipo_evento = 'Gol'
        ) AS goles,

        STRING_AGG(
            g.nombre || ' ' || g.apellido,
            ', '
        ) FILTER (
            WHERE e.tipo_evento = 'Amarilla'
              AND e.id_jugador IS NOT NULL
        ) AS amarillas,

        STRING_AGG(
            g.nombre || ' ' || g.apellido,
            ', '
        ) FILTER (
            WHERE e.tipo_evento = 'Roja'
              AND e.id_jugador IS NOT NULL
        ) AS rojas

    FROM evento_partido e

    LEFT JOIN jugador g
        ON g.id_jugador = e.id_jugador

    LEFT JOIN jugador a
        ON a.id_jugador = e.id_asistente

    GROUP BY e.id_partido

)

SELECT
    hp.id_partido,
    hp.fecha,
    hp.id_temporada,

    hp.id_rival,
    hp.rival,

    hp.instancia,
    hp.estado,
    hp.resultado,

    hp.goles_inter_nados,
    hp.goles_rival,

    hp.goles_inter_nados::TEXT
        || ' - ' ||
    hp.goles_rival::TEXT AS marcador,

    hp.hubo_penales,
    hp.penales_inter_nados,
    hp.penales_rival,

    COALESCE(pl.jugadores, '') AS jugadores,
    COALESCE(ev.goles, '') AS goles,
    COALESCE(ev.amarillas, '') AS amarillas,
    COALESCE(ev.rojas, '') AS rojas

FROM historial_partidos hp

LEFT JOIN planteles pl
    ON pl.id_partido = hp.id_partido

LEFT JOIN eventos ev
    ON ev.id_partido = hp.id_partido;