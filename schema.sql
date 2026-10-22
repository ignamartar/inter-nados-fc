--
-- PostgreSQL database dump
--

\restrict bVhnQ3HafVYVE7nkFBf5u6zXmBXVXApOgvYny6NMvdfLXFA6vFVOa0NWFgI3ybY

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-10-22 12:07:16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 917 (class 1247 OID 24956)
-- Name: estado_partido; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_partido AS ENUM (
    'Jugado',
    'No_presentacion_propia',
    'No_presentacion_rival',
    'Alineacion_indebida_propia',
    'Alineacion_indebida_rival'
);


ALTER TYPE public.estado_partido OWNER TO postgres;

--
-- TOC entry 881 (class 1247 OID 24758)
-- Name: instancia_enum; Type: TYPE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TYPE public.instancia_enum AS ENUM (
    'Fecha',
    'Octavos',
    'Cuartos',
    'Semifinal',
    'Final',
    'Octavos Plata',
    'Cuartos Plata',
    'Semifinal Plata',
    'Final Plata',
    'Octavos Oro',
    'Cuartos Oro',
    'Semifinal Oro',
    'Final Oro'
);


ALTER TYPE public.instancia_enum OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 884 (class 1247 OID 24692)
-- Name: posicion_enum; Type: TYPE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TYPE public.posicion_enum AS ENUM (
    'Delantero',
    'Mediocampista',
    'Defensa',
    'Arquero'
);


ALTER TYPE public.posicion_enum OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 887 (class 1247 OID 24717)
-- Name: resultado_enum; Type: TYPE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TYPE public.resultado_enum AS ENUM (
    'Victoria',
    'Empate',
    'Derrota'
);


ALTER TYPE public.resultado_enum OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 908 (class 1247 OID 24906)
-- Name: tipo_evento; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tipo_evento AS ENUM (
    'Gol',
    'Asistencia',
    'Amarilla',
    'Roja'
);


ALTER TYPE public.tipo_evento OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 24968)
-- Name: campeon; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campeon (
    id_campeon integer NOT NULL,
    id_torneo integer NOT NULL,
    id_temporada integer NOT NULL,
    id_club integer NOT NULL
);


ALTER TABLE public.campeon OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24967)
-- Name: campeon_id_campeon_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.campeon ALTER COLUMN id_campeon ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.campeon_id_campeon_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 24780)
-- Name: club; Type: TABLE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TABLE public.club (
    id_club integer NOT NULL,
    nombre character varying NOT NULL,
    pais character varying NOT NULL
);


ALTER TABLE public.club OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 226 (class 1259 OID 24916)
-- Name: evento_partido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evento_partido (
    id_evento integer NOT NULL,
    id_partido integer NOT NULL,
    id_jugador integer,
    id_asistente integer,
    tipo_evento public.tipo_evento NOT NULL,
    es_autogol boolean DEFAULT false
);


ALTER TABLE public.evento_partido OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24701)
-- Name: jugador; Type: TABLE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TABLE public.jugador (
    nombre character varying NOT NULL,
    apellido character varying NOT NULL,
    posicion public.posicion_enum NOT NULL,
    nacimiento date,
    nacionalidad character varying NOT NULL,
    id_jugador integer NOT NULL
);


ALTER TABLE public.jugador OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 228 (class 1259 OID 24938)
-- Name: participacion_partido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.participacion_partido (
    id_participacion integer NOT NULL,
    id_partido integer NOT NULL,
    id_jugador integer NOT NULL
);


ALTER TABLE public.participacion_partido OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24855)
-- Name: partido; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.partido (
    id_partido integer NOT NULL,
    fecha date NOT NULL,
    id_torneo integer NOT NULL,
    id_temporada integer NOT NULL,
    id_local integer NOT NULL,
    id_visitante integer NOT NULL,
    goles_local integer DEFAULT 0,
    goles_visitante integer DEFAULT 0,
    cancha character varying(100),
    instancia public.instancia_enum NOT NULL,
    estado public.estado_partido NOT NULL,
    hubo_penales boolean DEFAULT false,
    penales_local integer,
    penales_visitante integer,
    ganador_penales integer
);


ALTER TABLE public.partido OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 33342)
-- Name: debut_jugadores; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.debut_jugadores AS
 WITH primeros_partidos AS (
         SELECT pp_1.id_jugador,
            p.id_partido,
            p.id_temporada,
            p.fecha,
            p.id_visitante,
            p.goles_local,
            p.goles_visitante,
            p.estado,
            p.hubo_penales,
            p.penales_local,
            p.penales_visitante,
            row_number() OVER (PARTITION BY pp_1.id_jugador ORDER BY p.fecha, p.id_partido) AS orden_debut
           FROM (public.participacion_partido pp_1
             JOIN public.partido p ON ((pp_1.id_partido = p.id_partido)))
          WHERE (p.id_local = 1)
        ), eventos_debut AS (
         SELECT pp_1.id_jugador,
            pp_1.id_partido,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.id_jugador = pp_1.id_jugador) AND (e.es_autogol IS NOT TRUE))) AS goles_debut,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.id_asistente = pp_1.id_jugador))) AS asistencias_debut,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Amarilla'::public.tipo_evento) AND (e.id_jugador = pp_1.id_jugador))) AS amarillas_debut,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Roja'::public.tipo_evento) AND (e.id_jugador = pp_1.id_jugador))) AS rojas_debut
           FROM (primeros_partidos pp_1
             LEFT JOIN public.evento_partido e ON ((e.id_partido = pp_1.id_partido)))
          WHERE (pp_1.orden_debut = 1)
          GROUP BY pp_1.id_jugador, pp_1.id_partido
        )
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    pp.fecha AS fecha_debut,
    pp.id_partido AS id_partido_debut,
    pp.id_temporada,
    c.id_club AS id_rival,
    c.nombre AS rival,
    pp.goles_local,
    pp.goles_visitante,
        CASE
            WHEN (pp.estado = ANY (ARRAY['No_presentacion_rival'::public.estado_partido, 'Alineacion_indebida_rival'::public.estado_partido])) THEN 'Victoria'::text
            WHEN (pp.estado = ANY (ARRAY['No_presentacion_propia'::public.estado_partido, 'Alineacion_indebida_propia'::public.estado_partido])) THEN 'Derrota'::text
            WHEN ((pp.estado = 'Jugado'::public.estado_partido) AND ((pp.goles_local > pp.goles_visitante) OR ((pp.goles_local = pp.goles_visitante) AND (pp.hubo_penales = true) AND (pp.penales_local > pp.penales_visitante)))) THEN 'Victoria'::text
            WHEN ((pp.estado = 'Jugado'::public.estado_partido) AND ((pp.goles_local < pp.goles_visitante) OR ((pp.goles_local = pp.goles_visitante) AND (pp.hubo_penales = true) AND (pp.penales_local < pp.penales_visitante)))) THEN 'Derrota'::text
            WHEN ((pp.estado = 'Jugado'::public.estado_partido) AND (pp.goles_local = pp.goles_visitante) AND (pp.hubo_penales IS NOT TRUE)) THEN 'Empate'::text
            ELSE 'Sin definir'::text
        END AS resultado_debut,
    COALESCE(ed.goles_debut, (0)::bigint) AS goles_debut,
    COALESCE(ed.asistencias_debut, (0)::bigint) AS asistencias_debut,
    COALESCE(ed.amarillas_debut, (0)::bigint) AS amarillas_debut,
    COALESCE(ed.rojas_debut, (0)::bigint) AS rojas_debut
   FROM (((primeros_partidos pp
     JOIN public.jugador j ON ((pp.id_jugador = j.id_jugador)))
     JOIN public.club c ON ((pp.id_visitante = c.id_club)))
     LEFT JOIN eventos_debut ed ON (((ed.id_jugador = pp.id_jugador) AND (ed.id_partido = pp.id_partido))))
  WHERE (pp.orden_debut = 1);


