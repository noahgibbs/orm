require "sqlite3"

DB = SQLite3::Database.new "test1.db"

module ORM; class Model
  def self.schema
    return @schema if @schema
    table_info = DB.table_info(name.downcase)
    @schema = {}
    table_info.each do |row|
      @schema[row["name"]] = row["type"]
    end
    @schema
  end

  def self.table
    name.downcase
  end

  def self.insert(vals)
    k = schema.keys
    v = k.map { |key| vals[key] }

    DB.execute <<-SQL, v
      INSERT INTO #{name.downcase}
      (#{k.join ","})
      VALUES (#{k.map { '?' }.join ','});
    SQL
  end

  def initialize(data = nil)
    @hash = data
  end

  def self.find(id)
    row = DB.execute <<-SQL
      select #{schema.keys.join ","} from #{table}
      where id = #{id.to_i};
    SQL
    data = Hash[schema.keys.zip row[0]]
    self.new data
  end

  def [](name)
    @hash[name]
  end

  def []=(name, value)
    @hash[name] = value
  end

  def update!
    k = @hash.keys - ["id"]
    sql_k = k.map { |key| "#{key}=?" }
    v = k.map { |key| @hash[key] }

    DB.execute <<-SQL, v
      UPDATE #{self.class.table}
      SET #{sql_k.join ","}
      WHERE id = #{@hash["id"].to_i}
    SQL
  end

  def self.create(values)
    values.delete "id"
    insert values

    sql = "SELECT last_insert_rowid()"
    new_id = DB.execute(sql)[0][0]
    self.find new_id
  end

  def delete!
    DB.execute <<-SQL
      DELETE FROM #{self.class.table}
      WHERE id = #{@hash["id"].to_i}
    SQL
    @hash = {}
  end

end; end
