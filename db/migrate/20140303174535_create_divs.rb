class CreateDivs < ActiveRecord::Migration
  def change
    create_table :divs do |t|

      t.timestamps
    end
  end
end
