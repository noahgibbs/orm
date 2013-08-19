require "minitest/autorun"

require "orm/model"

$LOAD_PATH.unshift File.expand_path File.join(File.dirname(__FILE__), "..", "lib", "orm")

class Posts < ORM::Model
end

class TestORM < MiniTest::Unit::TestCase
  def setup
    @db = SQLite3::Database.new "unittest.db"
    schema = @db.table_info("posts")
    if schema.nil? || schema.empty?
      # Create posts table
      @db.execute <<-SQL
        CREATE TABLE posts (
          title varchar(64),
          body varchar(128),
          rating smallint
        );
      SQL
    end

    @db.execute "DELETE FROM posts;"
  end

  def test_orm
    assert_equal ["body", "rating", "title"], Posts.schema.keys.sort
  end

  def test_truth
    assert true
  end
end
