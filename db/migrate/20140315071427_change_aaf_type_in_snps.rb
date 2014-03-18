class ChangeAafTypeInSnps < ActiveRecord::Migration
  def change
    remove_column :snps, :aaf
    add_column :snps, :aaf, :float
  end
end
