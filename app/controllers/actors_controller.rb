class ActorsController < ApplicationController
    
    def index 
        @actors = Actor.all
    end
    
    def show
        @actor = Actor.find(params[:id])
        @movies = @actor.movies
        
        person = Tmdb::Person.detail(@actor.tmdb)
        
        @bio = person["biography"]
    end
end
