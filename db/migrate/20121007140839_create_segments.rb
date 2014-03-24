class CreateSegments < ActiveRecord::Migration
  def up
    create_table :segments do |t|
      t.integer :chromosome
      t.integer :start
      t.integer :stop
      t.integer :length
      t.string  :type
      t.text    :_ref_seq

      t.string :inclusion_pattern
      t.string :segment_gain
    end

    add_index :segments,
              [:id],
              :name => 'segment__id'

    add_index :segments,
              [:type, :chromosome],
              :name => 'segments__type_chromosome'
  end

  def down
    drop_table :segments
  end
end
