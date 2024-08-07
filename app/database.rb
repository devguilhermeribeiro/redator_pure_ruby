require 'pg'
require 'securerandom'
require 'bcrypt'
require 'dotenv/load'
require_relative 'migrate'

module Admin_query
  def exists_admin
    query = @db.exec('SELECT COUNT(*) FROM admin')
    result_query = query[0]['count'].to_i
    result_query.positive?
  end

  def create_admin(id, email, password)
    @db.exec_params('INSERT INTO admin (id, email, password)
      VALUES ($1, $2, $3)', [id, email, password])
  end

  def select_admin(email)
    @db.exec_params('SELECT password FROM admin WHERE email = $1', [email])
  end
end

module Article_query
  def insert_data(title, content)
    @db.exec_params('INSERT INTO articles (title, content)
      VALUES ($1, $2) RETURNING id', [title, content])
  end

  def select_all_data
    @db.exec('SELECT * FROM articles')
  end

  def select_article_by_id(id)
    @db.exec_params('SELECT * FROM articles WHERE id = $1', [id])
  end

  def update_article_by_id(title, content, id)
    @db.exec_params('UPDATE articles SET title = $1, content = $2 WHERE id = $3', [title, content, id])
  end

  def destroy_article_by_id(id)
    @db.exec_params('DELETE FROM articles WHERE id = $1', [id])
  end
end

class Database
  include Admin_query
  include Article_query

  attr_accessor :db

  def initialize
    db_connect
    db_migrate
  end

  def db_connect
    @db = PG.connect(ENV['DATABASE_URL'])
    @db.type_map_for_results = PG::BasicTypeMapForResults.new(@db)
  end
end
