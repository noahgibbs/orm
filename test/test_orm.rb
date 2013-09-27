require "minitest/autorun"

require "orm/model"

$LOAD_PATH.unshift File.expand_path File.join(File.dirname(__FILE__), "..", "lib", "orm")

class Posts < ORM::Model
end

class TestORM < MiniTest::Unit::TestCase
  def setup
    @db = SQLite3::Database.new "test1.db"
    schema = @db.table_info("posts")
    if schema.nil? || schema.empty?
      # Create posts table
      @db.execute <<-SQL
        CREATE TABLE posts (
          id integer primary key,
          title varchar(64),
          body varchar(128),
          rating integer
        );
      SQL
    end

    # And make sure posts is empty
    @db.execute "DELETE FROM posts;"
  end

  def test_orm
    assert_equal ["body", "id", "rating", "title"], Posts.schema.keys.sort
  end

  def test_insert
    Posts.insert "title" => "Post 1", "rating" => 3

    row = @db.execute <<-SQL
      select title, rating from posts;
    SQL

    assert_equal row[0][0], "Post 1"
    assert_equal row[0][1], 3
  end

  def test_find
    Posts.insert "id" => 7, "title" => "Yup"

    p = Posts.find(7)
    assert_equal p["title"], "Yup"
  end

  def test_update
    Posts.insert "id" => 9, "title" => "T1", "rating" => 4
    Posts.insert "id" => 1, "title" => "T2", "rating" => 6

    p = Posts.find(9)
    p["rating"] = 3
    p.update!

    p = Posts.find(1)
    p["title"] = "T3"
    p.update!

    row = @db.execute <<-SQL
      select id, title, rating from posts where id = 9;
    SQL
    assert_equal [9, "T1", 3], row[0]

    row = @db.execute <<-SQL
      select id, title, rating from posts where id = 1;
    SQL
    assert_equal [1, "T3", 6], row[0]
  end

  def test_create
    Posts.insert "title" => "T1", "rating" => 7

    p = Posts.create "title" => "T2", "rating" => 5

    row = @db.execute <<-SQL
      select title from posts;
    SQL

    assert_equal ["T1", "T2"], [row[0][0], row[1][0]]

    assert_equal "T2", p["title"]
    assert_equal 5, p["rating"]
  end

  def test_delete
    p = Posts.create "title" => "T1", "rating" => 7

    row = @db.execute <<-SQL
      SELECT COUNT(*) from posts;
    SQL
    assert_equal 1, row[0][0]

    p.delete!

    row = @db.execute <<-SQL
      SELECT COUNT(*) from posts;
    SQL
    assert_equal 0, row[0][0]
  end

  # This isn't for the GoGaRuCo version of the talk,
  # but you can still enjoy it ;-)
  def test_method_missing
    p = Posts.create "title" => "Why You Suck"

    assert_equal "Why You Suck", p.title

    p.title = "Why I Rock"
    p.update!

    p2 = Posts.find(p.id)
    assert_equal "Why I Rock", p2.title
  end
end
