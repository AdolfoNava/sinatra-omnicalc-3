require "sinatra"
require "sinatra/reloader"
require "http"
require 'sinatra/cookies'
get("/") do
  erb(:main)
end
get("/umbrella") do
  erb(:umbrellaForm)
end

post("/process_umbrella") do
  @user_location = params.fetch("user_location")
  url_encoded_string = @user_location.gsub(" ", "+")
  @gmaps_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_encoded_string}&key=#{@gmaps_key}"

  @raw_response = HTTP.get(gmaps_url).to_s
  @parsed_response = JSON.parse(@raw_response)
  @lat = @parsed_response.fetch("results").at(0).fetch("geometry").fetch("location").fetch("lat")
  @long = @parsed_response.fetch("results").at(0).fetch("geometry").fetch("location").fetch("lng")

  pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
  pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{@lat},#{@long}"

  @pirate_response = JSON.parse(HTTP.get(pirate_weather_url).to_s)
  @temp = @pirate_response.fetch("currently").fetch("temperature")
  @skies = @pirate_response.fetch("currently").fetch("summary")

  hourly_data_array = @pirate_response.fetch("hourly").fetch('data')

  next_twelve_hours = hourly_data_array[1..12]

  precip_prob_threshold = 0.10

  any_precipitation = false

  next_twelve_hours.each do |hour_hash|
    precip_prob = hour_hash.fetch("precipProbability")

    if precip_prob > precip_prob_threshold
      any_precipitation = true

      precip_time = Time.at(hour_hash.fetch("time"))

      seconds_from_now = precip_time - Time.now

      hours_from_now = seconds_from_now / 60 / 60

      puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
    end
  end

  if any_precipitation == true
    @answer = "You might want to take an umbrella!"
  else
    @answer =  "You probably won't need an umbrella."
  end
  erb(:umbrellaAnswer)
end
get("/message") do
  erb(:aiMessage)
end
post("/process_single_message") do
  @message = params.fetch("the_message")
  erb(:aiMessage)
end
get("/chat") do
  erb(:chat)
end
post("/add_message_to_chat") do
  cookies.store('uMessage',params.fetch('user_message'))
  #api side
  client = OpenAI::Client.new(
  access_token: ENV.fetch('OPENAI_API_KEY'),
  log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production.
)
  #gptkey= 
  #cookies.store('aiMessage',)
  erb(:chat)
end
post("/clear_chat") do
  erb(:chat)
end
