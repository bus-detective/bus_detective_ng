defmodule BusDetective.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:shapes) do
      add :agency_id, references(:agencies)
      add :remote_id, :string
      add :geometry, :"geography(LineString,4326)"

      timestamps()
    end

    create index(:shapes, :agency_id)
  end
end
