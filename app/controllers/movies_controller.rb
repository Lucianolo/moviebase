
class MoviesController < ApplicationController
  
  Tmdb::Api.key("8cb26e052ead7ca74eda6261beb93fd5")
  $configuration = Tmdb::Configuration.new
  
  $base_url = $configuration.secure_base_url
  $poster_size = "w342"
  $profile_size = "w185"
  
  def index
    movies = Tmdb::Movie.now_playing
    @movies = []
    movies.each do |movie|
      if Movie.where(tmdb: movie.id ).count > 0
        @movies.push(Movie.where(tmdb: movie.id ).first)
      else
        movie_par = Tmdb::Movie.detail(movie.id)
        @movie = Movie.new(movie_params(movie_par))
        if @movie.save!
          cast = Tmdb::Movie.casts(@movie.tmdb)
          if !cast.nil?
            add_cast(cast, @movie.id)
          end
        end
        @movies.push(@movie)     
      end
    end
  end
  
  def show
  	@movie = Movie.find(params[:id])
    @actors = @movie.actors
    trailer = Tmdb::Movie.trailers(@movie.tmdb)["youtube"]
    @imdb_link = "https://www.imdb.com/title/"+@movie.imdb unless @movie.imdb.nil?
    @trailer_url = "https://www.youtube.com/embed/"+trailer[0]["source"]+"?autoplay=0" unless !(trailer.size > 0)
  end
  
  
  def search
    @id = params[:search]
    @search = Tmdb::Search.new
    @search.resource('movie')
    @search.query(@id) 
    @movie_results = @search.fetch
  
    @movies = []
    
    @movie_results.each do |movie|
      cast = Tmdb::Movie.casts(movie["id"])
      posters = Tmdb::Movie.images(movie["id"])['posters']
      if ((!posters.nil?) && (!cast.nil?))
        if (cast.any? && posters.any?)
          @movies.push(movie)
        end
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
      movie_par = Tmdb::Movie.detail(tmdb_id)
      
      
      @movie = Movie.new(movie_params(movie_par))
      
      
      if @movie.save!
        trailer_hash = Tmdb::Movie.trailers(tmdb_id)
        if !trailer_hash.nil?
          if trailer_hash["youtube"].size > 0
            @trailer_url = "https://www.youtube.com/embed/"+Tmdb::Movie.trailers(tmdb_id)["youtube"][0]["source"]+"?autoplay=0"
          end
        end
       
        cast = Tmdb::Movie.casts(tmdb_id)
        
        if !cast.nil?
          add_cast(cast, @movie.id)
        end
      end
      @actors = @movie.actors
      render :show
    end
  end
  
  
  def categories
    @categorie = params[:id].capitalize
    case params[:id]
    when "upcoming"
      movies = Tmdb::Movie.upcoming
    when "top_rated"
      movies = Tmdb::Movie.top_rated
    when "popular"
      movies = Tmdb::Movie.popular
    end
    @movies = []
    movies.each do |movie|
      if Movie.where(tmdb: movie.id ).count > 0
        @movies.push(Movie.where(tmdb: movie.id ).first)
        
      else
        movie_par = Tmdb::Movie.detail(movie.id)
        @movie = Movie.new(movie_params(movie_par))
        if @movie.save!
          cast = Tmdb::Movie.casts(movie.id)
          
          if !cast.nil?
            add_cast(cast, @movie.id)
          end
        end
        @movies.push(@movie)
      end
      @movies.sort! { |a,b| b.rating <=> a.rating }
    end
    
  end
  
  private 
  
    def movie_params(movie)
      
      title = movie["title"]
      plot = movie["overview"]
      release_year = movie["release_date"]
      if !movie["vote_average"].nil?
        rating = movie["vote_average"]/2
      else
        rating = 2.5
      end
      imdb = movie["imdb_id"]
      tmdb = movie["id"]
      poster_hash = Tmdb::Movie.images(tmdb)['posters']
      tagline = Tmdb::Movie.detail(tmdb)["tagline"]
        
      if !poster_hash.nil?
        if poster_hash.any?
          poster_path = $base_url+$poster_size+poster_hash[0]["file_path"]
        else
          poster_path = ""
        end
      end
      hash = { "title" => title, "release_year" => release_year, "image" => poster_path, "plot" => plot,  "tmdb"=> tmdb ,"imdb" => imdb, "rating" => rating, "tagline" => tagline }
      return hash
    end
    
    def actor_params
      { "name" => "test", "character" => "test"}
    end
    
    
    def add_cast(cast, movie_id)
      @movie = Movie.find(movie_id)  
# We check if the cast size is greater than 8 to have max 8 actors per film
      if cast.size > 7
        cast_size = 7
      else
        cast_size = cast.size
      end
      for i in 0..cast_size
        if !cast[i].nil?
          
# If an actor is already in our DB we don't add it again, but just push it into the @actors array
          actor = Actor.where(name: cast[i]["name"])
          if actor.any? 
            @movie.actors << actor.first
            Part.where(actor_id: actor.first.id, movie_id: @movie.id).first.update(character: cast[i]["character"])
          else
            actor = Actor.new(actor_params)
            if !cast[i]["profile_path"].nil?
                profile_image = $base_url+$profile_size+cast[i]["profile_path"]
            else
              profile_image = nil
            end
            
            if actor.save!
              actor.update(name: cast[i]["name"], character: cast[i]["character"], image: profile_image, tmdb: cast[i]["id"])
              @movie.actors << actor
              Part.where(actor_id: actor.id, movie_id: @movie.id).first.update(character: cast[i]["character"])
            end
          end
        end
      end
      @movie
    end
end
