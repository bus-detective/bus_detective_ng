defmodule BusDetective.Repo.Migrations.CreateServiceExceptions do
  use Ecto.Migration

  def change do
    create table(:service_exceptions) do
      add(:agency_id, references(:agencies, on_delete: :delete_all), null: false)
      add(:service_id, references(:services, on_delete: :delete_all), null: false)
      add(:date, :date)
      add(:exception, :integer)

      timestamps()
    end
  end
end