ALTER VIEW public.debut_jugadores OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 33347)
-- Name: historial_partidos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.historial_partidos AS
 SELECT p.id_partido,
    p.fecha,
    p.id_temporada,
    c.id_club AS id_rival,
    c.nombre AS rival,
    p.instancia,
    p.estado,
    p.goles_local AS goles_inter_nados,
    p.goles_visitante AS goles_rival,
    p.hubo_penales,
    p.penales_local AS penales_inter_nados,
    p.penales_visitante AS penales_rival,
        CASE
            WHEN (p.estado = ANY (ARRAY['No_presentacion_rival'::public.estado_partido, 'Alineacion_indebida_rival'::public.estado_partido])) THEN 'Victoria'::text
            WHEN (p.estado = ANY (ARRAY['No_presentacion_propia'::public.estado_partido, 'Alineacion_indebida_propia'::public.estado_partido])) THEN 'Derrota'::text
            WHEN ((p.estado = 'Jugado'::public.estado_partido) AND ((p.goles_local > p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local > p.penales_visitante)))) THEN 'Victoria'::text
            WHEN ((p.estado = 'Jugado'::public.estado_partido) AND ((p.goles_local < p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local < p.penales_visitante)))) THEN 'Derrota'::text
            WHEN ((p.estado = 'Jugado'::public.estado_partido) AND (p.goles_local = p.goles_visitante) AND (p.hubo_penales IS NOT TRUE)) THEN 'Empate'::text
            ELSE 'Sin definir'::text
        END AS resultado
   FROM (public.partido p
     JOIN public.club c ON ((p.id_visitante = c.id_club)))
  WHERE (p.id_local = 1);


ALTER VIEW public.historial_partidos OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 33357)
-- Name: detalle_partidos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.detalle_partidos AS
 WITH planteles AS (
         SELECT pp.id_partido,
            string_agg((((j.nombre)::text || ' '::text) || (j.apellido)::text), ', '::text ORDER BY j.apellido, j.nombre) AS jugadores
           FROM (public.participacion_partido pp
             JOIN public.jugador j ON ((j.id_jugador = pp.id_jugador)))
          GROUP BY pp.id_partido
        ), eventos AS (
         SELECT e.id_partido,
            string_agg(
                CASE
                    WHEN ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.es_autogol IS TRUE)) THEN 'Gol en contra'::text
                    WHEN (e.tipo_evento = 'Gol'::public.tipo_evento) THEN (COALESCE((((g.nombre)::text || ' '::text) || (g.apellido)::text), 'Goleador no registrado'::text) || COALESCE(((((' (Asist: '::text || (a.nombre)::text) || ' '::text) || (a.apellido)::text) || ')'::text), ''::text))
                    ELSE NULL::text
                END, ', '::text) FILTER (WHERE (e.tipo_evento = 'Gol'::public.tipo_evento)) AS goles,
            string_agg((((g.nombre)::text || ' '::text) || (g.apellido)::text), ', '::text) FILTER (WHERE ((e.tipo_evento = 'Amarilla'::public.tipo_evento) AND (e.id_jugador IS NOT NULL))) AS amarillas,
            string_agg((((g.nombre)::text || ' '::text) || (g.apellido)::text), ', '::text) FILTER (WHERE ((e.tipo_evento = 'Roja'::public.tipo_evento) AND (e.id_jugador IS NOT NULL))) AS rojas
           FROM ((public.evento_partido e
             LEFT JOIN public.jugador g ON ((g.id_jugador = e.id_jugador)))
             LEFT JOIN public.jugador a ON ((a.id_jugador = e.id_asistente)))
          GROUP BY e.id_partido
        )
 SELECT hp.id_partido,
    hp.fecha,
    hp.id_temporada,
    hp.id_rival,
    hp.rival,
    hp.instancia,
    hp.estado,
    hp.resultado,
    hp.goles_inter_nados,
    hp.goles_rival,
    (((hp.goles_inter_nados)::text || ' - '::text) || (hp.goles_rival)::text) AS marcador,
    hp.hubo_penales,
    hp.penales_inter_nados,
    hp.penales_rival,
    COALESCE(pl.jugadores, ''::text) AS jugadores,
    COALESCE(ev.goles, ''::text) AS goles,
    COALESCE(ev.amarillas, ''::text) AS amarillas,
    COALESCE(ev.rojas, ''::text) AS rojas
   FROM ((public.historial_partidos hp
     LEFT JOIN planteles pl ON ((pl.id_partido = hp.id_partido)))
     LEFT JOIN eventos ev ON ((ev.id_partido = hp.id_partido)));


ALTER VIEW public.detalle_partidos OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 33371)
-- Name: duplas_goleador_asistente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.duplas_goleador_asistente AS
 SELECT g.id_jugador AS id_goleador,
    (((g.nombre)::text || ' '::text) || (g.apellido)::text) AS goleador,
    a.id_jugador AS id_asistente,
    (((a.nombre)::text || ' '::text) || (a.apellido)::text) AS asistente,
    count(*) AS goles_con_asistencia
   FROM ((public.evento_partido e
     JOIN public.jugador g ON ((g.id_jugador = e.id_jugador)))
     JOIN public.jugador a ON ((a.id_jugador = e.id_asistente)))
  WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.es_autogol IS NOT TRUE) AND (e.id_asistente IS NOT NULL))
  GROUP BY g.id_jugador, g.nombre, g.apellido, a.id_jugador, a.nombre, a.apellido;


