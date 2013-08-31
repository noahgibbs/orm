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

  def self.to_sql(value)
    return "null" if value.nil?
    return value.to_s if value.is_a?(Numeric)
    value.inspect
  end

  def self.insert(vals)
    k = schema.keys
    v = k.map { |key| to_sql(vals[key]) }

    DB.execute <<-SQL
      INSERT INTO #{name.downcase}
      (#{k.join ","})
      VALUES (#{v.join ","});
    SQL
  end

  def initialize(data = nil)
    @hash = data
  end

  def self.find(id)
    row = DB.execute <<-SQL
      select #{schema.keys.join ","} from #{table}
      where id = #{id};
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
    fields = @hash.map do |k, v|
      "#{k}=#{self.class.to_sql(v)}"
    end

    DB.execute <<-SQL
      UPDATE #{self.class.table}
      SET #{fields.join ","}
      WHERE id = #{@hash["id"]}
    SQL
  end

  def self.create(values)
    values.delete "id"
    insert values

    sql = "SELECT last_insert_rowid()"
    new_id = DB.execute(sql)[0][0]
    self.find new_id
  end

end; end
