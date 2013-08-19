require "sqlite3"

DB = SQLite3::Database.new "testdb1"

module ORM
  class Model
    def self.table_name
      name.downcase  # lowercased *class* name
    end

    def self.schema
      return @schema if @schema
      @schema = {}
      DB.table_info(table_name) do |row|
        @schema[row["name"]] = row["type"]
      end
      @schema
    end
  end
end
