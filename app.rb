# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

airlines_table = DB.from(:airlines)
votes_table = DB.from(:votes)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts airlines_table.all
    @airlines = airlines_table.all.to_a
    view "airlines"
end

get "/airlines/:id" do
    @airline = airlines_table.where(id: params[:id]).to_a[0]

    @love_count = votes_table.where(airline_id: @airline[:id], love: true).count
    @hate_count = votes_table.where(airline_id: @airline[:id], love: false).count
    view "airline"
end

get "/airlines/:id/votes/new" do
    puts "params: #{params}"
    
    @airline = airlines_table.where(id: params[:id]).to_a[0]
    view "new_vote"
end

get "/airlines/:id/votes/create" do
    puts "params: #{params}"

    @airline = airlines_table.where(id: params["id"]).to_a[0]

    votes_table.insert(
        airline_id: @airline[:id],
        user_id: session["user_id"],
        date: params["date"],
        love: params["love"],
        testimonial: params["testimonial"],
    )

    view "create_vote"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts "params: #{params}"

    existing_user = users_table.where(email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
        users_table.insert(
            name: params["name"],
            email: params["email"],
            password: BCrypt::Password.create(params["password"])
        )

        redirect "/logins/new"
    end
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts "params: #{params}"

    @user = users_table.where(email: params["email"]).to_a[0]

    if @user
        if BCrypt::Password.new(@user[:password]) == params["password"]
            session["user_id"] = @user[:id]
            redirect "/" 
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    redirect "/logins/new"
end

