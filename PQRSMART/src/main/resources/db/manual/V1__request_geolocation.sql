-- Additive, nullable migration for existing PostgreSQL installations.
-- The legacy JPA table name includes trailing whitespace; resolve it by its
-- trimmed, case-insensitive name rather than assuming a physical identifier.
DO $$
DECLARE
    requests_table regclass;
    requests_schema text;
    requests_name text;
    requester_column text;
    users_table regclass;
    users_schema text;
    users_name text;
    user_id_column text;
BEGIN
    SELECT table_schema, table_name,
           to_regclass(format('%I.%I', table_schema, table_name))
      INTO requests_schema, requests_name, requests_table
      FROM information_schema.tables
     WHERE table_schema = current_schema()
       AND lower(trim(table_name)) = 'solicitudes'
     ORDER BY table_name
     LIMIT 1;

    IF requests_table IS NULL THEN
        RAISE EXCEPTION 'No se encontró la tabla existente de solicitudes en el esquema actual';
    END IF;

    EXECUTE format(
        'ALTER TABLE %s
            ADD COLUMN IF NOT EXISTS latitud double precision,
            ADD COLUMN IF NOT EXISTS longitud double precision,
            ADD COLUMN IF NOT EXISTS fuente_ubicacion varchar(24),
            ADD COLUMN IF NOT EXISTS metodo_ubicacion varchar(16),
            ADD COLUMN IF NOT EXISTS descripcion_lugar varchar(300),
            ADD COLUMN IF NOT EXISTS fecha_captura_ubicacion timestamp with time zone,
            ADD COLUMN IF NOT EXISTS nombre_ciudadano varchar(160),
            ADD COLUMN IF NOT EXISTS correo_ciudadano varchar(254),
            ADD COLUMN IF NOT EXISTS telefono_ciudadano varchar(40),
            ADD COLUMN IF NOT EXISTS registrado_por bigint',
        requests_table
    );

    SELECT column_name
      INTO requester_column
      FROM information_schema.columns
     WHERE table_schema = requests_schema
       AND table_name = requests_name
       AND lower(trim(column_name)) = 'usuario'
     LIMIT 1;

    IF requester_column IS NOT NULL THEN
        EXECUTE format(
            'ALTER TABLE %s ALTER COLUMN %I DROP NOT NULL',
            requests_table,
            requester_column
        );
    END IF;

    SELECT table_schema, table_name,
           to_regclass(format('%I.%I', table_schema, table_name))
      INTO users_schema, users_name, users_table
      FROM information_schema.tables
     WHERE table_schema = current_schema()
       AND lower(trim(table_name)) = 'usuario'
     ORDER BY table_name
     LIMIT 1;

    SELECT column_name
      INTO user_id_column
      FROM information_schema.columns
     WHERE table_schema = users_schema
       AND table_name = users_name
       AND lower(trim(column_name)) = 'id'
     LIMIT 1;

    IF users_table IS NOT NULL AND user_id_column IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
             FROM information_schema.key_column_usage key_column
             JOIN information_schema.table_constraints constraint_info
               ON constraint_info.constraint_catalog = key_column.constraint_catalog
              AND constraint_info.constraint_schema = key_column.constraint_schema
              AND constraint_info.constraint_name = key_column.constraint_name
            WHERE key_column.table_schema = requests_schema
              AND key_column.table_name = requests_name
              AND lower(trim(key_column.column_name)) = 'registrado_por'
              AND constraint_info.constraint_type = 'FOREIGN KEY'
       ) THEN
        EXECUTE format(
            'ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %s (%I) ON DELETE SET NULL',
            requests_table,
            'fk_solicitudes_registrado_por',
            'registrado_por',
            users_table,
            user_id_column
        );
    END IF;
END
$$;
