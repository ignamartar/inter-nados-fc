CREATE OR REPLACE VIEW estadisticas_jugadores_temporada AS

WITH participaciones AS (
    SELECT
        pp.id_jugador,
        p.id_temporada,

        COUNT(*) AS partidos,

        COUNT(*) FILTER (
            WHERE p.goles_local > p.goles_visitante
               OR (
                   p.goles_local = p.goles_visitante
                   AND p.hubo_penales = TRUE
                   AND p.penales_local > p.penales_visitante
               )
        ) AS pg,

        COUNT(*) FILTER (
            WHERE p.goles_local = p.goles_visitante
              AND p.hubo_penales IS NOT TRUE
        ) AS pe,

        COUNT(*) FILTER (
            WHERE p.goles_local < p.goles_visitante
               OR (
                   p.goles_local = p.goles_visitante
                   AND p.hubo_penales = TRUE
                   AND p.penales_local < p.penales_visitante
               )
        ) AS pp,

        COUNT(*) FILTER (
            WHERE j.posicion = 'Arquero'
              AND p.goles_visitante = 0
              AND p.estado = 'Jugado'
        ) AS vallas_invictas

    FROM participacion_partido pp
    JOIN partido p ON pp.id_partido = p.id_partido
    JOIN jugador j ON pp.id_jugador = j.id_jugador

    GROUP BY pp.id_jugador, p.id_temporada
),

eventos AS (
    SELECT
        j.id_jugador,
        p.id_temporada,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Gol'
              AND e.id_jugador = j.id_jugador
        ) AS goles,

        COUNT(*) FILTER (
            WHERE e.id_asistente = j.id_jugador
        ) AS asistencias,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Gol'
              AND e.id_jugador = j.id_jugador
              AND p.instancia != 'Fecha'
        ) AS goles_ko,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Amarilla'
              AND e.id_jugador = j.id_jugador
        ) AS amarillas,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Roja'
              AND e.id_jugador = j.id_jugador
        ) AS rojas

    FROM evento_partido e
    JOIN partido p ON e.id_partido = p.id_partido
    JOIN jugador j
      ON j.id_jugador = e.id_jugador
      OR j.id_jugador = e.id_asistente

    GROUP BY j.id_jugador, p.id_temporada
),

jugador_temporada AS (
    SELECT id_jugador, id_temporada
    FROM participaciones

    UNION

    SELECT id_jugador, id_temporada
    FROM eventos
)

SELECT
    j.id_jugador,
    j.nombre || ' ' || j.apellido AS jugador,
    jt.id_temporada,

    COALESCE(pa.partidos, 0) AS partidos,
    COALESCE(pa.pg, 0) AS pg,
    COALESCE(pa.pe, 0) AS pe,
    COALESCE(pa.pp, 0) AS pp,

    COALESCE(ev.goles, 0) AS goles,
    COALESCE(ev.asistencias, 0) AS asistencias,
    COALESCE(ev.goles_ko, 0) AS goles_ko,
    COALESCE(ev.amarillas, 0) AS amarillas,
    COALESCE(ev.rojas, 0) AS rojas,
    COALESCE(pa.vallas_invictas, 0) AS vallas_invictas

FROM jugador_temporada jt

JOIN jugador j
    ON jt.id_jugador = j.id_jugador

LEFT JOIN participaciones pa
    ON pa.id_jugador = jt.id_jugador
   AND pa.id_temporada = jt.id_temporada

LEFT JOIN eventos ev
    ON ev.id_jugador = jt.id_jugador
   AND ev.id_temporada = jt.id_temporada;