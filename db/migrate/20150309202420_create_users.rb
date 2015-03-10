class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :gr_id
      t.string :username

      t.timestamps
    end
  end
end
