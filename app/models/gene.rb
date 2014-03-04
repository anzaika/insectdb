class Gene < ActiveRecord::Base
  validates :flybase_id,
            :presence => true
end
