class CreateRides < ActiveRecord::Migration[5.1]
  def change
    create_table :rides do |t|
      t.string :from_location
      t.string :to_location
      t.decimal :miles
      t.datetime :day
    end
  end
end
