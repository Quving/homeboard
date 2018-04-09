require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'

def get_latest_photo(json)
    json["data"]["posts"].each do |post|
        if post["type"].eql? "Photo"
            title = post["title"]
            post["images"].keys.each do |key|
                url = post["images"][key]["url"]
                puts title
                if url.end_with? "jpg"
                    return {"url" => url, "title" => title}
                end
            end
        end
    end
end

def get_latest_animation(json)
    json["data"]["posts"].each do |post|
        if post["type"].eql? "Animated"
            title = post["title"]
            post["images"].keys.each do |key|
                url = post["images"][key]["url"]
                if url.end_with? "mp4"
                    return {"url" => url, "title" => title}
                end
            end
        end
    end
end

agent = Mechanize.new
page = agent.get("https://9gag.com")
page = Nokogiri::HTML(page.body)
page_str = page.css('script')[9].text
json_start_idx = page_str.index("{")
json_end_idx  = page_str.rindex("}).")
json_str =  page_str[json_start_idx..json_end_idx]
json = JSON.parse(json_str)
latest_animation = get_latest_animation(json)
latest_photo = get_latest_photo(json)

url_animation =  latest_animation["url"]
agent.get(url_animation).save "images/animation.mp4"
url_photo = latest_photo["url"]
# agent.get(url_photo).save "images/#{File.basename(url_photo)}"
agent.get(url_photo).save "images/photo.jpg"
