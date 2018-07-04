defmodule BusDetective.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add(:agency_id, references(:agencies))
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
    create(index(:stops, [:remote_id, :agency_id]))
  end
end
