CREATE OR REPLACE VIEW historial_rivales AS

SELECT
    c.id_club AS id_rival,
    c.nombre AS rival,

    -- PARTIDOS JUGADOS
    COUNT(*) AS pj,

    -- PARTIDOS GANADOS
    COUNT(*) FILTER (
        WHERE p.estado IN (
            'No_presentacion_rival',
            'Alineacion_indebida_rival'
        )
        OR (
            p.estado = 'Jugado'
            AND (
                p.goles_local > p.goles_visitante
                OR (
                    p.goles_local = p.goles_visitante
                    AND p.hubo_penales = TRUE
                    AND p.penales_local > p.penales_visitante
                )
            )
        )
    ) AS pg,

    -- PARTIDOS EMPATADOS
    COUNT(*) FILTER (
        WHERE p.estado = 'Jugado'
          AND p.goles_local = p.goles_visitante
          AND p.hubo_penales IS NOT TRUE
    ) AS pe,

    -- PARTIDOS PERDIDOS
    COUNT(*) FILTER (
        WHERE p.estado IN (
            'No_presentacion_propia',
            'Alineacion_indebida_propia'
        )
        OR (
            p.estado = 'Jugado'
            AND (
                p.goles_local < p.goles_visitante
                OR (
                    p.goles_local = p.goles_visitante
                    AND p.hubo_penales = TRUE
                    AND p.penales_local < p.penales_visitante
                )
            )
        )
    ) AS pp,

    -- GOLES A FAVOR
    COALESCE(
        SUM(p.goles_local) FILTER (
            WHERE p.estado = 'Jugado'
        ), 0
    ) AS gf,

    -- GOLES EN CONTRA
    COALESCE(
        SUM(p.goles_visitante) FILTER (
            WHERE p.estado = 'Jugado'
        ), 0
    ) AS gc,

    -- DIFERENCIA DE GOLES
    COALESCE(
        SUM(
            p.goles_local - p.goles_visitante
        ) FILTER (
            WHERE p.estado = 'Jugado'
        ), 0
    ) AS dif

FROM partido p

JOIN club c
    ON c.id_club = p.id_visitante

WHERE p.id_local = 1

GROUP BY
    c.id_club,
    c.nombre;