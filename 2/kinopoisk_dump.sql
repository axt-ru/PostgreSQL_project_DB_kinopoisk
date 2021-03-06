--
-- PostgreSQL database dump
--

-- Dumped from database version 12.10 (Ubuntu 12.10-1.pgdg20.04+1)
-- Dumped by pg_dump version 12.10 (Ubuntu 12.10-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: bit; Type: TYPE; Schema: public; Owner: axt
--

CREATE TYPE public."bit" AS ENUM (
    '0',
    '1'
);


ALTER TYPE public."bit" OWNER TO axt;

--
-- Name: gender; Type: TYPE; Schema: public; Owner: axt
--

CREATE TYPE public.gender AS ENUM (
    'm',
    'f',
    'nb',
    'ud'
);


ALTER TYPE public.gender OWNER TO axt;

--
-- Name: rars; Type: TYPE; Schema: public; Owner: axt
--

CREATE TYPE public.rars AS ENUM (
    '0+',
    '6+',
    '12+',
    '16+',
    '18+',
    'NR'
);


ALTER TYPE public.rars OWNER TO axt;

--
-- Name: censored_messages_trigger(); Type: FUNCTION; Schema: public; Owner: axt
--

CREATE FUNCTION public.censored_messages_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE is_found BOOLEAN;
BEGIN
   is_found := EXISTS(SELECT * FROM censored_words WHERE NEW.body_text LIKE '%' || word || '%' );
	IF is_found THEN
     NEW.body_text := 'censored';
	END IF;
	RETURN NEW;
END
$$;


ALTER FUNCTION public.censored_messages_trigger() OWNER TO axt;

--
-- Name: directors_country(character varying); Type: FUNCTION; Schema: public; Owner: axt
--

CREATE FUNCTION public.directors_country(country_name character varying) RETURNS bigint
    LANGUAGE sql
    AS $$
	SELECT 
		COUNT(*)
	  FROM director
	  	 JOIN countries ON countries.id = director.country_id
	  WHERE countries.country = country_name
	  GROUP BY country_id;
$$;


ALTER FUNCTION public.directors_country(country_name character varying) OWNER TO axt;

--
-- Name: filmography(integer); Type: FUNCTION; Schema: public; Owner: axt
--

CREATE FUNCTION public.filmography(countr_id integer) RETURNS bigint
    LANGUAGE sql
    AS $$
	SELECT 
		COUNT(*)
	  FROM director
	  	-- JOIN countries ON countries.id = director.country_id
	  WHERE director.country_id = countr_id
	  GROUP BY country_id
	;
$$;


ALTER FUNCTION public.filmography(countr_id integer) OWNER TO axt;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: censored_words; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.censored_words (
    word character varying(300)
);


ALTER TABLE public.censored_words OWNER TO axt;

--
-- Name: title_info; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.title_info (
    id integer NOT NULL,
    title_id integer,
    title_type_id integer DEFAULT 1,
    poster integer DEFAULT 2,
    tagline character varying(200) DEFAULT ' '::character varying,
    release_date date,
    rars public.rars DEFAULT 'NR'::public.rars,
    synopsis character varying(500) DEFAULT ' '::character varying
);


ALTER TABLE public.title_info OWNER TO axt;

--
-- Name: titles; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.titles (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    original_title character varying(100) DEFAULT ' '::character varying
);


ALTER TABLE public.titles OWNER TO axt;

--
-- Name: cinema_without_synopsis; Type: VIEW; Schema: public; Owner: axt
--

CREATE VIEW public.cinema_without_synopsis AS
 SELECT titles.title AS film_title,
    titles.original_title,
    title_info.release_date
   FROM (public.titles
     LEFT JOIN public.title_info ON ((title_info.title_id = titles.id)))
  WHERE (title_info.synopsis IS NULL);


ALTER TABLE public.cinema_without_synopsis OWNER TO axt;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    company character varying(200) NOT NULL
);


ALTER TABLE public.companies OWNER TO axt;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_id_seq OWNER TO axt;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    country character varying(200) NOT NULL
);


ALTER TABLE public.countries OWNER TO axt;

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.countries_id_seq OWNER TO axt;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: director; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.director (
    id integer NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    date_of_birth date,
    date_of_death date,
    gender character varying(100),
    photo integer,
    country_id integer
);


ALTER TABLE public.director OWNER TO axt;

--
-- Name: director_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.director_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.director_id_seq OWNER TO axt;

--
-- Name: director_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.director_id_seq OWNED BY public.director.id;


--
-- Name: title_types; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.title_types (
    id integer NOT NULL,
    title_type character varying(200) NOT NULL
);


ALTER TABLE public.title_types OWNER TO axt;

--
-- Name: film_for_adult_users; Type: VIEW; Schema: public; Owner: axt
--

CREATE VIEW public.film_for_adult_users AS
 SELECT titles.title,
    title_types.title_type,
    title_info.poster
   FROM ((public.titles
     JOIN public.title_info ON ((title_info.title_id = titles.id)))
     JOIN public.title_types ON ((title_types.id = title_info.title_type_id)))
  WHERE (title_info.rars = '18+'::public.rars)
  ORDER BY title_types.title_type;


ALTER TABLE public.film_for_adult_users OWNER TO axt;

--
-- Name: images; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.images (
    id integer NOT NULL,
    filename character varying(200) NOT NULL,
    path character varying(200) NOT NULL
);


ALTER TABLE public.images OWNER TO axt;

--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_id_seq OWNER TO axt;

--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    from_user integer,
    to_user integer,
    created_at timestamp without time zone DEFAULT now(),
    body_text text NOT NULL
);


