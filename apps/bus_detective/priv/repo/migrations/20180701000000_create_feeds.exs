defmodule BusDetective.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :last_updated, :utc_datetime
      add :last_file_hash, :string
      add :name, :string, null: false

      timestamps()
    end

    create(unique_index(:feeds, :name))
  end
end