ALTER VIEW public.duplas_goleador_asistente OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 33376)
-- Name: duplas_goleadoras; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.duplas_goleadoras AS
 WITH duplas AS (
         SELECT LEAST(duplas_goleador_asistente.id_goleador, duplas_goleador_asistente.id_asistente) AS id_jugador_1,
            GREATEST(duplas_goleador_asistente.id_goleador, duplas_goleador_asistente.id_asistente) AS id_jugador_2,
            sum(duplas_goleador_asistente.goles_con_asistencia) AS goles_generados,
            sum(duplas_goleador_asistente.goles_con_asistencia) FILTER (WHERE (duplas_goleador_asistente.id_goleador < duplas_goleador_asistente.id_asistente)) AS goles_j1_asistido_por_j2,
            sum(duplas_goleador_asistente.goles_con_asistencia) FILTER (WHERE (duplas_goleador_asistente.id_goleador > duplas_goleador_asistente.id_asistente)) AS goles_j2_asistido_por_j1
           FROM public.duplas_goleador_asistente
          WHERE (duplas_goleador_asistente.id_goleador <> duplas_goleador_asistente.id_asistente)
          GROUP BY LEAST(duplas_goleador_asistente.id_goleador, duplas_goleador_asistente.id_asistente), GREATEST(duplas_goleador_asistente.id_goleador, duplas_goleador_asistente.id_asistente)
        )
 SELECT d.id_jugador_1,
    d.id_jugador_2,
    d.goles_generados,
    (((j1.nombre)::text || ' '::text) || (j1.apellido)::text) AS jugador_1,
    (((j2.nombre)::text || ' '::text) || (j2.apellido)::text) AS jugador_2,
    COALESCE(d.goles_j1_asistido_por_j2, (0)::numeric) AS goles_j1_asistido_por_j2,
    COALESCE(d.goles_j2_asistido_por_j1, (0)::numeric) AS goles_j2_asistido_por_j1
   FROM ((duplas d
     JOIN public.jugador j1 ON ((j1.id_jugador = d.id_jugador_1)))
     JOIN public.jugador j2 ON ((j2.id_jugador = d.id_jugador_2)));


ALTER VIEW public.duplas_goleadoras OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 33296)
-- Name: estadisticas_jugadores; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.estadisticas_jugadores AS
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    COALESCE(p.partidos, (0)::bigint) AS partidos,
    COALESCE(p.pg, (0)::bigint) AS pg,
    COALESCE(p.pe, (0)::bigint) AS pe,
    COALESCE(p.pp, (0)::bigint) AS pp,
    COALESCE(g.goles, (0)::bigint) AS goles,
    COALESCE(a.asistencias, (0)::bigint) AS asistencias,
    COALESCE(gk.goles_ko, (0)::bigint) AS goles_ko,
    COALESCE(am.amarillas, (0)::bigint) AS amarillas,
    COALESCE(r.rojas, (0)::bigint) AS rojas,
    COALESCE(v.vallas_invictas, (0)::bigint) AS vallas_invictas
   FROM (((((((public.jugador j
     LEFT JOIN ( SELECT pp.id_jugador,
            count(*) AS partidos,
            count(*) FILTER (WHERE ((p_1.goles_local > p_1.goles_visitante) OR ((p_1.goles_local = p_1.goles_visitante) AND (p_1.hubo_penales = true) AND (p_1.penales_local > p_1.penales_visitante)))) AS pg,
            count(*) FILTER (WHERE ((p_1.goles_local = p_1.goles_visitante) AND (p_1.hubo_penales IS NOT TRUE))) AS pe,
            count(*) FILTER (WHERE ((p_1.goles_local < p_1.goles_visitante) OR ((p_1.goles_local = p_1.goles_visitante) AND (p_1.hubo_penales = true) AND (p_1.penales_local < p_1.penales_visitante)))) AS pp
           FROM (public.participacion_partido pp
             JOIN public.partido p_1 ON ((pp.id_partido = p_1.id_partido)))
          GROUP BY pp.id_jugador) p ON ((j.id_jugador = p.id_jugador)))
     LEFT JOIN ( SELECT evento_partido.id_jugador,
            count(*) AS goles
           FROM public.evento_partido
          WHERE (evento_partido.tipo_evento = 'Gol'::public.tipo_evento)
          GROUP BY evento_partido.id_jugador) g ON ((j.id_jugador = g.id_jugador)))
     LEFT JOIN ( SELECT evento_partido.id_asistente,
            count(*) AS asistencias
           FROM public.evento_partido
          WHERE (evento_partido.id_asistente IS NOT NULL)
          GROUP BY evento_partido.id_asistente) a ON ((j.id_jugador = a.id_asistente)))
     LEFT JOIN ( SELECT e.id_jugador,
            count(*) AS goles_ko
           FROM (public.evento_partido e
             JOIN public.partido p_1 ON ((e.id_partido = p_1.id_partido)))
          WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (p_1.instancia <> 'Fecha'::public.instancia_enum))
          GROUP BY e.id_jugador) gk ON ((j.id_jugador = gk.id_jugador)))
     LEFT JOIN ( SELECT evento_partido.id_jugador,
            count(*) AS amarillas
           FROM public.evento_partido
          WHERE (evento_partido.tipo_evento = 'Amarilla'::public.tipo_evento)
          GROUP BY evento_partido.id_jugador) am ON ((j.id_jugador = am.id_jugador)))
     LEFT JOIN ( SELECT evento_partido.id_jugador,
            count(*) AS rojas
           FROM public.evento_partido
          WHERE (evento_partido.tipo_evento = 'Roja'::public.tipo_evento)
          GROUP BY evento_partido.id_jugador) r ON ((j.id_jugador = r.id_jugador)))
     LEFT JOIN ( SELECT pp.id_jugador,
            count(*) AS vallas_invictas
           FROM ((public.participacion_partido pp
             JOIN public.partido p_1 ON ((pp.id_partido = p_1.id_partido)))
             JOIN public.jugador j2 ON ((pp.id_jugador = j2.id_jugador)))
          WHERE ((j2.posicion = 'Arquero'::public.posicion_enum) AND (p_1.goles_visitante = 0) AND (p_1.estado = 'Jugado'::public.estado_partido))
          GROUP BY pp.id_jugador) v ON ((j.id_jugador = v.id_jugador)));


