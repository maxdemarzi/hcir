require 'set'
require 'neography'

def prepare_files
    File.open("publication_details", "w") do |file|
      file.puts "id" + "\t" + "title" + "\t" + "primary_author_id" + "\t" + "readers" + "\t" + "year" + "\t" + "publication_id"  
    end
end

def get_json(line)
  Oj.load(line.split("\t")[1])
end

def generate_data
  publications        = File.open("data/publications", "r")
  countries           = Set.new ["Unknown"]
  journals            = Set.new
  authors             = Set.new
  reader_countries    = []
  reader_disciplines  = []
  reader_statuses     = []
  author_publications = []
  
  while (line = publications.gets)
    json_hash = get_json(line)
    
    country_hash = json_hash["stats"]["country"]
    if country_hash
      countries.merge(country_hash.keys)
      
      country_hash.each do |ch|
        ch[0] = "Unknown" if ch[0].empty?
        reader_countries << [json_hash["id"], ch[0], ch[1]]  
      end
    end
    
    discipline_hash = json_hash["stats"]["discipline"]
    if discipline_hash
      discipline_hash.each do |dh|
        reader_disciplines << [json_hash["id"], dh[0], dh[1]]  
      end
    end

    statuses_hash = json_hash["stats"]["academic_status"]
    if statuses_hash
      statuses_hash.each do |sh|
        reader_statuses << [json_hash["id"], sh[0], sh[1]]  
      end
    end

    author_array = json_hash["authors"]
    if author_array
      author_array.each do |aa|
        author_publications << [json_hash["id"], aa]
        authors.add("#{aa["forename"]}:#{aa["surname"]}")  
      end
    end

    journal_hash = json_hash["published_in"]
    journals.add(journal_hash) if journal_hash
    
  end
  
  @countries = countries.to_a
  @journals = journals.to_a
  @authors = {}
  authors.to_a.each_with_index do |author, index|
    @authors["#{author}"] = index
  end
  
  
  
  File.open("data/countries", "w") do |file|
    file.puts "id" + "\t" + "name"  
    @countries.each_with_index do |country, index|
      file.puts "#{index + 1}\t#{country}"
    end
  end

  puts "Generated #{@countries.size} countries"

  File.open("data/reader_countries", "w") do |file|
    file.puts "publication_id" + "\t" + "country_id" + "\t" + "nbr_of_readers"
    reader_countries.each do |rc|
      file.puts "#{rc[0]}\t#{@countries.index(rc[1]) + 1}\t#{rc[2]}"
    end  
  end

  puts "Generated #{reader_countries.size} reader_countries"

  File.open("data/reader_disciplines", "w") do |file|
    file.puts "publication_id" + "\t" + "discipline_id" + "\t" + "nbr_of_readers"  
    reader_disciplines.each do |rd|
      file.puts "#{rd[0]}\t#{rd[1]}\t#{rd[2]}"
    end  
  end
  
  puts "Generated #{reader_disciplines.size} reader disciplines"

  File.open("data/reader_academic_status", "w") do |file|
    file.puts "publication_id" + "\t" + "academic_status_id" + "\t" + "nbr_of_readers"  
    reader_statuses.each do |rs|
      file.puts "#{rs[0]}\t#{rs[1]}\t#{rs[2]}"
    end  
  end

  puts "Generated #{reader_statuses.size} reader statuses"

  File.open("data/journals", "w") do |file|
    file.puts "id" + "\t" + "name"  
    @journals.each_with_index do |journal, index|
      file.puts "#{index + 1}\t#{journal}"
    end
  end

  puts "Generated #{@journals.size} journals"

  File.open("data/authors", "w") do |file|
    file.puts "id" + "\t" + "author_forename" + "\t" + "author_surname"  
    @authors.each_pair do |author, id|
      name = author.split(':')
      file.puts "#{id + 1}\t#{name[0]}\t#{name[1]}"
    end
  end
  
  puts "Generated #{@authors.size} authors"

  File.open("data/publication_authors", "w") do |file|
    file.puts "publication_id" + "\t" + "author_id"  
    author_publications.each do |ap|
      key = "#{ap[1]["forename"]}:#{ap[1]["surname"]}"
      file.puts "#{ap[0]}\t#{@authors[key] + 1}"
    end
  end
  
  puts "Generated #{author_publications.size} author publications"

end


def process_publications
    publications = File.open("data/publications", "r")
    details = File.open("publication_details", "a")
    
    counter = 0
    
    while (line = publications.gets)
      split_line = line.split("\t")
      profile_id = split_line[0]
      pub_json = Oj.load(split_line[1])
      puts pub_json
        
      
      counter += 1
      break if counter > 2
    end
    
    publications.close
end