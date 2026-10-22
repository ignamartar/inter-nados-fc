CREATE OR REPLACE VIEW palmares_jugadores AS

SELECT
    j.id_jugador,

    j.nombre || ' ' || j.apellido AS jugador,

    COUNT(DISTINCT c.id_campeon) AS titulos

FROM jugador j

JOIN participacion_torneo pt
    ON pt.id_jugador = j.id_jugador

JOIN campeon c
    ON c.id_torneo = pt.id_torneo
    AND c.id_temporada = pt.id_temporada
    AND c.id_club = pt.id_club

WHERE c.id_club = 1

GROUP BY
    j.id_jugador,
    j.nombre,
    j.apellido;