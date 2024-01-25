class Article < ApplicationRecord
    include Visible

    # 記事とコメントは 1:N
    #has_many :comments

    # 記事を削除した場合に、関連付けられたコメントも削除する
    has_many :comments, dependent: :destroy

    # 必須項目
    validates :title, presence: true
    # 必須項目、文字数指定(10文字以上)
    validates :body, presence: true, length: { minimum: 10 }
end
