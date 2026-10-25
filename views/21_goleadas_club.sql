CREATE OR REPLACE VIEW goleadas_club AS

SELECT
    hp.id_partido,
    hp.fecha,
    hp.id_temporada,

    hp.id_rival,
    hp.rival,

    hp.goles_inter_nados,
    hp.goles_rival,

    (hp.goles_inter_nados - hp.goles_rival)
        AS diferencia_goles,

    ABS(
        hp.goles_inter_nados - hp.goles_rival
    ) AS margen_goles,

    hp.resultado,

    CASE
        WHEN hp.goles_inter_nados > hp.goles_rival
            THEN 'Goleada a favor'

        WHEN hp.goles_inter_nados < hp.goles_rival
            THEN 'Goleada en contra'
    END AS tipo_goleada

FROM historial_partidos hp

WHERE hp.estado = 'Jugado'
  AND ABS(
      hp.goles_inter_nados - hp.goles_rival
  ) >= 3;