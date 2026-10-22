CREATE OR REPLACE VIEW duplas_goleadoras AS

WITH duplas AS (

    SELECT
        LEAST(id_goleador, id_asistente) AS id_jugador_1,
        GREATEST(id_goleador, id_asistente) AS id_jugador_2,

        SUM(goles_con_asistencia) AS goles_generados,

        SUM(goles_con_asistencia) FILTER (
            WHERE id_goleador < id_asistente
        ) AS goles_j1_asistido_por_j2,

        SUM(goles_con_asistencia) FILTER (
            WHERE id_goleador > id_asistente
        ) AS goles_j2_asistido_por_j1

    FROM duplas_goleador_asistente

    WHERE id_goleador <> id_asistente

    GROUP BY
        LEAST(id_goleador, id_asistente),
        GREATEST(id_goleador, id_asistente)

)

SELECT
    d.id_jugador_1,
    d.id_jugador_2,
    d.goles_generados,

    j1.nombre || ' ' || j1.apellido AS jugador_1,
    j2.nombre || ' ' || j2.apellido AS jugador_2,

    COALESCE(d.goles_j1_asistido_por_j2, 0)
        AS goles_j1_asistido_por_j2,

    COALESCE(d.goles_j2_asistido_por_j1, 0)
        AS goles_j2_asistido_por_j1

FROM duplas d

JOIN jugador j1
    ON j1.id_jugador = d.id_jugador_1

JOIN jugador j2
    ON j2.id_jugador = d.id_jugador_2;