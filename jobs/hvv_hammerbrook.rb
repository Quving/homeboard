require 'net/http'
require 'json'

def get_departuretimes_hammerbrook
    url = ENV["MOBISPRING_URL"]
    uri = URI(url+'/api/geofox/departuretime')
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {"station":"Hammerbrook", "hhMMyyyy":Time.now.strftime("%d.%m.%Y"), "HHmm":Time.now.strftime("%H:%M"), "maxList":"10"}.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
    end
    return res.body
rescue => e
    puts "failed #{e}"
end

SCHEDULER.every '20s' do
    hvv_departures = {}
    departures_json = JSON.parse(get_departuretimes_hammerbrook())
    departures_json["departures"].each do |line|
        line_description = line["line"]["name"]
        line_direction = line["line"]["direction"]
        line_timeoffset = line["timeOffset"]
        hvv_departures[line_direction+line_description+"#{line_timeoffset}"] = {label: line_description + " " + line_direction, value: "#{line_timeoffset}" + "m"}
    end
    send_event('hvv_hammerbrook', { items: hvv_departures.values})
end
