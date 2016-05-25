class AddRatingToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :rating, :float
  end
end
