class Comment < ApplicationRecord
  belongs_to :article # コメントは記事に属する
end
