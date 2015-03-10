class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.integer :isbn10
      t.integer :isbn13
      t.string :publication_year
      t.string :publication_month
      t.string :num_pages
      t.string :description

      t.integer :user_rating
      t.datetime :date_added

      t.integer :gr_id
      t.string :gr_img_url
      t.integer :gr_review_id
      t.string :gr_book_url

      t.belongs_to :user
      t.timestamps
    end
  end
end
