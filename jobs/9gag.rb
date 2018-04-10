require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'json'


def extract_latest_posts_from_json(json)
    latest = {}
    json["data"]["posts"].each do |post|
        title = post["title"].sub! "&#039;", "'"
        puts title
        post["images"].keys.each do |key|
            url = post["images"][key]["url"]
            ratio =  post["images"][key]["width"].to_f / post["images"][key]["height"].to_f

            isPhoto = (url.end_with? "jpg") and (post["type"].eql? "Photo")
            isAnimation = (url.end_with? "mp4") and (post["type"].eql? "Animated")

            if isPhoto and ratio > 1
                unless latest.has_key? "latest_photo"
                    latest["latest_photo"] =  {"url" => url, "title" => title , "type" => post["type"], "ratio" => ratio}
                end
            end

            if isAnimation and ratio > 1
                unless latest.has_key? "latest_animation"
                    latest["latest_animation"] =  {"url" => url, "title" => title , "type" => post["type"], "ratio" => ratio}
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
    if latest_posts.key?("latest_photo")
        send_event("9gag-image", {title: latest_posts["latest_photo"]["title"], url: latest_posts["latest_photo"]["url"]})
    else
        puts "No keys found. #{latest_posts}"
    end
    if latest_posts.key?("latest_animation")
        send_event("9gag-video", {title: latest_posts["latest_animation"]["title"], url: latest_posts["latest_animation"]["url"]})
    else
        puts "No keys found. #{latest_posts}"
    end
end
