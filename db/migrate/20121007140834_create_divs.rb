class CreateDivs < ActiveRecord::Migration
  def up
    create_table :divs do |t|
      t.integer :chromosome
      t.integer :position
      t.text    :alleles
    end

    add_index :divs,
              [:chromosome, :position],
              :name => 'divs__chr_pos'
  end

  def down
    drop_table :divs
  end
end