ALTER VIEW public.estadisticas_jugadores OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 33398)
-- Name: efectividad_jugadores; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.efectividad_jugadores AS
 SELECT id_jugador,
    jugador,
    partidos,
    pg,
    pe,
    pp,
    goles,
    asistencias,
    (goles + asistencias) AS participaciones_gol,
    round(((goles)::numeric / (NULLIF(partidos, 0))::numeric), 2) AS goles_por_partido,
    round(((asistencias)::numeric / (NULLIF(partidos, 0))::numeric), 2) AS asistencias_por_partido,
    round((((goles + asistencias))::numeric / (NULLIF(partidos, 0))::numeric), 2) AS participaciones_por_partido,
    round((((pg)::numeric * (100)::numeric) / (NULLIF(partidos, 0))::numeric), 2) AS porcentaje_victorias,
    round(((((pg + pe))::numeric * (100)::numeric) / (NULLIF(partidos, 0))::numeric), 2) AS porcentaje_invicto
   FROM public.estadisticas_jugadores ej;


ALTER VIEW public.efectividad_jugadores OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 33308)
-- Name: historial_rivales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.historial_rivales AS
 SELECT c.id_club AS id_rival,
    c.nombre AS rival,
    count(*) AS pj,
    count(*) FILTER (WHERE ((p.estado = ANY (ARRAY['No_presentacion_rival'::public.estado_partido, 'Alineacion_indebida_rival'::public.estado_partido])) OR ((p.estado = 'Jugado'::public.estado_partido) AND ((p.goles_local > p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local > p.penales_visitante)))))) AS pg,
    count(*) FILTER (WHERE ((p.estado = 'Jugado'::public.estado_partido) AND (p.goles_local = p.goles_visitante) AND (p.hubo_penales IS NOT TRUE))) AS pe,
    count(*) FILTER (WHERE ((p.estado = ANY (ARRAY['No_presentacion_propia'::public.estado_partido, 'Alineacion_indebida_propia'::public.estado_partido])) OR ((p.estado = 'Jugado'::public.estado_partido) AND ((p.goles_local < p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local < p.penales_visitante)))))) AS pp,
    COALESCE(sum(p.goles_local) FILTER (WHERE (p.estado = 'Jugado'::public.estado_partido)), (0)::bigint) AS gf,
    COALESCE(sum(p.goles_visitante) FILTER (WHERE (p.estado = 'Jugado'::public.estado_partido)), (0)::bigint) AS gc,
    COALESCE(sum((p.goles_local - p.goles_visitante)) FILTER (WHERE (p.estado = 'Jugado'::public.estado_partido)), (0)::bigint) AS dif
   FROM (public.partido p
     JOIN public.club c ON ((c.id_club = p.id_visitante)))
  WHERE (p.id_local = 1)
  GROUP BY c.id_club, c.nombre;


ALTER VIEW public.historial_rivales OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 33328)
-- Name: estadisticas_club; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.estadisticas_club AS
 SELECT COALESCE(sum(pj), (0)::numeric) AS pj,
    COALESCE(sum(pg), (0)::numeric) AS pg,
    COALESCE(sum(pe), (0)::numeric) AS pe,
    COALESCE(sum(pp), (0)::numeric) AS pp,
    COALESCE(sum(gf), (0)::numeric) AS gf,
    COALESCE(sum(gc), (0)::numeric) AS gc,
    COALESCE(sum(dif), (0)::numeric) AS diferencia_goles,
    round(((100.0 * COALESCE(sum(pg), (0)::numeric)) / NULLIF(COALESCE(sum(pj), (0)::numeric), (0)::numeric)), 2) AS porcentaje_victorias
   FROM public.historial_rivales;


ALTER VIEW public.estadisticas_club OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 33332)
-- Name: estadisticas_club_temporada; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.estadisticas_club_temporada AS
 WITH resumen AS (
         SELECT p.id_temporada,
            count(*) AS pj,
            count(*) FILTER (WHERE ((p.estado = ANY (ARRAY['No_presentacion_rival'::public.estado_partido, 'Alineacion_indebida_rival'::public.estado_partido])) OR ((p.estado = 'Jugado'::public.estado_partido) AND ((p.goles_local > p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local > p.penales_visitante)))))) AS pg,
            count(*) FILTER (WHERE ((p.estado = 'Jugado'::public.estado_partido) AND (p.goles_local = p.goles_visitante) AND (p.hubo_penales IS NOT TRUE))) AS pe,
            count(*) FILTER (WHERE ((p.estado = ANY (ARRAY['No_presentacion_propia'::public.estado_partido, 'Alineacion_indebida_propia'::public.estado_partido])) OR ((p.estado = 'Jugado'::public.estado_partido) AND ((p.goles_local < p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local < p.penales_visitante)))))) AS pp,
            COALESCE(sum(p.goles_local) FILTER (WHERE (p.estado = 'Jugado'::public.estado_partido)), (0)::bigint) AS gf,
            COALESCE(sum(p.goles_visitante) FILTER (WHERE (p.estado = 'Jugado'::public.estado_partido)), (0)::bigint) AS gc
           FROM public.partido p
          WHERE (p.id_local = 1)
          GROUP BY p.id_temporada
        )
 SELECT id_temporada,
    pj,
    pg,
    pe,
    pp,
    gf,
    gc,
    (gf - gc) AS diferencia_goles,
    round(((100.0 * (pg)::numeric) / (NULLIF(pj, 0))::numeric), 2) AS porcentaje_victorias
   FROM resumen;


