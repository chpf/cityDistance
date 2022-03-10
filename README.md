# cityDistance

Small Http service to get the trip-distance between two cities, calculated via valhalla route-api.
Caches previous requests.

# Requirements
Julia Packages
    `HTTP`
    `JSON`
    `URIs`

# Usage

```julia src/cityDistance.jl```

## HTTP GET Example

```http://127.0.0.1:8081/?city1=Berlin&city2=Oldenburg```
