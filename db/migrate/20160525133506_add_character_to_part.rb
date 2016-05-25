class AddCharacterToPart < ActiveRecord::Migration
  def change
    add_column :parts, :character, :string
  end
end
