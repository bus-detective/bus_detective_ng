defmodule BusDetective.Repo.Migrations.AddDisplayNameToAgency do
  use Ecto.Migration

  def change do
    alter table(:agencies) do
      add(:display_name, :string)
    end
  end
end
