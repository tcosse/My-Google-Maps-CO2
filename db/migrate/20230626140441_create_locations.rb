class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.bigint :latitude
      t.bigint :longitude
      t.timestamps
    end
  end
end
