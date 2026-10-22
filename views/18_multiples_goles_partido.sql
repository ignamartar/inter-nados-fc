CREATE OR REPLACE VIEW multiples_goles_partido AS

SELECT
    j.id_jugador,
    j.nombre || ' ' || j.apellido AS jugador,

    hp.id_partido,
    hp.fecha,
    hp.id_temporada,
    hp.id_rival,
    hp.rival,

    COUNT(*) AS goles,

    CASE
        WHEN COUNT(*) = 2 THEN 'Doblete'
        WHEN COUNT(*) = 3 THEN 'Hat-trick'
        WHEN COUNT(*) = 4 THEN 'Póker'
        WHEN COUNT(*) >= 5 THEN '5 o más goles'
    END AS tipo_record

FROM evento_partido e

JOIN jugador j
    ON j.id_jugador = e.id_jugador

JOIN historial_partidos hp
    ON hp.id_partido = e.id_partido

WHERE e.tipo_evento = 'Gol'
  AND e.es_autogol IS NOT TRUE

GROUP BY
    j.id_jugador,
    j.nombre,
    j.apellido,
    hp.id_partido,
    hp.fecha,
    hp.id_temporada,
    hp.id_rival,
    hp.rival

HAVING COUNT(*) >= 2;