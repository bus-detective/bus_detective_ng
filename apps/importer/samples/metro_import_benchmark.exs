defmodule TimeFrame do
  def execute(name, units, fun) do
    start = System.monotonic_time(units)
    result = fun.()
    time_spent = System.monotonic_time(units) - start
    IO.puts("Executed #{name} in #{time_spent} #{units}")
    result
  end
end

import Importer, except: [import: 1]

gtfs_file = Path.join(File.cwd!(), "samples/google_transit_info.zip")
{:ok, tmp_path} = Briefly.create(directory: true)
{:ok, file_map} = unzip_gtfs_file(gtfs_file, tmp_path)


agency = TimeFrame.execute "agency", :seconds, fn ->
  [agency] = import_agencies(file_map["agency"])
  agency
end


trips_map = import_trips(file_map["trips"], agency, routes_map, services_map, shapes_map)
import_stop_times(file_map["stop_times"], agency, stops_map, trips_map)

services_map = TimeFrame.execute "services", :seconds, fn ->
  import_services(file_map["calendar"], agency)
end
TimeFrame.execute "service_exceptions", :seconds, fn ->
  import_service_exceptions(file_map["calendar_dates"], agency, services_map)
end
routes_map = TimeFrame.execute "routes", :seconds, fn ->
  import_routes(file_map["routes"], agency)
end
stops_map = TimeFrame.execute "stops", :seconds, fn ->
  import_stops(file_map["stops"], agency)
end
shapes_map = TimeFrame.execute "shapes", :seconds, fn ->
  import_shapes(file_map["shapes"], agency)
end
trips_map = TimeFrame.execute "trips", :seconds, fn ->
  import_trips(file_map["trips"], agency, routes_map, services_map, shapes_map)
end
TimeFrame.execute "stop_times", :seconds, fn ->
  import_stop_times(file_map["stop_times"], agency, stops_map, trips_map)
end
