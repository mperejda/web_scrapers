require 'rubygems'
require 'json'
require 'csv'
require 'curb'


puts "Scraper Initialized"

#create arrays to store all angels and two columns for csv writing
boston_angels = Array.new
boston_angels_names = Array.new
boston_angels_links = Array.new

#find number of pages and store
page_number_array = Array.new

number_of_pages = JSON.parse(Curl::Easy.perform("https://api.angel.co/1/tags/#{location}/users?include_children=true&investors=by_residence").body_str)["last_page"]





(1..15).each { |x| page_number_array << x}

location_array = [1620, 2390]

location_array.each {
    |location|

        page_number_array.each {
            |page_number| json = Curl::Easy.perform("https://api.angel.co/1/tags/#{location}/users?include_children=true&investors=by_residence&page=#{page_number}").body_str
            

            parsed_data = JSON.parse(json)

            investors_array = parsed_data['users']

            investors_array.each {
                |investor| investor['roles'].each {
                    |role| role["id"]
                    if role["id"] == 9300
                        boston_angels<<investor
                    end
                }
            }

            boston_angels= boston_angels.uniq

            boston_angels.each {
                |i| boston_angels_names << i["name"]
            }

            boston_angels.each {
                |i| boston_angels_links << i["angellist_url"]
            }

            table = [boston_angels_names, boston_angels_links].transpose
            CSV.open('ba_test.csv', 'ab') do |csv|
                table.each do |row|
                    csv << row
                end
            end

            puts "Names written to CSV. Page #{page_number} completed. Success!"
        }
        
    puts "Compiled names from Boston and Cambridge tags. Duplicates removed. We found #{boston_angels.count} angels in Boston"
}


