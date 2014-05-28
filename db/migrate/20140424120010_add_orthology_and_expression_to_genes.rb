class AddOrthologyAndExpressionToGenes < ActiveRecord::Migration
  def change
    add_column :genes, :orthology_pattern, :string
    add_column :genes, :expression_pattern, :string
  end
end
