class Movie < ActiveRecord::Base

  validates :imdb_id, uniqueness: true

  searchable do
    text :content, :stored => true do |m| ActionView::Base.full_sanitizer.sanitize(m.content) end
    text :name, :boost => 0.005
  end

  def self.create_from_sub(sub)
    self.create({
      content:      sub.extract_text,
      original_srt: sub.body,
      imdb_id:      sub.raw_data["IDMovieImdb"],
      year:         sub.raw_data["MovieYear"],
      filename:     sub.filename,
      imdb_rating:  sub.raw_data["MovieImdbRating"],
      name:         sub.movie_name,
      poster_url:   Movie.find_poster(sub.raw_data["IDMovieImdb"]),
    })
  end

  def keywords
    doc = Pismo::Document.new(content)
    tags = doc.keywords(:stem_at => 4, :limit => 15).reject{|p| p.first.length < 3 || !Stopwords.valid?(p.first)}#.map {|k,v| ["#{k} (#{v})", v]}
  end

  def poster
    self.update_attribute(:poster_url, Movie.find_poster(imdb_id)) unless self.poster_url
    self.poster_url
  end

  private

  def self.find_poster(id)
    FilmBuff.new.look_up_id("tt#{'0'*(7-id.size)}#{id}").poster_url rescue nil
  end
end
