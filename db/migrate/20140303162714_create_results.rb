class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.hstore :data

      t.timestamps
    end
  end
end
