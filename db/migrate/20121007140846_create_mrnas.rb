class CreateMrnas < ActiveRecord::Migration
  def up
    create_table :mrnas, :id => false do |t|
      t.integer :id
      t.integer :chromosome
      t.string  :strand
      t.integer :start
      t.integer :stop
      t.text    :_ref_seq
    end
    execute("ALTER TABLE mrnas ADD PRIMARY KEY (id)")
  end

  def down
    drop_table :mrnas
  end
end
