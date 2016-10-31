class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.time :join_date
      t.string :secret

      t.timestamps
    end
  end
end