ALTER VIEW public.estadisticas_club_temporada OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 33303)
-- Name: estadisticas_jugadores_temporada; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.estadisticas_jugadores_temporada AS
 WITH participaciones AS (
         SELECT pp.id_jugador,
            p.id_temporada,
            count(*) AS partidos,
            count(*) FILTER (WHERE ((p.goles_local > p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local > p.penales_visitante)))) AS pg,
            count(*) FILTER (WHERE ((p.goles_local = p.goles_visitante) AND (p.hubo_penales IS NOT TRUE))) AS pe,
            count(*) FILTER (WHERE ((p.goles_local < p.goles_visitante) OR ((p.goles_local = p.goles_visitante) AND (p.hubo_penales = true) AND (p.penales_local < p.penales_visitante)))) AS pp,
            count(*) FILTER (WHERE ((j_1.posicion = 'Arquero'::public.posicion_enum) AND (p.goles_visitante = 0) AND (p.estado = 'Jugado'::public.estado_partido))) AS vallas_invictas
           FROM ((public.participacion_partido pp
             JOIN public.partido p ON ((pp.id_partido = p.id_partido)))
             JOIN public.jugador j_1 ON ((pp.id_jugador = j_1.id_jugador)))
          GROUP BY pp.id_jugador, p.id_temporada
        ), eventos AS (
         SELECT j_1.id_jugador,
            p.id_temporada,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.id_jugador = j_1.id_jugador))) AS goles,
            count(*) FILTER (WHERE (e.id_asistente = j_1.id_jugador)) AS asistencias,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.id_jugador = j_1.id_jugador) AND (p.instancia <> 'Fecha'::public.instancia_enum))) AS goles_ko,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Amarilla'::public.tipo_evento) AND (e.id_jugador = j_1.id_jugador))) AS amarillas,
            count(*) FILTER (WHERE ((e.tipo_evento = 'Roja'::public.tipo_evento) AND (e.id_jugador = j_1.id_jugador))) AS rojas
           FROM ((public.evento_partido e
             JOIN public.partido p ON ((e.id_partido = p.id_partido)))
             JOIN public.jugador j_1 ON (((j_1.id_jugador = e.id_jugador) OR (j_1.id_jugador = e.id_asistente))))
          GROUP BY j_1.id_jugador, p.id_temporada
        ), jugador_temporada AS (
         SELECT participaciones.id_jugador,
            participaciones.id_temporada
           FROM participaciones
        UNION
         SELECT eventos.id_jugador,
            eventos.id_temporada
           FROM eventos
        )
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    jt.id_temporada,
    COALESCE(pa.partidos, (0)::bigint) AS partidos,
    COALESCE(pa.pg, (0)::bigint) AS pg,
    COALESCE(pa.pe, (0)::bigint) AS pe,
    COALESCE(pa.pp, (0)::bigint) AS pp,
    COALESCE(ev.goles, (0)::bigint) AS goles,
    COALESCE(ev.asistencias, (0)::bigint) AS asistencias,
    COALESCE(ev.goles_ko, (0)::bigint) AS goles_ko,
    COALESCE(ev.amarillas, (0)::bigint) AS amarillas,
    COALESCE(ev.rojas, (0)::bigint) AS rojas,
    COALESCE(pa.vallas_invictas, (0)::bigint) AS vallas_invictas
   FROM (((jugador_temporada jt
     JOIN public.jugador j ON ((jt.id_jugador = j.id_jugador)))
     LEFT JOIN participaciones pa ON (((pa.id_jugador = jt.id_jugador) AND (pa.id_temporada = jt.id_temporada))))
     LEFT JOIN eventos ev ON (((ev.id_jugador = jt.id_jugador) AND (ev.id_temporada = jt.id_temporada))));


ALTER VIEW public.estadisticas_jugadores_temporada OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 24915)
-- Name: evento_partido_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.evento_partido ALTER COLUMN id_evento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.evento_partido_id_evento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 236 (class 1259 OID 33323)
-- Name: goles_jugador_rival; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.goles_jugador_rival AS
 WITH partidos_por_rival AS (
         SELECT pp.id_jugador,
            p.id_visitante AS id_rival,
            count(DISTINCT p.id_partido) AS partidos_jugados
           FROM (public.participacion_partido pp
             JOIN public.partido p ON ((pp.id_partido = p.id_partido)))
          WHERE (p.id_local = 1)
          GROUP BY pp.id_jugador, p.id_visitante
        ), goles_por_rival AS (
         SELECT e.id_jugador,
            p.id_visitante AS id_rival,
            count(*) AS goles
           FROM (public.evento_partido e
             JOIN public.partido p ON ((e.id_partido = p.id_partido)))
          WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.id_jugador IS NOT NULL) AND (p.id_local = 1))
          GROUP BY e.id_jugador, p.id_visitante
        )
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    c.id_club AS id_rival,
    c.nombre AS rival,
    pr.partidos_jugados,
    COALESCE(gr.goles, (0)::bigint) AS goles
   FROM (((partidos_por_rival pr
     JOIN public.jugador j ON ((pr.id_jugador = j.id_jugador)))
     JOIN public.club c ON ((pr.id_rival = c.id_club)))
     LEFT JOIN goles_por_rival gr ON (((pr.id_jugador = gr.id_jugador) AND (pr.id_rival = gr.id_rival))))
  WHERE (gr.goles > 0);


ALTER VIEW public.goles_jugador_rival OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 33382)
-- Name: jugadores_mas_partidos_juntos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.jugadores_mas_partidos_juntos AS
 SELECT j1.id_jugador AS id_jugador_1,
    (((j1.nombre)::text || ' '::text) || (j1.apellido)::text) AS jugador_1,
    j2.id_jugador AS id_jugador_2,
    (((j2.nombre)::text || ' '::text) || (j2.apellido)::text) AS jugador_2,
    count(DISTINCT p1.id_partido) AS partidos_juntos
   FROM (((public.participacion_partido p1
     JOIN public.participacion_partido p2 ON (((p1.id_partido = p2.id_partido) AND (p1.id_jugador < p2.id_jugador))))
     JOIN public.jugador j1 ON ((j1.id_jugador = p1.id_jugador)))
     JOIN public.jugador j2 ON ((j2.id_jugador = p2.id_jugador)))
  GROUP BY j1.id_jugador, j1.nombre, j1.apellido, j2.id_jugador, j2.nombre, j2.apellido;


ALTER VIEW public.jugadores_mas_partidos_juntos OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 33393)
-- Name: multiples_goles_partido; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.multiples_goles_partido AS
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    hp.id_partido,
    hp.fecha,
    hp.id_temporada,
    hp.id_rival,
    hp.rival,
    count(*) AS goles,
        CASE
            WHEN (count(*) = 2) THEN 'Doblete'::text
            WHEN (count(*) = 3) THEN 'Hat-trick'::text
            WHEN (count(*) = 4) THEN 'Póker'::text
            WHEN (count(*) >= 5) THEN '5 o más goles'::text
            ELSE NULL::text
        END AS tipo_record
   FROM ((public.evento_partido e
     JOIN public.jugador j ON ((j.id_jugador = e.id_jugador)))
     JOIN public.historial_partidos hp ON ((hp.id_partido = e.id_partido)))
  WHERE ((e.tipo_evento = 'Gol'::public.tipo_evento) AND (e.es_autogol IS NOT TRUE))
  GROUP BY j.id_jugador, j.nombre, j.apellido, hp.id_partido, hp.fecha, hp.id_temporada, hp.id_rival, hp.rival
 HAVING (count(*) >= 2);


ALTER VIEW public.multiples_goles_partido OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24787)
-- Name: temporada; Type: TABLE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TABLE public.temporada (
    id_temporada integer NOT NULL,
    anio integer NOT NULL
);


