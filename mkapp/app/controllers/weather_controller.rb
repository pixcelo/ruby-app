class WeatherController < ApplicationController
  def show
    weather_client = OpenWeatherMapClient.new(ENV['OPEN_WEATHER_MAP_API_KEY'])
    response = weather_client.get_weather(params[:city])
    if response.success?
      @weather_data = response.parsed_response
    else
      puts response.body # ここでエラーレスポンスを出力
      @weather_data = nil
    end
  end  
end
