CREATE OR REPLACE VIEW estadisticas_club_temporada AS

WITH resumen AS (
    SELECT
        p.id_temporada,

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
        ) AS gc

    FROM partido p

    WHERE p.id_local = 1

    GROUP BY p.id_temporada
)

SELECT
    id_temporada,
    pj,
    pg,
    pe,
    pp,
    gf,
    gc,

    gf - gc AS diferencia_goles,

    ROUND(
        100.0 * pg / NULLIF(pj, 0),
        2
    ) AS porcentaje_victorias

FROM resumen;