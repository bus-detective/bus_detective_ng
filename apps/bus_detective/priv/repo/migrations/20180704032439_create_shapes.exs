defmodule BusDetective.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:shapes) do
      add(:agency_id, references(:agencies, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:geometry, :"geography(LineString,4326)")

      timestamps()
    end

    create(index(:shapes, :agency_id))
    create(unique_index(:shapes, [:agency_id, :remote_id]))
  end
end
