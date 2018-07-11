defmodule BusDetective.Repo.Migrations.CreateRoutes do
  use Ecto.Migration

  def change do
    create table(:routes) do
      add(:agency_id, references(:agencies, on_delete: :delete_all), null: false)
      add(:remote_id, :string)
      add(:short_name, :string)
      add(:long_name, :string)
      add(:description, :string)
      add(:route_type, :string)
      add(:url, :string)
      add(:color, :string)
      add(:text_color, :string)

      timestamps()
    end

    create(index(:routes, :agency_id))
    create(index(:routes, [:remote_id, :agency_id]))
  end
end
