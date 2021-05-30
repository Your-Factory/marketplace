--
-- PostgreSQL database dump
--

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

CREATE PROCEDURE public.add_image_format(f_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    insert into image_formats(name) values (f_name);
END
$$;


CREATE PROCEDURE public.add_images_to_model(model_id integer, m_images bytea[], m_images_formats text[])
    LANGUAGE plpgsql
    AS $$
DECLARE
    image_number int;
    tmp_id int;
    formats_id int[];
BEGIN
    select array_agg(model_formats.id) from model_formats where model_formats.name = ANY(m_images_formats) into formats_id;
    for image_number in 1 .. array_length(m_images, 1)
        loop
            select image_formats.id from image_formats where name = m_images_formats[image_number] into tmp_id;
            formats_id[image_number] = tmp_id;
        end loop;

    for image_number in 1 .. array_length(m_images, 1)
        loop
            insert into model_images(id_model, image_file, image_format_id)
            values (model_id, m_images[image_number], formats_id[image_number]);
        end loop;
END
$$;

CREATE PROCEDURE public.add_material(m_name text, m_base_cost real)
    LANGUAGE plpgsql
    AS $$
BEGIN
    insert into material_types(name, base_cost) values (m_name, m_base_cost);
END
$$;


CREATE PROCEDURE public.add_model(m_name text, m_description text, m_model_file bytea, m_author_id integer, m_model_format text, m_images bytea[], m_images_formats text[])
    LANGUAGE plpgsql
    AS $$
DECLARE
    model_id int;
    format_id int;
BEGIN
    select model_formats.id from model_formats where model_formats.name = m_model_format into format_id;
    call add_model_information(m_name, m_description,
                               m_model_file, m_author_id, format_id);
    select currval(pg_get_serial_sequence('models', 'id')) into model_id;
    call add_images_to_model(model_id, m_images, m_images_formats);
END;
$$;


CREATE PROCEDURE public.add_model_format(f_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    insert into model_formats(name) values (f_name);
END
$$;


CREATE PROCEDURE public.add_model_information(m_name text, m_description text, m_model_file bytea, m_author_id integer, m_model_format_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    insert into models(name, description, model_file, author_id, model_format_id)
    values (m_name, m_description, m_model_file, m_author_id, m_model_format_id);
END
$$;


CREATE PROCEDURE public.add_tags_images_materials_to_model(model_id integer, m_tags integer[], m_images bytea[], m_images_descriptions text[], m_images_formats_id integer[], m_materials integer[])
    LANGUAGE plpgsql
    AS $$
DECLARE
    image_number int;
    tag_id       int;
    material_id  int;
BEGIN
    foreach tag_id in array m_tags
        loop
            insert into model_tags(id_model, id_tag) values (model_id, tag_id);
        end loop;

    for image_number in 1 .. array_length(m_images, 1)
        loop
            insert into model_images(id_model, description, image_file, image_format_id)
            values (model_id, m_images_descriptions[image_number], m_images[image_number],
                    m_images_formats_id[image_number]);
        end loop;

    foreach material_id in array m_materials
        loop
            insert into model_materials(id_model, id_material) values (model_id, material_id);
        end loop;
END
$$;

CREATE PROCEDURE public.add_user(u_login text, u_email text, u_salt text, u_password_hash text)
    LANGUAGE sql
    AS $$
INSERT INTO users(login, email, salt, password_hash)
VALUES (u_login, u_email, u_salt, u_password_hash);
$$;


CREATE FUNCTION public.check_user_authentication(u_login text, u_password_hash text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    u_id int;
BEGIN
    SELECT id
    FROM public.users AS users
    WHERE users.login = u_login
      AND users.password_hash = u_password_hash
    INTO u_id;
    RETURN u_id;
END
$$;


CREATE PROCEDURE public.create_tag(t_name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    insert into tags(name) values (t_name);
END
$$;


CREATE FUNCTION public.get_model(m_id integer, OUT m_name text, OUT m_description text, OUT m_model_file bytea, OUT m_model_type text, OUT m_images bytea[], OUT m_image_types text[]) RETURNS record
    LANGUAGE plpgsql
    AS $$
BEGIN
    select models.name, models.description, models.model_file, model_formats.name
    into m_name, m_description, m_model_file, m_model_type
    from models join model_formats on model_formats.id = models.model_format_id
    where models.id = m_id;

    select array_agg(image_file::bytea), array_agg(image_formats.name::text)
    into m_images, m_image_types
    from model_images join image_formats on model_images.image_format_id = image_formats.id
    where model_images.id_model = m_id;
END
$$;

CREATE FUNCTION public.get_model_previews() RETURNS TABLE(id integer, name text, preview bytea, format text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query select distinct on (models.id) models.id, models.name, model_images.image_file, image_formats.name
                 from models
                 join model_images on models.id = model_images.id_model
                 join image_formats on model_images.image_format_id = image_formats.id
                 order by models.id;
END
$$;


CREATE FUNCTION public.get_tags() RETURNS TABLE(id integer, name text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query select * from tags;
END
$$;


CREATE FUNCTION public.get_user_salt(u_login text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    usalt text;
BEGIN
    SELECT users.salt
    FROM public.users AS users
    WHERE users.login = u_login
    INTO usalt;
    RETURN usalt;
END
$$;


SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE public.image_formats (
    id integer NOT NULL,
    name text NOT NULL
);


CREATE SEQUENCE public.image_formats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.image_formats_id_seq OWNED BY public.image_formats.id;

CREATE TABLE public.material_types (
    id integer NOT NULL,
    name text NOT NULL,
    base_cost real
);

CREATE SEQUENCE public.material_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.material_types_id_seq OWNED BY public.material_types.id;

CREATE TABLE public.model_formats (
    id integer NOT NULL,
    name text NOT NULL
);


CREATE SEQUENCE public.model_formats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.model_formats_id_seq OWNED BY public.model_formats.id;

CREATE TABLE public.model_images (
    id_model integer NOT NULL,
    id_image integer NOT NULL,
    image_file bytea NOT NULL,
    image_format_id integer NOT NULL
);


CREATE SEQUENCE public.model_images_id_image_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.model_images_id_image_seq OWNED BY public.model_images.id_image;

CREATE TABLE public.model_materials (
    id_model integer NOT NULL,
    id_material integer
);


CREATE TABLE public.model_tags (
    id_model integer NOT NULL,
    id_tag integer NOT NULL
);


CREATE TABLE public.models (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    model_file bytea NOT NULL,
    author_id integer NOT NULL,
    model_format_id integer NOT NULL
);

CREATE SEQUENCE public.models_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.models_id_seq OWNED BY public.models.id;

CREATE TABLE public.tags (
    id integer NOT NULL,
    name text NOT NULL
);

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


CREATE TABLE public.users (
    id integer NOT NULL,
    login text NOT NULL,
    email text NOT NULL,
    salt text NOT NULL,
    password_hash text NOT NULL
);

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

ALTER TABLE ONLY public.image_formats ALTER COLUMN id SET DEFAULT nextval('public.image_formats_id_seq'::regclass);
ALTER TABLE ONLY public.material_types ALTER COLUMN id SET DEFAULT nextval('public.material_types_id_seq'::regclass);
ALTER TABLE ONLY public.model_formats ALTER COLUMN id SET DEFAULT nextval('public.model_formats_id_seq'::regclass);
ALTER TABLE ONLY public.model_images ALTER COLUMN id_image SET DEFAULT nextval('public.model_images_id_image_seq'::regclass);
ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.models_id_seq'::regclass);
ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

INSERT INTO public.image_formats (id, name) VALUES (1, '.png');
INSERT INTO public.image_formats (id, name) VALUES (2, '.jpg');
INSERT INTO public.model_formats (id, name) VALUES (1, '.obj');

-- SELECT pg_catalog.setval('public.image_formats_id_seq', 2, true);
-- SELECT pg_catalog.setval('public.material_types_id_seq', 1, false);
-- SELECT pg_catalog.setval('public.model_formats_id_seq', 1, true);
-- SELECT pg_catalog.setval('public.model_images_id_image_seq', 18, true);
-- SELECT pg_catalog.setval('public.tags_id_seq', 1, false);
-- SELECT pg_catalog.setval('public.users_id_seq', 44, true);

ALTER TABLE ONLY public.image_formats
    ADD CONSTRAINT image_formats_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.material_types
    ADD CONSTRAINT material_types_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.model_formats
    ADD CONSTRAINT model_formats_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.model_images
    ADD CONSTRAINT model_images_pk PRIMARY KEY (id_image);

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pk PRIMARY KEY (id);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX image_formats_name_uindex ON public.image_formats USING btree (name);
CREATE UNIQUE INDEX material_types_name_uindex ON public.material_types USING btree (name);
CREATE UNIQUE INDEX model_formats_id_uindex ON public.model_formats USING btree (id);
CREATE UNIQUE INDEX model_images_id_image_uindex ON public.model_images USING btree (id_image);
CREATE UNIQUE INDEX users_email_uindex ON public.users USING btree (email);
CREATE UNIQUE INDEX users_id_uindex ON public.users USING btree (id);
CREATE UNIQUE INDEX users_login_uindex ON public.users USING btree (login);

ALTER TABLE ONLY public.model_images
    ADD CONSTRAINT model_images_image_formats_id_fk FOREIGN KEY (image_format_id) REFERENCES public.image_formats(id);

ALTER TABLE ONLY public.model_images
    ADD CONSTRAINT model_images_models_id_fk FOREIGN KEY (id_model) REFERENCES public.models(id);

ALTER TABLE ONLY public.model_materials
    ADD CONSTRAINT model_materials_material_types_id_fk FOREIGN KEY (id_material) REFERENCES public.material_types(id);

ALTER TABLE ONLY public.model_materials
    ADD CONSTRAINT model_materials_models_id_fk FOREIGN KEY (id_model) REFERENCES public.models(id);

ALTER TABLE ONLY public.model_tags
    ADD CONSTRAINT model_tags_models_id_fk FOREIGN KEY (id_model) REFERENCES public.models(id);

ALTER TABLE ONLY public.model_tags
    ADD CONSTRAINT model_tags_tags_id_fk FOREIGN KEY (id_tag) REFERENCES public.tags(id);

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_model_formats_id_fk FOREIGN KEY (model_format_id) REFERENCES public.model_formats(id);

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_users_id_fk FOREIGN KEY (author_id) REFERENCES public.users(id);
