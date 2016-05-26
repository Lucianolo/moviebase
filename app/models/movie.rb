class Movie < ActiveRecord::Base
    has_many :parts 
    has_many :actors, through: :parts
    
    def short_description
        self.plot[0...50]
    end
    
    
end
