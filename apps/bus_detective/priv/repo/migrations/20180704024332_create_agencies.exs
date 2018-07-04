defmodule BusDetective.Repo.Migrations.CreateAgencies do
  use Ecto.Migration

  def change do
    create table(:agencies) do
      add :remote_id, :string
      add :name, :string
      add :url, :string
      add :fare_url, :string
      add :timezone, :string
      add :language, :string
      add :phone, :string
      add :gtfs_endpoint, :string
      add :gtfs_trip_updates_url, :string
      add :gtfs_vehicle_positions_url, :string
      add :gtfs_service_alerts_url, :string

      timestamps()
    end

    create index(:agencies, :remote_id)
  end
end
