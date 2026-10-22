CREATE OR REPLACE VIEW efectividad_jugadores AS

SELECT
    ej.id_jugador,
    ej.jugador,

    ej.partidos,
    ej.pg,
    ej.pe,
    ej.pp,

    ej.goles,
    ej.asistencias,

    (ej.goles + ej.asistencias)
        AS participaciones_gol,

    ROUND(
        ej.goles::numeric / NULLIF(ej.partidos, 0),
        2
    ) AS goles_por_partido,

    ROUND(
        ej.asistencias::numeric / NULLIF(ej.partidos, 0),
        2
    ) AS asistencias_por_partido,

    ROUND(
        (ej.goles + ej.asistencias)::numeric
        / NULLIF(ej.partidos, 0),
        2
    ) AS participaciones_por_partido,

    ROUND(
        ej.pg::numeric * 100
        / NULLIF(ej.partidos, 0),
        2
    ) AS porcentaje_victorias,

    ROUND(
        (ej.pg + ej.pe)::numeric * 100
        / NULLIF(ej.partidos, 0),
        2
    ) AS porcentaje_invicto

FROM estadisticas_jugadores ej;