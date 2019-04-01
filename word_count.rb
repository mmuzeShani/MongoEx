require 'mongo'

class WordCount
  def initialize
    @words = Hash.new
  end

  def count (dir) #get path?
    unless File::directory?(dir)
      return
    end

    Dir.foreach(dir) do |file|
      file_path = "#{dir}/#{file}" #get the full path of the file
      if File::file?(file_path) && File::readable?(file_path) #only if it's a file + readable
        File.open(file_path, "r") do |aFile|
          if aFile
            aFile.each_line do |line|
              line.split.each do |word|
                if @words.has_key?(word)
                  @words[word] += 1
                else
                  @words[word] = 1
                end
              end
            end
          else
            puts "Cannot read the file #{file}"
          end
        end
      end

    end

    return @words
  end

end


if __FILE__ == $0

  wc = WordCount.new
  words = wc.count("/Users/shanicohen/Documents/test")

  mongo_client = Mongo::Client.new(['127.0.0.1:27017'], :connect => :direct) #connect to mongo
  db = Mongo::Database.new(mongo_client, "test_db") #create a database
  coll = Mongo::Collection.new(db, "test_coll") #create a collection

  coll.insert_one(words) #add the result to the collection

  # array = coll.find({}).to_a
  #
  # array.each do |block|
  #   puts block

  end





end