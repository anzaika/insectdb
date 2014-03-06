class CreateGenes < ActiveRecord::Migration
  def up
    create_table :genes, :id => false do |t|
      t.integer :id
      t.string  :flybase_id
    end
    execute("ALTER TABLE genes ADD PRIMARY KEY (id)")
  end

  def down
    drop_table :genes
  end
end