ALTER TABLE public.temporada OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 220 (class 1259 OID 24790)
-- Name: torneo; Type: TABLE; Schema: public; Owner: Ignacio Martínez Tarigo
--

CREATE TABLE public.torneo (
    id_torneo integer NOT NULL,
    nombre character varying NOT NULL,
    organizador character varying NOT NULL
);


ALTER TABLE public.torneo OWNER TO "Ignacio Martínez Tarigo";

--
-- TOC entry 245 (class 1259 OID 33367)
-- Name: palmares_club; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.palmares_club AS
 SELECT c.id_campeon,
    c.id_torneo,
    t.nombre AS torneo,
    c.id_temporada,
    temp.anio AS temporada
   FROM ((public.campeon c
     JOIN public.torneo t ON ((t.id_torneo = c.id_torneo)))
     JOIN public.temporada temp ON ((temp.id_temporada = c.id_temporada)))
  WHERE (c.id_club = 1);


ALTER VIEW public.palmares_club OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 24989)
-- Name: participacion_torneo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.participacion_torneo (
    id_participacion integer NOT NULL,
    id_torneo integer NOT NULL,
    id_temporada integer NOT NULL,
    id_jugador integer NOT NULL,
    id_club integer NOT NULL
);


ALTER TABLE public.participacion_torneo OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 33362)
-- Name: palmares_jugadores; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.palmares_jugadores AS
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    count(DISTINCT c.id_campeon) AS titulos
   FROM ((public.jugador j
     JOIN public.participacion_torneo pt ON ((pt.id_jugador = j.id_jugador)))
     JOIN public.campeon c ON (((c.id_torneo = pt.id_torneo) AND (c.id_temporada = pt.id_temporada) AND (c.id_club = pt.id_club))))
  WHERE (c.id_club = 1)
  GROUP BY j.id_jugador, j.nombre, j.apellido;


ALTER VIEW public.palmares_jugadores OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24937)
-- Name: participacion_partido_id_participacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.participacion_partido ALTER COLUMN id_participacion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.participacion_partido_id_participacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 24988)
-- Name: participacion_torneo_id_participacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.participacion_torneo ALTER COLUMN id_participacion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.participacion_torneo_id_participacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 24854)
-- Name: partido_id_partido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.partido_id_partido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partido_id_partido_seq OWNER TO postgres;

--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 223
-- Name: partido_id_partido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.partido_id_partido_seq OWNED BY public.partido.id_partido;


--
-- TOC entry 239 (class 1259 OID 33337)
-- Name: partidos_penales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.partidos_penales AS
 SELECT p.id_partido,
    p.id_temporada,
    c.id_club AS id_rival,
    c.nombre AS rival,
    p.goles_local AS goles_inter_nados,
    p.goles_visitante AS goles_rival,
    p.penales_local AS penales_inter_nados,
    p.penales_visitante AS penales_rival,
        CASE
            WHEN (p.penales_local > p.penales_visitante) THEN 'Victoria'::text
            WHEN (p.penales_local < p.penales_visitante) THEN 'Derrota'::text
            ELSE 'Sin definir'::text
        END AS resultado_penales
   FROM (public.partido p
     JOIN public.club c ON ((c.id_club = p.id_visitante)))
  WHERE ((p.id_local = 1) AND (p.estado = 'Jugado'::public.estado_partido) AND (p.hubo_penales = true));


ALTER VIEW public.partidos_penales OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24825)
-- Name: plantel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plantel (
    id_plantel integer NOT NULL,
    id_club integer NOT NULL,
    id_jugador integer NOT NULL,
    id_temporada integer NOT NULL,
    dorsal integer
);


ALTER TABLE public.plantel OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24824)
-- Name: plantel_id_plantel_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.plantel ALTER COLUMN id_plantel ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.plantel_id_plantel_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 249 (class 1259 OID 33388)
-- Name: rachas_club; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.rachas_club AS
 WITH partidos_ordenados AS (
         SELECT historial_partidos.id_partido,
            historial_partidos.fecha,
            historial_partidos.resultado,
            historial_partidos.estado,
            historial_partidos.goles_inter_nados,
            row_number() OVER (ORDER BY historial_partidos.fecha, historial_partidos.id_partido) AS orden
           FROM public.historial_partidos
        ), tipos_racha AS (
         SELECT p.id_partido,
            p.fecha,
            p.resultado,
            p.estado,
            p.goles_inter_nados,
            p.orden,
            r.tipo_racha,
                CASE
                    WHEN (r.tipo_racha = 'Victorias consecutivas'::text) THEN (p.resultado = 'Victoria'::text)
                    WHEN (r.tipo_racha = 'Partidos invictos'::text) THEN (p.resultado = ANY (ARRAY['Victoria'::text, 'Empate'::text]))
                    WHEN (r.tipo_racha = 'Derrotas consecutivas'::text) THEN (p.resultado = 'Derrota'::text)
                    WHEN (r.tipo_racha = 'Partidos marcando goles'::text) THEN ((p.estado = 'Jugado'::public.estado_partido) AND (p.goles_inter_nados > 0))
                    ELSE NULL::boolean
                END AS cumple
           FROM (partidos_ordenados p
             CROSS JOIN ( VALUES ('Victorias consecutivas'::text), ('Partidos invictos'::text), ('Derrotas consecutivas'::text), ('Partidos marcando goles'::text)) r(tipo_racha))
        ), grupos AS (
         SELECT tipos_racha.id_partido,
            tipos_racha.fecha,
            tipos_racha.resultado,
            tipos_racha.estado,
            tipos_racha.goles_inter_nados,
            tipos_racha.orden,
            tipos_racha.tipo_racha,
            tipos_racha.cumple,
            sum(
                CASE
                    WHEN tipos_racha.cumple THEN 0
                    ELSE 1
                END) OVER (PARTITION BY tipos_racha.tipo_racha ORDER BY tipos_racha.orden ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS grupo_racha
           FROM tipos_racha
        )
 SELECT tipo_racha,
    count(*) AS partidos_consecutivos,
    min(fecha) AS fecha_inicio,
    max(fecha) AS fecha_fin,
    (array_agg(id_partido ORDER BY orden))[1] AS id_partido_inicio,
    (array_agg(id_partido ORDER BY orden DESC))[1] AS id_partido_fin,
    bool_or((orden = ( SELECT max(partidos_ordenados.orden) AS max
           FROM partidos_ordenados))) AS racha_vigente
   FROM grupos
  WHERE cumple
  GROUP BY tipo_racha, grupo_racha;


ALTER VIEW public.rachas_club OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 33352)
-- Name: records_jugadores; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.records_jugadores AS
 WITH estadisticas AS (
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más partidos disputados'::text AS record,
            estadisticas_jugadores.partidos AS cantidad
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más partidos ganados'::text,
            estadisticas_jugadores.pg
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Máximo goleador histórico'::text,
            estadisticas_jugadores.goles
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más asistencias'::text,
            estadisticas_jugadores.asistencias
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más goles KO'::text,
            estadisticas_jugadores.goles_ko
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más vallas invictas'::text,
            estadisticas_jugadores.vallas_invictas
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más tarjetas amarillas'::text,
            estadisticas_jugadores.amarillas
           FROM public.estadisticas_jugadores
        UNION ALL
         SELECT estadisticas_jugadores.id_jugador,
            estadisticas_jugadores.jugador,
            'Más tarjetas rojas'::text,
            estadisticas_jugadores.rojas
           FROM public.estadisticas_jugadores
        ), ranking AS (
         SELECT estadisticas.id_jugador,
            estadisticas.jugador,
            estadisticas.record,
            estadisticas.cantidad,
            rank() OVER (PARTITION BY estadisticas.record ORDER BY estadisticas.cantidad DESC) AS posicion
           FROM estadisticas
        )
 SELECT record,
    id_jugador,
    jugador,
    cantidad
   FROM ranking
  WHERE ((posicion = 1) AND (cantidad > 0));


