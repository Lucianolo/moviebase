class Actor < ActiveRecord::Base
    has_many :parts 
    has_many :movies, through: :parts
    
    
    def character_in(movie)
        part = Part.where(actor_id: self.id, movie_id: movie.id).first
        part.character
    end
end
