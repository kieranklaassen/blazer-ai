require "test_helper"

class Blazer::Ai::SqlValidatorTest < ActiveSupport::TestCase
  def setup
    @validator = Blazer::Ai::SqlValidator.new
  end

  def test_allows_select
    assert @validator.safe?("SELECT * FROM users")
  end

  def test_allows_with_cte
    assert @validator.safe?("WITH cte AS (SELECT 1) SELECT * FROM cte")
  end

  def test_blocks_insert
    refute @validator.safe?("INSERT INTO users (name) VALUES ('test')")
  end

  def test_blocks_update
    refute @validator.safe?("UPDATE users SET name = 'test'")
  end

  def test_blocks_delete
    refute @validator.safe?("DELETE FROM users")
  end

  def test_blocks_drop
    refute @validator.safe?("DROP TABLE users")
  end

  def test_blocks_multiple_statements
    refute @validator.safe?("SELECT 1; DROP TABLE users")
  end

  def test_blocks_sql_comments
    refute @validator.safe?("SELECT * FROM users -- comment")
  end

  def test_requires_select_or_with
    refute @validator.safe?("SHOW TABLES")
  end

  def test_extract_sql_from_markdown
    content = "Here's the query:\n```sql\nSELECT * FROM users\n```"
    assert_equal "SELECT * FROM users", @validator.extract_clean_sql(content)
  end

  def test_extract_plain_sql
    assert_equal "SELECT 1", @validator.extract_clean_sql("SELECT 1")
  end
end
