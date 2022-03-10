module cityDistance

export startServer

import JSON
import HTTP
using URIs


# TODO http keepalive for consecutive requests

struct Location
    lat::String
    lon::String
end

struct Trip
    tour::String
    length::Float64
end

trips = Dict{String,Float64}()

function getCoordinates(city::String)::Location
    url = string("https://nominatim.openstreetmap.org/search/", city, "?format=json")
    result = HTTP.request("GET", url; verbose=0)
    ob = JSON.parse(String(result.body))
    return Location(ob[1]["lat"], ob[1]["lon"])
end

function getDistance(coord1::Location, coord2::Location)::Float64
    params = Dict(
    "locations" => [
        Dict(
            "lat" => string(coord1.lat),
            "lon" => string(coord1.lon),
            "type" => "break"
             ),
        Dict(
            "lat" => string(coord2.lat),
            "lon" => string(coord2.lon),
            "type" => "break"
             ),
    ],
    "costing" => "auto",
    "directions_options" => Dict(
        "directions_type" => "none"
    ))
    url = string("https://valhalla1.openstreetmap.de/route")
    result = HTTP.request("POST", url, ["Content-Type" => "application/json"], JSON.json(params))
    ob = JSON.parse(String(result.body))
    return ob["trip"]["summary"]["length"]
end

function distanceBetweenCities(city1::String, city2::String)::Float64
    # normalize order
    order = cmp(city1, city2)
    if (order == 1)
        s = string(city1,city2)
    elseif (order == -1)
        s = string(city2,city1)
    else
        # string equal, no trip
        return 0;
    end
        
    # check for key, if it doesn't exists get new value and insert into Dict
    # otherwise return from Dict
    if (haskey( trips, s))
        length = trips[s]
    else
        length = getDistance(getCoordinates(city1), getCoordinates(city2))
        trips[s] = length
    end
    return length
end



function startServer()
    HTTP.listen() do http::HTTP.Stream
        uri = URI(HTTP.uri(http.message))
        params = queryparams(uri)
        length = distanceBetweenCities(params["city1"], params["city2"])

        HTTP.setstatus(http, 200)
        HTTP.setheader(http, "Connection" => "Keep-Alive")
        HTTP.setheader(http, "Content-Type" => "text/plain; charset=utf-8")
        HTTP.startwrite(http)
        write(http, string(length))
    end
end

startServer()

end