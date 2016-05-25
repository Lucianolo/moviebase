class AddTmdbToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :tmdb, :string
  end
end
