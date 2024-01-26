# API
## 1.環境変数の管理
### dotenv gemの追加
`dotenv`` gemを使用することで、アプリケーションの実行時に.envファイルから環境変数を読み込むことができます。<br>
まず、Gemfileにdotenv-railsを追加し、bundle installを実行します。

```rb
# Gemfile
gem 'dotenv-rails', groups: [:development, :test]
```
### .envファイルの作成
プロジェクトのルートディレクトリに.envファイルを作成します。ここに環境変数を定義します。
```
# .env
OPEN_WEATHER_MAP_API_KEY=your_api_key_here
```
このファイルにAPIキーやデータベースのパスワードなど、機密情報を記述します。
### 環境変数の使用
アプリケーション内で環境変数にアクセスするには、ENVオブジェクトを使用します。
```
api_key = ENV['OPEN_WEATHER_MAP_API_KEY']
```
コンソールで確認する方法
```
rails c
irb(main):001> ENV['OPEN_WEATHER_MAP_API_KEY']
```
### 注意点
注意点:
セキュリティ: .envファイルには機密情報が含まれるため、絶対にソースコードリポジトリ（特に公開リポジトリ）にはコミットしないでください。.gitignoreファイルに.envを追加して、リポジトリに含まれないようにします。

環境ごとの管理: 開発、テスト、本番など異なる環境で異なる設定を適用する場合は、.env.development、.env.test、.env.productionなどのように環境ごとのファイルを作成することができます。

本番環境: 本番環境（例えばHerokuやAWSなど）では、環境変数はホスティングサービスの設定を通じて直接設定することが一般的です。


## 2.OpenWeatherMap APIを叩くためのステップ
### Gemのセットアップ:
まず、Gemfileにhttpartyを追加し、bundle installを実行します。
```
# Gemfile
gem 'httparty'
```
### サービスクラスの作成
OpenWeatherMap APIを叩くためのサービスクラスを作成します。
```rb
# app/services/open_weather_map_client.rb
class OpenWeatherMapClient
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/2.5'

  def initialize(api_key)
    @api_key = api_key
  end

  def get_weather(city)
    self.class.get("/weather?q=#{city}&appid=#{@api_key}")
  end
end
```

### コントローラでの使用
```
rails generate controller Weather
```
このサービスクラスをコントローラから呼び出して、特定の都市の天気情報を取得します。
```rb
# app/controllers/weather_controller.rb
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
```

サービスクラスを定義
```rb
# app/controllers/weather_controller.rb
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
```

ビューを追加
```erb
# app/views/weather/show.html.erb
<h1>Weather Information</h1>

<% if @weather_data %>
  <p>City: <%= @weather_data["name"] %></p>
  <p>Temperature: <%= @weather_data["main"]["temp"] %>°C</p>
  <p>Humidity: <%= @weather_data["main"]["humidity"] %>%</p>
  <p>Description: <%= @weather_data["weather"][0]["description"] %></p>
<% else %>
  <p>No weather data available.</p>
<% end %>
```

このコードは、params[:city]で指定された都市の天気情報を取得します。
### エラーハンドリングとJSONの扱い]
エラーハンドリングを行い、JSONレスポンスを適切に処理する
```rb
def get_weather(city)
  response = self.class.get("/weather?q=#{city}&appid=#{@api_key}")
  raise "Error: #{response.code}" unless response.success?
  JSON.parse(response.body)
end
```

ルーティング追加
```rb
get "weather", to: "weather#show"
get "weather/:city", to: "weather#show"
```