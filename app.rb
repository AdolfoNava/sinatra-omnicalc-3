require "sinatra"
require "sinatra/reloader"
require "http"
get("/") do
  erb(:main)
end
get("/umbrella") do
  erb(:umbrellaForm)
end

post("/process_umbrella") do
  @user_location = params.fetch('user_location')
  url_encoded_string = @user_location.gsub(' ','+')
  @gmaps_key = ENV.fetch('GMAPS_KEY')
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_encoded_string}&key=#{@gmaps_key}"

  @raw_response = HTTP.get(gmaps_url).to_s
  @parsed_response = JSON.parse(@raw_response)
  @lat = @parsed_response.fetch('results').at(0).fetch('geometry').fetch('location').fetch('lat')
  @long = @parsed_response.fetch('results').at(0).fetch('geometry').fetch('location').fetch('lng')

  pirate_weather_key = ENV.fetch('PIRATE_WEATHER_KEY')
  pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{@lat},#{@long}"

  @pirate_response = JSON.parse(HTTP.get(pirate_weather_url).to_s)
  @temp = @pirate_response.fetch('currently').fetch('temperature')
  @skies= @pirate_response.fetch('currently').fetch('summary')
  #@api = ''
  erb(:umbrellaAnswer)
end
get('/message') do 
  erb(:aiMessage)
end
post('/process_single_message') do
  @message = params.fetch('the_message')
  erb(:aiMessage)  
end
get('/chat') do
  erb(:chat)
end
post("/add_message_to_chat") do
  erb(:chat)
end
post("/clear_chat") do
  erb(:chat)
end 
