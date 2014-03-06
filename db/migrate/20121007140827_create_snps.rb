class CreateSnps < ActiveRecord::Migration
  def up
    create_table :snps do |t|
      t.integer :chromosome
      t.integer :position
      t.integer :sig_count
      t.integer :aaf
      t.text    :alleles
    end

    add_index :snps,
              [:chromosome, :position, :sig_count],
              :name => 'snps__chr_sigcount_pos'
  end

  def down
    drop_table :snps
  end
end
