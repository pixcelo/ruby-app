class CommentsController < ApplicationController
    def create
        @article = Article.find(params[:article_id])

        # createでコメントの作成と保存を同時に行う
        @comment = @article.comments.create(comment_params)
        redirect_to article_path(@article)
    end
    
    private
        def comment_params
          params.require(:comment).permit(:commenter, :body, :status)
        end
end
