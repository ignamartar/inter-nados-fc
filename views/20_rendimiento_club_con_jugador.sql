CREATE OR REPLACE VIEW rendimiento_club_con_jugador AS

SELECT
    j.id_jugador,
    j.nombre || ' ' || j.apellido AS jugador,

    COUNT(DISTINCT hp.id_partido) AS partidos,

    COUNT(*) FILTER (
        WHERE hp.resultado = 'Victoria'
    ) AS pg,

    COUNT(*) FILTER (
        WHERE hp.resultado = 'Empate'
    ) AS pe,

    COUNT(*) FILTER (
        WHERE hp.resultado = 'Derrota'
    ) AS pp,

    COALESCE(SUM(
        CASE
            WHEN hp.estado = 'Jugado'
            THEN hp.goles_inter_nados
            ELSE 0
        END
    ), 0) AS gf,

    COALESCE(SUM(
        CASE
            WHEN hp.estado = 'Jugado'
            THEN hp.goles_rival
            ELSE 0
        END
    ), 0) AS gc,

    COALESCE(SUM(
        CASE
            WHEN hp.estado = 'Jugado'
            THEN hp.goles_inter_nados - hp.goles_rival
            ELSE 0
        END
    ), 0) AS diferencia_goles,

    ROUND(
        COUNT(*) FILTER (
            WHERE hp.resultado = 'Victoria'
        )::numeric * 100
        / NULLIF(COUNT(DISTINCT hp.id_partido), 0),
        2
    ) AS porcentaje_victorias,

    ROUND(
        COUNT(*) FILTER (
            WHERE hp.resultado IN ('Victoria', 'Empate')
        )::numeric * 100
        / NULLIF(COUNT(DISTINCT hp.id_partido), 0),
        2
    ) AS porcentaje_invicto,

    ROUND(
        COALESCE(SUM(
            CASE
                WHEN hp.estado = 'Jugado'
                THEN hp.goles_inter_nados
                ELSE 0
            END
        ), 0)::numeric
        / NULLIF(COUNT(DISTINCT hp.id_partido), 0),
        2
    ) AS promedio_goles_favor,

    ROUND(
        COALESCE(SUM(
            CASE
                WHEN hp.estado = 'Jugado'
                THEN hp.goles_rival
                ELSE 0
            END
        ), 0)::numeric
        / NULLIF(COUNT(DISTINCT hp.id_partido), 0),
        2
    ) AS promedio_goles_contra

FROM jugador j

JOIN participacion_partido pp
    ON pp.id_jugador = j.id_jugador

JOIN historial_partidos hp
    ON hp.id_partido = pp.id_partido

GROUP BY
    j.id_jugador,
    j.nombre,
    j.apellido;