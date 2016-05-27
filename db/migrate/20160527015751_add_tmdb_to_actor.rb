class AddTmdbToActor < ActiveRecord::Migration
  def change
    add_column :actors, :tmdb, :string
  end
end
