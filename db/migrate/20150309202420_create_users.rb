class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :gr_id
      t.string :username
      t.string :gr_oauth_token
      t.string :gr_oauth_secret
      t.string :gr_full_name

      t.timestamps
    end
  end
end
