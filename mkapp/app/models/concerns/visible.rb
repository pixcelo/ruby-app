module Visible
    extend ActiveSupport::Concern
  
    # 記事のステータス
    VALID_STATUSES = ['public', 'private', 'archived']
  
    included do
      validates :status, inclusion: { in: VALID_STATUSES }
    end
  
    # 記事の件数(クラスメソッドも追加できる)
    class_methods do
      def public_count
        where(status: 'public').count
      end
    end
  
    def archived?
      status == 'archived'
    end
  end