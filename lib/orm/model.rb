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

  # Method_missing wasn't defined in the GoGaRuCo version of the talk,
  # but it's not hard to do.
  def method_missing(name, val = nil)
    if self.class.schema[name.to_s]
      return self[name.to_s]  # Get value
    end
    if self.class.schema[name.to_s[0..-2]] &&
      name.to_s[-1] == "="
      return self[name.to_s] = val # Set value
    end
    super  # Raise an error like normal
  end

  # If you ever redefine method_missing, it's highly polite to also
  # redefine respond_to? (in older Ruby versions) or
  # respond_to_missing? (now).
  # See: http://robots.thoughtbot.com/post/28335346416/always-define-respond-to-missing-when-overriding
  def respond_to_missing?(name, include_priv = false)
    schema = self.class.schema
    return true if schema[name.to_s]
    return true if schema[name.to_s[0..-2]] && name.to_s[-1] == "="
    super
  end

end; end
