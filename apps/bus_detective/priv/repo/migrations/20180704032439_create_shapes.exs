defmodule BusDetective.Repo.Migrations.CreateShapes do
  use Ecto.Migration

  def change do
    create table(:shapes) do
      add(:feed_id, references(:feeds, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:geometry, :"geography(LineString,4326)")

      timestamps()
    end

    create(index(:shapes, :feed_id))
    create(unique_index(:shapes, [:feed_id, :remote_id]))
  end
end
