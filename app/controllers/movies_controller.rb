
class MoviesController < ApplicationController
  
  Tmdb::Api.key("8cb26e052ead7ca74eda6261beb93fd5")
  
  
  def index
    movies = Tmdb::Movie.now_playing
    puts movies
    @movies = []
    movies.each do |movie|
      if Movie.where(tmdb: movie.id ).count > 0
        @movies.push(Movie.where(tmdb: movie.id ).first)
        
      else
        
        configuration = Tmdb::Configuration.new
      
        base_url = configuration.secure_base_url
        poster_size = configuration.poster_sizes.last
        profile_size = configuration.profile_sizes.last
        
        title = movie.title
        plot = movie.overview
        release_year = movie.release_date
        rating = movie.vote_average/2
        @imdb = movie.imdb_id
        
        tagline = Tmdb::Movie.detail(movie.id)["tagline"]
        
        puts tagline
        
        if Tmdb::Movie.images(movie.id)['posters'].size > 0
          poster_path = base_url+poster_size+Tmdb::Movie.images(movie.id)['posters'][0]["file_path"]
        end
        
        
        @movie = Movie.new(movie_params)
        if @movie.save!
          @movie.update(title: title, release_year: release_year, image: poster_path, plot: plot, tmdb: movie.id, imdb: @imdb, rating: rating, tagline: tagline)
        end
        
        cast = Tmdb::Movie.casts(movie.id)
        
        if cast.size > 8
          for i in 0..7 
          
          # If an actor is already in our DB we don't add it again, but just push it into the @actors array
            actor = Actor.where(name: cast[i]["name"]).first
            if !actor.nil? 
              @movie.actors << actor
              Part.where(actor_id: actor.id, movie_id: @movie.id).first.update(character: cast[i]["character"])
            else
              actor = Actor.new(actor_params)
              if !cast[i]["profile_path"].nil?
                profile_image = base_url+profile_size+cast[i]["profile_path"]
              else
                next
              end
              if actor.save!
                actor.update(name: cast[i]["name"], character: cast[i]["character"], image: profile_image)
                @movie.actors << actor
                Part.where(actor_id: actor.id, movie_id: @movie.id).first.update(character: cast[i]["character"])
              end
            end
            
          end
        end
        @movies.push(@movie)
        
          
      end
      
    end
    puts @movies
  end
  
  def show
  	@movie = Movie.find(params[:id])
    @actors = @movie.actors
    @trailer_url = "https://www.youtube.com/embed/"+Tmdb::Movie.trailers(@movie.tmdb)["youtube"][0]["source"]+"?autoplay=0"
  end
  
  
  def search
    
    puts params
    
    @id = params[:search]
    
    
    
    @search = Tmdb::Search.new
    @search.resource('movie')
    @search.query(@id) 
    @movie_results = @search.fetch
    #@movie_results = Tmdb::Movie.now_playing
    @movies = []
    i = 0
    @movie_results.each do |movie|
      if ((!Tmdb::Movie.images(movie["id"])['posters'].nil?) && (!Tmdb::Movie.casts(movie["id"]).nil?))
        puts "iteration "+i.to_s
        puts Tmdb::Movie.casts(movie["id"])
        @movies.push(movie)
        i+=1
      end
    end
    render 'movie_results'
    
  end
  
  def add_movie
    
    tmdb_id = params[:id]
    
    # If a movie is already in our db then render the show page of that movie
    
    if Movie.where(tmdb: tmdb_id).count > 0 
      @movie = Movie.where(tmdb: tmdb_id).first
      @actors = @movie.actors
      render 'show'
    else
    
    # If it's not, then we retrieve the movie's informations and store it in the db
    
      configuration = Tmdb::Configuration.new
      
      @base_url = configuration.secure_base_url
      @poster_size = configuration.poster_sizes.last
      @profile_size = configuration.profile_sizes.last
      
      movie = Tmdb::Movie.detail(tmdb_id)
      title = movie["title"]
      plot = movie["overview"]
      release_year = movie["release_date"]
      rating = movie["vote_average"]/2
      @imdb = movie["imdb_id"]
      tagline = movie["tagline"]
      
      
      if Tmdb::Movie.images(tmdb_id)['posters'].size > 0
        poster_path = @base_url+@poster_size+Tmdb::Movie.images(tmdb_id)['posters'][0]["file_path"]
      end
      
      
      @movie = Movie.new(movie_params)
      if @movie.save!
        @movie.update(title: title, release_year: release_year, image: poster_path, plot: plot, tmdb: tmdb_id, imdb: @imdb, rating: rating, tagline: tagline)
      end
      @trailer_url = "https://www.youtube.com/embed/"+Tmdb::Movie.trailers(tmdb_id)["youtube"][0]["source"]+"?autoplay=0"
     
      cast = Tmdb::Movie.casts(tmdb_id)
      
      if cast.size > 0
        for i in 0..7 
        # If an actor is already in our DB we don't add it again, but just push it into the @actors array
          actor = Actor.where(name: cast[i]["name"]).first
          if !actor.nil? 
            @movie.actors << actor
            Part.where(actor_id: actor.id, movie_id: @movie.id).first.update(character: cast[i]["character"])
          else
            if cast[i]["profile_path"].size > 0
              actor = Actor.new(actor_params)
              profile_image = @base_url+@profile_size+cast[i]["profile_path"]
            else
              next
            end
            if actor.save!
              actor.update(name: cast[i]["name"], character: cast[i]["character"], image: profile_image)
              @movie.actors << actor
              Part.where(actor_id: actor.id, movie_id: @movie.id).first.update(character: cast[i]["character"])
            end
          end
          
        end
      end
      @actors = @movie.actors
      render :show
    end
  end
  
  private 
    def movie_params
      { "title" => "test", "plot" => "test"}
    end
    def actor_params
      { "name" => "test", "character" => "test"}
    end
end
