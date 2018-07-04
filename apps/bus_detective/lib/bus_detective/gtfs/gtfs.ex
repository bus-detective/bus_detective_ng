defmodule BusDetective.GTFS do
  @moduledoc """
  The GTFS context.
  """

  import Ecto.Query, warn: false
  alias BusDetective.Repo

  alias BusDetective.GTFS.{Agency, Service, ServiceException}

  @doc """
  Returns the list of agencies.

  ## Examples

      iex> list_agencies()
      [%Agency{}, ...]

  """
  def list_agencies do
    Repo.all(Agency)
  end

  # @doc """
  # Gets a single agency.

  # Raises `Ecto.NoResultsError` if the Agency does not exist.

  # ## Examples

  #     iex> get_agency!(123)
  #     %Agency{}

  #     iex> get_agency!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_agency!(id), do: Repo.get!(Agency, id)

  @doc """
  Creates a agency.

  ## Examples

      iex> create_agency(%{field: value})
      {:ok, %Agency{}}

      iex> create_agency(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_agency(attrs \\ %{}) do
    %Agency{}
    |> Agency.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a agency.

  # ## Examples

  #     iex> update_agency(agency, %{field: new_value})
  #     {:ok, %Agency{}}

  #     iex> update_agency(agency, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_agency(%Agency{} = agency, attrs) do
  #   agency
  #   |> Agency.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a Agency.

  # ## Examples

  #     iex> delete_agency(agency)
  #     {:ok, %Agency{}}

  #     iex> delete_agency(agency)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_agency(%Agency{} = agency) do
  #   Repo.delete(agency)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking agency changes.

  # ## Examples

  #     iex> change_agency(agency)
  #     %Ecto.Changeset{source: %Agency{}}

  # """
  # def change_agency(%Agency{} = agency) do
  #   Agency.changeset(agency, %{})
  # end

  @doc """
  Returns the list of services.

  ## Examples

      iex> list_services()
      [%Service{}, ...]

  """
  def list_services(agency: %Agency{id: agency_id}) do
    Repo.all(from(service in Service, where: service.agency_id == ^agency_id))
  end

  @doc """
  Gets a single service by agency and remote_id.

  Returns nil if no matching service exists

  ## Examples

      iex> get_service(agency_id: 5, remote_id: "6")
      %Service{}

      iex> get_service!(agency_id: 5, remote_id: "6")
      ** (Ecto.NoResultsError)

  """
  def get_service(agency: %Agency{id: agency_id}, remote_id: remote_id) do
    Repo.one(from(service in Service, where: service.agency_id == ^agency_id and service.remote_id == ^remote_id))
  end

  @doc """
  Creates a service.

  ## Examples

      iex> create_service(%{field: value})
      {:ok, %Service{}}

      iex> create_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service(attrs \\ %{}) do
    %Service{}
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a service.

  # ## Examples

  #     iex> update_service(service, %{field: new_value})
  #     {:ok, %Service{}}

  #     iex> update_service(service, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_service(%Service{} = service, attrs) do
  #   service
  #   |> Service.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a Service.

  # ## Examples

  #     iex> delete_service(service)
  #     {:ok, %Service{}}

  #     iex> delete_service(service)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_service(%Service{} = service) do
  #   Repo.delete(service)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking service changes.

  # ## Examples

  #     iex> change_service(service)
  #     %Ecto.Changeset{source: %Service{}}

  # """
  # def change_service(%Service{} = service) do
  #   Service.changeset(service, %{})
  # end

  @doc """
  Returns the list of service_exceptions.

  ## Examples

      iex> list_service_exceptions()
      [%ServiceException{}, ...]

  """
  def list_service_exceptions(agency: %Agency{id: agency_id}, service: %Service{id: service_id}) do
    Repo.all(from(se in ServiceException, where: se.agency_id == ^agency_id and se.service_id == ^service_id))
  end

  @doc """
  Gets a single service_exception.

  Raises `Ecto.NoResultsError` if the Service exception does not exist.

  ## Examples

      iex> get_service_exception!(123)
      %ServiceException{}

      iex> get_service_exception!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_exception!(id), do: Repo.get!(ServiceException, id)

  @doc """
  Creates a service_exception.

  ## Examples

      iex> create_service_exception(%{field: value})
      {:ok, %ServiceException{}}

      iex> create_service_exception(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_exception(attrs \\ %{}) do
    %ServiceException{}
    |> ServiceException.changeset(attrs)
    |> Repo.insert()
  end

  # @doc """
  # Updates a service_exception.

  # ## Examples

  #     iex> update_service_exception(service_exception, %{field: new_value})
  #     {:ok, %ServiceException{}}

  #     iex> update_service_exception(service_exception, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_service_exception(%ServiceException{} = service_exception, attrs) do
  #   service_exception
  #   |> ServiceException.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a ServiceException.

  # ## Examples

  #     iex> delete_service_exception(service_exception)
  #     {:ok, %ServiceException{}}

  #     iex> delete_service_exception(service_exception)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_service_exception(%ServiceException{} = service_exception) do
  #   Repo.delete(service_exception)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking service_exception changes.

  # ## Examples

  #     iex> change_service_exception(service_exception)
  #     %Ecto.Changeset{source: %ServiceException{}}

  # """
  # def change_service_exception(%ServiceException{} = service_exception) do
  #   ServiceException.changeset(service_exception, %{})
  # end

  # alias BusDetective.GTFS.Route

  # @doc """
  # Returns the list of routes.

  # ## Examples

  #     iex> list_routes()
  #     [%Route{}, ...]

  # """
  # def list_routes do
  #   Repo.all(Route)
  # end

  # @doc """
  # Gets a single route.

  # Raises `Ecto.NoResultsError` if the Route does not exist.

  # ## Examples

  #     iex> get_route!(123)
  #     %Route{}

  #     iex> get_route!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_route!(id), do: Repo.get!(Route, id)

  # @doc """
  # Creates a route.

  # ## Examples

  #     iex> create_route(%{field: value})
  #     {:ok, %Route{}}

  #     iex> create_route(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_route(attrs \\ %{}) do
  #   %Route{}
  #   |> Route.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a route.

  # ## Examples

  #     iex> update_route(route, %{field: new_value})
  #     {:ok, %Route{}}

  #     iex> update_route(route, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_route(%Route{} = route, attrs) do
  #   route
  #   |> Route.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a Route.

  # ## Examples

  #     iex> delete_route(route)
  #     {:ok, %Route{}}

  #     iex> delete_route(route)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_route(%Route{} = route) do
  #   Repo.delete(route)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking route changes.

  # ## Examples

  #     iex> change_route(route)
  #     %Ecto.Changeset{source: %Route{}}

  # """
  # def change_route(%Route{} = route) do
  #   Route.changeset(route, %{})
  # end

  # alias BusDetective.GTFS.Stop

  # @doc """
  # Returns the list of stops.

  # ## Examples

  #     iex> list_stops()
  #     [%Stop{}, ...]

  # """
  # def list_stops do
  #   Repo.all(Stop)
  # end

  # @doc """
  # Gets a single stop.

  # Raises `Ecto.NoResultsError` if the Stop does not exist.

  # ## Examples

  #     iex> get_stop!(123)
  #     %Stop{}

  #     iex> get_stop!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_stop!(id), do: Repo.get!(Stop, id)

  # @doc """
  # Creates a stop.

  # ## Examples

  #     iex> create_stop(%{field: value})
  #     {:ok, %Stop{}}

  #     iex> create_stop(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_stop(attrs \\ %{}) do
  #   %Stop{}
  #   |> Stop.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a stop.

  # ## Examples

  #     iex> update_stop(stop, %{field: new_value})
  #     {:ok, %Stop{}}

  #     iex> update_stop(stop, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_stop(%Stop{} = stop, attrs) do
  #   stop
  #   |> Stop.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a Stop.

  # ## Examples

  #     iex> delete_stop(stop)
  #     {:ok, %Stop{}}

  #     iex> delete_stop(stop)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_stop(%Stop{} = stop) do
  #   Repo.delete(stop)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking stop changes.

  # ## Examples

  #     iex> change_stop(stop)
  #     %Ecto.Changeset{source: %Stop{}}

  # """
  # def change_stop(%Stop{} = stop) do
  #   Stop.changeset(stop, %{})
  # end

  # alias BusDetective.GTFS.Shape

  # @doc """
  # Returns the list of shapes.

  # ## Examples

  #     iex> list_shapes()
  #     [%Shape{}, ...]

  # """
  # def list_shapes do
  #   Repo.all(Shape)
  # end

  # @doc """
  # Gets a single shape.

  # Raises `Ecto.NoResultsError` if the Shape does not exist.

  # ## Examples

  #     iex> get_shape!(123)
  #     %Shape{}

  #     iex> get_shape!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_shape!(id), do: Repo.get!(Shape, id)

  # @doc """
  # Creates a shape.

  # ## Examples

  #     iex> create_shape(%{field: value})
  #     {:ok, %Shape{}}

  #     iex> create_shape(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_shape(attrs \\ %{}) do
  #   %Shape{}
  #   |> Shape.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a shape.

  # ## Examples

  #     iex> update_shape(shape, %{field: new_value})
  #     {:ok, %Shape{}}

  #     iex> update_shape(shape, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_shape(%Shape{} = shape, attrs) do
  #   shape
  #   |> Shape.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a Shape.

  # ## Examples

  #     iex> delete_shape(shape)
  #     {:ok, %Shape{}}

  #     iex> delete_shape(shape)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_shape(%Shape{} = shape) do
  #   Repo.delete(shape)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking shape changes.

  # ## Examples

  #     iex> change_shape(shape)
  #     %Ecto.Changeset{source: %Shape{}}

  # """
  # def change_shape(%Shape{} = shape) do
  #   Shape.changeset(shape, %{})
  # end

  # alias BusDetective.GTFS.Trip

  # @doc """
  # Returns the list of trips.

  # ## Examples

  #     iex> list_trips()
  #     [%Trip{}, ...]

  # """
  # def list_trips do
  #   Repo.all(Trip)
  # end

  # @doc """
  # Gets a single trip.

  # Raises `Ecto.NoResultsError` if the Trip does not exist.

  # ## Examples

  #     iex> get_trip!(123)
  #     %Trip{}

  #     iex> get_trip!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_trip!(id), do: Repo.get!(Trip, id)

  # @doc """
  # Creates a trip.

  # ## Examples

  #     iex> create_trip(%{field: value})
  #     {:ok, %Trip{}}

  #     iex> create_trip(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_trip(attrs \\ %{}) do
  #   %Trip{}
  #   |> Trip.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a trip.

  # ## Examples

  #     iex> update_trip(trip, %{field: new_value})
  #     {:ok, %Trip{}}

  #     iex> update_trip(trip, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_trip(%Trip{} = trip, attrs) do
  #   trip
  #   |> Trip.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a Trip.

  # ## Examples

  #     iex> delete_trip(trip)
  #     {:ok, %Trip{}}

  #     iex> delete_trip(trip)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_trip(%Trip{} = trip) do
  #   Repo.delete(trip)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking trip changes.

  # ## Examples

  #     iex> change_trip(trip)
  #     %Ecto.Changeset{source: %Trip{}}

  # """
  # def change_trip(%Trip{} = trip) do
  #   Trip.changeset(trip, %{})
  # end

  # alias BusDetective.GTFS.StopTime

  # @doc """
  # Returns the list of stop_times.

  # ## Examples

  #     iex> list_stop_times()
  #     [%StopTime{}, ...]

  # """
  # def list_stop_times do
  #   Repo.all(StopTime)
  # end

  # @doc """
  # Gets a single stop_time.

  # Raises `Ecto.NoResultsError` if the Stop time does not exist.

  # ## Examples

  #     iex> get_stop_time!(123)
  #     %StopTime{}

  #     iex> get_stop_time!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_stop_time!(id), do: Repo.get!(StopTime, id)

  # @doc """
  # Creates a stop_time.

  # ## Examples

  #     iex> create_stop_time(%{field: value})
  #     {:ok, %StopTime{}}

  #     iex> create_stop_time(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_stop_time(attrs \\ %{}) do
  #   %StopTime{}
  #   |> StopTime.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a stop_time.

  # ## Examples

  #     iex> update_stop_time(stop_time, %{field: new_value})
  #     {:ok, %StopTime{}}

  #     iex> update_stop_time(stop_time, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_stop_time(%StopTime{} = stop_time, attrs) do
  #   stop_time
  #   |> StopTime.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a StopTime.

  # ## Examples

  #     iex> delete_stop_time(stop_time)
  #     {:ok, %StopTime{}}

  #     iex> delete_stop_time(stop_time)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_stop_time(%StopTime{} = stop_time) do
  #   Repo.delete(stop_time)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking stop_time changes.

  # ## Examples

  #     iex> change_stop_time(stop_time)
  #     %Ecto.Changeset{source: %StopTime{}}

  # """
  # def change_stop_time(%StopTime{} = stop_time) do
  #   StopTime.changeset(stop_time, %{})
  # end
end
