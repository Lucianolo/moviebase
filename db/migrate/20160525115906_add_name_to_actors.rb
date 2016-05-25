class AddNameToActors < ActiveRecord::Migration
  def change
    add_column :actors, :name, :string
  end
end
