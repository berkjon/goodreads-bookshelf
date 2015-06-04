class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :isbn10
      t.string :isbn13
      t.string :publication_year
      t.string :publication_month
      t.string :num_pages
      t.text :description

      t.string :user_rating
      t.text :user_review
      t.datetime :date_added

      t.integer :gr_review_id
      t.integer :gr_book_id
      t.string :gr_avg_rating
      t.string :gr_book_url

      t.string :cover_img_url
      t.boolean :cover_img_set_by_user, default: false

      t.belongs_to :user
      t.timestamps null: false
    end
  end
end
