class Gene < ActiveRecord::Base
  has_and_belongs_to_many :mrnas
  has_many :segments, :through => :mrnas

  scope :age_oldest, -> { where("orthology_pattern = '111111111111'")}
  scope :age_old,    -> { where("orthology_pattern = '111111110000'")}
  scope :age_new,    -> { where("orthology_pattern = '111111000000'")}
  scope :age_newest, -> { where("orthology_pattern = '111110000000'")}

  scope :exp_up,   -> { where("expression_pattern = '>>='")}
  scope :exp_down, -> { where("expression_pattern = '<<='")}
  scope :exp_same, -> { where("expression_pattern = '==='")}
  scope :exp_all,  -> { where("expression_pattern in ('===', '>>=', '<<=')")}
end
