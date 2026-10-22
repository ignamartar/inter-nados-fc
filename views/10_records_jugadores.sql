CREATE OR REPLACE VIEW records_jugadores AS

WITH estadisticas AS (

    SELECT
        id_jugador,
        jugador,
        'Más partidos disputados' AS record,
        partidos AS cantidad
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Más partidos ganados',
        pg
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Máximo goleador histórico',
        goles
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Más asistencias',
        asistencias
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Más goles KO',
        goles_ko
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Más vallas invictas',
        vallas_invictas
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Más tarjetas amarillas',
        amarillas
    FROM estadisticas_jugadores

    UNION ALL

    SELECT
        id_jugador,
        jugador,
        'Más tarjetas rojas',
        rojas
    FROM estadisticas_jugadores
),

ranking AS (

    SELECT
        id_jugador,
        jugador,
        record,
        cantidad,

        RANK() OVER (
            PARTITION BY record
            ORDER BY cantidad DESC
        ) AS posicion

    FROM estadisticas

)

SELECT
    record,
    id_jugador,
    jugador,
    cantidad

FROM ranking

WHERE posicion = 1
  AND cantidad > 0;