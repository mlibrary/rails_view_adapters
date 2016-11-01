class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.time :join_date
      t.string :secret
      t.boolean :admin
      t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
