class CreateFeelings < ActiveRecord::Migration[5.1]
  def change
    create_table :feelings do |t|
      t.integer :ride_id
      t.string :feeling_description
    end
  end
end
