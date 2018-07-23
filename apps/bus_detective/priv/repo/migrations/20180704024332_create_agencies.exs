defmodule BusDetective.Repo.Migrations.CreateAgencies do
  use Ecto.Migration

  def change do
    create table(:agencies) do
      add(:feed_id, references(:feeds, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:name, :string)
      add(:url, :string)
      add(:fare_url, :string)
      add(:timezone, :string)
      add(:language, :string)
      add(:phone, :string)
      add(:gtfs_endpoint, :string)
      add(:gtfs_trip_updates_url, :string)
      add(:gtfs_vehicle_positions_url, :string)
      add(:gtfs_service_alerts_url, :string)

      timestamps()
    end

    create(unique_index(:agencies, [:feed_id, :remote_id]))
  end
end
