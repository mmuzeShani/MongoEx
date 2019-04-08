require 'mongo'

class WordCount2

  def count (dir, coll) #get path?
    unless File::directory?(dir) #make sure the path is a valid directory
      return
    end


    Dir.foreach(dir) do |file|
      file_path = "#{dir}/#{file}" #get the full path of the file

      if File::file?(file_path) && File::readable?(file_path) #only if it's a file + readable
        File.open(file_path, "r") do |aFile|

          if aFile
            line_count = 0

            aFile.each_line do |line|
              line_count += 1
              word_count = 0

              line.split.each do |word|
                word_count += 1
                word_location = Hash["File"=>file, "Line number"=>line_count, "Word number"=>word_count]
                word.downcase! #ignore capital letters (! -changes the actual value of the string )
                coll.find_one_and_update(
                     {"Word":word},
                     {
                         "$setOnInsert": { "Word Count": 0 , "Locations": []},
                     },
                     upsert: true,
                     returnNewDocument: true
                )
                coll.update_one({"Word": word}, {"$inc": {"Word Count": 1}, "$addToSet": {"Locations": word_location}})
              end
            end

          else
            puts "Cannot read the file #{file}"
          end
        end
      end

    end

  end

end


if __FILE__ == $0

  wc = WordCount2.new

  mongo_client = Mongo::Client.new(['127.0.0.1:27017'], :connect => :direct) #connect to mongo
  db = Mongo::Database.new(mongo_client, "test_db") #create a database
  coll = Mongo::Collection.new(db, "test_coll2") #create a collection

  wc.count("/Users/shanicohen/Documents/test", coll)

end
