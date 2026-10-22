DROP VIEW IF EXISTS goles_jugador_rival;

CREATE OR REPLACE VIEW goles_jugador_rival AS

WITH partidos_por_rival AS (
    SELECT
        pp.id_jugador,
        p.id_visitante AS id_rival,
        COUNT(DISTINCT p.id_partido) AS partidos_jugados

    FROM participacion_partido pp

    JOIN partido p
        ON pp.id_partido = p.id_partido

    WHERE p.id_local = 1

    GROUP BY
        pp.id_jugador,
        p.id_visitante
),

goles_por_rival AS (
    SELECT
        e.id_jugador,
        p.id_visitante AS id_rival,
        COUNT(*) AS goles

    FROM evento_partido e

    JOIN partido p
        ON e.id_partido = p.id_partido

    WHERE e.tipo_evento = 'Gol'
      AND e.id_jugador IS NOT NULL
      AND p.id_local = 1

    GROUP BY
        e.id_jugador,
        p.id_visitante
)

SELECT
    j.id_jugador,
    j.nombre || ' ' || j.apellido AS jugador,

    c.id_club AS id_rival,
    c.nombre AS rival,

    pr.partidos_jugados,
    COALESCE(gr.goles, 0) AS goles

FROM partidos_por_rival pr

JOIN jugador j
    ON pr.id_jugador = j.id_jugador

JOIN club c
    ON pr.id_rival = c.id_club

LEFT JOIN goles_por_rival gr
    ON pr.id_jugador = gr.id_jugador
   AND pr.id_rival = gr.id_rival

   WHERE gr.goles > 0;