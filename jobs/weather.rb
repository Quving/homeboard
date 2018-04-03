require 'net/http'
require 'json'


def get_weather
    openweather_api_key=ENV["OPENWEATHER_API_KEY"]
    hamburg_id = '2911288'
    uri = URI('http://api.openweathermap.org/data/2.5/weather?id='+ hamburg_id + '&APPID='+openweather_api_key+'&units=metric')
    return Net::HTTP.get(uri) # => String
rescue => e
    puts "failed #{e}"
end

weather_json = JSON.parse(get_weather())
temperature_celsius = weather_json["main"]["temp"]

points = []
points << { x: 0, y: temperature_celsius}
last_x = points.last[:x]

SCHEDULER.every '300s' do
    weather_json = JSON.parse(get_weather())
    temperature_celsius = weather_json["main"]["temp"]
    temperature_celsius_min = weather_json["main"]["temp_min"]
    temperature_celsius_max = weather_json["main"]["temp_max"]
    humidity = weather_json["main"]["humidity"]
    weather_main = weather_json["weather"][0]["main"]
    weather_description = weather_json["weather"][0]["description"]

    points.shift
    last_x += 1
    points << { x: last_x, y: temperature_celsius}
    send_event('weather', points: points)
end

