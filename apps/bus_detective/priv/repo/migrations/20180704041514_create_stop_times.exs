defmodule BusDetective.Repo.Migrations.CreateStopTimes do
  use Ecto.Migration

  def change do
    create table(:stop_times) do
      add(:agency_id, references(:agencies), null: false)
      add(:stop_id, references(:stops), null: false)
      add(:trip_id, references(:trips), null: false)
      add(:stop_headsign, :string)
      add(:pickup_type, :integer)
      add(:drop_off_type, :integer)
      add(:shape_dist_traveled, :float)
      add(:arrival_time, :integer)
      add(:departure_time, :integer)
      add(:stop_sequence, :integer)

      timestamps()
    end

    create(index(:stop_times, :agency_id))
    create(index(:stop_times, [:agency_id, :stop_id, :trip_id]))
    create(index(:stop_times, :stop_id))
    create(index(:stop_times, :trip_id))
  end
end
