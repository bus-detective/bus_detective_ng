defmodule BusDetective.Repo.Migrations.AddCalculatedStopFunctions do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIEW service_days AS
    SELECT sd.id,
    sd.agency_id,
    sd.remote_id,
    sd.start_date,
    sd.end_date,
    sd.dow
    FROM ( SELECT services.id,
    services.agency_id,
    services.remote_id,
    services.start_date,
    services.end_date,
    unnest(ARRAY['monday'::text, 'tuesday'::text, 'wednesday'::text, 'thursday'::text, 'friday'::text, 'saturday'::text, 'sunday'::text]) AS dow,
    unnest(ARRAY[services.monday, services.tuesday, services.wednesday, services.thursday, services.friday, services.saturday, services.sunday]) AS active
    FROM services) sd
    WHERE sd.active;
    """)

    execute("""
        CREATE FUNCTION effective_services(start_date date DEFAULT ('now'::text)::date, end_date date DEFAULT (('now'::text)::date + '1 day'::interval)) RETURNS TABLE(agency_id bigint, service_id bigint, date date, dow character)
        LANGUAGE sql
        AS $$
      SELECT agencies.id as agency_id, service_exceptions.service_id, d as date, rtrim(to_char(days.d, 'day')) as dow
         FROM agencies
           CROSS JOIN (SELECT d::date FROM generate_series(start_date, end_date, interval '1 day') d) days
           INNER JOIN service_days ON service_days.dow = rtrim(to_char(days.d, 'day')) AND agencies.id = service_days.agency_id and days.d between service_days.start_date and service_days.end_date
           INNER JOIN service_exceptions ON service_exceptions.date = days.d AND agencies.id = service_exceptions.agency_id
           WHERE service_exceptions.exception = 1
         UNION ALL
         SELECT agencies.id as agency_id, service_days.id, d as date, rtrim(to_char(days.d, 'day')) as dow
         FROM agencies
           CROSS JOIN (SELECT d::date FROM generate_series(start_date, end_date, interval '1 day') d) days
           INNER JOIN service_days ON service_days.dow = rtrim(to_char(days.d, 'day')) AND agencies.id = service_days.agency_id and days.d between service_days.start_date and service_days.end_date
           LEFT JOIN service_exceptions ON service_exceptions.date = days.d AND agencies.id = service_exceptions.agency_id AND service_days.id = service_exceptions.service_id
           WHERE service_exceptions IS NULL OR service_exceptions.exception != 2
    $$;
    """)

    execute("""
    CREATE FUNCTION start_time(start_date date DEFAULT ('now'::text)::date) RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
    DECLARE
    noon varchar(50);
    BEGIN
    SELECT INTO noon to_char(start_date, 'YYYY-mm-dd') || ' 12:00:00';
    RETURN noon::timestamp - interval '12 hours';
    END;
    $$;
    """)
  end
end
