CREATE OR REPLACE VIEW partidos_penales AS

SELECT
    p.id_partido,
    p.id_temporada,

    c.id_club AS id_rival,
    c.nombre AS rival,

    p.goles_local AS goles_inter_nados,
    p.goles_visitante AS goles_rival,

    p.penales_local AS penales_inter_nados,
    p.penales_visitante AS penales_rival,

    CASE
        WHEN p.penales_local > p.penales_visitante
            THEN 'Victoria'
        WHEN p.penales_local < p.penales_visitante
            THEN 'Derrota'
        ELSE 'Sin definir'
    END AS resultado_penales

FROM partido p

JOIN club c
    ON c.id_club = p.id_visitante

WHERE p.id_local = 1
  AND p.estado = 'Jugado'
  AND p.hubo_penales = TRUE;