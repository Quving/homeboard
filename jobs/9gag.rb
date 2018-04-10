require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'

def extract_latest_posts_from_json(json)
    latest = {}
    json["data"]["posts"].each do |post|
        title = post["title"]
        post["images"].keys.each do |key|
            url = post["images"][key]["url"]
            isPhoto = (url.end_with? "jpg") and (post["type"].eql? "Photo")
            isAnimation = (url.end_with? "mp4") and (post["type"].eql? "Animated")
            if isPhoto or isAnimation
                unless latest.has_key? "latest_x"
                    latest["latest_x"] =  {"url" => url, "title" => title}
                end
            end

            if isPhoto
                unless latest.has_key? "latest_photo"
                    latest["latest_photo"] =  {"url" => url, "title" => title, "type" => post["type"]}
                end
            end

            if isAnimation
                unless latest.has_key? "latest_animation"
                    latest["latest_animation"] =  {"url" => url, "title" => title, "type" => post["type"]}
                end
            end
        end
    end
    return latest
end


# Returns the latest posted post. Can be type of photo as well as animation.
def get_latest_posts
    agent = Mechanize.new
    page = agent.get("https://9gag.com/fresh")
    page = Nokogiri::HTML(page.body)
    page_str = page.css('script')[9].text
    json_start_idx = page_str.index("{")
    json_end_idx  = page_str.rindex("}).")
    json_str =  page_str[json_start_idx..json_end_idx]
    json = JSON.parse(json_str)
    return  extract_latest_posts_from_json(json)
end

SCHEDULER.every '10s' do
    latest_posts = get_latest_posts()
    puts latest_posts
    send_event("9gag-image", {title: latest_posts["latest_photo"]["title"], url: latest_posts["latest_photo"]["url"]})
    send_event("9gag-video", {title: latest_posts["latest_animation"]["title"], url: latest_posts["latest_animation"]["url"]})
end
