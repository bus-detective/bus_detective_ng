defmodule BusDetective.Repo.Migrations.CreateProjectedStopTimes do
  use Ecto.Migration

  def change do
    create table(:projected_stop_times) do
      add(:scheduled_arrival_time, :utc_datetime, null: false)
      add(:scheduled_departure_time, :utc_datetime, null: false)
      add(:stop_time_id, references(:stop_times, on_delete: :delete_all, null: false))

      timestamps()
    end

    create(index(:projected_stop_times, [:stop_time_id]))
    create(unique_index(:projected_stop_times, [:stop_time_id, :scheduled_arrival_time, :scheduled_departure_time]))
  end
end
