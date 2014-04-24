class Gene < ActiveRecord::Base
  has_and_belongs_to_many :mrnas
end
