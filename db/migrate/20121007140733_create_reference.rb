class CreateReference < ActiveRecord::Migration
  def up
    create_table :reference do |t|
      t.integer :chromosome
      t.integer :position
      t.string  :dmel
      t.string  :dsim
      t.string  :dyak
    end

    add_index :reference,
              [:chromosome, :position],
              :name => 'ref__chr_pos'
  end

  def down
    drop_table :reference
  end
end
