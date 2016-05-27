module MoviesHelper
    def random_movie
        movie_list = []
        last = Movie.last.id
        val = rand(last-50..last)
        i=0
        while i<4
            if !Movie.exists?(val)
                val = rand(last-50..last)
                next
            elsif movie_list.include?(Movie.find(val))
                val = rand(last-50..last)
                next
            else
                movie_list.push(Movie.find(val))
                i+=1
            end
        end
        movie_list
        
    end
end
