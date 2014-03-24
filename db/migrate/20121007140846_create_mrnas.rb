class CreateMrnas < ActiveRecord::Migration
  def up
    create_table :mrnas do |t|
      t.integer :chromosome
      t.string  :strand
      t.integer :start
      t.integer :stop
      t.text    :_ref_seq

      t.boolean :good_quality
      t.string  :bad_quality_reason
    end

    add_index :mrnas,
              [:id],
              :name => 'mrna__id'
    add_index :mrnas,
              [:good_quality],
              :name => 'mrna__good_quality'
  end

  def down
    drop_table :mrnas
  end
end
