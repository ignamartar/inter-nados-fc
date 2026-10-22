CREATE OR REPLACE VIEW debut_jugadores AS

WITH primeros_partidos AS (

    SELECT
        pp.id_jugador,
        p.id_partido,
        p.id_temporada,
        p.fecha,
        p.id_visitante,
        p.goles_local,
        p.goles_visitante,
        p.estado,
        p.hubo_penales,
        p.penales_local,
        p.penales_visitante,

        ROW_NUMBER() OVER (
            PARTITION BY pp.id_jugador
            ORDER BY p.fecha ASC, p.id_partido ASC
        ) AS orden_debut

    FROM participacion_partido pp

    JOIN partido p
        ON pp.id_partido = p.id_partido

    WHERE p.id_local = 1
),

eventos_debut AS (

    SELECT
        pp.id_jugador,
        pp.id_partido,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Gol'
              AND e.id_jugador = pp.id_jugador
              AND e.es_autogol IS NOT TRUE
        ) AS goles_debut,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Gol'
              AND e.id_asistente = pp.id_jugador
        ) AS asistencias_debut,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Amarilla'
              AND e.id_jugador = pp.id_jugador
        ) AS amarillas_debut,

        COUNT(*) FILTER (
            WHERE e.tipo_evento = 'Roja'
              AND e.id_jugador = pp.id_jugador
        ) AS rojas_debut

    FROM primeros_partidos pp

    LEFT JOIN evento_partido e
        ON e.id_partido = pp.id_partido

    WHERE pp.orden_debut = 1

    GROUP BY
        pp.id_jugador,
        pp.id_partido
)

SELECT
    j.id_jugador,

    j.nombre || ' ' || j.apellido AS jugador,

    pp.fecha AS fecha_debut,

    pp.id_partido AS id_partido_debut,

    pp.id_temporada,

    c.id_club AS id_rival,

    c.nombre AS rival,

    pp.goles_local,

    pp.goles_visitante,

    CASE
        WHEN pp.estado IN (
            'No_presentacion_rival',
            'Alineacion_indebida_rival'
        ) THEN 'Victoria'

        WHEN pp.estado IN (
            'No_presentacion_propia',
            'Alineacion_indebida_propia'
        ) THEN 'Derrota'

        WHEN pp.estado = 'Jugado'
         AND (
             pp.goles_local > pp.goles_visitante
             OR (
                 pp.goles_local = pp.goles_visitante
                 AND pp.hubo_penales = TRUE
                 AND pp.penales_local > pp.penales_visitante
             )
         ) THEN 'Victoria'

        WHEN pp.estado = 'Jugado'
         AND (
             pp.goles_local < pp.goles_visitante
             OR (
                 pp.goles_local = pp.goles_visitante
                 AND pp.hubo_penales = TRUE
                 AND pp.penales_local < pp.penales_visitante
             )
         ) THEN 'Derrota'

        WHEN pp.estado = 'Jugado'
         AND pp.goles_local = pp.goles_visitante
         AND pp.hubo_penales IS NOT TRUE
        THEN 'Empate'

        ELSE 'Sin definir'

    END AS resultado_debut,

    COALESCE(ed.goles_debut, 0) AS goles_debut,

    COALESCE(ed.asistencias_debut, 0) AS asistencias_debut,

    COALESCE(ed.amarillas_debut, 0) AS amarillas_debut,

    COALESCE(ed.rojas_debut, 0) AS rojas_debut

FROM primeros_partidos pp

JOIN jugador j
    ON pp.id_jugador = j.id_jugador

JOIN club c
    ON pp.id_visitante = c.id_club

LEFT JOIN eventos_debut ed
    ON ed.id_jugador = pp.id_jugador
    AND ed.id_partido = pp.id_partido

WHERE pp.orden_debut = 1;