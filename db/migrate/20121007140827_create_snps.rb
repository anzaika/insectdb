class CreateSnps < ActiveRecord::Migration
  def up
    create_table :snps do |t|
      t.integer :chromosome
      t.integer :position
      t.integer :sig_count
      t.float   :aaf
      t.text    :alleles
    end

    add_index :snps,
              [:chromosome, :position, :sig_count, :aaf],
              :name => 'snps__chr_sigcount_pos_aaf'
  end

  def down
    drop_table :snps
  end
end
