# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :airlines do
  primary_key :id
  String :name
  String :founded
  String :hq 
  String :ceo 
  String :destinations 
end
DB.create_table! :votes do
  primary_key :id
  foreign_key :airline_id
  foreign_key :user_id
  Boolean :love
  String :date
  String :testimonial, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
airlines_table = DB.from(:airlines)

airlines_table.insert(name: "United Airlines", 
                    founded: "1892",
                    hq: "Salt Lake City, Utah",
                    ceo: "Fred Jones",
                    destinations: "1,456")

airlines_table.insert(name: "American Airlines", 
                    founded: "1876",
                    hq: "New York, New York",
                    ceo: "Beth Johnson",
                    destinations: "1,786")
