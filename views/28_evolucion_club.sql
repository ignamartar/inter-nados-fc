CREATE OR REPLACE VIEW evolucion_club AS

WITH partidos_ordenados AS (

    SELECT
        hp.id_partido,
        hp.fecha,
        hp.id_temporada,
        hp.id_rival,
        hp.rival,
        hp.resultado,
        hp.estado,

        CASE
            WHEN hp.estado = 'Jugado'
            THEN hp.goles_inter_nados
            ELSE 0
        END AS gf_partido,

        CASE
            WHEN hp.estado = 'Jugado'
            THEN hp.goles_rival
            ELSE 0
        END AS gc_partido,

        ROW_NUMBER() OVER (
            ORDER BY hp.fecha, hp.id_partido
        ) AS numero_partido

    FROM historial_partidos hp

),

acumulados AS (

    SELECT
        *,

        COUNT(*) OVER (
            ORDER BY numero_partido
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS pj_acumulados,

        SUM(
            CASE WHEN resultado = 'Victoria'
                 THEN 1 ELSE 0 END
        ) OVER (
            ORDER BY numero_partido
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS pg_acumuladas,

        SUM(
            CASE WHEN resultado = 'Empate'
                 THEN 1 ELSE 0 END
        ) OVER (
            ORDER BY numero_partido
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS pe_acumulados,

        SUM(
            CASE WHEN resultado = 'Derrota'
                 THEN 1 ELSE 0 END
        ) OVER (
            ORDER BY numero_partido
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS pp_acumuladas,

        SUM(gf_partido) OVER (
            ORDER BY numero_partido
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS gf_acumulados,

        SUM(gc_partido) OVER (
            ORDER BY numero_partido
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS gc_acumulados

    FROM partidos_ordenados

)

SELECT
    numero_partido,
    id_partido,
    fecha,
    id_temporada,
    id_rival,
    rival,
    resultado,

    pj_acumulados,
    pg_acumuladas,
    pe_acumulados,
    pp_acumuladas,

    gf_acumulados,
    gc_acumulados,

    gf_acumulados - gc_acumulados
        AS diferencia_acumulada,

    ROUND(
        pg_acumuladas::numeric * 100
        / NULLIF(pj_acumulados, 0),
        2
    ) AS porcentaje_victorias,

    (pg_acumuladas * 3 + pe_acumulados)
        AS puntos_acumulados

FROM acumulados;