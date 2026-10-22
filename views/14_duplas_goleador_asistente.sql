CREATE OR REPLACE VIEW duplas_goleador_asistente AS

SELECT
    g.id_jugador AS id_goleador,
    g.nombre || ' ' || g.apellido AS goleador,

    a.id_jugador AS id_asistente,
    a.nombre || ' ' || a.apellido AS asistente,

    COUNT(*) AS goles_con_asistencia

FROM evento_partido e

JOIN jugador g
    ON g.id_jugador = e.id_jugador

JOIN jugador a
    ON a.id_jugador = e.id_asistente

WHERE e.tipo_evento = 'Gol'
  AND e.es_autogol IS NOT TRUE
  AND e.id_asistente IS NOT NULL

GROUP BY
    g.id_jugador,
    g.nombre,
    g.apellido,
    a.id_jugador,
    a.nombre,
    a.apellido;