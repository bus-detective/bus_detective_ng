defmodule BusDetective.Repo.Migrations.CreateRoutesStops do
  use Ecto.Migration

  def change do
    create table(:routes_stops) do
      add(:route_id, references(:routes, on_delete: :delete_all), null: false)
      add(:stop_id, references(:stops, on_delete: :delete_all), null: false)
    end
  end
end
