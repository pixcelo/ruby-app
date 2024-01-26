class OpenWeatherMapClient
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/2.5'

  def initialize(api_key)
    @api_key = api_key
  end

  def get_weather(city)
    self.class.get("/weather?q=#{city}&appid=#{@api_key}&lang=ja&units=metric")
  end
end
