defmodule BusDetective.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips) do
      add :agency_id, references(:agencies)
      add :service_id, references(:services)
      add :route_id, references(:routes)
      add :shape_id, references(:shapes)
      add :remote_id, :string
      add :headsign, :string
      add :short_name, :string
      add :direction_id, :integer
      add :block_id, :integer
      add :wheelchair_accessible, :integer
      add :bikes_allowed, :integer

      timestamps()
    end

    create index(:trips, :agency_id)
    create index(:trips, [:remote_id, :agency_id])
    create index(:trips, :route_id)
    create index(:trips, :shape_id)
  end
end
