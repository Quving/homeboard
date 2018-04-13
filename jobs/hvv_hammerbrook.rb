require 'net/http'
require 'json'

def get_icon(line)
    return "http://www.geofox.de/icon_service/line?lineKey=ZVU-DB:#{line}_ZVU-DB_S-ZVU&height=17"
end
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

    if departures_json.key?("departures")
        departures_json["departures"].each do |line|
            line_description = line["line"]["name"]
            line_direction = line["line"]["direction"]
            line_timeoffset = if line["timeOffset"].eql? 0 then "now" else "#{line["timeOffset"]}m" end
            hvv_departures[line_direction+line_description+"#{line_timeoffset}"] = {url: get_icon(line_description), label: "   " + line_direction, value: "#{line_timeoffset}"}
        end
    else
        hvv_departures["outofservice"] = {label: "Currently out of service.", value: ""}
    end
    send_event('hvv_hammerbrook', { items: hvv_departures.values})
end
