class CreateSegments < ActiveRecord::Migration
  def up
    create_table :segments, :id => false do |t|
      t.integer :id
      t.integer :chromosome
      t.integer :start
      t.integer :stop
      t.integer :length
      t.string  :type
      t.text    :_ref_seq
    end
    execute("ALTER TABLE segments ADD PRIMARY KEY (id)")

    add_index :segments,
              [:chromosome, :start, :stop],
              :name => 'segments__chr_start_stop'

    add_index :segments,
              [:type],
              :name => 'segments__type'
  end

  def down
    drop_table :segments
  end
end