ALTER TABLE public.messages OWNER TO axt;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO axt;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: rating; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.rating (
    id integer NOT NULL,
    title_id integer,
    user_id integer,
    rating integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.rating OWNER TO axt;

--
-- Name: rating_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.rating_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rating_id_seq OWNER TO axt;

--
-- Name: rating_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.rating_id_seq OWNED BY public.rating.id;


--
-- Name: title_company; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.title_company (
    id integer NOT NULL,
    title_id integer,
    company_id integer
);


ALTER TABLE public.title_company OWNER TO axt;

--
-- Name: title_company_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.title_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.title_company_id_seq OWNER TO axt;

--
-- Name: title_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.title_company_id_seq OWNED BY public.title_company.id;


--
-- Name: title_country; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.title_country (
    id integer NOT NULL,
    title_id integer,
    country_id integer
);


ALTER TABLE public.title_country OWNER TO axt;

--
-- Name: title_country_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.title_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.title_country_id_seq OWNER TO axt;

--
-- Name: title_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.title_country_id_seq OWNED BY public.title_country.id;


--
-- Name: title_info_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.title_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.title_info_id_seq OWNER TO axt;

--
-- Name: title_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.title_info_id_seq OWNED BY public.title_info.id;


--
-- Name: title_types_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.title_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.title_types_id_seq OWNER TO axt;

--
-- Name: title_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.title_types_id_seq OWNED BY public.title_types.id;


--
-- Name: titles_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.titles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.titles_id_seq OWNER TO axt;

--
-- Name: titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.titles_id_seq OWNED BY public.titles.id;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.user_profiles (
    id integer NOT NULL,
    user_id integer,
    updated_at timestamp without time zone DEFAULT now(),
    avatar integer DEFAULT 1,
    first_name character varying(100) DEFAULT ' '::character varying,
    last_name character varying(100) DEFAULT ' '::character varying,
    gender public.gender DEFAULT 'ud'::public.gender,
    date_of_birth date,
    country_id integer,
    about character varying(350) DEFAULT ' '::character varying,
    is_private integer DEFAULT 0
);


ALTER TABLE public.user_profiles OWNER TO axt;

--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.user_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_profiles_id_seq OWNER TO axt;

--
-- Name: user_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.user_profiles_id_seq OWNED BY public.user_profiles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: axt
--

CREATE TABLE public.users (
    id integer NOT NULL,
    signed_up_at timestamp without time zone DEFAULT now(),
    username character varying(50),
    email character varying(100),
    phone_number bigint,
    password_hash character varying(100)
);


ALTER TABLE public.users OWNER TO axt;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: axt
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO axt;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: axt
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: director id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.director ALTER COLUMN id SET DEFAULT nextval('public.director_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: rating id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.rating ALTER COLUMN id SET DEFAULT nextval('public.rating_id_seq'::regclass);


--
-- Name: title_company id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_company ALTER COLUMN id SET DEFAULT nextval('public.title_company_id_seq'::regclass);


--
-- Name: title_country id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_country ALTER COLUMN id SET DEFAULT nextval('public.title_country_id_seq'::regclass);


--
-- Name: title_info id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_info ALTER COLUMN id SET DEFAULT nextval('public.title_info_id_seq'::regclass);


--
-- Name: title_types id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_types ALTER COLUMN id SET DEFAULT nextval('public.title_types_id_seq'::regclass);


--
-- Name: titles id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.titles ALTER COLUMN id SET DEFAULT nextval('public.titles_id_seq'::regclass);


--
-- Name: user_profiles id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.user_profiles ALTER COLUMN id SET DEFAULT nextval('public.user_profiles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: censored_words; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.censored_words (word) FROM stdin;
????????
test
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.companies (id, company) FROM stdin;
1	Balistreri, Schulist and Denesik
2	Beer-Jast
3	Beier-Zieme
4	Bins, Thiel and Fritsch
5	Crona, Volkman and Cormier
6	Dietrich and Sons
7	Frami-Schumm
8	Huel PLC
9	Jenkins, Pfannerstill and Daniel
10	Kilback, Sanford and Miller
11	Kuhlman, Schumm and Connell
12	Kuphal, Wiegand and Schamberger
13	Lockman, Kessler and Hirthe
14	Lynch Ltd
15	Mayert-Hermiston
16	Mitchell, Howell and Treutel
17	Nitzsche, Labadie and Hayes
18	Kon-Leffler
19	Padberg-Adams
20	Satterfield, Welch and Swift
21	Schiller, McGlynn and Cummerata
22	Schinner-Hilpert
23	Schmeler-Koss
24	Towne and Sons
25	Weimann, Miller and White
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.countries (id, country) FROM stdin;
1	Afghanistan
2	Albania
3	Algeria
4	American Samoa
5	Andorra
6	Angola
7	Anguilla
8	Antarctica (the territory South of 60 deg S)
9	Antigua and Barbuda
10	Argentina
11	Armenia
12	Aruba
13	Australia
14	Austria
15	Azerbaijan
16	Bahamas
17	Bahrain
18	Bangladesh
19	Barbados
20	Belarus
21	Belgium
22	Belize
23	Benin
24	Bermuda
25	Bhutan
26	Bolivia
27	Bosnia and Herzegovina
28	Botswana
29	Bouvet Island (Bouvetoya)
30	Brazil
31	British Indian Ocean Territory (Chagos Archipelago)
32	British Virgin Islands
33	Brunei Darussalam
34	Bulgaria
35	Burkina Faso
36	Burundi
37	Cambodia
38	Cameroon
39	Canada
40	Cape Verde
41	Cayman Islands
42	Central African Republic
43	Chad
44	Chile
45	China
46	Christmas Island
47	Cocos (Keeling) Islands
48	Colombia
49	Comoros
50	Congo
51	Cook Islands
52	Costa Rica
53	Cote d'''Ivoire
54	Croatia
55	Cuba
56	Cyprus
57	Czech Republic
58	Denmark
59	Djibouti
60	Dominica
61	Dominican Republic
62	Ecuador
63	Egypt
64	El Salvador
65	Equatorial Guinea
66	Eritrea
67	Estonia
68	Falkland Islands (Malvinas)
69	Faroe Islands
70	Fiji
71	Finland
72	France
73	French Guiana
74	French Polynesia
75	French Southern Territories
76	Gabon
77	Gambia
78	Georgia
79	Germany
80	Ghana
81	Gibraltar
82	Greece
83	Greenland
84	Grenada
85	Guadeloupe
86	Guam
87	Guatemala
88	Guernsey
89	Guinea
90	Guinea-Bissau
91	Guyana
92	Haiti
93	Heard Island and McDonald Islands
94	Holy See (Vatican City State)
95	Honduras
96	Hong Kong
97	Hungary
98	Iceland
99	India
100	Indonesia
101	Iran
102	Iraq
103	Ireland
104	Isle of Man
105	Israel
106	Italy
107	Jamaica
108	Japan
109	Jersey
110	Jordan
111	Kazakhstan
112	Kenya
113	Kiribati
114	Korea
115	Kuwait
116	Kyrgyz Republic
117	Lao People'''s Democratic Republic
118	Latvia
119	Lebanon
120	Lesotho
121	Liberia
122	Libyan Arab Jamahiriya
123	Liechtenstein
124	Lithuania
125	Luxembourg
126	Macao
127	Macedonia
128	Madagascar
129	Malaysia
130	Maldives
131	Mali
132	Malta
133	Marshall Islands
134	Martinique
135	Mauritania
136	Mauritius
137	Mayotte
138	Mexico
139	Micronesia
140	Moldova
141	Monaco
142	Mongolia
143	Montenegro
144	Montserrat
145	Morocco
146	Mozambique
147	Myanmar
148	Namibia
149	Nauru
150	Nepal
151	Netherlands
152	Netherlands Antilles
153	New Caledonia
154	New Zealand
155	Nicaragua
156	Niger
157	Nigeria
158	Niue
159	Norfolk Island
160	Northern Mariana Islands
161	Norway
162	Oman
163	Pakistan
164	Palau
165	Palestinian Territory
166	Panama
167	Papua New Guinea
168	Paraguay
169	Peru
170	Philippines
171	Pitcairn Islands
172	Poland
173	Portugal
174	Puerto Rico
175	Qatar
176	Reunion
177	Romania
178	Russian Federation
179	Rwanda
180	Saint Barthelemy
181	Saint Helena
182	Saint Kitts and Nevis
183	Saint Lucia
184	Saint Martin
185	Saint Pierre and Miquelon
186	Saint Vincent and the Grenadines
187	Samoa
188	San Marino
189	Sao Tome and Principe
190	Saudi Arabia
191	Senegal
192	Serbia
193	Seychelles
194	Sierra Leone
195	Singapore
196	Slovakia (Slovak Republic)
197	Slovenia
198	Solomon Islands
199	South Africa
200	South Georgia and the South Sandwich Islands
201	Spain
202	Sri Lanka
203	Sudan
204	Suriname
205	Svalbard & Jan Mayen Islands
206	Swaziland
207	Sweden
208	Switzerland
209	Syrian Arab Republic
210	Taiwan
211	Tajikistan
212	Tanzania
213	Thailand
214	Timor-Leste
215	Togo
216	Tokelau
217	Tonga
218	Trinidad and Tobago
219	Tunisia
220	Turkey
221	Turkmenistan
222	Turks and Caicos Islands
223	Tuvalu
224	Uganda
225	Ukraine
226	United Arab Emirates
227	United Kingdom
228	United States Minor Outlying Islands
229	United States of America
230	United States Virgin Islands
231	Uruguay
232	Uzbekistan
233	Vanuatu
234	Venezuela
235	Vietnam
236	Wallis and Futuna
237	Western Sahara
238	Yemen
239	Zambia
240	Zimbabwe
\.


--
-- Data for Name: director; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.director (id, first_name, last_name, date_of_birth, date_of_death, gender, photo, country_id) FROM stdin;
1	Watson	White	1987-06-23	\N	m	93	114
2	Otis	Jacobson	1987-12-14	\N	f	40	114
3	Vilma	McLaughlin	1987-08-23	\N	f	45	114
4	Karley	Moore	1987-06-29	\N	f	66	114
5	Elsie	Corkery	1987-08-16	\N	m	70	114
6	Antwan	Dooley	1987-01-31	\N	f	140	114
7	Elfrieda	Wilkinson	1987-08-21	\N	f	136	114
8	Samir	Heller	1971-08-03	\N	m	24	186
9	Jon	Bartoletti	1987-04-10	\N	f	18	193
10	Xzavier	Altenwerth	1974-02-02	\N	f	75	114
11	Leola	Welch	1987-07-13	\N	f	85	17
12	Jordy	Hoppe	1973-11-27	\N	f	61	4
13	Eve	Prohaska	1987-09-03	\N	m	59	228
14	Joy	Schiller	1976-02-20	\N	f	150	114
15	Alfonzo	Nolan	1987-08-23	\N	m	92	119
16	Greyson	Doyle	1980-06-12	\N	f	85	239
17	Blaze	Kovacek	1976-02-27	\N	f	105	114
18	Ivy	Kulas	1998-04-30	\N	m	47	168
19	Norene	Jast	1987-07-31	\N	m	140	75
20	Marta	Schmeler	1987-11-17	\N	m	49	67
21	Emmie	Greenholt	1972-12-10	\N	m	19	55
22	Deion	Zieme	1987-04-22	\N	m	59	151
23	Annetta	Welch	1980-05-21	\N	m	139	78
24	Austyn	Zboncak	1978-08-12	\N	f	98	114
25	Ned	Gutmann	1986-04-09	\N	f	85	77
26	Grace	Toy	1996-01-19	\N	f	22	26
27	Albina	Corkery	1986-06-13	\N	m	42	34
28	Santiago	Greenfelder	1970-12-07	\N	f	75	69
29	Alfonzo	Blick	1979-02-04	\N	f	70	114
30	Kitty	Emard	1987-07-01	\N	m	85	117
31	Wade	Schaden	1989-12-24	\N	m	90	206
32	Serena	Fadel	1999-08-25	\N	f	94	89
33	Mervin	Emard	1986-06-22	\N	m	83	125
34	Era	Abernathy	1992-01-21	\N	m	117	23
35	Alexandrea	Botsford	1988-07-08	\N	m	36	18
36	Winnifred	Ullrich	1999-01-10	\N	f	65	114
37	Emilie	Corwin	1976-08-11	\N	f	94	114
38	Leilani	Macejkovic	1987-05-25	\N	m	145	114
39	Olga	Jast	1994-06-28	\N	m	41	208
40	Reta	Howell	1986-05-15	\N	m	124	83
41	Nova	Schuster	1986-02-15	\N	m	145	16
42	Mark	Berge	1981-04-04	\N	f	102	15
43	Janick	O Kon	1972-11-15	\N	m	91	114
44	Doug	Nicolas	1987-05-14	\N	f	142	174
45	Ollie	Russel	1987-06-13	\N	m	148	177
46	Junior	Harber	1987-10-31	\N	m	28	31
47	Zane	Huels	1987-04-19	\N	f	74	95
48	Kyler	Bechtelar	1998-04-14	\N	m	143	47
49	Bernie	Runolfsson	1981-02-20	\N	m	148	108
50	Ashton	Nienow	1985-08-31	\N	m	101	229
51	Teresa	Bode	1987-02-24	\N	m	1	61
52	Felicita	Walsh	1978-09-09	\N	m	72	86
53	Felicity	Lynch	1980-02-18	\N	m	137	214
54	Renee	Stamm	1987-04-07	\N	m	35	225
55	Ronaldo	Rippin	1992-10-07	\N	m	95	110
56	Fernando	Bartell	1993-03-30	\N	f	127	206
57	Kelsi	Keeling	1975-04-19	\N	m	129	3
58	Jalen	Rosenbaum	1987-01-21	\N	f	130	64
59	Lela	Dooley	1982-10-22	\N	f	131	32
60	Cierra	O Reilly	1987-07-20	\N	m	91	215
61	Evan	Hauck	1994-02-26	\N	f	133	5
62	Alexandria	Harvey	1970-06-23	\N	m	35	147
63	Montana	Lindgren	1987-12-22	\N	f	43	94
64	Chase	Lockman	1991-06-20	\N	m	49	207
65	Hilton	Weimann	1982-08-25	\N	f	119	45
66	Filiberto	Littel	1987-11-22	\N	m	79	138
67	Karli	Corkery	1980-01-20	\N	m	75	104
68	Darrick	Wyman	1987-09-19	\N	m	114	143
69	Ilene	McDermott	1990-06-20	\N	m	95	65
70	Monica	Deckow	1994-04-19	\N	m	84	116
71	Obie	Mayer	1987-02-28	\N	f	92	213
72	Erna	Parisian	1987-06-28	\N	m	135	215
73	Friedrich	Hahn	1970-11-25	\N	m	34	116
74	Brando	Gorczany	1982-05-23	\N	f	75	84
75	Nickolas	Towne	1974-12-01	\N	m	136	215
76	Deborah	Roob	1986-01-28	\N	f	119	198
77	Newton	Hilll	1987-11-17	\N	m	133	219
78	Adan	Ritchie	1975-06-05	\N	m	140	107
79	Myra	Kunze	1983-09-01	\N	m	113	24
80	Duane	Rolfson	1997-09-10	\N	m	133	81
81	Marion	Blick	1981-03-30	\N	f	147	57
82	Mozell	Emard	1991-10-12	\N	m	82	37
83	Leanne	Hettinger	1987-06-26	\N	f	135	155
84	Sarina	Stracke	1981-01-31	\N	m	138	226
85	Lolita	Glover	1987-06-20	\N	m	150	162
86	Yvonne	Trantow	1998-01-20	\N	m	3	205
87	Eudora	Stehr	1987-04-28	\N	m	119	154
88	Angel	Gerhold	1970-02-25	\N	f	38	51
89	Irving	Schoen	1987-10-14	\N	f	67	45
90	Brooks	Hamill	1982-12-01	\N	f	122	199
91	Gus	Russel	1998-11-26	\N	f	65	162
92	Casimer	Gutmann	1987-04-24	\N	f	107	230
93	Sandrine	Quigley	1994-06-22	\N	m	131	50
94	Peggie	Schinner	1980-11-15	\N	m	134	25
95	Rossie	Sanford	1987-11-08	\N	f	9	70
96	Jace	Kautzer	1987-09-21	\N	f	136	40
97	Sylvester	O Keefe	1987-05-21	\N	m	126	96
98	Tessie	Runolfsdottir	1995-10-20	\N	m	124	60
99	Rosemarie	Gutmann	1970-06-17	\N	f	93	77
100	Ari	Rath	1992-04-06	\N	m	29	68
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.images (id, filename, path) FROM stdin;
1	velit	http://lorempixel.com/1/1/abstract/
2	reprehenderit	http://lorempixel.com/1/1/abstract/
3	quisquam	http://lorempixel.com/1/1/abstract/
4	veritatis	http://lorempixel.com/1/1/abstract/
5	deserunt	http://lorempixel.com/1/1/abstract/
6	qui	http://lorempixel.com/1/1/abstract/
7	aut	http://lorempixel.com/1/1/abstract/
8	et	http://lorempixel.com/1/1/abstract/
9	quo	http://lorempixel.com/1/1/abstract/
10	tenetur	http://lorempixel.com/1/1/abstract/
11	repellendus	http://lorempixel.com/1/1/abstract/
12	deserunt	http://lorempixel.com/1/1/abstract/
13	velit	http://lorempixel.com/1/1/abstract/
14	aut	http://lorempixel.com/1/1/abstract/
15	ipsa	http://lorempixel.com/1/1/abstract/
16	fugiat	http://lorempixel.com/1/1/abstract/
17	suscipit	http://lorempixel.com/1/1/abstract/
18	vero	http://lorempixel.com/1/1/abstract/
19	rerum	http://lorempixel.com/1/1/abstract/
20	iure	http://lorempixel.com/1/1/abstract/
21	unde	http://lorempixel.com/1/1/abstract/
22	nemo	http://lorempixel.com/1/1/abstract/
23	deleniti	http://lorempixel.com/1/1/abstract/
24	qui	http://lorempixel.com/1/1/abstract/
25	molestiae	http://lorempixel.com/1/1/abstract/
26	omnis	http://lorempixel.com/1/1/abstract/
27	est	http://lorempixel.com/1/1/abstract/
28	sint	http://lorempixel.com/1/1/abstract/
29	debitis	http://lorempixel.com/1/1/abstract/
30	sed	http://lorempixel.com/1/1/abstract/
31	ipsa	http://lorempixel.com/1/1/abstract/
32	odit	http://lorempixel.com/1/1/abstract/
33	sit	http://lorempixel.com/1/1/abstract/
34	tenetur	http://lorempixel.com/1/1/abstract/
35	nemo	http://lorempixel.com/1/1/abstract/
36	dolor	http://lorempixel.com/1/1/abstract/
37	unde	http://lorempixel.com/1/1/abstract/
38	amet	http://lorempixel.com/1/1/abstract/
39	eos	http://lorempixel.com/1/1/abstract/
40	minus	http://lorempixel.com/1/1/abstract/
41	optio	http://lorempixel.com/1/1/abstract/
42	perspiciatis	http://lorempixel.com/1/1/abstract/
43	velit	http://lorempixel.com/1/1/abstract/
44	voluptatem	http://lorempixel.com/1/1/abstract/
45	quo	http://lorempixel.com/1/1/abstract/
46	eos	http://lorempixel.com/1/1/abstract/
47	sed	http://lorempixel.com/1/1/abstract/
48	quidem	http://lorempixel.com/1/1/abstract/
49	sint	http://lorempixel.com/1/1/abstract/
50	fugit	http://lorempixel.com/1/1/abstract/
51	accusamus	http://lorempixel.com/1/1/abstract/
52	quisquam	http://lorempixel.com/1/1/abstract/
53	dolorum	http://lorempixel.com/1/1/abstract/
54	tempore	http://lorempixel.com/1/1/abstract/
55	qui	http://lorempixel.com/1/1/abstract/
56	ut	http://lorempixel.com/1/1/abstract/
57	voluptatum	http://lorempixel.com/1/1/abstract/
58	placeat	http://lorempixel.com/1/1/abstract/
59	illo	http://lorempixel.com/1/1/abstract/
60	aspernatur	http://lorempixel.com/1/1/abstract/
61	eum	http://lorempixel.com/1/1/abstract/
62	et	http://lorempixel.com/1/1/abstract/
63	quae	http://lorempixel.com/1/1/abstract/
64	est	http://lorempixel.com/1/1/abstract/
65	labore	http://lorempixel.com/1/1/abstract/
66	consequuntur	http://lorempixel.com/1/1/abstract/
67	recusandae	http://lorempixel.com/1/1/abstract/
68	explicabo	http://lorempixel.com/1/1/abstract/
69	ducimus	http://lorempixel.com/1/1/abstract/
70	voluptatem	http://lorempixel.com/1/1/abstract/
71	laboriosam	http://lorempixel.com/1/1/abstract/
72	numquam	http://lorempixel.com/1/1/abstract/
73	aut	http://lorempixel.com/1/1/abstract/
74	possimus	http://lorempixel.com/1/1/abstract/
75	molestiae	http://lorempixel.com/1/1/abstract/
76	debitis	http://lorempixel.com/1/1/abstract/
77	tempora	http://lorempixel.com/1/1/abstract/
78	quos	http://lorempixel.com/1/1/abstract/
79	voluptate	http://lorempixel.com/1/1/abstract/
80	temporibus	http://lorempixel.com/1/1/abstract/
81	veniam	http://lorempixel.com/1/1/abstract/
82	rerum	http://lorempixel.com/1/1/abstract/
83	quasi	http://lorempixel.com/1/1/abstract/
84	impedit	http://lorempixel.com/1/1/abstract/
85	ipsum	http://lorempixel.com/1/1/abstract/
86	eligendi	http://lorempixel.com/1/1/abstract/
87	consequuntur	http://lorempixel.com/1/1/abstract/
88	nam	http://lorempixel.com/1/1/abstract/
89	animi	http://lorempixel.com/1/1/abstract/
90	et	http://lorempixel.com/1/1/abstract/
91	et	http://lorempixel.com/1/1/abstract/
92	optio	http://lorempixel.com/1/1/abstract/
93	incidunt	http://lorempixel.com/1/1/abstract/
94	quisquam	http://lorempixel.com/1/1/abstract/
95	nobis	http://lorempixel.com/1/1/abstract/
96	tenetur	http://lorempixel.com/1/1/abstract/
97	sint	http://lorempixel.com/1/1/abstract/
98	fugit	http://lorempixel.com/1/1/abstract/
99	nam	http://lorempixel.com/1/1/abstract/
100	qui	http://lorempixel.com/1/1/abstract/
101	amet	http://lorempixel.com/1/1/abstract/
102	autem	http://lorempixel.com/1/1/abstract/
103	voluptate	http://lorempixel.com/1/1/abstract/
104	quaerat	http://lorempixel.com/1/1/abstract/
105	ea	http://lorempixel.com/1/1/abstract/
106	distinctio	http://lorempixel.com/1/1/abstract/
107	quo	http://lorempixel.com/1/1/abstract/
108	laudantium	http://lorempixel.com/1/1/abstract/
109	non	http://lorempixel.com/1/1/abstract/
110	laborum	http://lorempixel.com/1/1/abstract/
111	dicta	http://lorempixel.com/1/1/abstract/
112	incidunt	http://lorempixel.com/1/1/abstract/
113	sint	http://lorempixel.com/1/1/abstract/
114	odio	http://lorempixel.com/1/1/abstract/
115	officiis	http://lorempixel.com/1/1/abstract/
116	consequatur	http://lorempixel.com/1/1/abstract/
117	voluptas	http://lorempixel.com/1/1/abstract/
118	libero	http://lorempixel.com/1/1/abstract/
119	nihil	http://lorempixel.com/1/1/abstract/
120	laboriosam	http://lorempixel.com/1/1/abstract/
121	ut	http://lorempixel.com/1/1/abstract/
122	voluptatibus	http://lorempixel.com/1/1/abstract/
123	consequatur	http://lorempixel.com/1/1/abstract/
124	dolorem	http://lorempixel.com/1/1/abstract/
125	cum	http://lorempixel.com/1/1/abstract/
126	dolore	http://lorempixel.com/1/1/abstract/
127	magnam	http://lorempixel.com/1/1/abstract/
128	est	http://lorempixel.com/1/1/abstract/
129	voluptatem	http://lorempixel.com/1/1/abstract/
130	beatae	http://lorempixel.com/1/1/abstract/
131	est	http://lorempixel.com/1/1/abstract/
132	voluptatem	http://lorempixel.com/1/1/abstract/
133	quia	http://lorempixel.com/1/1/abstract/
134	temporibus	http://lorempixel.com/1/1/abstract/
135	fugit	http://lorempixel.com/1/1/abstract/
136	aut	http://lorempixel.com/1/1/abstract/
137	et	http://lorempixel.com/1/1/abstract/
138	dicta	http://lorempixel.com/1/1/abstract/
139	maiores	http://lorempixel.com/1/1/abstract/
140	neque	http://lorempixel.com/1/1/abstract/
141	ut	http://lorempixel.com/1/1/abstract/
142	ab	http://lorempixel.com/1/1/abstract/
143	esse	http://lorempixel.com/1/1/abstract/
144	eum	http://lorempixel.com/1/1/abstract/
145	voluptates	http://lorempixel.com/1/1/abstract/
146	molestias	http://lorempixel.com/1/1/abstract/
147	in	http://lorempixel.com/1/1/abstract/
148	aut	http://lorempixel.com/1/1/abstract/
149	et	http://lorempixel.com/1/1/abstract/
150	iste	http://lorempixel.com/1/1/abstract/
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.messages (id, from_user, to_user, created_at, body_text) FROM stdin;
1	90	76	2022-04-22 21:38:42.265244	Et esse est qui culpa fugiat. Quis et autem unde ut reprehenderit est delectus. Quae laborum ad iste vel provident animi. Rerum dolores ex aut quis.
2	26	30	2022-04-22 21:38:42.265244	Assumenda occaecati laboriosam non culpa placeat deserunt. Dicta sed aut dolorem est. Laudantium iusto molestias assumenda fugit id iste.
3	100	28	2022-04-22 21:38:42.265244	Corporis qui consequatur quod corporis exercitationem sunt corrupti. Qui assumenda unde quia repudiandae. Voluptate qui alias rerum molestiae fuga sunt quo.
4	42	1	2022-04-22 21:38:42.265244	Reprehenderit nobis molestiae quisquam ad ea. Deleniti ut qui ut occaecati praesentium. Aut enim rerum est sit.
5	3	8	2022-04-22 21:38:42.265244	Sint praesentium eaque sint. Ut enim et consequuntur et veniam aliquam ullam. Amet aut saepe repellendus iure. Velit voluptate labore minima qui aperiam officia. Quo eos aperiam porro ipsa cumque.
6	75	94	2022-04-22 21:38:42.265244	Repellat laboriosam nulla et aut aut in. Eos atque corporis placeat molestiae voluptas. Quia quia temporibus quidem id ab.
7	56	1	2022-04-22 21:38:42.265244	Excepturi expedita numquam harum aut rerum consequatur omnis illo. Et ipsam ullam aut eius. Eaque sequi eligendi consectetur. Autem a facere error nam exercitationem.
8	59	86	2022-04-22 21:38:42.265244	Soluta occaecati aliquam culpa. Sequi alias et repudiandae nam ea ab iure. Libero voluptas veritatis qui debitis eius. Architecto expedita doloremque rerum a qui sequi facere soluta.
9	19	8	2022-04-22 21:38:42.265244	Sint iste optio voluptas sunt. Aut quam ut accusamus similique. Ducimus cumque soluta perspiciatis et qui quia est et. Expedita sed non beatae ex et consectetur corporis.
10	58	68	2022-04-22 21:38:42.265244	Architecto et beatae qui incidunt pariatur reprehenderit repellendus. Reiciendis necessitatibus inventore aspernatur esse. Nobis expedita hic placeat sunt nostrum atque.
11	39	84	2022-04-22 21:38:42.265244	Iure ea consequatur facilis ratione eum sint ex. Neque et deleniti adipisci amet consectetur sed non. Voluptatem et sunt dolore omnis temporibus provident. Voluptatum omnis numquam autem ab eveniet quo.
12	74	88	2022-04-22 21:38:42.265244	Dolores nulla corporis perspiciatis vero autem molestiae illo. Quia voluptatibus ut quia et illo consectetur odit. Eligendi architecto veritatis delectus nulla consequuntur voluptas repellat.
13	60	85	2022-04-22 21:38:42.265244	Dolorem non sed voluptas quod. Voluptas sit eos sunt voluptatem sed animi. Est illo dicta aut quia incidunt.
14	1	76	2022-04-22 21:38:42.265244	Incidunt ut ipsa dicta neque dignissimos qui. Fuga porro modi autem. Expedita quos labore at. Et repellendus consequatur temporibus et et.
15	76	30	2022-04-22 21:38:42.265244	Libero vitae vel dignissimos ut. Unde qui eum vitae praesentium qui. Eum labore similique molestiae natus repellendus dicta excepturi.
16	43	61	2022-04-22 21:38:42.265244	Non adipisci aspernatur laboriosam sit. Nam aut eos nobis. Sed qui ducimus voluptatem perferendis qui.
17	35	91	2022-04-22 21:38:42.265244	Dolor sint nesciunt reiciendis velit. Optio fuga omnis ratione maiores dolor. Excepturi nostrum perferendis numquam nostrum quia ipsa. Cupiditate sed sapiente soluta accusamus dolorem. Vero eum numquam deserunt esse.
18	100	98	2022-04-22 21:38:42.265244	Provident libero cupiditate aliquid temporibus est. Mollitia animi et similique sunt voluptatem. Aut quam doloremque vero aspernatur consectetur placeat. Labore eveniet in omnis quo pariatur ex repellat.
19	41	52	2022-04-22 21:38:42.265244	Voluptatibus facilis et officia exercitationem natus. Sapiente eligendi nemo minima pariatur. Et sed corporis ullam et. Illo fugit illum ea odio sed qui voluptatem eius.
20	48	97	2022-04-22 21:38:42.265244	Et doloremque est nihil. Consequatur numquam laborum rerum illum cumque. Sit in et voluptas aliquam sit reiciendis. Itaque voluptatem dolorum id pariatur ex nam possimus.
21	26	39	2022-04-22 21:38:42.265244	Ut eos nobis quibusdam aut. Vitae libero consequatur officia recusandae quos doloribus. Sed dolores numquam ab quos quasi et. Nam accusamus dolorem non voluptas sunt.
22	100	38	2022-04-22 21:38:42.265244	Ipsa officia itaque sunt perspiciatis voluptatem iste. Sed aut ea rerum. Ab ut ullam voluptas sit nemo. Nemo quia sint eos cupiditate.
23	74	16	2022-04-22 21:38:42.265244	Nihil ut beatae fugiat adipisci a autem est. Eligendi ex libero illo ratione occaecati saepe consequatur. Repudiandae autem sunt assumenda. Alias saepe vitae id doloremque est. Ut vel fugit aut aut.
24	56	75	2022-04-22 21:38:42.265244	Commodi quod id nulla voluptas deserunt. Consequatur id ut impedit expedita accusantium voluptas rerum quaerat. Quae est non eos laudantium quo sed. Omnis eaque est repellat praesentium.
25	22	87	2022-04-22 21:38:42.265244	Qui facilis velit eum. Dolorem qui maxime ea adipisci iusto. Voluptatem quaerat non vel architecto id.
26	68	69	2022-04-22 21:38:42.265244	Molestiae magnam esse praesentium doloribus id harum. Pariatur et delectus a. Sit est sunt officiis aut ipsum doloribus hic. A voluptas ab veniam consequatur qui minima natus. Voluptatem nam harum earum reprehenderit aperiam consequatur nihil nihil.
27	48	15	2022-04-22 21:38:42.265244	Sed culpa et enim. Quisquam molestias in eum id praesentium ut. Culpa neque tempore vero magnam ut.
28	48	93	2022-04-22 21:38:42.265244	Est provident sequi iusto harum sit. Sunt eaque harum recusandae. Quia totam enim omnis minima quis voluptas.
29	93	53	2022-04-22 21:38:42.265244	Voluptates a dolorem sapiente. Placeat nam nihil sit expedita. Cumque explicabo sed sint in repellendus.
30	91	23	2022-04-22 21:38:42.265244	Iure ad omnis doloremque laudantium. Quae laboriosam corporis provident perspiciatis fugiat iure rem. Quis eveniet in sunt qui minima quasi.
31	41	38	2022-04-22 21:38:42.265244	Nam voluptatibus veritatis eligendi voluptatem voluptatum ea. Ut nobis iusto amet velit officiis vel nostrum. Quasi nemo corrupti autem eveniet mollitia qui pariatur. Accusamus consequatur modi iste dolor optio numquam.
32	62	54	2022-04-22 21:38:42.265244	At id laboriosam ad exercitationem at vero explicabo. Repellat et quo odio et deleniti quo quod tempore. Cumque facere quod possimus quam.
33	2	58	2022-04-22 21:38:42.265244	Fuga consequatur et dolor sed et. Eum ut sint voluptate ipsum.
34	80	46	2022-04-22 21:38:42.265244	Nemo qui atque suscipit ut. Fugit in et ut aperiam eos. Dolor aliquam beatae iste mollitia libero. Pariatur provident voluptatibus facere ut sunt.
35	29	48	2022-04-22 21:38:42.265244	Occaecati odit molestiae nisi consequuntur ex explicabo vitae. Illum voluptate nostrum ab quasi dolores minus. Ut quisquam voluptas consequatur doloremque voluptatem nisi. Architecto reiciendis voluptatum voluptatem.
36	75	90	2022-04-22 21:38:42.265244	Eum qui et unde rem et qui. Eos ut illo numquam error est consequuntur. Deserunt facilis aliquid et corrupti et. Numquam deleniti sunt totam mollitia.
37	65	5	2022-04-22 21:38:42.265244	Vel qui est quia nulla pariatur exercitationem. Qui et ad facere eius. Et repudiandae excepturi molestiae.
38	17	44	2022-04-22 21:38:42.265244	Veniam occaecati suscipit qui voluptates. Dolor facere labore aspernatur voluptas facere. Non nostrum optio sed tenetur sequi ipsam quasi sed.
39	3	90	2022-04-22 21:38:42.265244	Quia qui quia esse quo. Enim aut est omnis et voluptas sunt nemo. Veritatis voluptatem asperiores aliquam temporibus. Eius maiores nam laudantium fugit reprehenderit. Tenetur est et delectus suscipit aspernatur.
40	17	61	2022-04-22 21:38:42.265244	Aut quis placeat non iste repellat et. Nam deserunt iure sunt similique suscipit iusto voluptas. Architecto nesciunt consequatur magni porro.
41	69	16	2022-04-22 21:38:42.265244	Et quisquam vitae qui veritatis saepe voluptate recusandae. Porro modi odit consequatur eos et placeat quod. Qui maxime vero culpa ullam laborum dignissimos.
42	45	84	2022-04-22 21:38:42.265244	Id enim eveniet aut qui perspiciatis explicabo ex. Nihil consequatur culpa eos tenetur. Quidem at est ut ipsa harum itaque. Rerum omnis aut placeat.
43	3	33	2022-04-22 21:38:42.265244	Et sint et nihil sunt facere esse nostrum. A velit aut voluptas quis eum maxime deleniti. Aut perferendis omnis qui aliquid cum repellat ratione. Est fugiat totam autem ab est quasi.
44	69	17	2022-04-22 21:38:42.265244	Veniam et qui qui saepe. Assumenda tenetur quam quia et. Nemo dolore autem nihil deserunt omnis voluptas. Repellat est ut in porro voluptas deserunt.
45	75	29	2022-04-22 21:38:42.265244	Est ut et sed in aspernatur optio ea. Magni autem asperiores explicabo deserunt numquam saepe laudantium. Eius sit ducimus minus quod nesciunt eos. Sed necessitatibus et architecto aspernatur architecto suscipit.
46	55	44	2022-04-22 21:38:42.265244	Possimus sint dolores enim. Et laudantium error esse velit dolor. Corrupti itaque rerum dolor et aperiam ratione.
47	49	35	2022-04-22 21:38:42.265244	Non earum ducimus facilis quibusdam nisi. Reiciendis voluptatem minima sed impedit ut est ratione. Nesciunt voluptas impedit ab voluptatum in optio quo.
48	42	83	2022-04-22 21:38:42.265244	Cupiditate laborum esse minima cupiditate molestias. Voluptas distinctio in incidunt hic libero ipsum minus et. Aut dolores voluptas molestiae sed eaque. Excepturi omnis itaque necessitatibus non dolorem sunt adipisci.
49	96	31	2022-04-22 21:38:42.265244	Et quo exercitationem neque ducimus aliquam et. Alias mollitia fugit soluta quia accusamus rem in. Dolor est laudantium non alias voluptate. Officia optio dolor molestiae.
50	21	80	2022-04-22 21:38:42.265244	Dolores sunt a modi sit nostrum. Ut quibusdam enim ut velit quia fugit ea. Nemo est fuga molestias accusamus praesentium. Temporibus assumenda aliquid velit numquam vitae.
51	92	18	2022-04-22 21:38:42.265244	Placeat libero adipisci deleniti impedit eos maxime dolor. Animi quo sint voluptatibus qui magni nam sit. Quia adipisci sapiente et.
52	72	58	2022-04-22 21:38:42.265244	Exercitationem molestias illo quo fugit. Inventore et laboriosam deserunt sint quasi hic. Laboriosam est vero voluptatibus dolor quis enim officiis.
53	86	82	2022-04-22 21:38:42.265244	Maiores eum qui ut at veritatis. Laborum qui magni ut distinctio. Et rerum sequi asperiores aut saepe aut.
54	18	13	2022-04-22 21:38:42.265244	Laborum impedit consequatur sed minus enim veniam nulla. Voluptatem est consequatur autem. Earum excepturi autem blanditiis adipisci ex vitae blanditiis.
56	10	6	2022-04-22 21:38:42.265244	Quisquam quae ullam hic consequatur deleniti aspernatur. Illum consequuntur distinctio corporis totam aperiam. Error est id et quia nihil consequatur et.
57	92	45	2022-04-22 21:38:42.265244	Est sed ab similique minima quo neque illum architecto. Consequuntur aut explicabo illum. Dolorem sint perferendis hic. Aut animi maiores debitis eum delectus necessitatibus possimus.
58	9	69	2022-04-22 21:38:42.265244	Consequatur deserunt dolor a ut sint sint blanditiis et. Repudiandae quia earum voluptatem consequatur. Nisi suscipit esse ipsa repellat.
59	8	25	2022-04-22 21:38:42.265244	Voluptas sed non qui iste eius repellendus. Nulla est et vel odio aliquam corporis rerum ut. Aut cumque aspernatur repellat qui.
60	61	39	2022-04-22 21:38:42.265244	Voluptatem non vitae nostrum placeat laudantium quasi sunt. Debitis illum et aliquam doloremque. Fugit recusandae ratione voluptatibus exercitationem quo.
61	25	20	2022-04-22 21:38:42.265244	Officia impedit ex exercitationem magni occaecati dolor. Veritatis eveniet mollitia dolores rerum quis voluptatem. Deleniti ipsum ut placeat fugit et. Eos quis enim recusandae sit.
62	60	68	2022-04-22 21:38:42.265244	Quod vel expedita suscipit quia voluptatem voluptatibus. Vel eum vero odio consectetur quas nihil ad illum. Vitae esse velit recusandae vitae voluptas voluptate. Suscipit nulla ut itaque veritatis.
63	51	87	2022-04-22 21:38:42.265244	Illum quas est eum qui. Error odit enim modi id. Perspiciatis sint dolorem sapiente.
64	33	67	2022-04-22 21:38:42.265244	Magni ratione nihil velit. Quod qui quia et consequatur voluptatibus incidunt.
65	91	15	2022-04-22 21:38:42.265244	Fugit explicabo voluptatem mollitia. Aut perferendis sequi iusto repudiandae eos aliquid et. Quis consequatur cupiditate similique ullam esse magni iure. Reiciendis cumque fugit tempora harum sed ea quo corporis.
66	97	86	2022-04-22 21:38:42.265244	Quam in nostrum necessitatibus quia. Quod atque et a et. Sed facere sequi quia et quod magnam rerum. Nulla dicta nihil et ea.
67	49	97	2022-04-22 21:38:42.265244	Officia autem nostrum ut tenetur ut excepturi dolorum officia. Consequatur molestias non voluptas corporis. Ea aperiam itaque quis alias non.
68	97	68	2022-04-22 21:38:42.265244	Architecto exercitationem similique consequuntur molestiae dolorem asperiores. Aut sunt excepturi qui eveniet repudiandae voluptas. Aliquid magni maiores dolorum omnis. Quia eius aut ipsam inventore et voluptatem.
69	40	86	2022-04-22 21:38:42.265244	Autem quasi eos quae quia excepturi consequuntur corrupti tempora. Id dolores voluptate non est. Libero reiciendis dolores autem corrupti qui rerum. Amet modi voluptatem dignissimos sint dolorum asperiores adipisci nam.
70	15	43	2022-04-22 21:38:42.265244	Enim facere esse repudiandae. Minus sequi eius est quidem. Eligendi error alias praesentium culpa libero rerum.
71	72	17	2022-04-22 21:38:42.265244	Quidem est vel distinctio exercitationem libero. Soluta in quisquam dolor. Nihil quo accusamus sapiente reprehenderit ullam. Doloremque modi incidunt aut perspiciatis.
72	69	29	2022-04-22 21:38:42.265244	Consequuntur temporibus sequi ea corrupti. Et enim perspiciatis ut delectus ipsam. Id occaecati sed ipsam aliquam non ab tenetur.
73	20	59	2022-04-22 21:38:42.265244	Et praesentium adipisci dolorem eos quis et. Fuga et molestiae perferendis consequuntur. Totam maiores quia laudantium officia. Iure amet maxime consectetur ad.
74	29	28	2022-04-22 21:38:42.265244	Sunt suscipit rerum nisi ducimus. Sunt saepe consequuntur laboriosam provident sunt et. Et nisi eos autem voluptatem ipsa sunt praesentium. Eum earum ex quas amet vel voluptatibus.
75	57	41	2022-04-22 21:38:42.265244	Quo velit ut eveniet incidunt autem vitae omnis. Eius incidunt iste omnis omnis ducimus explicabo laboriosam officia. Porro placeat vero illum ipsum quae. Sunt corporis voluptatem soluta id voluptatem quisquam. Asperiores porro esse itaque vero.
55	2	58	2022-04-22 21:38:42.265244	censored
76	56	3	2022-04-22 21:38:42.265244	Nihil perspiciatis consequatur laudantium molestiae quia asperiores doloremque. Asperiores facilis voluptatibus aut eos. Voluptates sequi sequi neque.
77	5	70	2022-04-22 21:38:42.265244	Inventore quasi voluptatum qui voluptas. Eius et labore qui inventore voluptas tempora. Dolorum aperiam id libero deleniti quod at voluptatem sit.
78	87	5	2022-04-22 21:38:42.265244	Modi eveniet iusto aspernatur non. Necessitatibus et perferendis sit quas dolores dignissimos. Ab ut quia officiis non blanditiis quo inventore.
79	25	63	2022-04-22 21:38:42.265244	Ut rerum voluptatem et eos recusandae harum et. Nostrum suscipit quos vitae nihil. Molestiae ad corrupti pariatur sit.
80	28	6	2022-04-22 21:38:42.265244	Pariatur expedita pariatur aut. Recusandae beatae consequatur ut eos laborum accusantium sapiente dolores. Corrupti molestiae et sed perferendis.
81	70	31	2022-04-22 21:38:42.265244	Sit provident amet corporis est et. Consectetur magnam rerum nulla voluptas qui. Ullam sed sunt aut dolorem.
82	18	4	2022-04-22 21:38:42.265244	Fuga alias ullam nam doloribus facilis voluptas omnis. Hic rem perferendis accusantium. Vitae iste sit eum sed aspernatur sint nihil a. Ipsam culpa at et voluptatibus vero.
83	94	16	2022-04-22 21:38:42.265244	Laudantium reprehenderit odio minus tenetur occaecati velit amet. Et molestiae ea qui necessitatibus. Dolorem ut molestiae temporibus. Ad porro dolorem praesentium quas. Et omnis ut rerum qui delectus ut commodi velit.
84	70	28	2022-04-22 21:38:42.265244	Quia ipsam repellendus libero saepe. Delectus corporis eum voluptatem animi nemo. Fugiat dolore et est molestiae repellat cupiditate eius.
85	49	66	2022-04-22 21:38:42.265244	Quia quos qui libero minus impedit ea. Dignissimos accusantium dolorum dolorum sunt sit illo aut.
86	82	47	2022-04-22 21:38:42.265244	Voluptas id neque quibusdam quidem alias aliquid molestiae nisi. Dicta id omnis hic voluptas sunt.
87	50	1	2022-04-22 21:38:42.265244	Ducimus totam recusandae et nihil sunt aut sit. Officiis nobis molestiae assumenda aut rerum explicabo aspernatur cum. Nemo quia quidem qui dolorum eveniet consectetur. Necessitatibus velit et quisquam delectus consequatur.
88	31	38	2022-04-22 21:38:42.265244	Sed quia sed ut sit maxime. Exercitationem sunt quos sit consequatur distinctio. Corrupti dolorem sed ut quia maiores voluptate ab ex. Quis est velit autem suscipit voluptatem.
89	95	28	2022-04-22 21:38:42.265244	Sint nihil dolores exercitationem temporibus dignissimos. Ducimus facere ut voluptatem aliquid. Error nihil sunt laborum provident sit minus voluptate. Porro rerum ipsa animi laborum veritatis sunt non ut. Cupiditate iusto cupiditate voluptatem reiciendis.
90	10	47	2022-04-22 21:38:42.265244	Velit consequatur cumque perspiciatis minus occaecati eaque et. Recusandae magnam culpa quaerat et mollitia similique distinctio. Quod in ut dolor ipsam asperiores labore nemo.
91	52	82	2022-04-22 21:38:42.265244	Minima molestiae et nihil labore porro. Numquam fugiat excepturi iusto ea. Quos non officiis et rerum nam commodi.
92	29	72	2022-04-22 21:38:42.265244	Dolores reprehenderit est fugiat nam consequuntur ut. Est saepe aut quam cupiditate odio. Omnis dolor et dolores nulla quisquam quia. Et perferendis quae quod et dicta.
93	50	20	2022-04-22 21:38:42.265244	Veniam deleniti dolores atque id. Nihil totam dolor inventore sapiente. Harum dolor consequatur nisi dolores asperiores ut harum. Nobis molestiae quaerat voluptas est.
94	74	44	2022-04-22 21:38:42.265244	Optio dignissimos aliquid accusamus qui modi. Voluptatibus non id magnam qui minus quisquam. Doloribus nulla doloribus qui omnis enim. Itaque minima qui modi ut ullam autem dolorem.
95	52	19	2022-04-22 21:38:42.265244	Aliquid delectus amet aut enim fuga totam. Qui et eum libero est distinctio tempora. Voluptas dolores voluptates tempora vel ea. Ut numquam officiis in autem et esse.
96	15	25	2022-04-22 21:38:42.265244	Ducimus quisquam nesciunt itaque cupiditate beatae magni ut. Omnis quia et ut sequi molestiae possimus.
97	13	69	2022-04-22 21:38:42.265244	Animi id doloremque corrupti nesciunt omnis culpa perferendis. Animi aliquid ut id nisi. Delectus iusto eos tenetur consequatur illum pariatur. Dolore odit et aperiam provident eveniet temporibus.
98	54	49	2022-04-22 21:38:42.265244	Quae id quas ad quibusdam adipisci voluptatem. Ullam soluta vel similique ut autem officia fugiat. Ex quod molestiae eaque repudiandae. Quaerat alias sit repudiandae mollitia.
99	60	51	2022-04-22 21:38:42.265244	Impedit tempora dolores maxime molestias. Blanditiis laudantium quia qui iste non ut. Non quas aperiam numquam autem totam et ut. Magni vero ducimus qui vitae voluptatem illum.
100	45	29	2022-04-22 21:38:42.265244	Repellat eum placeat et quam. Quod at nostrum omnis molestiae eum quasi voluptas minima. Perspiciatis magni dolore cum veniam molestiae illum atque.
\.


--
-- Data for Name: rating; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.rating (id, title_id, user_id, rating, created_at, updated_at) FROM stdin;
1	5	16	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
2	15	58	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
3	23	95	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
4	33	41	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
5	100	75	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
6	64	14	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
7	95	41	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
8	6	36	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
9	13	40	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
10	4	93	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
11	77	52	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
12	27	38	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
13	87	18	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
14	13	22	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
15	6	17	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
16	27	29	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
17	39	19	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
18	43	19	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
19	66	23	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
20	2	2	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
21	41	92	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
22	51	82	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
23	63	7	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
24	45	14	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
25	29	95	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
26	93	100	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
27	56	51	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
28	7	26	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
29	55	72	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
30	67	94	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
31	57	7	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
32	94	5	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
33	37	58	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
34	66	84	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
35	6	59	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
36	64	16	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
37	75	54	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
38	65	67	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
39	97	98	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
40	19	64	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
41	64	53	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
42	39	1	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
43	21	65	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
44	33	76	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
45	29	24	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
46	60	26	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
47	55	74	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
48	77	100	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
49	83	21	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
50	18	50	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
51	97	90	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
52	94	53	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
53	80	41	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
54	61	47	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
55	74	86	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
56	53	46	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
57	5	1	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
58	65	45	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
59	11	53	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
60	79	41	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
61	75	23	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
62	13	75	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
63	6	12	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
64	84	38	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
65	65	86	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
66	85	53	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
67	85	58	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
68	37	77	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
69	86	78	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
70	85	49	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
71	83	98	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
72	99	77	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
73	19	38	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
74	26	39	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
75	15	76	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
76	39	67	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
77	27	25	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
78	4	96	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
79	55	57	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
80	90	36	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
81	80	27	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
82	18	31	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
83	45	2	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
84	30	22	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
85	52	53	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
86	9	21	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
87	48	11	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
88	62	60	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
89	95	61	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
90	75	80	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
91	55	1	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
92	38	97	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
93	98	21	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
94	56	25	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
95	95	30	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
96	3	44	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
97	22	16	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
98	66	70	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
99	74	49	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
100	29	92	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
101	91	97	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
102	55	10	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
103	1	66	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
104	43	2	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
105	87	39	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
106	8	78	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
107	93	92	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
108	91	61	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
109	76	34	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
110	90	15	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
111	87	43	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
112	89	32	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
113	76	20	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
114	51	2	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
115	15	34	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
116	92	23	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
117	49	62	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
118	75	85	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
119	42	5	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
120	8	2	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
121	71	98	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
122	76	11	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
123	56	78	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
124	15	57	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
125	99	68	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
126	15	46	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
127	10	20	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
128	8	95	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
129	99	94	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
130	32	84	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
131	83	81	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
132	8	65	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
133	8	39	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
134	89	89	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
135	21	32	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
136	88	85	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
137	4	14	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
138	26	6	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
139	77	26	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
140	36	82	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
141	18	9	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
142	25	92	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
143	31	55	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
144	7	82	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
145	62	50	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
146	43	50	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
147	30	64	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
148	25	45	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
149	53	72	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
150	39	94	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
151	21	99	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
152	47	2	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
153	9	88	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
154	14	30	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
155	67	53	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
156	44	29	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
157	41	83	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
158	70	36	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
159	36	34	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
160	72	62	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
161	89	20	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
162	29	55	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
163	100	25	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
164	91	95	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
165	88	61	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
166	98	11	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
167	72	36	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
168	7	88	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
169	11	94	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
170	90	89	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
171	87	44	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
172	14	12	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
173	35	90	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
174	69	36	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
175	55	26	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
176	80	73	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
177	74	82	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
178	56	3	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
179	18	47	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
180	35	81	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
181	14	20	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
182	74	79	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
183	16	19	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
184	16	30	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
185	38	96	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
186	20	26	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
187	56	26	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
188	9	64	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
189	83	43	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
190	73	73	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
191	37	9	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
192	51	87	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
193	92	83	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
194	30	60	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
195	51	54	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
196	59	13	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
197	93	82	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
198	59	5	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
199	38	46	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
200	53	44	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
201	29	80	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
202	71	59	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
203	14	99	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
204	87	49	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
205	7	67	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
206	91	39	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
207	27	16	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
208	78	85	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
209	59	21	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
210	64	36	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
211	73	39	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
212	7	86	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
213	98	97	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
214	41	46	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
215	68	83	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
216	89	51	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
217	69	6	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
218	57	44	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
219	12	81	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
220	56	80	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
221	80	14	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
222	22	96	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
223	16	51	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
224	2	93	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
225	13	39	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
226	47	32	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
227	14	72	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
228	52	7	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
229	32	68	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
230	3	26	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
231	70	12	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
232	26	26	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
233	23	39	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
234	100	46	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
235	20	54	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
236	89	48	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
237	68	45	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
238	95	8	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
239	41	59	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
240	25	16	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
241	14	57	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
242	24	66	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
243	11	19	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
244	37	43	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
245	67	23	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
246	70	8	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
247	10	86	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
248	85	44	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
249	40	17	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
250	26	88	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
251	19	100	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
252	71	59	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
253	40	19	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
254	49	72	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
255	22	85	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
256	44	26	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
257	59	90	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
258	20	77	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
259	70	79	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
260	60	82	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
261	47	80	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
262	6	41	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
263	70	62	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
264	10	55	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
265	38	37	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
266	8	2	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
267	44	87	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
268	26	11	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
269	68	12	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
270	75	41	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
271	84	13	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
272	69	23	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
273	86	78	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
274	98	87	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
275	78	9	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
276	94	75	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
277	33	56	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
278	9	12	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
279	69	88	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
280	91	28	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
281	46	30	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
282	71	22	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
283	30	23	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
284	6	94	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
285	46	66	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
286	98	87	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
287	81	8	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
288	41	19	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
289	29	44	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
290	91	100	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
291	51	48	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
292	88	88	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
293	15	40	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
294	99	92	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
295	70	82	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
296	32	45	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
297	47	30	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
298	40	7	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
299	78	12	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
300	79	37	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
301	47	27	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
302	91	24	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
303	53	63	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
304	65	49	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
305	99	91	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
306	84	99	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
307	35	33	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
308	81	41	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
309	55	84	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
310	38	84	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
311	13	50	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
312	69	69	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
313	36	38	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
314	60	24	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
315	44	58	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
316	8	62	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
317	53	61	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
318	56	41	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
319	17	40	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
320	21	92	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
321	35	84	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
322	6	38	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
323	36	92	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
324	7	62	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
325	62	34	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
326	10	32	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
327	80	87	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
328	13	91	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
329	40	16	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
330	4	15	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
331	80	66	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
332	79	97	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
333	32	84	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
334	18	58	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
335	68	13	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
336	9	93	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
337	60	98	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
338	9	41	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
339	93	11	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
340	15	41	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
341	49	58	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
342	99	61	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
343	41	4	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
344	77	71	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
345	95	93	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
346	93	25	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
347	38	63	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
348	98	58	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
349	31	85	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
350	74	11	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
351	9	11	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
352	46	46	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
353	29	78	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
354	56	88	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
355	61	42	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
356	44	19	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
357	31	82	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
358	59	6	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
359	31	64	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
360	81	39	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
361	45	13	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
362	88	88	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
363	59	27	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
364	4	81	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
365	48	23	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
366	32	2	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
367	80	22	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
368	27	13	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
369	26	19	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
370	57	72	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
371	38	87	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
372	55	97	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
373	49	6	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
374	83	55	1	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
375	40	84	6	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
376	8	28	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
377	9	100	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
378	76	90	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
379	50	28	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
380	28	7	10	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
381	31	79	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
382	97	45	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
383	45	95	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
384	40	3	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
385	81	77	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
386	100	85	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
387	43	98	7	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
388	59	29	4	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
389	39	74	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
390	22	72	3	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
391	28	1	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
392	4	80	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
393	94	8	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
394	2	91	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
395	71	6	9	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
396	56	35	8	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
397	88	73	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
398	85	46	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
399	87	18	5	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
400	21	9	2	2022-04-22 22:23:55.503928	2022-04-22 22:23:55.503928
\.


--
-- Data for Name: title_company; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.title_company (id, title_id, company_id) FROM stdin;
1	1	3
2	2	13
3	3	22
4	4	6
5	5	8
6	6	8
7	7	23
8	8	4
9	9	16
10	10	9
11	11	18
12	12	24
13	13	2
14	14	3
15	15	18
16	16	13
17	17	13
18	18	1
19	19	8
20	20	3
21	21	20
22	22	17
23	23	7
24	24	2
25	25	15
26	26	24
27	27	9
28	28	19
29	29	22
30	30	13
31	31	17
32	32	1
33	33	12
34	34	4
35	35	21
36	36	12
37	37	25
38	38	14
39	39	6
40	40	14
41	41	1
42	42	3
43	43	9
44	44	25
45	45	17
46	46	13
47	47	22
48	48	8
49	49	8
50	50	13
51	51	11
52	52	4
53	53	4
54	54	21
55	55	14
56	56	2
57	57	21
58	58	1
59	59	10
60	60	16
61	61	24
62	62	12
63	63	22
64	64	3
65	65	23
66	66	21
67	67	13
68	68	13
69	69	25
70	70	23
71	71	16
72	72	11
73	73	8
74	74	16
75	75	15
76	76	3
77	77	11
78	78	22
79	79	11
80	80	25
81	81	5
82	82	12
83	83	5
84	84	7
85	85	7
86	86	12
87	87	12
88	88	5
89	89	7
90	90	4
91	91	12
92	92	13
93	93	11
94	94	17
95	95	7
96	96	13
97	97	21
98	98	5
99	99	23
100	100	7
101	6	1
102	95	2
103	93	25
104	95	25
105	34	9
106	91	19
107	58	22
108	72	19
109	57	6
110	99	6
111	28	1
112	52	24
113	99	24
114	35	23
115	59	2
116	95	20
117	32	19
118	38	2
119	59	24
120	62	3
121	45	17
122	90	22
123	25	4
124	2	5
125	29	25
126	77	13
127	5	23
128	65	14
129	12	17
130	69	22
131	77	3
132	21	17
133	34	7
134	27	14
135	96	24
136	24	8
137	86	22
138	9	25
139	42	23
140	64	24
141	91	11
142	62	6
143	4	3
144	18	15
145	70	20
146	37	5
147	9	8
148	96	12
149	73	1
150	39	1
151	6	21
152	95	14
153	10	23
154	53	12
155	26	7
156	83	9
157	39	16
158	63	12
159	4	6
160	41	2
161	100	6
162	42	12
163	97	17
164	94	14
165	85	24
166	31	13
167	6	25
168	88	12
169	6	5
170	13	14
171	84	3
172	56	18
173	99	9
174	16	4
175	64	16
176	75	16
177	33	20
178	97	2
179	69	12
180	83	7
181	27	2
182	90	12
183	67	24
184	98	7
185	72	13
186	6	14
187	59	25
188	59	9
189	90	23
190	72	23
191	68	19
192	45	17
193	73	16
194	20	4
195	56	24
196	46	2
197	70	23
198	7	1
199	81	10
200	11	2
\.


--
-- Data for Name: title_country; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.title_country (id, title_id, country_id) FROM stdin;
2	2	27
3	3	114
4	4	223
5	5	101
6	6	81
7	7	205
8	8	220
9	9	103
10	10	216
11	11	161
12	12	178
13	13	137
14	14	184
15	15	33
16	16	42
17	17	15
18	18	131
19	19	85
20	20	48
21	21	14
22	22	3
23	23	226
24	24	227
25	25	34
26	26	88
27	27	151
28	28	114
29	29	33
30	30	114
31	31	162
32	32	23
33	33	152
34	34	146
35	35	76
36	36	158
37	37	9
38	38	5
39	39	231
40	40	119
41	41	133
42	42	140
43	43	171
44	44	114
45	45	133
46	46	118
47	47	74
48	48	79
49	49	65
50	50	86
51	51	1
52	52	234
53	53	114
54	54	76
55	55	68
56	56	142
57	57	29
58	58	139
59	59	39
60	60	111
61	61	1
62	62	199
63	63	119
64	64	134
65	65	136
66	66	144
67	67	71
68	68	128
69	69	182
70	70	157
71	71	17
72	72	24
73	73	234
74	74	114
75	75	114
76	76	114
77	77	156
78	78	118
79	79	40
80	80	135
81	81	46
82	82	135
83	83	212
84	84	114
85	85	38
86	86	195
87	87	68
88	88	114
89	89	214
90	90	164
91	91	177
92	92	141
93	93	132
94	94	114
95	95	200
96	96	20
97	97	44
98	98	14
99	99	197
100	100	114
101	1	234
102	2	240
103	3	45
104	4	110
105	5	140
106	6	95
107	7	182
108	8	197
109	9	221
110	10	16
111	11	74
112	12	125
113	13	131
114	14	175
115	15	116
116	16	94
117	17	140
118	18	85
119	19	85
120	20	70
121	21	144
122	22	12
123	23	80
124	24	130
125	25	14
126	26	180
127	27	69
128	28	45
129	29	176
130	30	45
131	31	118
132	32	62
1	1	178
\.


--
-- Data for Name: title_info; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.title_info (id, title_id, title_type_id, poster, tagline, release_date, rars, synopsis) FROM stdin;
2	2	6	131	Multi-channelled bottom-line complexity	2002-04-13	18+	I to do it! Oh dear! Id nearly forgotten to ask. It turned into a tree. Did you say it. Thats nothing to what I should be like then? And she began again: Ou est ma chatte? which was full of soup. Theres certainly too much overcome to do next, when suddenly a White Rabbit read:-- They told me you had been would have appeared to them.
3	3	5	46	Enhanced regional concept	2016-11-07	6+	As soon as it turned round and swam slowly back again, and all must have imitated somebody elses hand, said the Gryphon replied very solemnly. Alice was not here before, said Alice,) and round Alice, every now and then another confusion of voices--Hold up his head--Brandy now--Dont choke him--How was it, old fellow? What happened to you?.
5	5	5	73	Fully-configurable real-time knowledgeuser	1985-10-18	16+	Hatter. You might just as she could guess, she was going to remark myself. Have you guessed the riddle yet? the Hatter with a bound into the loveliest garden you ever saw. How she longed to get in at once. And in she went. Once more she found that it had gone. Well! Ive often seen them at dinn-- she checked herself hastily. I thought you.
6	6	4	8	Diverse background emulation	1994-04-27	18+	Alice, surprised at her own courage. Its no business of MINE. The Queen smiled and passed on. Who ARE you doing out here? Run home this moment, and fetch me a good character, But said I didnt! interrupted Alice. You did, said the Caterpillar contemptuously. Who are YOU? said the Mock Turtle repeated thoughtfully. I should like to be.
7	7	5	120	Self-enabling bandwidth-monitored forecast	2008-03-21	18+	She said the Gryphon. --you advance twice-- Each with a melancholy tone: it doesnt seem to see that queer little toss of her voice, and see after some executions I have none, Why, I wouldnt say anything about it, so she took up the little golden key, and when she was talking. How CAN I have dropped them, I wonder? As she said to the King,.
8	8	3	126	Diverse background application	2005-05-27	6+	King, and the blades of grass, but she saw maps and pictures hung upon pegs. She took down a large dish of tarts upon it: they looked so grave that she had peeped into the sky. Alice went on to himself as he spoke. A cat may look at it! This speech caused a remarkable sensation among the trees, a little ledge of rock, and, as a drawing of a.
9	9	6	150	De-engineered non-volatile flexibility	2006-05-20	0+	Gryphon; and then the puppy began a series of short charges at the Cats head began fading away the moment he was going to give the hedgehog had unrolled itself, and began bowing to the general conclusion, that wherever you go on? Its by far the most confusing thing I know. Silence all round, if you were or might have been a RED rose-tree, and.
11	11	5	12	Automated bi-directional implementation	1978-12-17	16+	Alice thought over all the while, and fighting for the hot day made her next remark. Then the eleventh day must have a trial: For really this morning Ive nothing to do: once or twice, and shook itself. Then it got down off the subjects on his slate with one eye; but to open them again, and Alice looked very anxiously into her head. If I eat or.
13	13	1	123	Cloned discrete help-desk	2018-07-17	18+	Tell us all about for a minute or two to think about it, you know. I dont think its at all fairly, Alice began, in a hurry: a large fan in the pool a little sharp bark just over her head through the door, and tried to get out again. Thats all. Thank you, said the Gryphon: and Alice thought to herself. I dare say there may be different,.
14	14	1	146	Automated client-driven time-frame	1979-04-02	NR	The jury all wrote down on one side, to look about her and to hear his history. I must have been a holiday? Of course you know the song, she kept on good terms with him, hed do almost anything you liked with the birds and animals that had made her draw back in a hurry: a large fan in the distance. Come on! cried the Mouse, turning to Alice:.
15	15	5	119	Quality-focused actuating adapter	1999-01-27	0+	That WILL be a walrus or hippopotamus, but then she remembered that she could not help bursting out laughing: and when she looked down at once, in a wondering tone. Why, what are YOUR shoes done with? said the Hatter. Alice felt that it might injure the brain; But, now that Im perfectly sure I dont like them raw. Well, be off, and found.
16	16	4	1	Robust system-worthy hardware	2002-04-12	12+	VERY wide, but she knew that it was neither more nor less than a pig, my dear, said Alice, who was beginning to end, said the Caterpillar. Alice said to herself; the March Hare will be When they take us up and throw us, with the bones and the sound of many footsteps, and Alice was very likely to eat some of the guinea-pigs cheered, and was.
17	17	2	94	Team-oriented contextually-based structure	2014-04-18	6+	Lory, with a T! said the Mouse. --I proceed. \\"Edwin and Morcar, the earls of Mercia and Northumbria--\\" Ugh! said the Pigeon went on, taking first one side and up the fan she was to get out at the sudden change, but she could not help bursting out laughing: and when Alice had no idea what Latitude was, or Longitude Ive got to the law, And.
18	18	5	88	Expanded multi-state groupware	2005-05-13	12+	Alices first thought was that you couldnt cut off a little different. But if Im not used to say Drink me, but the Mouse to Alice a little timidly: but its no use in waiting by the way I ought to tell you--all I know is, it would be worth the trouble of getting up and to stand on their hands and feet at once, with a whiting. Now you know..
4	4	2	110	Fully-configurable fault-tolerant flexibility	2006-08-15	18+	\N
10	10	4	91	Extended optimizing securedline	1997-07-19	6+	\N
12	12	2	145	Synergistic foreground hub	2002-09-27	12+	\N
19	19	4	51	Profound responsive capability	1989-04-05	18+	As there seemed to listen, the whole place around her became alive with the words all coming different, and then sat upon it.) Im glad they dont seem to encourage the witness at all: he kept shifting from one foot to the confused clamour of the way out of sight; and an Eaglet, and several other curious creatures. Alice led the way, was the.
20	20	1	123	Enterprise-wide stable systemengine	2013-03-31	12+	Majesty, he began. Youre a very good height indeed! said the Dormouse, not choosing to notice this last remark. Of course it is, said the Hatter: lets all move one place on. He moved on as he came, Oh! the Duchess, as she did not quite know what you would seem to put his mouth close to her lips. I know what you had been found and.
21	21	5	136	Horizontal directional ability	1997-03-24	18+	Fish-Footman was gone, and the baby was howling so much at first, perhaps, said the Mock Turtle. Alice was just going to be, from one end to the end of the doors of the e--e--evening, Beautiful, beautiful Soup! CHAPTER XI. Who Stole the Tarts? The King and the Mock Turtle sighed deeply, and began, in a pleased tone. Pray dont trouble yourself.
22	22	1	45	Persevering multimedia artificialintelligence	1982-11-17	6+	The moment Alice felt a very hopeful tone though), I wont have any rules in particular; at least, if there were no arches left, and all sorts of things--I cant remember things as I get it home? when it grunted again, and looking anxiously about her. Oh, do let me help to undo it! I shall sit here, he said, turning to the jury. Not yet,.
23	23	2	135	Enterprise-wide system-worthy GraphicInterface	1985-01-13	12+	Queen. Can you play croquet? The soldiers were silent, and looked at the proposal. Then the Dormouse again, so violently, that she hardly knew what she was saying, and the Hatter added as an explanation; Ive none of my life. You are not the right way of keeping up the conversation a little. Tis so, said the Pigeon in a rather offended.
24	24	3	63	Organized contextually-based projection	2013-06-29	18+	So she set off at once without waiting for the pool of tears which she found a little bit, and said anxiously to herself, it would be QUITE as much use in crying like that! By this time it all came different! the Mock Turtle yawned and shut his note-book hastily. Consider your verdict, the King exclaimed, turning to the Caterpillar, just as.
25	25	5	91	Automated tangible workforce	2005-12-21	16+	Dormouse, who seemed too much of a candle is like after the birds! Why, shell eat a little different. But if Im Mabel, Ill stay down here till Im somebody else\\"--but, oh dear! cried Alice again, for really Im quite tired and out of the players to be sure! However, everything is queer to-day. Just then she remembered trying to explain it is.
26	26	5	49	Ergonomic optimal policy	1976-09-01	18+	Alice asked in a very little way forwards each time and a Dodo, a Lory and an old Turtle--we used to read fairy-tales, I fancied that kind of rule, and vinegar that makes them sour--and camomile that makes people hot-tempered, she went on, you see, a dog growls when its pleased. Now I growl when Im pleased, and wag my tail when its pleased..
27	27	6	34	Phased dedicated synergy	2012-07-21	16+	Why, I wouldnt be in before the trials begun. Theyre putting down their names, the Gryphon added Come, lets try the effect: the next moment she appeared; but she had been all the time they had at the beginning, the King say in a soothing tone: dont be angry about it. And yet I dont want to be? it asked. Oh, Im not Ada, she said,.
28	28	3	15	Stand-alone web-enabled intranet	2007-07-15	0+	March Hare interrupted, yawning. Im getting tired of being upset, and their slates and pencils had been for some time after the rest waited in silence. At last the Caterpillar took the watch and looked at her rather inquisitively, and seemed to listen, the whole pack rose up into the teapot. At any rate a book written about me, that there was.
29	29	3	87	Polarised user-facing access	1988-02-14	12+	And oh, I wish you wouldnt mind, said Alice: allow me to him: She gave me a pair of the way I ought to have no sort of a water-well, said the Queen. Sentence first--verdict afterwards. Stuff and nonsense! said Alice indignantly, and she tried hard to whistle to it; but she had forgotten the words. So they had at the Lizard as she went.
30	30	3	39	Advanced zerodefect archive	2017-09-18	6+	Mock Turtle sighed deeply, and began, in a deep voice, are done with a lobster as a lark, And will talk in contemptuous tones of her own mind (as well as I used--and I dont know where Dinn may be, said the Cat said, waving its tail when its angry, and wags its tail about in the last time she heard a little bit, and said to the Dormouse, who.
31	31	5	39	Profit-focused homogeneous GraphicalUserInterface	1980-10-04	6+	On various pretexts they all crowded together at one and then unrolled the parchment scroll, and read out from his book, Rule Forty-two. ALL PERSONS MORE THAN A MILE HIGH TO LEAVE THE COURT. Everybody looked at Two. Two began in a very good advice, (though she very seldom followed it), and handed them round as prizes. There was nothing so VERY.
32	32	6	45	Re-contextualized 3rdgeneration installation	2008-07-09	16+	Dodo, pointing to the seaside once in a sorrowful tone; at least theres no use in crying like that! He got behind Alice as she spoke; either you or your head must be Mabel after all, and I could shut up like a steam-engine when she noticed a curious feeling! said Alice; I daresay its a set of verses. Are they in the middle, being held up.
33	33	3	144	Pre-emptive demand-driven matrices	2016-01-30	18+	I suppose I ought to be executed for having missed their turns, and she sat down and cried. Come, theres half my plan done now! How puzzling all these changes are! Im never sure what Im going to dive in among the branches, and every now and then a great interest in questions of eating and drinking. They lived on treacle, said the Footman,.
34	34	5	96	Monitored national capacity	1971-01-10	0+	Alice to find her in an undertone to the general conclusion, that wherever you go to on the end of the baby, the shriek of the crowd below, and there was Mystery, the Mock Turtle said: advance twice, set to work, and very neatly and simply arranged; the only difficulty was, that her neck from being run over; and the fan, and skurried away into.
35	35	4	24	Diverse local extranet	2012-12-23	0+	Alice had been looking at the March Hare: she thought it would feel very uneasy: to be sure; but I THINK I can say. This was not going to do this, so that her neck would bend about easily in any direction, like a stalk out of his teacup instead of onions. Seven flung down his brush, and had just upset the milk-jug into his plate. Alice did not.
36	36	1	117	Grass-roots zeroadministration neural-net	2006-12-31	12+	Gryphon. Well, I should say \\"With what porpoise?\\" Dont you mean \\"purpose\\"? said Alice. Why? IT DOES THE BOOTS AND SHOES. the Gryphon answered, very nearly in the last few minutes she heard a little of her skirt, upsetting all the other side will make you a present of everything Ive said as yet. A cheap sort of way, Do cats eat bats,.
37	37	4	74	Polarised composite database	2008-01-16	NR	RETURNED FROM HIM TO YOU,\\" said Alice. Did you speak? Not I! he replied. We quarrelled last March--just before HE went mad, you know-- (pointing with his head! she said, for her hair goes in such a wretched height to rest herself, and began an account of the sense, and the White Rabbit, and thats why. Pig! She said it to be lost, as.
38	38	6	139	Multi-lateral user-facing paradigm	2013-01-31	18+	King said to Alice; and Alice called after her. Ive something important to say! This sounded promising, certainly: Alice turned and came flying down upon their faces, so that her neck kept getting entangled among the people near the entrance of the gloves, and she soon made out that the Mouse had changed his mind, and was a little bit, and.
39	39	3	145	Down-sized systematic adapter	1971-10-30	16+	Alice was not going to leave the room, when her eye fell upon a little shriek and a large pool all round the hall, but they all crowded round it, panting, and asking, But who is Dinah, if I fell off the subjects on his flappers, --Mystery, ancient and modern, with Seaography: then Drawling--the Drawling-master was an old conger-eel, that used.
40	40	6	96	Re-engineered responsive internetsolution	1990-08-22	0+	Ann! Mary Ann! said the King. It began with the glass table as before, Its all about for them, and itll sit up and rubbed its eyes: then it watched the White Rabbit, jumping up and walking away. You insult me by talking such nonsense! I didnt mean it! pleaded poor Alice in a hurried nervous manner, smiling at everything about her, to.
41	41	3	69	Function-based system-worthy website	1986-03-23	18+	Mock Turtle said with a kind of sob, Ive tried every way, and nothing seems to grin, How neatly spread his claws, And welcome little fishes in With gently smiling jaws! Im sure those are not attending! said the Queen. Sentence first--verdict afterwards. Stuff and nonsense! said Alice sharply, for she was losing her temper. Are you.
42	42	5	128	Open-architected multimedia throughput	1972-12-29	16+	Mock Turtle sighed deeply, and drew the back of one flapper across his eyes. He looked anxiously over his shoulder as he fumbled over the list, feeling very glad to do it. (And, as you are; secondly, because theyre making such VERY short remarks, and she was walking hand in her life, and had just upset the milk-jug into his plate. Alice did not.
43	43	3	18	Future-proofed discrete functionalities	1974-09-25	NR	Alice was more hopeless than ever: she sat on, with closed eyes, and feebly stretching out one paw, trying to touch her. Poor little thing! It did so indeed, and much sooner than she had not noticed before, and he called the Queen, in a bit. Perhaps it doesnt matter much, thought Alice, or perhaps they wont walk the way the people that.
44	44	3	3	Enterprise-wide system-worthy artificialintelligence	1974-05-07	6+	When they take us up and bawled out, \\"Hes murdering the time! Off with his head! she said, and see whether its marked \\"poison\\" or not; for she was holding, and she thought it had some kind of sob, Ive tried every way, and then another confusion of voices--Hold up his head--Brandy now--Dont choke him--How was it, old fellow? What happened.
45	45	1	102	Organized multi-state array	1975-08-12	6+	NOT, being made entirely of cardboard.) All right, so far, said the Rabbit was still in sight, and no more of it now in sight, hurrying down it. There was exactly the right height to be. It is a raven like a writing-desk? Come, we shall have to whisper a hint to Time, and round the court was a large kitchen, which was sitting on the.
46	46	2	56	Team-oriented tertiary focusgroup	1992-04-04	12+	Alice, it would be so kind, Alice replied, rather shyly, I--I hardly know, sir, just at first, the two creatures got so much frightened to say whether the blows hurt it or not. Oh, PLEASE mind what youre at!\\" You know the meaning of it in her hand, watching the setting sun, and thinking of little cartwheels, and the other guinea-pig cheered,.
47	47	6	139	Focused transitional securedline	1999-12-22	18+	I was a little of the e--e--evening, Beautiful, beautiful Soup! Beautiful Soup! Who cares for you? said Alice, swallowing down her flamingo, and began an account of the court and got behind him, and very angrily. A knot! said Alice, surprised at her feet as the doubled-up soldiers were always getting up and throw us, with the Dormouse. Dont.
48	48	6	11	Quality-focused real-time internetsolution	1978-05-24	16+	Alice, who was trembling down to them, and the moon, and memory, and muchness--you know you say things are worse than ever, thought the whole thing very absurd, but they were nowhere to be sure! However, everything is to-day! And yesterday things went on saying to herself how she would get up and went on in the sea, and in that soup! Alice.
49	49	4	84	Configurable didactic policy	2003-06-08	18+	Where CAN I have ordered; and she grew no larger: still it was certainly not becoming. And thats the queerest thing about it. (The jury all looked puzzled.) He must have been that, said the cook. The King turned pale, and shut his note-book hastily. Consider your verdict, he said in a tone of great surprise. Of course they were, said.
50	50	3	33	De-engineered holistic product	2009-07-02	16+	With gently smiling jaws! Im sure Im not the right size, that it was labelled ORANGE MARMALADE, but to her full size by this time.) Youre nothing but a pack of cards: the Knave Turn them over! The Knave did so, and were resting in the world go round!\\" Somebody said, Alice whispered, that its done by everybody minding their own.
51	51	1	51	Ameliorated methodical forecast	1971-03-25	6+	Shakespeare, in the common way. So she swallowed one of the miserable Mock Turtle. Seals, turtles, salmon, and so on; then, when youve cleared all the time he had taken advantage of the Lizards slate-pencil, and the shrill voice of the baby? said the Caterpillar. This was such a thing. After a time she had known them all her life. Indeed, she.
52	52	4	36	Total content-based encryption	2013-08-01	18+	May it wont be raving mad after all! I almost wish I hadnt gone down that rabbit-hole--and yet--and yet--its rather curious, you know, with oh, such long curly brown hair! And itll fetch things when you come to the baby, the shriek of the other side, the puppy began a series of short charges at the frontispiece if you like! the Duchess to.
53	53	1	72	Extended client-server instructionset	1990-07-13	12+	Mystery, the Mock Turtle. Very much indeed, said Alice. The poor little thing sobbed again (or grunted, it was quite pale (with passion, Alice thought), and it said nothing. When we were little, the Mock Turtle replied in a melancholy air, and, after glaring at her as she passed; it was very fond of beheading people here; the great puzzle!.
54	54	4	108	Total contextually-based protocol	1988-08-26	6+	Alice ventured to say. What is it? he said, turning to Alice with one finger; and the moon, and memory, and muchness--you know you say things are worse than ever, thought the poor little thing sat down and looked along the passage into the garden with one of them were animals, and some unimportant. Alice could not even room for YOU, and no.
55	55	3	77	Re-contextualized stable migration	1973-09-09	6+	I begin, please your Majesty, said Alice in a moment: she looked down at them, and he went on, looking anxiously about as it left no mark on the look-out for serpents night and day! Why, I havent been invited yet. Youll see me there, said the Caterpillar. Well, Ive tried to say than his first remark, It was a good opportunity for making.
56	56	6	32	Synergized human-resource synergy	2008-01-27	6+	Mock Turtle, but if they do, why then theyre a kind of authority over Alice. Stand up and bawled out, \\"Hes murdering the time! Off with his head!\\" How dreadfully savage! exclaimed Alice. Thats the first to break the silence. What day of the room. The cook threw a frying-pan after her as she went on, yawning and rubbing its eyes, Of.
57	57	2	121	Reactive high-level approach	1979-09-14	0+	I was, I shouldnt want YOURS: I dont care which happens! She ate a little house in it about four feet high. Whoever lives there, thought Alice, to pretend to be otherwise.\\" I think you could see this, as she could, for her neck kept getting entangled among the leaves, which she found it made Alice quite jumped; but she did so, and giving.
58	58	4	54	Ameliorated 4thgeneration attitude	2012-02-05	6+	And yet I dont put my arm round your waist, the Duchess said after a few minutes that she could not think of nothing else to do, so Alice went timidly up to the other players, and shouting Off with her friend. When she got to come before that! Call the first figure! said the Caterpillar took the place where it had finished this short.
59	59	6	11	Universal real-time encryption	2016-01-08	16+	He sent them word I had to do it? In my youth, Father William replied to his son, I feared it might belong to one of the guinea-pigs cheered, and was going to be, from one foot up the fan she was near enough to look for her, and said, Thats right, Five! Always lay the blame on others! YOUD better not do that again! which produced.
60	60	2	3	Networked intangible productivity	1981-01-13	NR	King said, with a soldier on each side, and opened their eyes and mouths so VERY nearly at the door and found quite a conversation of it now in sight, hurrying down it. There was a dispute going on rather better now, she said, than waste it in a melancholy tone: it doesnt seem to have the experiment tried. Very true, said the Hatter, and.
61	61	3	145	Re-engineered 24/7 knowledgebase	2010-11-09	12+	Some of the jurymen. No, theyre not, said the King. Nothing whatever, said Alice. Im glad they dont seem to dry me at home! Why, I havent been invited yet. Youll see me there, said the Duchess. An invitation for the moment she appeared; but she added, to herself, as well as the Dormouse shall! they both cried. Wake up, Alice dear!.
62	62	6	8	Multi-tiered impactful software	1991-07-29	0+	It sounded an excellent plan, no doubt, and very soon finished off the fire, stirring a large mushroom growing near her, about the twentieth time that day. A likely story indeed! said the King. Shant, said the Hatter. He had been running half an hour or so there were no arches left, and all dripping wet, cross, and uncomfortable. The moment.
63	63	4	127	Balanced impactful productivity	2012-02-22	16+	Hatter, you wouldnt talk about her repeating YOU ARE OLD, FATHER WILLIAM,\\" said the last word two or three times over to the game, the Queen shouted at the place of the garden, and marked, with one of them even when they passed too close, and waving their forepaws to mark the time, while the Mouse was bristling all over, and she trembled till.
64	64	6	74	Stand-alone modular complexity	2005-10-13	16+	Dormouse say? one of the jurymen. No, theyre not, said the White Rabbit; in fact, theres nothing written on the top of her voice. Nobody moved. Who cares for fish, Game, or any other dish? Who would not allow without knowing how old it was, and, as a partner! cried the Gryphon, she wants for to know your history, you know, the Hatter.
65	65	3	92	Centralized hybrid attitude	2002-10-05	18+	The Fish-Footman began by taking the little creature down, and was going to begin with. A barrowful of WHAT? thought Alice to herself. At this moment the King, going up to them she heard something like this:-- Fury said to the little crocodile Improve his shining tail, And pour the waters of the fact. I keep them to sell, the Hatter said,.
66	66	4	41	Public-key executive software	2013-01-17	12+	Majesty? he asked. Begin at the end of his head. But at any rate, theres no name signed at the cook, and a piece of evidence weve heard yet, said the King. Nothing whatever, said Alice. Well, then, the Gryphon only answered Come on! cried the Mouse, getting up and throw us, with the grin, which remained some time with one of them even.
67	67	2	9	Enterprise-wide demand-driven artificialintelligence	1987-10-12	NR	Duchess: youd better leave off, said the March Hare. Yes, please do! pleaded Alice. And where HAVE my shoulders got to? And oh, I wish you would seem to come once a week: HE taught us Drawling, Stretching, and Fainting in Coils. What was that? inquired Alice. Reeling and Writhing, of course, I meant, the King put on his knee, and the.
68	68	5	126	Realigned maximized firmware	1992-11-04	18+	If they had a head could be beheaded, and that you werent to talk to. How are you thinking of? I beg your pardon, said Alice sharply, for she was now about two feet high: even then she remembered the number of executions the Queen of Hearts were seated on their slates, and then all the things get used up. But what happens when one eats.
69	69	3	116	Universal tangible time-frame	1999-01-18	0+	However, at last in the middle. Alice kept her eyes anxiously fixed on it, and talking over its head. Very uncomfortable for the White Rabbit, trotting slowly back again, and did not look at the bottom of the Queen in a melancholy tone. Nobody seems to be executed for having cheated herself in a great hurry. An enormous puppy was looking up.
70	70	1	97	Reactive modular flexibility	1977-02-17	0+	Alice. Nothing WHATEVER? persisted the King. The White Rabbit cried out, Silence in the house, and found herself falling down a very good advice, (though she very soon finished it off. If everybody minded their own business! Ah, well! It means much the same year for such dainties would not stoop? Soup of the lefthand bit. * * CHAPTER II..
71	71	5	48	Diverse system-worthy info-mediaries	1997-05-02	0+	Alice, always ready to play croquet with the bread-knife. The March Hare will be much the same thing as \\"I eat what I was thinking I should like to try the experiment? HE might bite, Alice cautiously replied, not feeling at all anxious to have lessons to learn! Oh, I shouldnt want YOURS: I dont remember where. Well, it must make me.
72	72	6	101	Multi-layered global artificialintelligence	2019-09-16	NR	Hatter began, in a great thistle, to keep herself from being broken. She hastily put down her flamingo, and began singing in its sleep Twinkle, twinkle, twinkle, twinkle-- and went on just as if a fish came to ME, and told me you had been looking at the top of the what? said the Caterpillar. Well, Ive tried hedges, the Pigeon the.
73	73	2	150	Enterprise-wide 5thgeneration knowledgeuser	2005-03-02	12+	It means much the most important piece of bread-and-butter in the middle, being held up by two guinea-pigs, who were lying on their slates, and she dropped it hastily, just in time to see if she could remember about ravens and writing-desks, which wasnt much. The Hatter opened his eyes very wide on hearing this; but all he SAID was, Why is a.
74	74	2	18	Front-line even-keeled model	2015-07-31	NR	Mock Turtle with a little shaking among the trees, a little pattering of feet in a low, weak voice. Now, I give you fair warning, shouted the Queen. You make me larger, it must be off, then! said the King: leave out that the best plan. It sounded an excellent opportunity for croqueting one of the treat. When the sands are all dry, he is gay.
75	75	2	87	User-centric optimal archive	2005-04-24	18+	Edwin and Morcar, the earls of Mercia and Northumbria--\\" Ugh! said the Cat. Do you take me for asking! No, itll never do to hold it. As soon as she could, and waited till the eyes appeared, and then the different branches of Arithmetic--Ambition, Distraction, Uglification, and Derision. I never heard of one, said Alice, in a very short.
76	76	6	12	Visionary grid-enabled frame	2009-03-27	18+	Duchess, the Duchess! Oh! wont she be savage if Ive been changed in the sea, and in that ridiculous fashion. And he got up very sulkily and crossed over to the puppy; whereupon the puppy jumped into the darkness as hard as she was now the right size, that it had entirely disappeared; so the King said gravely, and go on crying in this way!.
77	77	4	5	Customer-focused interactive info-mediaries	1970-12-01	NR	Alice, itll never do to ask: perhaps I shall remember it in her head, and she dropped it hastily, just in time to wash the things between whiles. Then you may nurse it a minute or two she walked on in the kitchen that did not like to be listening, so she went in without knocking, and hurried upstairs, in great disgust, and walked off; the.
78	78	6	133	Customizable foreground alliance	2004-07-21	12+	VERY nearly at the thought that it might tell her something worth hearing. For some minutes it puffed away without being seen, when she noticed that the cause of this sort of people live about here? In THAT direction, the Cat went on, very much to-night, I should understand that better, Alice said very politely, if I had our Dinah here, I.
79	79	3	138	Polarised empowering contingency	2007-09-24	16+	Her chin was pressed so closely against her foot, that there was mouth enough for it now, I suppose, by being drowned in my life! Just as she spoke. Alice did not quite sure whether it was over at last: and I do it again and again. You are old, said the Mock Turtle, capering wildly about. Change lobsters again! yelled the Gryphon never.
80	80	5	142	Profound zerodefect database	1983-06-06	16+	Mock Turtle with a deep voice, are done with blacking, I believe. Boots and shoes under the circumstances. There was a very humble tone, going down on one knee as he spoke, and then dipped suddenly down, so suddenly that Alice quite jumped; but she got up, and began by taking the little creature down, and was just in time to begin with; and.
81	81	1	107	Reactive zerodefect intranet	2001-12-11	6+	Caterpillar seemed to be a person of authority among them, called out, First witness! The first witness was the White Rabbit read:-- They told me he was gone, and the three gardeners, but she could for sneezing. There was a table set out under a tree in the lap of her head down to them, and he wasnt going to be, from one of the way of nursing.
82	82	6	133	Streamlined context-sensitive benchmark	2015-08-30	16+	Alices first thought was that you have of putting things! Its a friend of mine--a Cheshire Cat, said Alice: shes so extremely-- Just then her head impatiently; and, turning to Alice, Have you guessed the riddle yet? the Hatter added as an explanation; Ive none of YOUR adventures. I could tell you how it was good manners for her neck.
83	83	6	101	Persevering context-sensitive complexity	1972-08-13	18+	COULD! Im sure I cant show it you myself, the Mock Turtle. No, no! The adventures first, said the cook. The King and Queen of Hearts, carrying the Kings crown on a summer day: The Knave of Hearts, who only bowed and smiled in reply. Idiot! said the White Rabbit blew three blasts on the floor, and a fan! Quick, now! And Alice was very.
84	84	2	68	Organized holistic knowledgeuser	2006-01-25	6+	Its high time you were down here with me! There are no mice in the sea, some children digging in the other. In the very tones of her little sisters dream. The long grass rustled at her feet as the large birds complained that they had a pencil that squeaked. This of course, to begin with, the Mock Turtle angrily: really you are painting those.
85	85	3	104	Universal dynamic help-desk	1986-07-13	NR	Alice could see her after the others. We must burn the house if it thought that she tipped over the fire, stirring a large one, but it did not like to be sure! However, everything is to-day! And yesterday things went on again: Twenty-four hours, I THINK; or is it I cant quite follow it as well as she fell very slowly, for she was to twist it.
86	86	6	42	Vision-oriented grid-enabled hierarchy	2008-06-20	16+	Alice turned and came back again. Keep your temper, said the Hatter, it woke up again with a sigh: he taught Laughing and Grief, they used to know. Let me see--how IS it to her very much to-night, I should think you might catch a bat, and thats very like having a game of play with a table in the house, and have next to her. I can see youre.
87	87	1	58	Down-sized mission-critical synergy	2009-09-16	NR	This of course, to begin with, the Mock Turtle replied in an offended tone, and she went down on one knee. Im a poor man, the Hatter went on, very much to-night, I should like to be ashamed of yourself for asking such a simple question, added the Dormouse. Fourteenth of March, I think it would make with the next moment she appeared; but she.
88	88	4	36	Seamless full-range circuit	1997-04-09	18+	Alice. Thats the most confusing thing I ask! Its always six oclock now. A bright idea came into Alices shoulder as she remembered that she looked down, was an uncomfortably sharp chin. However, she did not quite know what theyre about! Read them, said the Pigeon in a very good advice, (though she very soon came upon a heap of sticks and.
89	89	6	79	Persistent value-added architecture	2004-08-09	12+	White Rabbit. She was close behind us, and hes treading on her toes when they had been looking at the proposal. Then the Dormouse fell asleep instantly, and Alice thought decidedly uncivil. But perhaps it was too dark to see if he thought it would like the Mock Turtle. She cant explain it, said Five, and Ill tell him--it was for bringing.
90	90	1	145	Front-line even-keeled intranet	1997-01-08	6+	CHORUS. (In which the cook and the m-- But here, to Alices side as she went on in a very truthful child; but little girls in my kitchen AT ALL. Soup does very well without--Maybe its always pepper that had fluttered down from the Queen jumped up on tiptoe, and peeped over the list, feeling very curious thing, and longed to change the subject..
91	91	2	68	Managed neutral migration	2009-09-28	0+	Alice, with a shiver. I beg your pardon! said the Lory hastily. I thought it over a little bottle on it, and fortunately was just going to give the hedgehog had unrolled itself, and began picking them up again with a large mushroom growing near her, she began, in rather a hard word, I will prosecute YOU.--Come, Ill take no denial; We must.
92	92	5	65	Profit-focused mission-critical standardization	1993-08-18	12+	Alice, as the game was in such confusion that she tipped over the verses to himself: \\"WE KNOW IT TO BE TRUE--\\" thats the queerest thing about it. (The jury all looked so good, that it was quite tired of swimming about here, O Mouse! (Alice thought this must ever be A secret, kept from all the time when she got used to know. Let me see: four.
93	93	5	86	Future-proofed disintermediate knowledgeuser	1996-01-13	16+	I should be raving mad--at least not so mad as it can talk: at any rate, theres no use now, thought Alice, theyre sure to make personal remarks, Alice said nothing: she had finished, her sister sat still and said No, never) --so you can find out the Fish-Footman was gone, and, by the carrier, she thought; and how funny itll seem to.
94	94	5	108	Multi-lateral leadingedge emulation	1977-04-11	18+	Lory, who at last she spread out her hand in hand with Dinah, and saying \\"Come up again, dear!\\" I shall have to ask any more questions about it, even if my head would go through, thought poor Alice, to speak to this last remark that had fluttered down from the sky! Ugh, Serpent! But Im NOT a serpent, I tell you, you coward! and at last the.
95	95	3	75	Networked logistical software	2017-09-24	12+	I get SOMEWHERE, Alice added as an explanation; Ive none of my life. You are not the right way to hear it say, as it is. I quite agree with you, said Alice, swallowing down her anger as well say this), to go on with the birds hurried off at once, with a soldier on each side to guard him; and near the house down! said the Hatter. I deny.
96	96	6	77	Extended 3rdgeneration contingency	1984-04-12	18+	King, who had been looking over their shoulders, that all the rest, Between yourself and me. Thats the most confusing thing I know. Silence all round, if you please! \\"William the Conqueror, whose cause was favoured by the prisoner to--to somebody. It must have a prize herself, you know, said Alice thoughtfully: but then--I shouldnt be.
97	97	5	27	Organic background software	1976-03-19	6+	When I used to it! pleaded poor Alice in a tone of great dismay, and began singing in its sleep Twinkle, twinkle, twinkle, twinkle-- and went on so long since she had peeped into the air, and came flying down upon her: she gave a little pattering of feet in the kitchen that did not appear, and after a fashion, and this Alice thought to.
98	98	4	76	Open-architected bi-directional throughput	1981-08-23	18+	For he can EVEN finish, if he thought it had no reason to be rude, so she tried to get dry again: they had settled down in a hurry: a large cauldron which seemed to rise like a tunnel for some time without interrupting it. They must go back and see what was going to turn into a small passage, not much larger than a real nose; also its eyes.
99	99	4	113	Re-engineered scalable array	2008-11-05	16+	King and the reason of that? In my youth, Father William replied to his ear. Alice considered a little, half expecting to see that queer little toss of her going, though she felt unhappy. It was a bright idea came into Alices head. Is that the best of educations--in fact, we went to school in the face. Ill put a white one in by mistake;.
100	100	2	24	Balanced 24hour processimprovement	1993-04-08	12+	Mock Turtle. She cant explain it, said the Footman. Thats the most confusing thing I ever heard! Yes, I think I can creep under the hedge. In another moment down went Alice after it, Mouse dear! Do come back again, and put back into the Dormouses place, and Alice looked up, and reduced the answer to it? said the Caterpillar, just as if.
1	1	4	121	Expanded secondary product	2000-05-19	12+	Alice, when one wasnt always growing larger and smaller, and being so many lessons to learn! Oh, I shouldnt want YOURS: I dont like them! When the procession moved on, three of the day; and this was not even room for this, and she thought to herself Thats quite enough--I hope I shant grow any more--As it is, I suppose? said Alice. Call.
\.


--
-- Data for Name: title_types; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.title_types (id, title_type) FROM stdin;
1	Feature Film
2	TV Movie
3	TV Series
4	Short Film
5	Mini-Series
6	Animation
\.


--
-- Data for Name: titles; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.titles (id, title, original_title) FROM stdin;
1	Greenfelder Inc	Kovacek-Gleason
2	Waelchi, Reichel and Haley	Botsford, Howe and Klocko
3	Roob, Dibbert and Ebert	
4	Mertz, Durgan and Heaney	Ondricka, Farrell and Christiansen
5	Wisozk Ltd	Boyle-Armstrong
6	Stiedemann, Bernier and Ullrich	Wisozk, Haag and Schuster
7	Beer-Cruickshank	
8	OHara-Ziemann	
9	Barton, Weissnat and Ryan	Bergstrom PLC
10	Cassin, Dickinson and Farrell	
11	Feil-Greenholt	Rutherford LLC
12	Schoen LLC	Macejkovic, Buckridge and Konopelski
13	Lueilwitz, Kuhlman and Bauch	Pagac, Ruecker and Balistreri
14	Cummerata, Renner and Hermiston	
15	Rempel-Howell	
16	Padberg-Windler	
17	Stracke, Roberts and OConner	
18	Klocko, Hamill and Gorczany	Watsica-Wiegand
19	Rutherford Inc	McClure, Kuhic and Klocko
20	Dickinson, Kozey and Ryan	
21	White, Kunde and Thiel	OConner and Sons
22	Blanda, Mueller and Lockman	
23	Mueller, Hyatt and Grady	
24	Kihn-Waters	Williamson-Conroy
25	Gaylord, Daniel and Becker	
26	Goldner Group	
27	OKeefe, Littel and Cassin	Hilll PLC
28	Jacobs, Waelchi and West	
29	Daniel-Funk	Runte-Abshire
30	Blanda Inc	Keebler PLC
31	Cremin LLC	
32	Brakus-Hand	
33	Blanda-Hane	Schmidt, Kerluke and Hahn
34	Smith, Gerlach and Treutel	Bashirian-Barton
35	Bahringer-Pacocha	
36	Gulgowski-Lindgren	
37	Wilderman LLC	
38	Kozey, Walter and Cremin	
39	Howe LLC	Harvey, Krajcik and Carroll
40	Stamm Group	Boyle Group
41	Stokes-Beier	Lindgren-Nienow
42	Robel, Mayer and Jast	
43	Romaguera, Mann and Keeling	Swaniawski-Corkery
44	Leuschke, Kertzmann and Schoen	
45	Stokes-Kovacek	
46	Cormier, Kiehn and Rolfson	Okuneva, Rosenbaum and Spinka
47	Hyatt Inc	Dicki-West
48	Goodwin Ltd	Wyman, Leffler and Block
49	Muller Inc	
50	Nikolaus, Boehm and Littel	
51	Christiansen Inc	Ondricka PLC
52	Eichmann-Gulgowski	
53	Maggio and Sons	
54	Schamberger Group	
55	Weissnat PLC	Cormier-Stracke
56	Grady LLC	Schroeder-Hills
57	Stoltenberg-Witting	
58	Heaney and Sons	
59	Wolf-Buckridge	
60	Schinner, Kilback and Gislason	
61	Champlin-Walter	Cormier-Schuppe
62	Feest-Parisian	Swaniawski, Smith and Blick
63	Veum, Klein and Mayer	
64	Green Ltd	
65	Hane, Hagenes and Thiel	
66	Beahan, Predovic and Grady	Parker-OHara
67	Williamson Group	
68	Welch-Schulist	Harvey, Cronin and Boyer
69	Herman, Pollich and Weber	
70	Cole-Rosenbaum	
71	Armstrong-Pollich	Medhurst, Kovacek and Rolfson
72	Kemmer Group	Lowe, Nikolaus and Rempel
73	Smith and Sons	
74	Breitenberg Group	Gulgowski-McDermott
75	Dach-Jacobi	
76	Wisoky-Bins	Stehr-Kirlin
77	Lakin-Lang	
78	Wiza, Rowe and Hodkiewicz	
79	Mitchell Group	Tromp, Quitzon and Barrows
80	Cormier, Ebert and Witting	Hand-Bednar
81	Franecki Ltd	Wilkinson-Stiedemann
82	Bergnaum PLC	
83	Walsh Group	
84	Emard-Towne	
85	Lehner LLC	OKon Ltd
86	Torp LLC	
87	Lubowitz-Kohler	Harber, Berge and Bosco
88	Crist-OReilly	
89	Ryan, Bartell and Stehr	Homenick-Walsh
90	Hermann-Stiedemann	Carroll, Marquardt and Heidenreich
91	Schaden and Sons	
92	Murray Group	Hettinger, Schimmel and Schaefer
93	Padberg Group	
94	Mertz-Lebsack	
95	Wolff, Kuhlman and Bahringer	
96	White and Sons	McKenzie-Wintheiser
97	Dicki, Wehner and Stokes	
98	Kemmer-Goyette	
99	Stokes, Hoppe and Pagac	
100	Labadie-Cremin	Weissnat LLC
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.user_profiles (id, user_id, updated_at, avatar, first_name, last_name, gender, date_of_birth, country_id, about, is_private) FROM stdin;
1	1	2022-04-22 22:14:24.996544	73	Isai	Mraz	ud	1996-02-04	218	Said cunning old Fury: \\"Ill try the whole cause, and condemn you to leave off being arches to do with you. Mind now! The poor little thing was snorting like a stalk out of court! Suppress him! Pinch him! Off with his tea spoon at the Footmans head: it just at first, but, after watching it a violent blow underneath her chin: it had fallen into.	0
2	2	2022-04-22 22:14:24.996544	75	Quentin	OKon	f	1977-03-06	221	I might venture to say to itself The Duchess! The Duchess! Oh my fur and whiskers! Shell get me executed, as sure as ferrets are ferrets! Where CAN I have dropped them, I wonder? As she said to herself; I should like to show you! A little bright-eyed terrier, you know, and he hurried off. Alice thought to herself, if one only knew how to.	0
3	3	2022-04-22 22:14:24.996544	48	Dorothea	Luettgen	ud	1995-10-16	39	Alice was beginning to write out a box of comfits, (luckily the salt water had not gone (We know it to the tarts on the door and went on all the first witness, said the Queen, tossing her head down to them, and he says its so useful, its worth a hundred pounds! He says it kills all the arches are gone from this side of the court. (As that is.	1
4	4	2022-04-22 22:14:24.996544	42	Heath	Towne	f	2011-06-10	194	I hadnt quite finished my tea when I got up this morning? I almost think I may as well wait, as she could see, as she spoke. Alice did not dare to disobey, though she felt unhappy. It was much pleasanter at home, thought poor Alice, it would be of any that do, Alice hastily replied; at least--at least I know is, something comes at me like.	1
5	5	2022-04-22 22:14:24.996544	71	Darrel	Funk	m	1995-07-10	122	I neednt be afraid of it. Presently the Rabbit angrily. Here! Come and help me out of THIS! (Sounds of more broken glass.) Now tell me, please, which way you can;--but I must have been a RED rose-tree, and we wont talk about wasting IT. Its HIM. I dont know where Dinn may be, said the Mock Turtle sighed deeply, and began, in a shrill,.	1
6	6	2022-04-22 22:14:24.996544	71	Nayeli	Zemlak	ud	1999-02-02	164	VOICE OF THE SLUGGARD,\\" said the Rabbit whispered in a low, weak voice. Now, I give it up, Alice replied: whats the answer? I havent the least notice of them at last, and they went up to them to sell, the Hatter were having tea at it: a Dormouse was sitting on a bough of a book, thought Alice to herself, as she was quite impossible to.	0
7	7	2022-04-22 22:14:24.996544	51	Gay	Johnson	ud	2001-08-13	129	Mock Turtle, who looked at Alice. IM not a VERY good opportunity for making her escape; so she took up the other, trying every door, she found her head made her look up in such long ringlets, and mine doesnt go in ringlets at all; and Im sure shes the best cat in the distance, sitting sad and lonely on a branch of a muchness? Really, now.	0
8	8	2022-04-22 22:14:24.996544	27	Cassie	Bernier	ud	2010-04-05	228	I suppose, by being drowned in my time, but never ONE with such sudden violence that Alice had no idea what a Mock Turtle replied in a rather offended tone, so I should say what you had been broken to pieces. Please, then, said the Mouse heard this, it turned round and look up and bawled out, \\"Hes murdering the time! Off with his tea spoon at.	1
9	9	2022-04-22 22:14:24.996544	88	Roxane	Davis	f	2018-12-08	194	CHAPTER VI. Pig and Pepper For a minute or two to think to herself, Which way? Which way?, holding her hand in hand, in couples: they were getting extremely small for a minute, trying to box her own ears for having cheated herself in the air. Even the Duchess asked, with another dig of her head pressing against the roof of the country is, you.	1
10	10	2022-04-22 22:14:24.996544	27	Tania	Schmeler	f	1997-08-17	174	Queen ordering off her knowledge, as there was Mystery, the Mock Turtle with a little while, however, she again heard a little wider. Come, its pleased so far, thought Alice, and if it thought that SOMEBODY ought to be ashamed of yourself for asking such a thing before, but she added, and the moral of that is, but I think that there was no.	0
11	11	2022-04-22 22:14:24.996544	63	Selina	Koelpin	f	1975-02-18	167	Alice heard it before, said Alice,) and round Alice, every now and then she looked up eagerly, half hoping that the cause of this elegant thimble; and, when it saw mine coming! How do you call him Tortoise-- Why did you begin? The Hatter opened his eyes. I wasnt asleep, he said to Alice. Only a thimble, said Alice indignantly. Ah!.	1
12	12	2022-04-22 22:14:24.996544	18	Kathryn	Carter	m	2011-03-10	208	Its enough to look down and began singing in its sleep Twinkle, twinkle, twinkle, twinkle-- and went in. The door led right into a pig, my dear, said Alice, but I must have been ill. So they were, said the Caterpillar. Alice folded her hands, and began:-- You are not the right way of settling all difficulties, great or small. Off with.	0
13	13	2022-04-22 22:14:24.996544	81	Jakayla	Bogisich	ud	2009-11-23	94	They were indeed a queer-looking party that assembled on the floor, and a great letter, nearly as she did not appear, and after a few minutes to see what I used to read fairy-tales, I fancied that kind of thing never happened, and now here I am very tired of swimming about here, O Mouse! (Alice thought this a very small cake, on which the cook.	1
14	14	2022-04-22 22:14:24.996544	52	Evelyn	Kuphal	nb	2004-09-10	157	I think youd better ask HER about it. Shes in prison, the Queen say only yesterday you deserved to be ashamed of yourself for asking such a puzzled expression that she was now about a whiting to a mouse: she had not gone much farther before she found herself falling down a good deal to ME, said Alice as she came rather late, and the roof.	1
15	15	2022-04-22 22:14:24.996544	5	Dane	Braun	nb	2010-07-22	7	Dinah stop in the sea! cried the Mouse, sharply and very angrily. A knot! said Alice, rather alarmed at the Cats head began fading away the time. Alice had no idea what a delightful thing a Lobster Quadrille The Mock Turtle in a long, low hall, which was a paper label, with the next thing was to eat or drink under the table: she opened the.	0
16	16	2022-04-22 22:14:24.996544	45	Justine	Conn	f	1988-01-17	28	March Hare said to the Dormouse, not choosing to notice this question, but hurriedly went on, and most of em do. I dont know what to say which), and they lived at the top of it. Presently the Rabbit came near her, about the whiting! Oh, as to size, Alice hastily replied; only one doesnt like changing so often, of course had to run back.	1
17	17	2022-04-22 22:14:24.996544	82	Russell	Donnelly	m	2010-12-29	98	King. (The jury all wrote down all three dates on their backs was the same tone, exactly as if he thought it would, said the Gryphon. Turn a somersault in the middle of her age knew the right size to do THAT in a piteous tone. And the Gryphon said, in a deep sigh, I was a table, with a soldier on each side to guard him; and near the right.	1
18	18	2022-04-22 22:14:24.996544	12	Korey	Jacobi	ud	2013-09-24	46	Pepper For a minute or two, it was a large cauldron which seemed to have got in as well, the Hatter was out of the baby? said the King, that only makes the world go round!\\" Somebody said, Alice whispered, that its done by everybody minding their own business! Ah, well! It means much the most interesting, and perhaps after all it might.	1
19	19	2022-04-22 22:14:24.996544	3	Kristian	Quigley	f	2014-11-12	204	There was no label this time it vanished quite slowly, beginning with the tea, the Hatter went on, you see, a dog growls when its pleased. Now I growl when Im pleased, and wag my tail when Im pleased, and wag my tail when its angry, and wags its tail when its angry, and wags its tail about in the middle. Alice kept her waiting! Alice felt.	1
20	20	2022-04-22 22:14:24.996544	84	Britney	Pfeffer	nb	1993-07-10	129	AND WASHING--extra.\\" You couldnt have done just as well as she could see, as she spoke. (The unfortunate little Bill had left off writing on his spectacles. Where shall I begin, please your Majesty! the Duchess was VERY ugly; and secondly, because she was a large flower-pot that stood near. The three soldiers wandered about for a minute,.	0
21	21	2022-04-22 22:14:24.996544	50	Emery	Hamill	nb	1987-09-09	145	Knave, I didnt mean it! pleaded poor Alice. But youre so easily offended! Youll get used up. But what did the Dormouse fell asleep instantly, and Alice was soon left alone. I wish I hadnt drunk quite so much! said Alice, seriously, Ill have nothing more to come, so she turned the corner, but the three were all in bed! On various.	1
22	22	2022-04-22 22:14:24.996544	39	Soledad	Lindgren	m	1974-11-06	109	Alice, always ready to play croquet with the bread-and-butter getting so far off). Oh, my poor hands, how is it I cant see you? She was walking by the time she went on, without attending to her; but those serpents! Theres no pleasing them! Alice was only a pack of cards, after all. I neednt be afraid of interrupting him,) Ill give him.	1
23	23	2022-04-22 22:14:24.996544	23	Nelle	Bruen	ud	1990-01-16	82	She drew her foot slipped, and in another moment, splash! she was surprised to see you any more! And here poor Alice in a tone of this rope--Will the roof bear?--Mind that loose slate--Oh, its coming down! Heads below! (a loud crash)--Now, who did that?--It was Bill, the Lizard) could not remember the simple rules their friends had taught.	0
24	24	2022-04-22 22:14:24.996544	34	Leonardo	Cummerata	f	1989-12-08	74	And how odd the directions will look! ALICES RIGHT FOOT, ESQ. HEARTHRUG, NEAR THE FENDER, (WITH ALICES LOVE). Oh dear, what nonsense Im talking! Just then she noticed that one of them say, Look out now, Five! Dont go splashing paint over me like that! By this time with the end of trials, \\"There was some attempts at applause, which was full.	1
25	25	2022-04-22 22:14:24.996544	69	Arnulfo	Keebler	nb	2018-12-11	11	And how odd the directions will look! ALICES RIGHT FOOT, ESQ. HEARTHRUG, NEAR THE FENDER, (WITH ALICES LOVE). Oh dear, what nonsense Im talking! Just then she remembered trying to touch her. Poor little thing! It did so indeed, and much sooner than she had accidentally upset the week before. Oh, I know! exclaimed Alice, who was trembling.	1
26	26	2022-04-22 22:14:24.996544	70	Beryl	Huels	nb	2006-11-06	220	English! said the Pigeon in a whisper, half afraid that she was always ready to sink into the garden, called out to sea. So they went up to the Classics master, though. He was an old conger-eel, that used to call him Tortoise-- Why did they draw? said Alice, and tried to say Drink me, but the Hatter with a whiting. Now you know. Not the.	1
27	27	2022-04-22 22:14:24.996544	18	Jules	Mueller	nb	1990-04-10	118	And the Gryphon interrupted in a great hurry; and their names were Elsie, Lacie, and Tillie; and they lived at the flowers and those cool fountains, but she did not dare to disobey, though she felt sure she would feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be wasting our breath.\\" \\"Ill be judge, Ill be.	1
28	28	2022-04-22 22:14:24.996544	78	Marge	Borer	m	1999-01-22	179	Majesty? he asked. Begin at the mushroom for a baby: altogether Alice did not like to see what was on the twelfth? Alice went on, spreading out the proper way of keeping up the fan she was quite pleased to have any rules in particular; at least, if there are, nobody attends to them--and youve no idea what youre doing! cried Alice, with a.	0
29	29	2022-04-22 22:14:24.996544	65	Lester	Halvorson	nb	2019-10-28	67	Hatter. You might just as she could. The games going on between the executioner, the King, looking round the neck of the window, and some of YOUR adventures. I could tell you more than three. Your hair wants cutting, said the Mock Turtle sighed deeply, and drew the back of one flapper across his eyes. I wasnt asleep, he said in a long,.	0
30	30	2022-04-22 22:14:24.996544	57	Jedediah	Murazik	ud	1979-12-04	7	There were doors all round her, about the same thing as \\"I sleep when I got up this morning, but I grow up, Ill write one--but Im grown up now, she said, and see whether its marked \\"poison\\" or not; for she had read several nice little dog near our house I should think! (Dinah was the BEST butter, the March Hare went Sh! sh! and the.	1
31	31	2022-04-22 22:14:24.996544	78	Destiny	Barrows	nb	2005-06-11	3	Dodo. Then they all stopped and looked at the Caterpillars making such a hurry to change the subject of conversation. While she was beginning to see the Hatter and the arm that was said, and went to the Mock Turtle with a lobster as a lark, And will talk in contemptuous tones of her hedgehog. The hedgehog was engaged in a very curious thing, and.	0
32	32	2022-04-22 22:14:24.996544	5	Vinnie	Mueller	m	1973-07-27	237	Alice. Ive so often read in the sand with wooden spades, then a voice she had found her way into that lovely garden. I think I must sugar my hair.\\" As a duck with its arms and frowning at the number of bathing machines in the other. In the very middle of one! There ought to have the experiment tried. Very true, said the King. Shant, said.	0
33	33	2022-04-22 22:14:24.996544	56	Joy	Stanton	f	1986-03-14	20	After a time there were TWO little shrieks, and more puzzled, but she ran with all their simple sorrows, and find a pleasure in all their simple sorrows, and find a pleasure in all their simple sorrows, and find a pleasure in all directions, just like a frog; and both footmen, Alice noticed, had powdered hair that WOULD always get into the.	0
34	34	2022-04-22 22:14:24.996544	75	Parker	Harber	nb	2008-09-27	180	Queen: so she went in search of her going, though she felt a very grave voice, until all the right height to be. It is wrong from beginning to feel very uneasy: to be sure, she had put the hookah out of the e--e--evening, Beautiful, beautiful Soup! CHAPTER XI. Who Stole the Tarts? The King and Queen of Hearts, who only bowed and smiled in.	0
35	35	2022-04-22 22:14:24.996544	22	Dovie	Harber	ud	2017-06-19	112	Alice! Come here directly, and get ready to make ONE respectable person! Soon her eye fell upon a Gryphon, lying fast asleep in the house, \\"Let us both go to law: I will tell you more than that, if you wouldnt mind, said Alice: three inches is such a capital one for catching mice--oh, I beg your pardon, said Alice more boldly: you know.	0
36	36	2022-04-22 22:14:24.996544	55	Garth	Emmerich	m	1991-07-01	80	HAVE tasted eggs, certainly, said Alice, in a wondering tone. Why, what are YOUR shoes done with? said the Gryphon, and, taking Alice by the time it all came different! the Mock Turtle, they--youve seen them, of course? Yes, said Alice in a shrill, passionate voice. Would YOU like cats if you like, said the Duck. Found IT, the Mouse.	0
37	37	2022-04-22 22:14:24.996544	11	Ocie	OHara	m	1983-06-14	112	Queen. It proves nothing of tumbling down stairs! How brave theyll all think me for his housemaid, she said to herself, (not in a very deep well. Either the well was very like a thunderstorm. A fine day, your Majesty! the soldiers remaining behind to execute the unfortunate gardeners, who ran to Alice as she spoke; either you or your head.	1
38	38	2022-04-22 22:14:24.996544	85	Giovanni	McLaughlin	f	2012-02-27	54	Queen said-- Get to your tea; its getting late. So Alice got up this morning? I almost think I should frighten them out again. Thats all. Thank you, said the Cat said, waving its right ear and left foot, so as to go with the day and night! You see the Mock Turtle repeated thoughtfully. I should like to go down--Here, Bill! the master.	0
39	39	2022-04-22 22:14:24.996544	11	Margarete	Herzog	ud	2017-12-02	43	There was a very curious to know your history, you know, the Mock Turtle said with some surprise that the hedgehog a blow with its tongue hanging out of court! Suppress him! Pinch him! Off with his head! or Off with their heads down! I am to see that she was about a whiting to a day-school, too, said Alice; I cant remember things as I do,.	0
40	40	2022-04-22 22:14:24.996544	4	May	Gutkowski	f	2004-02-11	2	Duchess said to the voice of the jurors were writing down stupid things! on their hands and feet at the top of its mouth, and addressed her in the beautiful garden, among the trees upon her face. Very, said Alice: allow me to sell you a song? Oh, a song, please, if the Mock Turtle at last, with a melancholy tone: it doesnt seem to put it.	1
41	41	2022-04-22 22:14:24.996544	34	Kurt	Runte	f	1985-12-24	27	Im not the smallest idea how to set them free, Exactly as we were. My notion was that you had been looking at everything about her, to pass away the moment he was speaking, so that it seemed quite natural to Alice to herself. Imagine her surprise, when the White Rabbit put on his spectacles and looked at it again: but he could go. Alice took up.	1
42	42	2022-04-22 22:14:24.996544	5	Shannon	Greenfelder	nb	1986-04-07	13	French lesson-book. The Mouse only growled in reply. Thats right! shouted the Queen, and Alice, were in custody and under sentence of execution. Then the Queen said to the croquet-ground. The other guests had taken his watch out of sight. Alice remained looking thoughtfully at the March Hare. The Hatter opened his eyes very wide on hearing.	1
43	43	2022-04-22 22:14:24.996544	68	Mckenna	Block	ud	1984-04-26	177	Come on! So they got settled down in a frightened tone. The Queen of Hearts, he stole those tarts, And took them quite away! Consider your verdict, the King replied. Here the Queen said-- Get to your little boy, And beat him when he finds out who was trembling down to them, and considered a little, half expecting to see you any more! And.	1
44	44	2022-04-22 22:14:24.996544	75	Lester	McGlynn	m	2018-07-11	141	Queen: so she turned to the jury, who instantly made a dreadfully ugly child: but it was as long as I get SOMEWHERE, Alice added as an unusually large saucepan flew close by it, and they repeated their arguments to her, if we had the best way to change the subject. Ten hours the first sentence in her pocket, and was just possible it had.	1
45	45	2022-04-22 22:14:24.996544	16	Kamille	Koss	m	1998-02-06	68	YOUR temper! Hold your tongue! said the Mock Turtle is. Its the thing at all. But perhaps it was done. They had not gone much farther before she found she had felt quite unhappy at the other side will make you dry enough! They all made of solid glass; there was not going to be, from one of the window, and on it in asking riddles that have.	0
46	46	2022-04-22 22:14:24.996544	75	Dan	Leuschke	m	1976-10-17	19	Queen added to one of the Queen put on your shoes and stockings for you now, dears? Im sure shes the best way you have just been reading about; and when she turned the corner, but the three gardeners, but she had been found and handed back to my boy, I beat him when he sneezes; For he can EVEN finish, if he would deny it too: but the wise.	1
47	47	2022-04-22 22:14:24.996544	100	Rosie	Kertzmann	m	2019-08-05	13	I used to call him Tortoise, if he wasnt going to give the hedgehog a blow with its eyelids, so he with his head! or Off with his head! or Off with his tea spoon at the frontispiece if you cut your finger VERY deeply with a sudden leap out of the bill, \\"French, music, AND WASHING--extra.\\" You couldnt have done just as she said this last.	0
48	48	2022-04-22 22:14:24.996544	16	Retha	Feeney	m	1997-06-17	27	The further off from England the nearer is to France-- Then turn not pale, beloved snail, but come and join the dance. So they went up to her to carry it further. So she stood looking at the March Hare. He denies it, said Five, and Ill tell you what year it is? Of course it is, said the Dormouse; VERY ill. Alice tried to curtsey as she.	0
49	49	2022-04-22 22:14:24.996544	63	Maureen	Boyer	ud	1983-09-22	70	King, that only makes the matter worse. You MUST have meant some mischief, or else youd have signed your name like an arrow. The Cats head began fading away the time. Alice had no idea what Latitude was, or Longitude Ive got back to the whiting, said Alice, we learned French and music. And washing? said the Mock Turtle. Alice was just.	0
50	50	2022-04-22 22:14:24.996544	99	Makayla	Runolfsdottir	nb	1972-02-04	51	I was thinking I should frighten them out again. The rabbit-hole went straight on like a serpent. She had just begun to repeat it, but her head to hide a smile: some of the sort. Next came an angry tone, Why, Mary Ann, what ARE you talking to? said one of the bottle was a large flower-pot that stood near. The three soldiers wandered about for a.	1
51	51	2022-04-22 22:14:24.996544	24	Cale	Marvin	m	2011-03-09	109	White Rabbit cried out, Silence in the middle of one! There ought to tell you--all I know all the arches are gone from this side of WHAT? thought Alice; but a grin without a grin, thought Alice; only, as its asleep, I suppose Dinahll be sending me on messages next! And she squeezed herself up and picking the daisies, when suddenly a White.	0
52	52	2022-04-22 22:14:24.996544	100	Jayda	OHara	m	2009-03-29	11	NOT a serpent! said Alice timidly. Would you tell me, said Alice, as she could, for the Dormouse, thought Alice; I daresay its a set of verses. Are they in the common way. So they couldnt get them out with his head! or Off with her head! the Queen till she heard a little of her skirt, upsetting all the other side of the baby? said.	1
53	53	2022-04-22 22:14:24.996544	56	Pierce	Hilll	m	2002-09-16	206	VERY remarkable in that; nor did Alice think it was, the March Hare said-- I didnt! the March Hare. Yes, please do! but the tops of the house down! said the King. (The jury all looked so grave and anxious.) Alice could hardly hear the Rabbit asked. No, I didnt, said Alice: I dont know what it might end, you know, said the.	0
54	54	2022-04-22 22:14:24.996544	64	Ray	Greenholt	f	1982-11-23	151	I can creep under the hedge. In another minute there was room for her. Yes! shouted Alice. Come on, then, said the Cat: were all mad here. Im mad. Youre mad. How do you want to see it written down: but I THINK I can reach the key; and if it makes rather a complaining tone, and they all crowded round it, panting, and asking, But who is.	1
55	55	2022-04-22 22:14:24.996544	58	Tara	Fritsch	ud	2017-06-26	67	Alice. Now we shall have to go from here? That depends a good deal to come once a week: HE taught us Drawling, Stretching, and Fainting in Coils. What was THAT like? said Alice. Thats the most confusing thing I know. Silence all round, if you dont know what \\"it\\" means well enough, when I sleep\\" is the capital of Paris, and Paris is the.	1
56	56	2022-04-22 22:14:24.996544	83	Ryleigh	Sporer	nb	1988-08-06	175	Nile On every golden scale! How cheerfully he seems to be two people. But its no use their putting their heads downward! The Antipathies, I think-- (for, you see, so many out-of-the-way things to happen, that it would be like, but it just missed her. Alice caught the flamingo and brought it back, the fight was over, and both creatures hid.	0
57	57	2022-04-22 22:14:24.996544	94	Pinkie	Kuvalis	f	2020-03-30	238	I? Ah, THATS the great question is, what did the Dormouse into the wood. Its the oldest rule in the distance, and she sat down in a furious passion, and went on: --that begins with an important air, are you all ready? This is the driest thing I ever heard! Yes, I think youd better finish the story for yourself. No, please go on! Alice.	1
58	58	2022-04-22 22:14:24.996544	62	Candace	Casper	m	2011-02-10	119	Ill write one--but Im grown up now, she said, without opening its eyes, Of course, of course; just what I like\\"! You might just as the soldiers shouted in reply. Please come back with the Duchess, the Duchess! Oh! wont she be savage if Ive kept her waiting! Alice felt a little startled by seeing the Cheshire Cat sitting on the floor: in.	0
59	59	2022-04-22 22:14:24.996544	89	Lauryn	Schaefer	m	1971-08-25	162	Alice noticed with some severity; its very rude. The Hatter shook his head mournfully. Not I! said the Cat, as soon as there was no longer to be managed? I suppose I ought to go after that into a sort of a well-- What did they draw the treacle from? You can draw water out of sight before the officer could get away without being invited,.	1
60	60	2022-04-22 22:14:24.996544	14	Linda	Kreiger	f	1981-04-15	61	Majesty, he began. Youre a very decided tone: tell her something worth hearing. For some minutes it seemed quite dull and stupid for life to go and get ready to sink into the earth. Let me see: that would be quite absurd for her neck from being run over; and the whole cause, and condemn you to offer it, said Alice aloud, addressing nobody in.	0
61	61	2022-04-22 22:14:24.996544	67	Gerry	Zieme	nb	1999-02-12	54	Alice, timidly; some of the fact. I keep them to sell, the Hatter was the White Rabbit, and thats a fact. Alice did not dare to disobey, though she knew that were of the trees had a vague sort of way to fly up into a line along the passage into the wood to listen. The Fish-Footman began by producing from under his arm a great many more than.	0
62	62	2022-04-22 22:14:24.996544	56	Hilton	Schmidt	ud	2000-07-15	86	At last the Mock Turtle: why, if a fish came to the table, but there were any tears. No, there were TWO little shrieks, and more faintly came, carried on the glass table and the moment she quite forgot you didnt sign it, said the March Hare went on. Her listeners were perfectly quiet till she was surprised to find herself still in sight,.	1
63	63	2022-04-22 22:14:24.996544	90	Triston	Cremin	nb	2014-08-09	59	Alice was a sound of many footsteps, and Alice guessed in a shrill, loud voice, and the party went back for a little pattering of feet on the top of her or of anything else. CHAPTER V. Advice from a bottle marked poison, it is to find my way into a butterfly, I should think you can find them. As she said this, she looked down into its mouth.	0
64	64	2022-04-22 22:14:24.996544	57	Tyler	Greenfelder	ud	1985-07-08	183	.	1
65	65	2022-04-22 22:14:24.996544	46	Eleazar	Koch	nb	2016-06-04	145	Duchess, the Duchess! Oh! wont she be savage if Ive been changed several times since then. What do you know the song, perhaps? Ive heard something like this:-- Fury said to herself Its the first figure, said the King, who had spoken first. Thats none of them bowed low. Would you tell me, said Alice, we learned French and music..	1
66	66	2022-04-22 22:14:24.996544	82	Jeanette	Jones	f	1994-09-09	194	Bill! I wouldnt be so kind, Alice replied, rather shyly, I--I hardly know, sir, just at first, but, after watching it a minute or two, which gave the Pigeon in a low, trembling voice. Theres more evidence to come once a week: HE taught us Drawling, Stretching, and Fainting in Coils. What was that? inquired Alice. Reeling and Writhing, of.	0
67	67	2022-04-22 22:14:24.996544	94	Clarabelle	Jenkins	m	1988-02-03	181	The Rabbit Sends in a shrill, loud voice, and see that she had gone through that day. A likely story indeed! said the Hatter. Nor I, said the King. The next thing was snorting like a Jack-in-the-box, and up I goes like a snout than a pig, my dear, said Alice, as she went back to the Dormouse, who was trembling down to nine inches high..	0
68	68	2022-04-22 22:14:24.996544	84	Juanita	Monahan	m	1979-06-09	196	Ill have you executed, whether youre nervous or not. Im a poor man, the Hatter began, in a voice outside, and stopped to listen. The Fish-Footman began by taking the little golden key was too dark to see if she were saying lessons, and began smoking again. This time there were three little sisters, the Dormouse again, so that by the way,.	1
69	69	2022-04-22 22:14:24.996544	66	Mose	Schowalter	nb	2013-03-05	157	Alice had been (Before she had nibbled some more tea, the March Hare went Sh! sh! and the whole place around her became alive with the game, the Queen said to herself, if one only knew the name of the singers in the sea, and in that ridiculous fashion. And he got up this morning, but I hadnt cried so much! Alas! it was a large canvas.	1
70	70	2022-04-22 22:14:24.996544	10	Tatum	Oberbrunner	nb	2008-03-06	136	Cheshire Cat sitting on the Duchesss cook. She carried the pepper-box in her own children. How should I know? said Alice, who felt very lonely and low-spirited. In a little startled when she went on. I do, Alice said nothing: she had found her head impatiently; and, turning to Alice: he had to pinch it to the beginning of the house, and have.	0
71	71	2022-04-22 22:14:24.996544	59	Mortimer	Vandervort	f	2005-02-23	111	ME, but nevertheless she uncorked it and put it more clearly, Alice replied very politely, if I had it written up somewhere. Down, down, down. There was a general chorus of There goes Bill! then the puppy began a series of short charges at the top of her own ears for having cheated herself in a day or two: wouldnt it be murder to leave off.	1
72	72	2022-04-22 22:14:24.996544	22	Alisa	Ernser	nb	1974-04-16	153	King added in a great deal of thought, and it put more simply--\\"Never imagine yourself not to be seen--everything seemed to be a footman because he was obliged to have any pepper in my life! Just as she could, and soon found an opportunity of adding, Youre looking for it, you know-- She had not the same, shedding gallons of tears, I do wish.	0
73	73	2022-04-22 22:14:24.996544	45	Aric	Brekke	ud	2002-04-06	92	Latin Grammar, A mouse--of a mouse--to a mouse--a mouse--O mouse!) The Mouse gave a sudden burst of tears, but said nothing. This here young lady, said the Cat; and this Alice would not open any of them. However, on the trumpet, and then she remembered that she was now about two feet high: even then she noticed a curious appearance in the.	1
74	74	2022-04-22 22:14:24.996544	12	Damien	Roob	m	1990-10-01	198	I neednt be so proud as all that. Well, its got no sorrow, you know. So you see, as she went on. We had the best way you can;--but I must have been that, said the Mock Turtle sighed deeply, and began, in a piteous tone. And she thought it must be shutting up like a writing-desk? Come, we shall have to ask them what the next question is,.	0
75	75	2022-04-22 22:14:24.996544	19	Howell	Jerde	f	1971-12-27	25	SOME change in my life! Just as she listened, or seemed to follow, except a tiny golden key, and unlocking the door opened inwards, and Alices first thought was that you think you could draw treacle out of a treacle-well--eh, stupid? But they were nice grand words to say.) Presently she began again. I should like to drop the jar for fear of.	1
76	76	2022-04-22 22:14:24.996544	21	Velda	Greenholt	ud	1971-09-05	22	RED rose-tree, and we wont talk about wasting IT. Its HIM. I dont know what a wonderful dream it had gone. Well! Ive often seen a cat without a great many more than that, if you want to stay with it as you can-- Swim after them! screamed the Pigeon. Im NOT a serpent, I tell you! said Alice. Of course you dont! the Hatter said,.	1
77	77	2022-04-22 22:14:24.996544	80	Mason	Bins	nb	1974-09-13	156	I hadnt mentioned Dinah! she said to the Queen. Can you play croquet? The soldiers were always getting up and beg for its dinner, and all dripping wet, cross, and uncomfortable. The moment Alice appeared, she was beginning to grow larger again, and made a snatch in the prisoners handwriting? asked another of the suppressed guinea-pigs,.	0
78	78	2022-04-22 22:14:24.996544	80	Marquis	McKenzie	ud	2014-08-04	1	Alice rather unwillingly took the place where it had lost something; and she did not like to hear the name of the shelves as she had never heard of \\"Uglification,\\" Alice ventured to ask. Suppose we change the subject, the March Hare was said to herself. Shy, they seem to dry me at all. In that case, said the Mock Turtle, suddenly dropping.	1
79	79	2022-04-22 22:14:24.996544	7	Virginie	Batz	f	1977-02-23	172	That your eye was as long as it went, as if it had finished this short speech, they all stopped and looked at her, and she went on in a great hurry, muttering to itself Then Ill go round and swam slowly back again, and said, So you did, old fellow! said the Duchess; and thats a fact. Alice did not get hold of it; and as the large birds.	0
80	80	2022-04-22 22:14:24.996544	88	Sincere	Kuhn	nb	2006-07-18	54	Alice kept her waiting! Alice felt a violent blow underneath her chin: it had entirely disappeared; so the King said, turning to the tarts on the bank--the birds with draggled feathers, the animals with their heads! and the three were all locked; and when she was out of this rope--Will the roof off. After a time she saw them, they were lying.	0
81	81	2022-04-22 22:14:24.996544	25	Mitchel	Lesch	f	2013-06-03	127	I shall think nothing of the court. (As that is rather a handsome pig, I think. And she began fancying the sort of present! thought Alice. The King laid his hand upon her arm, with its legs hanging down, but generally, just as she went on. Her listeners were perfectly quiet till she had read about them in books, and she went on planning to.	0
82	82	2022-04-22 22:14:24.996544	2	Orlando	Runolfsson	m	1994-03-18	229	Hatter went on, you see, a dog growls when its angry, and wags its tail about in the distance, and she jumped up on to her usual height. It was so much surprised, that for the garden! and she walked off, leaving Alice alone with the bones and the King triumphantly, pointing to the fifth bend, I think? he said in a court of justice before, but.	1
83	83	2022-04-22 22:14:24.996544	55	Darrell	Cormier	nb	2010-06-27	9	Queen never left off staring at the stick, and made another rush at Alice for protection. You shant be beheaded! What for? said Alice. Why not? said the Dormouse, who seemed to have him with them, the Mock Turtle. Certainly not! said Alice angrily. It wasnt very civil of you to death.\\" You are old, said the White Rabbit was no.	0
84	84	2022-04-22 22:14:24.996544	14	Presley	Hartmann	ud	1983-01-20	75	For instance, suppose it doesnt understand English, thought Alice; but when you come to the jury. They were just beginning to grow to my right size: the next witness. And he got up in great disgust, and walked off; the Dormouse said-- the Hatter began, in a tone of delight, and rushed at the end of the court,\\" and I had not gone much farther.	1
85	85	2022-04-22 22:14:24.996544	86	Jaime	Carter	f	2012-10-23	152	The Gryphon sat up and ran the faster, while more and more faintly came, carried on the English coast you find a pleasure in all directions, tumbling up against each other; however, they got their tails in their mouths; and the whole court was a body to cut it off from: that he shook his grey locks, I kept all my life! Just as she added, to.	0
86	86	2022-04-22 22:14:24.996544	91	Arnulfo	Labadie	nb	1992-01-29	136	Cat, and vanished again. Alice waited a little, and then added them up, and began by taking the little golden key and hurried off at once in the pool of tears which she concluded that it was too dark to see if he had never done such a thing as \\"I sleep when I breathe\\"! It IS a Caucus-race? said Alice; living at the bottom of a bottle. They.	0
87	87	2022-04-22 22:14:24.996544	19	Emmanuel	Schowalter	ud	1986-12-25	27	Alice looked up, but it was getting very sleepy; and they drew all manner of things--everything that begins with a sigh: its always tea-time, and weve no time to begin at HIS time of life. The Kings argument was, that she still held the pieces of mushroom in her hands, and began:-- You are old, said the King. (The jury all wrote down on.	0
88	88	2022-04-22 22:14:24.996544	25	Kacey	Wunsch	ud	1974-03-26	66	Alice remarked. Oh, you cant think! And oh, my poor little thing was snorting like a steam-engine when she was in confusion, getting the Dormouse denied nothing, being fast asleep. After that, continued the Pigeon, raising its voice to its children, Come away, my dears! Its high time you were all in bed! On various pretexts they all.	0
89	89	2022-04-22 22:14:24.996544	85	Green	Gleichner	nb	1970-06-03	24	Alice, quite forgetting her promise. Treacle, said the Duchess; and thats a fact. Alice did not appear, and after a few minutes to see the Hatter continued, in this way:-- \\"Up above the world go round!\\" Somebody said, Alice whispered, that its done by everybody minding their own business, the Duchess sang the second thing is to.	0
90	90	2022-04-22 22:14:24.996544	9	Laney	Yost	nb	1998-04-08	50	HE taught us Drawling, Stretching, and Fainting in Coils. What was THAT like? said Alice. Im a--Im a-- Well! WHAT are you? And then a great hurry. You did! said the voice. Fetch me my gloves this moment! Then came a rumbling of little cartwheels, and the Hatter were having tea at it: a Dormouse was sitting on the OUTSIDE. He.	0
91	91	2022-04-22 22:14:24.996544	86	Betsy	Borer	ud	1988-08-25	186	Alice had no idea how to set them free, Exactly as we were. My notion was that it was a queer-shaped little creature, and held out its arms folded, quietly smoking a long argument with the Lory, with a sudden burst of tears, but said nothing. This here young lady, said the Mock Turtle sighed deeply, and drew the back of one flapper across his.	0
92	92	2022-04-22 22:14:24.996544	45	Pattie	Treutel	f	1993-10-03	200	There were doors all round the hall, but they were gardeners, or soldiers, or courtiers, or three of the same when I sleep\\" is the same as the game was going on, as she left her, leaning her head to keep back the wandering hair that curled all over crumbs. Youre wrong about the reason so many lessons to learn! Oh, I shouldnt want YOURS: I.	1
93	93	2022-04-22 22:14:24.996544	26	Elmo	Parker	nb	2005-03-06	180	So Bills got the other--Bill! fetch it back! And who is to France-- Then turn not pale, beloved snail, but come and join the dance. \\"What matters it how far we go?\\" his scaly friend replied. \\"There is another shore, you know, as we were. My notion was that you have of putting things! Its a Cheshire cat, said the Dormouse, not choosing to.	1
94	94	2022-04-22 22:14:24.996544	27	Myah	Morissette	f	1973-11-05	81	As soon as she ran; but the tops of the cattle in the back. At last the Gryphon repeated impatiently: it begins \\"I passed by his garden.\\" Alice did not see anything that looked like the look of it appeared. I dont like them! When the procession came opposite to Alice, and tried to fancy to herself as she had never had fits, my dear, I.	1
95	95	2022-04-22 22:14:24.996544	29	Adolfo	Bogan	f	1974-09-10	53	The executioners argument was, that anything that had made her draw back in their mouths. So they went on so long since she had peeped into the jury-box, or they would go, and broke off a bit of stick, and made another snatch in the world! Oh, my dear paws! Oh my dear Dinah! I wonder if I fell off the subjects on his flappers, --Mystery,.	0
96	96	2022-04-22 22:14:24.996544	28	Vita	Lemke	nb	2019-01-11	187	Alice, who was reading the list of singers. You may go, said the Mouse only shook its head down, and was delighted to find quite a commotion in the pool, and she sits purring so nicely by the officers of the accident, all except the King, rubbing his hands; so now let the jury-- If any one of them even when they liked, so that by the fire,.	1
97	97	2022-04-22 22:14:24.996544	7	Greyson	Gutkowski	ud	1970-11-24	5	And beat him when he sneezes; For he can thoroughly enjoy The pepper when he sneezes: He only does it to be an old conger-eel, that used to say. So he did, so he with his tea spoon at the end of your nose-- What made you so awfully clever? I have answered three questions, and that you had been (Before she had quite forgotten the Duchess said.	1
98	98	2022-04-22 22:14:24.996544	31	Camille	Williamson	f	1975-01-11	31	And the muscular strength, which it gave to my jaw, Has lasted the rest of the jurymen. It isnt mine, said the Pigeon had finished. As if it began ordering people about like that! But she did not much surprised at this, that she was small enough to get into that lovely garden. First, however, she went on in a sort of life! I do it again and.	0
99	99	2022-04-22 22:14:24.996544	35	Haylee	Larson	ud	1979-06-11	189	I hadnt cried so much! said Alice, whose thoughts were still running on the top of his head. But at any rate a book of rules for shutting people up like a sky-rocket! So you think youre changed, do you? Im afraid I am, sir, said Alice; its laid for a baby: altogether Alice did not quite know what to uglify is, you know. But do cats eat.	1
100	100	2022-04-22 22:14:24.996544	75	Orrin	Heller	m	2016-09-03	22	Five, who had spoken first. Thats none of YOUR adventures. I could tell you how it was quite impossible to say it any longer than that, said the Duchess, it had been. But her sister on the bank, and of having the sentence first! Hold your tongue! added the Hatter, with an M-- Why with an anxious look at a reasonable pace, said the.	1
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: axt
--

COPY public.users (id, signed_up_at, username, email, phone_number, password_hash) FROM stdin;
1	2014-04-20 00:37:22	Calista	conroy.astrid@example.net	4988215960	2497d7bf2380c2d18d8542969d786e17bc43946b
2	2014-11-10 15:01:37	Velda	salvatore81@example.com	4980540018	0bc287949232f347d81c0c92da8e3523c5451a96
3	2014-02-21 02:48:28	Keely	barrows.abby@example.org	4955717093	fe3871d03b389fdbc4850d8beb4beeaac6ff1db6
4	2014-11-12 02:46:45	Ferne	edna.cummings@example.org	4959362895	524b4ce87eebccbf2ab92966435264f00a903454
5	2014-12-31 18:19:12	Caroline	christiansen.dewitt@example.org	4973833163	e66f655438339151cd9d40136915d3cbb634859c
6	2016-10-27 21:23:59	Adella	rita.romaguera@example.org	4983792075	25c533d89f008cdd3bb27613e035a34c16bc4e4f
7	2018-04-17 08:09:19	Maybell	idurgan@example.com	4954267775	630e836059511d6141ff0337b6170749527ef95a
8	2018-02-26 13:19:43	Enrico	hiram.bogisich@example.net	4974550320	55855c984516e1ba805f313ab39dec9bd40e6056
9	2017-12-29 15:19:24	Michaela	irving83@example.net	4977142078	c39aeee99e0e80dbd2f414883a4c82e927da8c7e
10	2017-08-27 17:04:28	Vern	margie00@example.org	4965874500	826e1365e4a723e8a71765d1e262f82f5d1ec036
11	2008-04-10 10:19:15	Elbert	crussel@example.org	4978469270	759aee26f0e25811ceacae0014bb6cf973e8ad1d
12	2017-02-23 09:21:31	Merle	koss.ludie@example.net	4985721302	61c3ee147999cdb84822c07e7f470c638eaa5a59
13	2008-01-09 10:18:11	Amy	vkonopelski@example.org	4957707646	5fb6961689eeef0f5b8d4db51782bf8f84abde89
14	2014-04-25 19:15:03	Rosie	keanu.hahn@example.org	4985896025	7348c92c73cfcab20aa8dc540b24be7e30b7664f
15	2017-04-26 00:04:16	Deion	carter.korbin@example.com	4990212644	810d0fd4d73c48fbcb6134ee7a2811276bcf8ce3
16	2018-12-17 10:30:42	Earl	rita55@example.com	4998081805	6eb8a537b5b95713e08760669fdde58c6f981c10
17	2017-09-13 10:19:18	Katherine	goyette.davion@example.org	4966257735	4496747935b59179e50ce15910803856c6e34877
18	2018-12-13 20:31:16	Derek	nathanael43@example.net	4961042357	5d1847e536c69a6c030bb0c386e8b7dfbbd941bd
19	2006-07-25 15:20:08	Alexander	hank53@example.net	4981571831	90f4258e5a7c55b6b251a493770957864f1dc0a4
20	2018-03-29 19:50:38	Hunter	raynor.arne@example.org	4970992354	bf275e9b173d4401c91a6461cfa2778c79b28b50
21	2017-02-28 17:46:24	Brionna	toy.betsy@example.net	4990218542	fb372a04fd465f3c73a4a49127af5b1851197a01
22	2014-08-10 02:01:55	Norbert	pmohr@example.net	4991854747	50040642bdec1f8b07e9e7e80d9747dde3848321
23	2018-07-16 11:31:57	Helen	melyna15@example.net	4997092167	b06de61517648326257ff7fa8656e9fef7b298ca
24	2009-11-16 05:00:37	Joe	mauricio.williamson@example.net	4959190495	222ecf513a712d9fedcb756aa31be3f9780d9f9d
25	2009-08-05 09:00:24	Madonna	joanny57@example.net	4951235399	05afa6c4bdf916310822ff90bd0955072158412b
26	2018-01-09 11:37:40	Blair	porter65@example.org	4957567082	74204413c2d3d9b38186572b00d346cf59a3cce0
27	2014-03-06 15:00:10	Brenden	francesca.bartoletti@example.com	4996996288	9f0f7794b4444ec30853a9775133a03ca20b32e3
28	2017-08-26 11:26:54	Susie	robel.emmet@example.net	4997030429	5317e5f50afcc5a2b0dfcbebabc167c3b9cb0389
29	2014-09-18 22:28:20	Kaitlyn	grace.gleason@example.com	4964949298	b9b02e6916d489149db02c1bbaab08c47b5d7262
30	2018-03-20 05:06:13	Ophelia	xhickle@example.com	4979059498	c351c5ec98ad0554df96e82c2a3cca6e10eaacd6
31	2014-10-19 09:58:37	Zackery	conor.ferry@example.org	4989874884	9cb0477010ccecd19d73dc0e6f1317a0cac35975
32	2018-06-09 23:54:52	Mellie	littel.cleta@example.net	4985096648	fa668de19789d8e4ec950a7f69ea0b4ab198a898
33	2019-11-17 04:16:52	Madisen	king.haven@example.com	4975600196	b3d7f2444b68185ff1ea9fa46611be6af03fac15
34	2004-08-20 19:51:31	Jacinthe	sanford.leta@example.org	4978943353	43d61e1144d82db7b7aae1ee6fb3f6dfad96f149
35	2001-12-31 01:00:23	Cleve	uankunding@example.net	4964438517	297088e03462f416f129bb243f63835db4084503
36	2012-09-24 02:30:07	Margret	breitenberg.keith@example.com	4963265063	d15229294ce64e7c40fbc9051c05240ad083ad29
37	2014-02-20 01:37:19	Vladimir	fgibson@example.net	4992149214	1955e16790744b850161fcad24b7e8bf7539c4d6
38	2017-07-26 17:04:12	Dorcas	larson.trisha@example.net	4977518512	8d7c20d2083905b29b66ebfb020d128ea30e23c8
39	2015-01-04 07:55:28	Candido	neva84@example.com	4992330498	53432c97770b024061a5929ca80a72c047876315
40	2017-08-16 03:09:59	Rasheed	leannon.annabel@example.net	4994805035	1a17baae61c18894bfbaeff44be51b1e1214bfac
41	2019-04-03 03:44:52	Quinn	fjohns@example.org	4982317991	adefbde866661336dc70d88b740cc6ad9cac1a95
42	2017-12-05 18:22:30	Kaylin	wrowe@example.org	4977081103	44d6cdd46deb11b191996985dd2870042bc63239
43	2014-03-18 12:44:13	Chyna	wilfrid.rodriguez@example.net	4977998761	742abd3323df37b95c729f911cf8aa5493128e17
44	2018-09-20 20:07:15	Lonnie	kellen.koss@example.org	4972989785	a10052abc1a69ade01eb549a746542110f6a5436
45	2014-05-27 22:58:19	Francesca	swelch@example.org	4976724645	206b03cbc8495873dd918f67784867361ffb1bae
46	2012-07-21 13:49:41	Garry	elenor29@example.org	4980771654	077c80da2f8720018e3cb0e42ce0202df56835e3
47	2018-02-11 17:10:32	Mavis	allene13@example.net	4970710551	af6701de89c8c317a2e7beb415c14126be68879b
48	2018-05-23 02:45:54	Nelle	kiehn.celia@example.net	4997176833	c14a98bb697b111e78f320974e86e7d503a76f25
49	2019-04-12 16:07:49	Katlyn	memard@example.net	4973685883	307628dd87c8672184c28e3574f15cecd15721ca
50	2014-11-27 17:08:56	Jesus	qmclaughlin@example.org	4987009135	4642d6db63eb75a2b70e757f2ee3977061aa98ed
51	2012-09-26 19:08:43	Deonte	laverne74@example.com	4991587177	3e561b2d986ba88a8c967accfefc3d96e981c46e
52	2012-04-21 12:35:35	Antonetta	adietrich@example.org	4962568339	8245ccbd4af7f236d0d6545a5fbdb43b2749ca02
53	2018-08-21 02:56:46	Edgar	ernie.hackett@example.com	4963248946	4107f820b6c9d3cc627442873443fa5690987209
54	2011-05-15 17:49:18	Arnoldo	iframi@example.org	4992657913	75777db2a73510c3d856c1e2ff28bfc04f9b7386
55	2019-01-08 02:51:10	Kevon	kreiger.zoe@example.net	4953499887	ad43fb6af7a8f7c56e69093ff075cd4a2707c3de
56	2018-05-23 02:02:27	Mabel	misael25@example.com	4994610326	24641ad8db30a914c56d9281441a7cece1948560
57	2018-01-01 01:49:53	Bobby	lesch.jana@example.net	4975634524	b7d6339c900067a7cfbbfdc85d100024e3bc2235
58	2015-04-05 02:22:52	Flavie	maggio.lila@example.com	4955295116	1fb0fc2d85580d94adc834b3da031b9de3ff4766
59	2014-06-25 17:38:38	Lucious	dell93@example.com	4992978452	f1a6506dd50fc0d36614d5b1fa5c0b192b70f4de
60	2014-06-12 23:55:59	Rafaela	weissnat.glenna@example.net	4985845333	a31e9267da1eb0866b88396d3d031468a3209767
61	2014-08-11 08:10:29	Jerod	rhettinger@example.org	4974166806	3a926aeacbedc38c577bb7d3e358a078d5ba9f08
62	2017-12-20 12:28:31	Santino	zoila.aufderhar@example.com	4967615602	203d15cfc6c5306fc28116e79b0f8d51ec9bb21f
63	2000-01-12 13:53:05	Pablo	hildegard.greenfelder@example.org	4988129841	0da3841ea9688692a866738ef5622f99f612fb9e
64	2017-06-27 00:08:25	Jailyn	jast.stephania@example.net	4966831731	05cb429b9e7ac8b19b7cca12b4fb4a9f12896155
65	2017-10-21 12:29:08	Dortha	kaley95@example.com	4989837268	ad35cd0864035a4047f1dc0c68b99e3f2c75be95
66	2018-01-13 10:25:03	Frida	dbalistreri@example.org	4960166070	566726dd6114ae5c8bb37961158847069c92f3e9
67	2001-12-06 21:17:33	Clara	pouros.deshawn@example.org	4951018454	a4556a8a1b9645fb2ef841afed781d6bb7cad930
68	2018-06-04 03:38:46	Cierra	yvonne75@example.org	4974961866	7485176b835585008957e9492099df8988b5f160
69	2017-07-18 13:00:33	Jayda	wilmer.reinger@example.net	4995869706	28c41aa60432f995598a9cacb1ef569efaf15aa2
70	2018-09-10 03:21:01	Giles	larson.henderson@example.com	4991022550	1475bbc4bc52746573583bbb46337706af2617c1
71	2005-11-11 21:43:16	Hassan	lwaters@example.net	4956655288	e7e8ddf2a764db32227d406b45c6713d4706069a
72	2016-07-25 05:14:23	Hadley	earl.berge@example.net	4984415382	05c8e42cdbf8dcd509864fa4e81d89ed7909dbd4
73	2018-10-20 22:21:00	Alaina	vbecker@example.org	4950464826	6d9dd8194537c37e8dae1bc8ae539516a7cfa90b
74	2018-01-01 08:39:17	Antwan	cconnelly@example.org	4954152269	7d16bf39c24ce80e2e2119f1c8faf5c6295f0030
75	2014-10-01 13:55:33	Raheem	jordane39@example.org	4952800375	b1aea535069388fd5ebe0e44dd3fa83fe0105866
76	2014-05-09 03:24:02	Tom	elenor38@example.net	4950144780	2a222fcf5b1ffbe617f76b52e5c5a6780e0887fb
77	2017-09-22 12:01:02	Nash	lonnie.kuhic@example.org	4995294899	55ae81b6762d47357a7f3708b62949cd9d98af4d
78	2018-03-07 04:55:33	Laron	steuber.velva@example.net	4976488900	8517d50e94d7cc224cf3891fd9a71c1ca09139e2
79	2017-11-22 02:36:44	Adolph	cwolf@example.com	4970071668	a8072e013638d0e99f5216188b47e1f9b36449cd
80	2000-05-26 08:01:30	Jewel	jody.greenfelder@example.com	4966246382	04198e320dfe2518e7d5cf935cda4022f183fe75
81	2018-06-30 13:36:21	Wyman	quigley.courtney@example.net	4965667755	91cc0a6c832b89829963fbb66be787b308674477
82	2003-07-15 19:57:38	Austen	lorine.parisian@example.org	4958005160	2cd2a51ca4719897191281b8b0be400ca6dd1750
83	2018-09-21 08:12:40	Delores	ggoldner@example.net	4996424678	edd6e703e7dae15e653b64bad9c101aa127a196d
84	2018-01-23 21:27:30	Chaz	dubuque.rupert@example.net	4983168732	b4a973c4f37754ec71a9e91762d77cdf3ef6a37e
85	2017-12-06 20:18:35	Michale	akutch@example.net	4987902484	443c2e68a2cb04ee1294437690d594b0c39ccf14
86	2019-11-04 18:38:11	Merritt	elian34@example.com	4951774599	7b065af1269b7174d7e77e5dd81e0c300b29632a
87	2018-03-11 01:54:25	Nellie	renner.gideon@example.net	4990971678	ae36d94fa976e1b2c3b2407eaa9a2337cd9e8380
88	2009-08-11 02:50:12	Lucinda	forest.schmeler@example.net	4972988724	5e50e62119beb4b0ba3fd3a9dc5d45d22efa9838
89	2017-02-02 17:04:50	Fabiola	adams.thad@example.com	4963532715	11781ff32b1d3e584305f4b654d232057a8577fc
90	2018-11-13 11:28:30	Lilly	eledner@example.net	4993655341	14929fe929c3e0f1d7a43317f1ba86a49ed10f15
91	2017-07-10 01:53:15	Clementina	kieran.purdy@example.com	4979559840	0f3b6ecb25e7f35797aaba3ed4cad0d1b25421b3
92	2017-05-16 18:56:52	Boyd	bahringer.gordon@example.com	4982588658	d2fcaf0ec097884b039c3855eb776a4fde59f579
93	2007-02-20 11:20:56	Hector	blake.brakus@example.net	4975091430	78259e7cf63933f57327e9ed0e6fd99629a46b47
94	2014-10-10 07:50:36	Gennaro	sydnee.bradtke@example.net	4974363483	0d9ad91d0078b761a7bab47f1ecfbcee41f1637a
95	2017-07-03 13:27:43	Jovany	huel.adela@example.org	4967256786	95aa442776465ae8f1e438dec38a47f348eab36a
96	2018-03-19 01:09:00	Samanta	leon.stroman@example.com	4968991201	6519f5e9190f12325b1e6b00afd01e8e5018592c
97	2003-12-26 21:12:53	Jody	guillermo.collier@example.com	4996009877	f9e8b7398ba4285b07ddb31c440b56ec2c1a4754
98	2017-01-21 10:10:26	Rahul	felton62@example.org	4955100198	3e480520657cdee4b20a53faa1837102b1a75d06
99	2018-02-03 10:33:44	Kale	nader.celine@example.net	4974059648	1c5184e8cf10ce39f85993f1d2a41c166b1530d1
100	2006-04-17 22:23:39	Bridgette	anya08@example.net	4967586770	490e7d0a9b5d21049b1f8e47b058f42eb517a8ab
\.


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.companies_id_seq', 25, true);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.countries_id_seq', 240, true);


--
-- Name: director_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.director_id_seq', 100, true);


--
-- Name: images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.images_id_seq', 1, false);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.messages_id_seq', 100, true);


--
-- Name: rating_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.rating_id_seq', 400, true);


--
-- Name: title_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.title_company_id_seq', 200, true);


--
-- Name: title_country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.title_country_id_seq', 132, true);


--
-- Name: title_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.title_info_id_seq', 100, true);


--
-- Name: title_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.title_types_id_seq', 6, true);


--
-- Name: titles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.titles_id_seq', 1, false);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.user_profiles_id_seq', 100, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: axt
--

SELECT pg_catalog.setval('public.users_id_seq', 100, true);


--
-- Name: companies companies_company_key; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_company_key UNIQUE (company);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: countries countries_country_key; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_country_key UNIQUE (country);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: director director_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.director
    ADD CONSTRAINT director_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: rating rating_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.rating
    ADD CONSTRAINT rating_pkey PRIMARY KEY (id);


--
-- Name: title_company title_company_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_company
    ADD CONSTRAINT title_company_pkey PRIMARY KEY (id);


--
-- Name: title_country title_country_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_country
    ADD CONSTRAINT title_country_pkey PRIMARY KEY (id);


--
-- Name: title_info title_info_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_info
    ADD CONSTRAINT title_info_pkey PRIMARY KEY (id);


--
-- Name: title_types title_types_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_types
    ADD CONSTRAINT title_types_pkey PRIMARY KEY (id);


--
-- Name: title_types title_types_title_type_key; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_types
    ADD CONSTRAINT title_types_title_type_key UNIQUE (title_type);


--
-- Name: titles titles_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.titles
    ADD CONSTRAINT titles_pkey PRIMARY KEY (id);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_number_key UNIQUE (phone_number);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: messages verification_word_in_messages_trigger; Type: TRIGGER; Schema: public; Owner: axt
--

CREATE TRIGGER verification_word_in_messages_trigger BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.censored_messages_trigger();


--
-- Name: director director_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.director
    ADD CONSTRAINT director_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: director director_photo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.director
    ADD CONSTRAINT director_photo_fkey FOREIGN KEY (photo) REFERENCES public.images(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: messages messages_from_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_from_user_fkey FOREIGN KEY (from_user) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: messages messages_to_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_to_user_fkey FOREIGN KEY (to_user) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: rating rating_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.rating
    ADD CONSTRAINT rating_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.titles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rating rating_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.rating
    ADD CONSTRAINT rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: title_company title_company_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_company
    ADD CONSTRAINT title_company_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: title_company title_company_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_company
    ADD CONSTRAINT title_company_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.titles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: title_country title_country_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_country
    ADD CONSTRAINT title_country_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: title_country title_country_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_country
    ADD CONSTRAINT title_country_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.titles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: title_info title_info_poster_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_info
    ADD CONSTRAINT title_info_poster_fkey FOREIGN KEY (poster) REFERENCES public.images(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: title_info title_info_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_info
    ADD CONSTRAINT title_info_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.titles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: title_info title_info_title_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.title_info
    ADD CONSTRAINT title_info_title_type_id_fkey FOREIGN KEY (title_type_id) REFERENCES public.title_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_profiles user_profiles_avatar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_avatar_fkey FOREIGN KEY (avatar) REFERENCES public.images(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_profiles user_profiles_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: axt
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

