defmodule BusDetective.Repo.Migrations.CreateStops do
  use Ecto.Migration

  def change do
    create table(:stops) do
      add(:feed_id, references(:feeds, on_delete: :delete_all), null: false)
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

    create(index(:stops, :feed_id))
    create(unique_index(:stops, [:feed_id, :remote_id]))
  end
end
