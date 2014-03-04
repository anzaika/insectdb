class MrnasSegments < ActiveRecord::Base
  self.table_name = 'mrnas_segments'

  validates :mrna_id,
            :presence => true,
            :numericality => { :only_integer => true }

  validates :segment_id,
            :presence => true,
            :numericality => { :only_integer => true }
end
