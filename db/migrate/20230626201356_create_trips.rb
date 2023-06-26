class CreateTrips < ActiveRecord::Migration[7.0]
  def change
    create_table :trips do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.bigint :distance
      t.string :activity_type
      t.string :confidence
      t.references :start_location, foreign_key: { to_table: :locations }
      t.references :end_location, foreign_key: { to_table: :locations }
      t.timestamps
    end
  end
end
