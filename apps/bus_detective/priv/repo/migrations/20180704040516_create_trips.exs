defmodule BusDetective.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips) do
      add(:agency_id, references(:agencies, on_delete: :delete_all), null: false)
      add(:service_id, references(:services, on_delete: :delete_all), null: false)
      add(:route_id, references(:routes, on_delete: :delete_all), null: false)
      add(:shape_id, references(:shapes, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:headsign, :string)
      add(:short_name, :string)
      add(:direction_id, :integer)
      add(:block_id, :integer)
      add(:wheelchair_accessible, :integer)
      add(:bikes_allowed, :integer)

      timestamps()
    end

    create(index(:trips, :agency_id))
    create(index(:trips, :route_id))
    create(index(:trips, :shape_id))
    create(index(:trips, :service_id))
    create(unique_index(:trips, [:agency_id, :remote_id]))
  end
end
