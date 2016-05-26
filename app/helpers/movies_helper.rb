module MoviesHelper
    def random_movie
        movie_list = []
        val = rand(230..240)
        i=0
        while i<4
            if movie_list.include?(Movie.find(val))
                val = rand(230..240)
                next
            else
                movie_list.push(Movie.find(val))
                i+=1
            end
        end
        movie_list
        
    end
end
