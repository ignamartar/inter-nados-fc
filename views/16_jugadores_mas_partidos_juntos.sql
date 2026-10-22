CREATE OR REPLACE VIEW jugadores_mas_partidos_juntos AS

SELECT
    j1.id_jugador AS id_jugador_1,
    j1.nombre || ' ' || j1.apellido AS jugador_1,

    j2.id_jugador AS id_jugador_2,
    j2.nombre || ' ' || j2.apellido AS jugador_2,

    COUNT(DISTINCT p1.id_partido) AS partidos_juntos

FROM participacion_partido p1

JOIN participacion_partido p2
    ON p1.id_partido = p2.id_partido
    AND p1.id_jugador < p2.id_jugador

JOIN jugador j1
    ON j1.id_jugador = p1.id_jugador

JOIN jugador j2
    ON j2.id_jugador = p2.id_jugador

GROUP BY
    j1.id_jugador,
    j1.nombre,
    j1.apellido,
    j2.id_jugador,
    j2.nombre,
    j2.apellido;