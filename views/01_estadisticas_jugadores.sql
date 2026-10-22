CREATE OR REPLACE VIEW estadisticas_jugadores AS

SELECT
    j.id_jugador,
    j.nombre || ' ' || j.apellido AS jugador,

    -- PARTIDOS Y RESULTADOS
    COALESCE(p.partidos, 0) AS partidos,
    COALESCE(p.pg, 0) AS pg,
    COALESCE(p.pe, 0) AS pe,
    COALESCE(p.pp, 0) AS pp,

    -- ESTADISTICAS INDIVIDUALES
    COALESCE(g.goles, 0) AS goles,
    COALESCE(a.asistencias, 0) AS asistencias,
    COALESCE(gk.goles_ko, 0) AS goles_ko,
    COALESCE(am.amarillas, 0) AS amarillas,
    COALESCE(r.rojas, 0) AS rojas,
    COALESCE(v.vallas_invictas, 0) AS vallas_invictas

FROM jugador j

-- PARTIDOS JUGADOS, GANADOS, EMPATADOS Y PERDIDOS
LEFT JOIN (
    SELECT
        pp.id_jugador,

        COUNT(*) AS partidos,

        COUNT(*) FILTER (
            WHERE p.goles_local > p.goles_visitante
               OR (
                   p.goles_local = p.goles_visitante
                   AND p.hubo_penales = TRUE
                   AND p.penales_local > p.penales_visitante
               )
        ) AS pg,

        COUNT(*) FILTER (
            WHERE p.goles_local = p.goles_visitante
              AND p.hubo_penales IS NOT TRUE
        ) AS pe,

        COUNT(*) FILTER (
            WHERE p.goles_local < p.goles_visitante
               OR (
                   p.goles_local = p.goles_visitante
                   AND p.hubo_penales = TRUE
                   AND p.penales_local < p.penales_visitante
               )
        ) AS pp

    FROM participacion_partido pp
    JOIN partido p ON pp.id_partido = p.id_partido
    GROUP BY pp.id_jugador
) p ON j.id_jugador = p.id_jugador

-- GOLES
LEFT JOIN (
    SELECT id_jugador, COUNT(*) AS goles
    FROM evento_partido
    WHERE tipo_evento = 'Gol'
    GROUP BY id_jugador
) g ON j.id_jugador = g.id_jugador

-- ASISTENCIAS
LEFT JOIN (
    SELECT id_asistente, COUNT(*) AS asistencias
    FROM evento_partido
    WHERE id_asistente IS NOT NULL
    GROUP BY id_asistente
) a ON j.id_jugador = a.id_asistente

-- GOLES EN MATA-MATA
LEFT JOIN (
    SELECT e.id_jugador, COUNT(*) AS goles_ko
    FROM evento_partido e
    JOIN partido p ON e.id_partido = p.id_partido
    WHERE e.tipo_evento = 'Gol'
      AND p.instancia != 'Fecha'
    GROUP BY e.id_jugador
) gk ON j.id_jugador = gk.id_jugador

-- TARJETAS AMARILLAS
LEFT JOIN (
    SELECT id_jugador, COUNT(*) AS amarillas
    FROM evento_partido
    WHERE tipo_evento = 'Amarilla'
    GROUP BY id_jugador
) am ON j.id_jugador = am.id_jugador

-- TARJETAS ROJAS
LEFT JOIN (
    SELECT id_jugador, COUNT(*) AS rojas
    FROM evento_partido
    WHERE tipo_evento = 'Roja'
    GROUP BY id_jugador
) r ON j.id_jugador = r.id_jugador

-- VALLAS INVICTAS
LEFT JOIN (
    SELECT
        pp.id_jugador,
        COUNT(*) AS vallas_invictas

    FROM participacion_partido pp
    JOIN partido p ON pp.id_partido = p.id_partido
    JOIN jugador j2 ON pp.id_jugador = j2.id_jugador

    WHERE j2.posicion = 'Arquero'
      AND p.goles_visitante = 0
      AND p.estado = 'Jugado'

    GROUP BY pp.id_jugador
) v ON j.id_jugador = v.id_jugador;