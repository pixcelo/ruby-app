class Article < ApplicationRecord
    has_many :comments # 記事とコメントは 1:N

    # 必須項目
    validates :title, presence: true
    # 必須項目、文字数指定(10文字以上)
    validates :body, presence: true, length: { minimum: 10 }
end
