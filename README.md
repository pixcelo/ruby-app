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

データベースの設定
```config/database.yml
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


# Reference
- [Ruby on Rails](https://rubyonrails.org/)