CREATE OR REPLACE VIEW palmares_club AS

SELECT
    c.id_campeon,
    c.id_torneo,
    t.nombre AS torneo,
    c.id_temporada,
    temp.anio AS temporada

FROM campeon c

JOIN torneo t
    ON t.id_torneo = c.id_torneo

JOIN temporada temp
    ON temp.id_temporada = c.id_temporada

WHERE c.id_club = 1;