defmodule BusDetective.Repo.Migrations.CreateServiceExceptions do
  use Ecto.Migration

  def change do
    create table(:service_exceptions) do
      add(:agency_id, references(:agencies))
      add(:service_id, references(:services))
      add(:date, :date)
      add(:exception, :integer)

      timestamps()
    end
  end
end
