class CreateSeqs < ActiveRecord::Migration
  def change
    create_table :seqs do |t|
      t.integer :chromosome
      t.integer :position
      t.string  :dmel
      t.string  :dsim
      t.string  :dyak
      t.text    :poly
    end
  end
end
