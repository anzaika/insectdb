class CreateGenesMrnas < ActiveRecord::Migration
  def up
    create_table :genes_mrnas, :id => false do |t|
      t.integer :gene_id
      t.integer :mrna_id
    end

    add_index :genes_mrnas,
              [:gene_id],
              :name => 'genes_mrnas__gene_id'

    add_index :genes_mrnas,
              [:mrna_id],
              :name => 'genes_mrnas__mrna_id'
  end

  def down
    drop_table :genes_mrnas
  end
end
