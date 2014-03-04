class CreateMrnas < ActiveRecord::Migration
  def change
    create_table :mrnas do |t|

      t.timestamps
    end
  end
end
