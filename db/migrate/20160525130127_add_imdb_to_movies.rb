class AddImdbToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :imdb, :string
  end
end
