defmodule BusDetective.Repo.Migrations.CreateServices do
  use Ecto.Migration

  def change do
    create table(:services) do
      add(:feed_id, references(:feeds, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:monday, :boolean, default: false, null: false)
      add(:tuesday, :boolean, default: false, null: false)
      add(:wednesday, :boolean, default: false, null: false)
      add(:thursday, :boolean, default: false, null: false)
      add(:friday, :boolean, default: false, null: false)
      add(:saturday, :boolean, default: false, null: false)
      add(:sunday, :boolean, default: false, null: false)
      add(:start_date, :date)
      add(:end_date, :date)

      timestamps()
    end

    create(index(:services, :feed_id))
    create(unique_index(:services, [:feed_id, :remote_id]))
  end
end
