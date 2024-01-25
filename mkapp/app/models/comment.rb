class Comment < ApplicationRecord
  include Visible

  belongs_to :article # コメントは記事に属する
end
