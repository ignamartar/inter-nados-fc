CREATE OR REPLACE VIEW rendimiento_arqueros AS

WITH goles_recibidos AS (

    SELECT
        pp.id_jugador,

        COUNT(DISTINCT hp.id_partido) AS partidos_jugados,

        COALESCE(
            SUM(
                CASE
                    WHEN hp.estado = 'Jugado'
                    THEN hp.goles_rival
                    ELSE 0
                END
            ),
            0
        ) AS goles_recibidos

    FROM participacion_partido pp

    JOIN historial_partidos hp
        ON hp.id_partido = pp.id_partido

    GROUP BY pp.id_jugador

)

SELECT
    j.id_jugador,

    j.nombre || ' ' || j.apellido AS arquero,

    ej.partidos,
    ej.pg,
    ej.pe,
    ej.pp,

    COALESCE(gr.goles_recibidos, 0)
        AS goles_recibidos,

    ej.vallas_invictas,

    ROUND(
        ej.vallas_invictas::numeric * 100
        / NULLIF(ej.partidos, 0),
        2
    ) AS porcentaje_vallas_invictas,

    ROUND(
        COALESCE(gr.goles_recibidos, 0)::numeric
        / NULLIF(ej.partidos, 0),
        2
    ) AS promedio_goles_recibidos,

    ROUND(
        ej.pg::numeric * 100
        / NULLIF(ej.partidos, 0),
        2
    ) AS porcentaje_victorias

FROM jugador j

JOIN estadisticas_jugadores ej
    ON ej.id_jugador = j.id_jugador

LEFT JOIN goles_recibidos gr
    ON gr.id_jugador = j.id_jugador

WHERE j.posicion = 'Arquero';