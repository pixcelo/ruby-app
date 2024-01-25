# ruby-app

## Install
### Ruby
[RubyInsaller](https://rubyinstaller.org/downloads/)<br>
Ruby + Devkit 3.2.2-1(x64)

インストール確認
```
ruby --version
ruby 3.2.2 (2023-03-30 revision e51014f9c0) [x64-mingw-ucrt]
```

### Rails
Rubyのパッケージ管理システム(npmやNuget的なやつ？)
```
gem update --system
gem install bundler
```

Successfully installed bundler-2.5.5

Rails 
```
gem install rails
```

管理者権限を付与して実行しないと失敗する
```
エラー: 処理を始められませんでした (データベースをロックできません)
エラー: データベースをロックできませんでした: Permission denied
pacman failed with the following output:
Building native extensions. This could take a while...
ERROR:  Error installing rails:
        ERROR: Failed to build gem native extension.
```

インストール確認
```
rails -v
Rails 7.1.3
```

## プロジェクト作成

オプションでデータベースを指定
```
rails new myapp --database=postgresql
```

データベースの設定<br>
`config/database.yml`
```
default: &default
  adapter: postgresql
  encoding: unicode

development:
  <<: *default
  database: myapp_development
  username: myuser
  password: mypassword
  host: localhost
```

データベースの作成
```
cd mkapp
bundle install
rails db:create
```

## サーバー起動
`rails s`でもOK
```
rails server
```

## bundle installが失敗する場合
1. [mingw-w64-x86_64-libyaml-0.2.5-2-any.pkg.tar.zst](https://packages.msys2.org/package/mingw-w64-x86_64-libyaml)をインストール
2. [zstd](https://github.com/facebook/zstd/releases)をインストールして解凍後、tarコマンドで解凍
3. 解凍したファイルを以下に配置後、再度`bundle install`
```
Ruby32-x64\include\ruby-3.2.0\yaml.h
Ruby32-x64\lib\libyaml.a
Ruby32-x64\lib\libyaml.dll.a
```

## ルーティング
`config\routes.rb`に記述
```rb
Rails.application.routes.draw do
  get "/articles", to: "articles#index"
end
```
GET /articlesリクエストをArticlesControllerのindexアクションに対応付け

初期表示画面を設定したい場合は、以下のようにルーティングする
```rb
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

## コントローラー作成
```
rails generate controller Articles index --skip-routes
```

複数のアクションを一度に作成する場合
```
rails generate controller Articles index show new create update delete
```

不要なコントローラーを消したい場合
```
rails destroy controller Articles
```

## モデル作成
モデル名は常に英語の「単数形」で表記
 ```
 rails generate model Article title:string body:text
 ```

## データベースマイグレーション
コードファーストで記述<br>
`db/migrate/`に作成される

マイグレーション実行
```
rails db:migrate
```
id,title,body,created_at,update_atカラムを持つarticlesテーブルが作成された

## モデル ⇔　データベースのやりとり
`article.save`まで行うとデータベースにレコードが追加された<br>
consoleに入力補完が出てきてとても便利
```
rails console
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
article.save
```

## データベースのデータを取り出す
`app/controllers/articles_controller.rb`<br>
コントローラ内のインスタンス変数（@で始まる変数）は、ビューから参照可
```rb
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

`app/views/articles/index.html.erb`
```html
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```
- `<% %>`はRubyコードをインラインで書くためのタグ（画面に非表示）
- `<%= %>`は値を返す（画面に表示）

## CRUD
### READ
データを1件表示<br>
ルーティングに追加　`get "/articles/:id", to: "articles#show"`
```rb
Rails.application.routes.draw do
  root "articles#index"
  
  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

コントローラー側で`params[:id]`で取得
```rb
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

　# idのデータを表示
  def show
    @article = Article.find(params[:id])
  end
end
```

ビューを追加　`app/views/articles/show.html.erb`
```html
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

## リソースフルルーティング
以下のように書き換えが可能
```rb
Rails.application.routes.draw do
  root "articles#index"
  
  # get "/articles", to: "articles#index"
  # get "/articles/:id", to: "articles#show"
  resources :articles
end
```
`rails s`で同じページにアクセスできることを確認


画面遷移を`link_to`ヘルパーで簡易に書ける
```html
<ul>
  <% @articles.each do |article| %>
    <li>
       <!-- <a href="/articles/<%= article.id %>">
        <%= article.title %>
       </a> -->
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

### CREATE
作成

コントローラー側
```rb
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    # Strong Parametersによる型付け
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Strong Parameters
  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

フォームビルダー<br>
ビューを作成 `app/views/articles/new.html.erb`
```html
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

### UPDATE
共有ビュー（newとeditで共通化する）
```html
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
注意点「上記のコードは`app/views/articles/new.html.erb`のフォームと同じですが、すべての@articleをarticleに置き換えてある点にご注目ください。パーシャルのコードは共有されるので、特定のインスタンス変数に依存しないようにするのがベストプラクティスです（コントローラのアクションで設定されるインスタンス変数に依存すると、他で使い回すときに不都合が生じます）。代わりに、記事をローカル変数としてパーシャルに渡します。」

### DELETE
コントローラーに追加
```rb
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end
```

ビューに追加 `<%= javascript_include_tag "turbo", type: "module" %>`を追加しないとデリートをリクエストしても`show`がGETで呼ばれるだけだった[(参考)](https://discuss.rubyonrails.org/t/guide-v7-0-3-1-link-to-destroy-turbo-method-delete-doesnt-works-ubuntu-22-04/81326)
```html
<%= javascript_include_tag "turbo", type: "module" %>

<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>

```

## モデルの追加
アプリのrootにてコマンドで追加(関連付け（アソシエーション: association）を設定)
```
rails generate model Comment commenter:string body:text article:references
```

```
invoke  active_record
create    db/migrate/20240124222147_create_comments.rb
create    app/models/comment.rb
invoke    test_unit
create      test/models/comment_test.rb
create      test/fixtures/comments.yml
```
作成されたマイグレーションファイルで、テーブル作成の定義が確認できる<br>

```rb
class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true # 外部キー制約

      t.timestamps
    end
  end
end
```

これまで実行されていないマイグレーションだけ実行される
```
rails db:migrate

== 20240124222147 CreateComments: migrating ===================================
-- create_table(:comments)
   -> 0.0917s
== 20240124222147 CreateComments: migrated (0.0926s) ==========================
```

## コントローラの追加


# Reference
- [Ruby on Rails](https://rubyonrails.org/)
- [Railsガイド](https://railsguides.jp/)
- [Ruby on Rails forum](https://discuss.rubyonrails.org/)