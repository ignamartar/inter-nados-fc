CREATE OR REPLACE VIEW historial_partidos AS

SELECT
    p.id_partido,
    p.fecha,
    p.id_temporada,

    c.id_club AS id_rival,
    c.nombre AS rival,

    p.instancia,
    p.estado,

    p.goles_local AS goles_inter_nados,
    p.goles_visitante AS goles_rival,

    p.hubo_penales,
    p.penales_local AS penales_inter_nados,
    p.penales_visitante AS penales_rival,

    CASE
        WHEN p.estado IN (
            'No_presentacion_rival',
            'Alineacion_indebida_rival'
        ) THEN 'Victoria'

        WHEN p.estado IN (
            'No_presentacion_propia',
            'Alineacion_indebida_propia'
        ) THEN 'Derrota'

        WHEN p.estado = 'Jugado'
         AND (
             p.goles_local > p.goles_visitante
             OR (
                 p.goles_local = p.goles_visitante
                 AND p.hubo_penales = TRUE
                 AND p.penales_local > p.penales_visitante
             )
         ) THEN 'Victoria'

        WHEN p.estado = 'Jugado'
         AND (
             p.goles_local < p.goles_visitante
             OR (
                 p.goles_local = p.goles_visitante
                 AND p.hubo_penales = TRUE
                 AND p.penales_local < p.penales_visitante
             )
         ) THEN 'Derrota'

        WHEN p.estado = 'Jugado'
         AND p.goles_local = p.goles_visitante
         AND p.hubo_penales IS NOT TRUE
        THEN 'Empate'

        ELSE 'Sin definir'
    END AS resultado

FROM partido p

JOIN club c
    ON p.id_visitante = c.id_club

WHERE p.id_local = 1;