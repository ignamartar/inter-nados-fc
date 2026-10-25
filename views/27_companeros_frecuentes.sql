CREATE OR REPLACE VIEW companeros_frecuentes AS

WITH parejas AS (

    SELECT
        id_jugador_1 AS id_jugador,
        jugador_1 AS jugador,

        id_jugador_2 AS id_companero,
        jugador_2 AS companero,

        partidos_juntos

    FROM jugadores_mas_partidos_juntos

    UNION ALL

    SELECT
        id_jugador_2 AS id_jugador,
        jugador_2 AS jugador,

        id_jugador_1 AS id_companero,
        jugador_1 AS companero,

        partidos_juntos

    FROM jugadores_mas_partidos_juntos

),

estadisticas AS (

    SELECT
        p.id_jugador,
        p.jugador,

        p.id_companero,
        p.companero,

        ej.partidos AS partidos_jugador,

        p.partidos_juntos,

        ROUND(
            p.partidos_juntos::numeric * 100
            / NULLIF(ej.partidos, 0),
            2
        ) AS porcentaje_partidos_juntos

    FROM parejas p

    JOIN estadisticas_jugadores ej
        ON ej.id_jugador = p.id_jugador

)

SELECT
    id_jugador,
    jugador,

    id_companero,
    companero,

    partidos_jugador,
    partidos_juntos,

    porcentaje_partidos_juntos,

    ROW_NUMBER() OVER (
        PARTITION BY id_jugador
        ORDER BY
            partidos_juntos DESC,
            id_companero ASC
    ) AS ranking_companero

FROM estadisticas;