ALTER VIEW public.records_jugadores OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 33402)
-- Name: rendimiento_club_con_jugador; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.rendimiento_club_con_jugador AS
 SELECT j.id_jugador,
    (((j.nombre)::text || ' '::text) || (j.apellido)::text) AS jugador,
    count(DISTINCT hp.id_partido) AS partidos,
    count(*) FILTER (WHERE (hp.resultado = 'Victoria'::text)) AS pg,
    count(*) FILTER (WHERE (hp.resultado = 'Empate'::text)) AS pe,
    count(*) FILTER (WHERE (hp.resultado = 'Derrota'::text)) AS pp,
    COALESCE(sum(
        CASE
            WHEN (hp.estado = 'Jugado'::public.estado_partido) THEN hp.goles_inter_nados
            ELSE 0
        END), (0)::bigint) AS gf,
    COALESCE(sum(
        CASE
            WHEN (hp.estado = 'Jugado'::public.estado_partido) THEN hp.goles_rival
            ELSE 0
        END), (0)::bigint) AS gc,
    COALESCE(sum(
        CASE
            WHEN (hp.estado = 'Jugado'::public.estado_partido) THEN (hp.goles_inter_nados - hp.goles_rival)
            ELSE 0
        END), (0)::bigint) AS diferencia_goles,
    round((((count(*) FILTER (WHERE (hp.resultado = 'Victoria'::text)))::numeric * (100)::numeric) / (NULLIF(count(DISTINCT hp.id_partido), 0))::numeric), 2) AS porcentaje_victorias,
    round((((count(*) FILTER (WHERE (hp.resultado = ANY (ARRAY['Victoria'::text, 'Empate'::text]))))::numeric * (100)::numeric) / (NULLIF(count(DISTINCT hp.id_partido), 0))::numeric), 2) AS porcentaje_invicto,
    round(((COALESCE(sum(
        CASE
            WHEN (hp.estado = 'Jugado'::public.estado_partido) THEN hp.goles_inter_nados
            ELSE 0
        END), (0)::bigint))::numeric / (NULLIF(count(DISTINCT hp.id_partido), 0))::numeric), 2) AS promedio_goles_favor,
    round(((COALESCE(sum(
        CASE
            WHEN (hp.estado = 'Jugado'::public.estado_partido) THEN hp.goles_rival
            ELSE 0
        END), (0)::bigint))::numeric / (NULLIF(count(DISTINCT hp.id_partido), 0))::numeric), 2) AS promedio_goles_contra
   FROM ((public.jugador j
     JOIN public.participacion_partido pp ON ((pp.id_jugador = j.id_jugador)))
     JOIN public.historial_partidos hp ON ((hp.id_partido = pp.id_partido)))
  GROUP BY j.id_jugador, j.nombre, j.apellido;


ALTER VIEW public.rendimiento_club_con_jugador OWNER TO postgres;

--
-- TOC entry 4878 (class 2604 OID 24858)
-- Name: partido id_partido; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido ALTER COLUMN id_partido SET DEFAULT nextval('public.partido_id_partido_seq'::regclass);


--
-- TOC entry 4886 (class 2606 OID 24786)
-- Name: club Club_pkey; Type: CONSTRAINT; Schema: public; Owner: Ignacio Martínez Tarigo
--

ALTER TABLE ONLY public.club
    ADD CONSTRAINT "Club_pkey" PRIMARY KEY (id_club);


--
-- TOC entry 4888 (class 2606 OID 24798)
-- Name: temporada Temporadas_pkey; Type: CONSTRAINT; Schema: public; Owner: Ignacio Martínez Tarigo
--

ALTER TABLE ONLY public.temporada
    ADD CONSTRAINT "Temporadas_pkey" PRIMARY KEY (id_temporada);


--
-- TOC entry 4890 (class 2606 OID 24796)
-- Name: torneo Torneos_pkey; Type: CONSTRAINT; Schema: public; Owner: Ignacio Martínez Tarigo
--

ALTER TABLE ONLY public.torneo
    ADD CONSTRAINT "Torneos_pkey" PRIMARY KEY (id_torneo);


--
-- TOC entry 4904 (class 2606 OID 24972)
-- Name: campeon campeon_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campeon
    ADD CONSTRAINT campeon_pkey PRIMARY KEY (id_campeon);


--
-- TOC entry 4896 (class 2606 OID 24921)
-- Name: evento_partido evento_partido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento_partido
    ADD CONSTRAINT evento_partido_pkey PRIMARY KEY (id_evento);


--
-- TOC entry 4884 (class 2606 OID 24823)
-- Name: jugador jugador_pkey; Type: CONSTRAINT; Schema: public; Owner: Ignacio Martínez Tarigo
--

ALTER TABLE ONLY public.jugador
    ADD CONSTRAINT jugador_pkey PRIMARY KEY (id_jugador);


--
-- TOC entry 4898 (class 2606 OID 24944)
-- Name: participacion_partido participacion_partido_id_partido_id_jugador_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_partido
    ADD CONSTRAINT participacion_partido_id_partido_id_jugador_key UNIQUE (id_partido, id_jugador);


