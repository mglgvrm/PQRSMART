-- The legacy entity mappings contain trailing spaces; resolve the existing
-- table/column names without renaming or rebuilding the production schema.
DO $$
DECLARE
    schema_name text := current_schema();
    requests_table text;
    states_table text;
    users_table text;
    request_id_column text;
    state_id_column text;
    user_id_column text;
    updated_at_column text;
BEGIN
    SELECT table_name INTO requests_table
    FROM information_schema.tables
    WHERE table_schema = schema_name
      AND lower(trim(table_name)) = 'solicitudes'
    ORDER BY length(table_name)
    LIMIT 1;

    SELECT table_name INTO states_table
    FROM information_schema.tables
    WHERE table_schema = schema_name
      AND lower(trim(table_name)) = 'estados_solicitud'
    ORDER BY length(table_name)
    LIMIT 1;

    SELECT table_name INTO users_table
    FROM information_schema.tables
    WHERE table_schema = schema_name
      AND lower(trim(table_name)) = 'usuario'
    ORDER BY length(table_name)
    LIMIT 1;

    IF requests_table IS NULL OR states_table IS NULL OR users_table IS NULL THEN
        RAISE EXCEPTION 'No se encontraron las tablas de solicitudes, estados o usuarios.';
    END IF;

    SELECT column_name INTO request_id_column
    FROM information_schema.columns
    WHERE table_schema = schema_name
      AND table_name = requests_table
      AND lower(trim(column_name)) = 'id_solicitud'
    LIMIT 1;

    SELECT column_name INTO state_id_column
    FROM information_schema.columns
    WHERE table_schema = schema_name
      AND table_name = states_table
      AND lower(trim(column_name)) = 'id_estado_solicitud'
    LIMIT 1;

    SELECT column_name INTO user_id_column
    FROM information_schema.columns
    WHERE table_schema = schema_name
      AND table_name = users_table
      AND lower(trim(column_name)) = 'id'
    LIMIT 1;

    SELECT column_name INTO updated_at_column
    FROM information_schema.columns
    WHERE table_schema = schema_name
      AND table_name = requests_table
      AND lower(trim(column_name)) = 'fecha_actualizacion'
    LIMIT 1;

    IF request_id_column IS NULL OR state_id_column IS NULL OR user_id_column IS NULL THEN
        RAISE EXCEPTION 'No se encontraron las columnas identificadoras requeridas.';
    END IF;

    IF updated_at_column IS NULL THEN
        updated_at_column := 'Fecha_Actualizacion';
        EXECUTE format(
            'ALTER TABLE %I.%I ADD COLUMN %I timestamp with time zone',
            schema_name, requests_table, updated_at_column
        );
    END IF;

    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I.historial_estado_solicitud (
            id_historial_estado bigserial PRIMARY KEY,
            id_solicitud bigint NOT NULL REFERENCES %I.%I (%I) ON DELETE CASCADE,
            estado_anterior bigint REFERENCES %I.%I (%I),
            estado_nuevo bigint NOT NULL REFERENCES %I.%I (%I),
            fecha_cambio timestamp with time zone NOT NULL DEFAULT now(),
            funcionario_responsable bigint REFERENCES %I.%I (%I) ON DELETE SET NULL,
            observacion text
        )',
        schema_name,
        schema_name, requests_table, request_id_column,
        schema_name, states_table, state_id_column,
        schema_name, states_table, state_id_column,
        schema_name, users_table, user_id_column
    );
END $$;

CREATE INDEX IF NOT EXISTS idx_historial_estado_solicitud_fecha
    ON historial_estado_solicitud (id_solicitud, fecha_cambio);
