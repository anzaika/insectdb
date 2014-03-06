class CreateMrnasSegments < ActiveRecord::Migration
  def up
    create_table :mrnas_segments, :id => false do |t|
      t.integer :mrna_id
      t.integer :segment_id
    end

    add_index :mrnas_segments,
              [:mrna_id],
              :name => 'mrnas_segments__mrna_id'
    add_index :mrnas_segments,
              [:segment_id],
              :name => 'mrnas_segments__segment_id'
  end

  def down
    drop_table :mrnas_segments
  end
end
