require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'


def get_latest_post(json)
    json["data"]["posts"].each do |post|
        title = post["title"]
        post["images"].keys.each do |key|
            url = post["images"][key]["url"]
            if (url.end_with? "jpg" and post["type"].eql? "Photo") or ( url.end_with? "mp4" and post["type"].eql? "Animated")
                return {"url" => url, "title" => title}
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
latest_post = get_latest_post(json)

url_post = latest_post["url"]
agent.get(url_post).save! "9gag_medias/media#{File.extname(url_post)}"
