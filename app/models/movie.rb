class Movie < ActiveRecord::Base

  validates :imdb_id, uniqueness: true

  def self.create_from_sub(sub)
    self.create({
      content:      sub.extract_text,
      original_srt: sub.body,
      imdb_id:      sub.raw_data["IDMovieImdb"],
      year:         sub.raw_data["MovieYear"],
      filename:     sub.filename,
      imdb_rating:  sub.raw_data["MovieImdbRating"],
      name:         sub.movie_name
    })
  end
end
