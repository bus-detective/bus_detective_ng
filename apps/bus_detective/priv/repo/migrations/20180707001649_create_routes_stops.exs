defmodule BusDetective.Repo.Migrations.CreateRoutesStops do
  use Ecto.Migration

  def change do
    create table(:routes_stops) do
      add(:route_id, references(:routes), null: false)
      add(:stop_id, references(:stops), null: false)
    end
  end
end
