defmodule BusDetective.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add(:agency_id, references(:agencies, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:code, :integer)
      add(:name, :string)
      add(:description, :string)
      add(:latitude, :float)
      add(:longitude, :float)
      add(:zone_id, :integer)
      add(:url, :string)
      add(:location_type, :integer)
      add(:parent_station, :string)
      add(:timezone, :string)
      add(:wheelchair_boarding, :integer)

      timestamps()
    end

    create(index(:stops, :agency_id))
    create(unique_index(:stops, [:agency_id, :remote_id]))
  end
end
