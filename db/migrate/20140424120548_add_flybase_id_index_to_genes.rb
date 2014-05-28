class AddFlybaseIdIndexToGenes < ActiveRecord::Migration
  def change
    add_index :genes, 'flybase_id'
  end
end
