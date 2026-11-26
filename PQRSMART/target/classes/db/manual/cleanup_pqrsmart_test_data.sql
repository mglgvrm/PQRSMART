-- Delete only the 20 requests and 10 accounts created by the opt-in test seeder.
-- Safe to run repeatedly. It never uses DROP or deletes unrelated citizens/PQRS.
BEGIN;

DO $$
BEGIN
    IF current_database() NOT IN ('pqrsmartdb', 'pqrsmart_dev', 'pqrsmart_test') THEN
        RAISE EXCEPTION 'Cleanup permitido solo en una base local PQRSMART de desarrollo.';
    END IF;
    IF inet_client_addr() IS NOT NULL
       AND inet_client_addr() NOT IN ('127.0.0.1'::inet, '::1'::inet) THEN
        RAISE EXCEPTION 'Cleanup permitido solo desde una conexión loopback local.';
    END IF;
END
$$;

DELETE FROM solicitudes request
 USING usuario test_user
 WHERE request.usuario = test_user.id
   AND request.radicado LIKE 'TEST-PQRSMART-20261119-%'
   AND request.descripcion_solicitud LIKE 'TEST DATA - PQRSMART.%'
   AND test_user.usuario ~ '^pqrsmart_test_[0-9]{2}$'
   AND test_user.correo_persona ~ '^pqrsmart[.]test[.][0-9]{2}@example[.]invalid$';

DELETE FROM usuario test_user
 WHERE test_user.usuario ~ '^pqrsmart_test_[0-9]{2}$'
   AND test_user.correo_persona ~ '^pqrsmart[.]test[.][0-9]{2}@example[.]invalid$'
   AND NOT EXISTS (
       SELECT 1
         FROM solicitudes request
        WHERE request.usuario = test_user.id
           OR request.usuario_asignado = test_user.id
           OR request.registrado_por = test_user.id
   );

COMMIT;
