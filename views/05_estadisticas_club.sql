CREATE OR REPLACE VIEW estadisticas_club AS

SELECT
    COALESCE(SUM(pj), 0) AS pj,
    COALESCE(SUM(pg), 0) AS pg,
    COALESCE(SUM(pe), 0) AS pe,
    COALESCE(SUM(pp), 0) AS pp,

    COALESCE(SUM(gf), 0) AS gf,
    COALESCE(SUM(gc), 0) AS gc,

    COALESCE(SUM(dif), 0) AS diferencia_goles,

    ROUND(
        100.0 * COALESCE(SUM(pg), 0)
        / NULLIF(COALESCE(SUM(pj), 0), 0),
        2
    ) AS porcentaje_victorias

FROM historial_rivales;