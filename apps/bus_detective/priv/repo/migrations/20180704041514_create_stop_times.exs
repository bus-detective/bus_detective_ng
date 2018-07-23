defmodule BusDetective.Repo.Migrations.CreateStopTimes do
  use Ecto.Migration

  def change do
    create table(:stop_times) do
      add(:feed_id, references(:feeds, on_delete: :delete_all), null: false)
      add(:stop_id, references(:stops, on_delete: :delete_all), null: false)
      add(:trip_id, references(:trips, on_delete: :delete_all), null: false)
      add(:stop_headsign, :string)
      add(:pickup_type, :integer)
      add(:drop_off_type, :integer)
      add(:shape_dist_traveled, :float)
      add(:arrival_time, :interval)
      add(:departure_time, :interval)
      add(:stop_sequence, :integer)

      timestamps()
    end

    create(index(:stop_times, :feed_id))
    create(index(:stop_times, [:feed_id, :stop_id, :trip_id]))
    create(index(:stop_times, :stop_id))
    create(index(:stop_times, :trip_id))
  end
end
