create table image_formats
(
    id   serial not null
        constraint image_formats_pk
            primary key,
    name text   not null
);

create table material_types
(
    id        serial not null
        constraint material_types_pk
            primary key,
    name      text   not null,
    base_cost real
);

create unique index material_types_name_uindex
    on material_types (name);

create table model_formats
(
    id   serial not null
        constraint model_formats_pk
            primary key,
    name text   not null
);

create unique index model_formats_id_uindex
    on model_formats (id);

create table tags
(
    id   serial not null
        constraint tags_pk
            primary key,
    name text   not null
);

create table users
(
    id            serial not null
        constraint users_pk
            primary key,
    login         text   not null,
    email         text   not null,
    salt          text   not null,
    password_hash text   not null
);

create table models
(
    id              serial  not null
        constraint models_pk
            primary key,
    name            text    not null,
    description     text    not null,
    preview         bytea,
    model_file      bytea   not null,
    author_id       integer not null
        constraint models_users_id_fk
            references users,
    model_format_id integer not null
        constraint models_model_formats_id_fk
            references model_formats
);

create table model_images
(
    id_model        integer not null
        constraint model_images_models_id_fk
            references models,
    id_image        serial  not null
        constraint model_images_pk
            primary key,
    description     text,
    image_file      bytea   not null,
    image_format_id integer not null
        constraint model_images_image_formats_id_fk
            references image_formats
);

create unique index model_images_id_image_uindex
    on model_images (id_image);

create table model_materials
(
    id_model    integer not null
        constraint model_materials_models_id_fk
            references models,
    id_material integer
        constraint model_materials_material_types_id_fk
            references material_types
);

create table model_tags
(
    id_model integer not null
        constraint model_tags_models_id_fk
            references models,
    id_tag   integer not null
        constraint model_tags_tags_id_fk
            references tags
);

create unique index users_email_uindex
    on users (email);

create unique index users_id_uindex
    on users (id);

create unique index users_login_uindex
    on users (login);

create or replace procedure add_image_format(f_name text)
    language plpgsql
as
$$
BEGIN
    insert into image_formats(name) values (f_name);
END
$$;

create or replace procedure add_material(m_name text, m_base_cost real)
    language plpgsql
as
$$
BEGIN
    insert into material_types(name, base_cost) values (m_name, m_base_cost);
END
$$;

create or replace procedure add_model(m_name text, m_description text, m_preview bytea, m_model_file bytea,
                                      m_author_id integer, m_model_format_id integer, m_tags integer[],
                                      m_images bytea[], m_images_descriptions text[], m_images_formats_id integer[],
                                      m_materials integer[])
    language plpgsql
as
$$
DECLARE
    model_id int;
BEGIN
    call add_model_information(m_name, m_description, m_preview,
                               m_model_file, m_author_id, m_model_format_id);
    select currval(pg_get_serial_sequence('models', 'id')) into model_id;

    call add_tags_images_materials_to_model(model_id, m_tags, m_images,
                                            m_images_descriptions, m_images_formats_id, m_materials);
END
$$;

create or replace procedure add_model_format(f_name text)
    language plpgsql
as
$$
BEGIN
    insert into model_formats(name) values (f_name);
END
$$;

create or replace procedure add_model_information(m_name text, m_description text, m_preview bytea, m_model_file bytea,
                                                  m_author_id integer, m_model_format_id integer)
    language plpgsql
as
$$
DECLARE
    model_id int;
BEGIN
    select nextval(pg_get_serial_sequence('models', 'id')) into model_id;
    insert into models(name, description, preview, model_file, author_id, model_format_id)
    values (m_name, m_description, m_preview, m_model_file, m_author_id, m_model_format_id);
END
$$;

create or replace procedure add_tags_images_materials_to_model(model_id integer, m_tags integer[], m_images bytea[],
                                                               m_images_descriptions text[],
                                                               m_images_formats_id integer[], m_materials integer[])
    language plpgsql
as
$$
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

create or replace procedure add_user(u_login text, u_email text, u_salt text, u_password_hash text)
    language sql
as
$$
INSERT INTO users(login, email, salt, password_hash)
VALUES (u_login, u_email, u_salt, u_password_hash);
$$;

create or replace function check_user_authentication(u_login text, u_password_hash text) returns boolean
    immutable
    language plpgsql
as
$$
DECLARE
    u_id int;
BEGIN
    SELECT users.id
    FROM public.users AS users
    WHERE users.login = u_login
      AND users.password_hash = u_password_hash
    INTO u_id;
    RETURN u_id;
END
$$;

create or replace procedure create_tag(t_name text)
    language plpgsql
as
$$
BEGIN
    insert into tags(name) values (t_name);
END
$$;

create or replace function get_model(m_id integer, OUT m_name text, OUT m_description text, OUT m_model_file bytea,
                                     OUT m_model_type text, OUT m_images bytea[], OUT m_image_types text[],
                                     OUT m_image_descriptions text[]) returns record
    language plpgsql
as
$$
BEGIN
    select models.name, models.description, models.model_file, model_formats.name
    into m_name, m_description, m_model_file, m_model_type
    from models
             join model_formats on model_formats.id = models.model_format_id
    where models.id = m_id;

    select array_agg(image_file::bytea), array_agg(image_formats.name::text), array_agg(description::text)
    into m_images, m_image_types, m_image_descriptions
    from model_images
             join image_formats on model_images.image_format_id = image_formats.id
    where model_images.id_model = m_id;

END
$$;

create or replace function get_model_previews()
    returns TABLE
            (
                id      integer,
                name    text,
                preview bytea,
                author  text
            )
    language plpgsql
as
$$
BEGIN
    return query select models.id, name, preview, users.login
                 from models
                          join users on author_id = users.id;
END
$$;

create or replace function get_tags()
    returns TABLE
            (
                id   integer,
                name text
            )
    language plpgsql
as
$$
BEGIN
    return query select * from tags;
END
$$;

create or replace function get_user_salt(u_login text) returns text
    language plpgsql
as
$$
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