--
-- TOC entry 4900 (class 2606 OID 24942)
-- Name: participacion_partido participacion_partido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_partido
    ADD CONSTRAINT participacion_partido_pkey PRIMARY KEY (id_participacion);


--
-- TOC entry 4906 (class 2606 OID 24993)
-- Name: participacion_torneo participacion_torneo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_torneo
    ADD CONSTRAINT participacion_torneo_pkey PRIMARY KEY (id_participacion);


--
-- TOC entry 4894 (class 2606 OID 24862)
-- Name: partido partido_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido
    ADD CONSTRAINT partido_pkey PRIMARY KEY (id_partido);


--
-- TOC entry 4892 (class 2606 OID 24829)
-- Name: plantel plantel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plantel
    ADD CONSTRAINT plantel_pkey PRIMARY KEY (id_plantel);


--
-- TOC entry 4902 (class 2606 OID 25017)
-- Name: participacion_partido unique_participacion_partido; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_partido
    ADD CONSTRAINT unique_participacion_partido UNIQUE (id_partido, id_jugador);


--
-- TOC entry 4908 (class 2606 OID 25015)
-- Name: participacion_torneo unique_participacion_torneo; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_torneo
    ADD CONSTRAINT unique_participacion_torneo UNIQUE (id_torneo, id_temporada, id_jugador, id_club);


--
-- TOC entry 4922 (class 2606 OID 24983)
-- Name: campeon campeon_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campeon
    ADD CONSTRAINT campeon_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.club(id_club);


--
-- TOC entry 4923 (class 2606 OID 24978)
-- Name: campeon campeon_id_temporada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campeon
    ADD CONSTRAINT campeon_id_temporada_fkey FOREIGN KEY (id_temporada) REFERENCES public.temporada(id_temporada);


--
-- TOC entry 4924 (class 2606 OID 24973)
-- Name: campeon campeon_id_torneo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campeon
    ADD CONSTRAINT campeon_id_torneo_fkey FOREIGN KEY (id_torneo) REFERENCES public.torneo(id_torneo);


--
-- TOC entry 4917 (class 2606 OID 24932)
-- Name: evento_partido evento_partido_id_asistente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento_partido
    ADD CONSTRAINT evento_partido_id_asistente_fkey FOREIGN KEY (id_asistente) REFERENCES public.jugador(id_jugador);


--
-- TOC entry 4918 (class 2606 OID 24927)
-- Name: evento_partido evento_partido_id_jugador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento_partido
    ADD CONSTRAINT evento_partido_id_jugador_fkey FOREIGN KEY (id_jugador) REFERENCES public.jugador(id_jugador);


--
-- TOC entry 4919 (class 2606 OID 24922)
-- Name: evento_partido evento_partido_id_partido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evento_partido
    ADD CONSTRAINT evento_partido_id_partido_fkey FOREIGN KEY (id_partido) REFERENCES public.partido(id_partido);


--
-- TOC entry 4912 (class 2606 OID 25019)
-- Name: partido fk_ganador_penales; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_ganador_penales FOREIGN KEY (ganador_penales) REFERENCES public.club(id_club);


--
-- TOC entry 4913 (class 2606 OID 24873)
-- Name: partido fk_partido_local; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_partido_local FOREIGN KEY (id_local) REFERENCES public.club(id_club);


--
-- TOC entry 4914 (class 2606 OID 24868)
-- Name: partido fk_partido_temporada; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_partido_temporada FOREIGN KEY (id_temporada) REFERENCES public.temporada(id_temporada);


--
-- TOC entry 4915 (class 2606 OID 24863)
-- Name: partido fk_partido_torneo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_partido_torneo FOREIGN KEY (id_torneo) REFERENCES public.torneo(id_torneo);


--
-- TOC entry 4916 (class 2606 OID 24878)
-- Name: partido fk_partido_visitante; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partido
    ADD CONSTRAINT fk_partido_visitante FOREIGN KEY (id_visitante) REFERENCES public.club(id_club);


--
-- TOC entry 4920 (class 2606 OID 24950)
-- Name: participacion_partido participacion_partido_id_jugador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_partido
    ADD CONSTRAINT participacion_partido_id_jugador_fkey FOREIGN KEY (id_jugador) REFERENCES public.jugador(id_jugador);


--
-- TOC entry 4921 (class 2606 OID 24945)
-- Name: participacion_partido participacion_partido_id_partido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_partido
    ADD CONSTRAINT participacion_partido_id_partido_fkey FOREIGN KEY (id_partido) REFERENCES public.partido(id_partido);


--
-- TOC entry 4925 (class 2606 OID 25009)
-- Name: participacion_torneo participacion_torneo_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_torneo
    ADD CONSTRAINT participacion_torneo_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.club(id_club);


--
-- TOC entry 4926 (class 2606 OID 25004)
-- Name: participacion_torneo participacion_torneo_id_jugador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_torneo
    ADD CONSTRAINT participacion_torneo_id_jugador_fkey FOREIGN KEY (id_jugador) REFERENCES public.jugador(id_jugador);


--
-- TOC entry 4927 (class 2606 OID 24999)
-- Name: participacion_torneo participacion_torneo_id_temporada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_torneo
    ADD CONSTRAINT participacion_torneo_id_temporada_fkey FOREIGN KEY (id_temporada) REFERENCES public.temporada(id_temporada);


--
-- TOC entry 4928 (class 2606 OID 24994)
-- Name: participacion_torneo participacion_torneo_id_torneo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participacion_torneo
    ADD CONSTRAINT participacion_torneo_id_torneo_fkey FOREIGN KEY (id_torneo) REFERENCES public.torneo(id_torneo);


--
-- TOC entry 4909 (class 2606 OID 24830)
-- Name: plantel plantel_id_club_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plantel
    ADD CONSTRAINT plantel_id_club_fkey FOREIGN KEY (id_club) REFERENCES public.club(id_club);


--
-- TOC entry 4910 (class 2606 OID 24835)
-- Name: plantel plantel_id_jugador_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plantel
    ADD CONSTRAINT plantel_id_jugador_fkey FOREIGN KEY (id_jugador) REFERENCES public.jugador(id_jugador);


--
-- TOC entry 4911 (class 2606 OID 24840)
-- Name: plantel plantel_id_temporada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plantel
    ADD CONSTRAINT plantel_id_temporada_fkey FOREIGN KEY (id_temporada) REFERENCES public.temporada(id_temporada);


-- Completed on 2026-10-22 12:07:16

--
-- PostgreSQL database dump complete
--

\unrestrict bVhnQ3HafVYVE7nkFBf5u6zXmBXVXApOgvYny6NMvdfLXFA6vFVOa0NWFgI3ybY

