![Landing Page](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/01_landing_page.png "Landing Page")

> *Watch the [Product Demo Video](https://www.youtube.com/watch?v=GVh5b7ZRkec "Product Demo") on YouTube*

Shelfworm is your bookshelf's home on the web.  Users simply log in with their Goodreads account and pick a custom URL, and Shelfworm creates a clean virtual bookshelf, finding the best cover image online for each book in their collection.  Hovering over each book cover reveals additional information, including the user's rating and written review, and a variety of other information from Goodreads.  Users can edit book covers or delete books entirely, if they don't want them to appear on their bookshelf.  Changes to a user's information on Goodreads can be synced to Shelfworm with the click of a button, without overwriting previous custom changes to their bookshelf on Shelfworm.  Due to the large size of many users' bookshelves, books are loaded incrementally as viewers scroll down the page ("infinie scrolling").

This was a solo project built in one week at Dev Bootcamp.

## Screen Grabs
#### 1) Authorize App via Goodreads
* Granting access to Goodreads enables Shelfowrm to create a bookshelf with existing information, so users don't need to enter the same information twice
* Authenticating via Goodreads also serves as the user's authentication to Shelfworm, eliminating the need to create or remember another login/password

![Authorizing Goodreads](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/02_goodreads_authorize.png "Authorizing Goodreads")

#### 2) Bookshelf (top)
* Books are organized first by rating, and then alphabetically
* Bookshelf is visible to anyone with the URL (e.g. www.shelfworm.com/berkjon)
* Navigation bar at top only visible to logged-in user
  * Visitors cannot make changes to another person's bookshelf

![Bookshelf - Top](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/03_bookshelf_top.png "Bookshelf - Top")

#### 3) Hover Rotation
* On mouse hover, cover images rotate to reveal detailed information about the book

![Hover Rotation](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/04_hover_rotation.png "Hover Rotation")

#### 4) Book Details
* Details include the user's rating and written review, publisher description, community average rating, and links to the book on Goodreads and Amazon

![Book Details](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/05_book_details.png "Book Details")

#### 5) Infinite Scrolling
* When viewing a bookshelf, new books are loaded incrementally as the user scrolls down
  * This eliminates speed issues associated with loading a user's full bookshelf at once
  * When a user creates their bookshelf for the first time, this also allows them to begin exploring it almost immediately, while a Resque background job continues to load the remaining books into the database

![Infinite Scrolling](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/06_infinite_scrolling.png "Infinite Scrolling")

#### 6) Edit / Update Book Information
* Users can update cover images for books, or delete books from Shelfworm entirely
* If a user specifies a cover image for a book, this will not be overwritten when they re-sync their Goodreads collection to Shelfworm

![Edit and Delete](https://raw.githubusercontent.com/berkjon/shelfworm/master/public/img/screenshots/07_update_information.png "Edit and Delete")

## Technologies
* Ruby
* Sinatra web framework
* JavaScript and jQuery (infinite scrolling)
* AJAX (infinite scrolling)
* Redis and Resque (background job queuing)
* CSS3 for hover effects
* PostgreSQL database on Heroku
* Nokogiri and HTTParty Ruby gems
* Goodreads API & OAuth 1.0
* OpenLibrary API (additional cover images)
* LibraryThing API (additional cover images)