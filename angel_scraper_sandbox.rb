

require 'rubygems'
require 'json'
require 'csv'
require 'curb'
require 'pry'


puts "Scraper Initialized"

# location => id hash
locations = {"austin" => 1617, "washington, dc" => 1691, "philadelphia" => 1671, "miami" => 1657, "new york, ny" => 1664}

#split hash into city and id arrays
cities = locations.keys 
ids = locations.values

puts "cities are #{cities}"
puts "id are #{ids}"

#number of pages of data, indexed by location
pages_per_location = Array.new

ids.each {
    |location| 
        count = JSON.parse(Curl::Easy.perform("https://api.angel.co/1/tags/#{location}/users?include_children=true&investors=by_residence").body_str)["last_page"]

        pages_per_location << (1..count).to_a #outputs  [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]], seems fine...
}

#page counter for locations
page_counter = Hash[cities.zip pages_per_location]

#create 3 hashes of arrays to store: angels, angel_names, and angel_links ex. angels = {"boston" => [array of angels], "new_york" => [array of angels]}
angels = Hash[cities.map { |c| [c, []] }]
angel_names = Hash[cities.map { |c| [c, []] }]
angel_links = Hash[cities.map { |c| [c, []] }]

#loop through the locations hash for each location
locations.each {
    |city, id|

        #get every page of data
        page_counter["#{city}"].each {
            |page_number| json = Curl::Easy.perform("https://api.angel.co/1/tags/#{id}/users?include_children=true&investors=by_residence&page=#{page_number}").body_str
            
            investors = JSON.parse(json)['users']
            
            #filter out investors w/ blank angellist profiles
            filtered_investors = Array.new

            investors.each {
                |i| if i["angellist_url"] != nil && i["name"] != nil
                    filtered_investors << i
                    end
            }

            #check roles and grab angels
            filtered_investors.each {
                |investor| investor['roles'].each {
                    |role| role["id"]
                    if role["id"] == 9300
                        angels["#{city}"]<<investor
                    end
                }
            }

            #eliminate duplicates
            angels["#{city}"]= angels["#{city}"].uniq

            #add names & links to angel_names array
            angels["#{city}"].each {
                |i| 

                a = Array.new

                a << i["name"]

                a << i["angellist_url"]

                angel_names["#{city}"] << a


            }

            #eliminate duplicates
            angel_names["#{city}"] = angel_names["#{city}"].uniq
        }

        puts angel_names["#{city}"].count

        puts angel_links["#{city}"].count


       #format names & links into two columns
        export_data = angel_names["#{city}"]

        #create, write, and save new .CSv file for each location
        CSV.open("#{city}.csv", 'wb') do |csv|
            export_data.each do |row|
                csv << row
            end
        end

        puts "#{city} finished"
}

puts "Scraper finished"






