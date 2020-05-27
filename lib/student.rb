require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO students(name, grade)
        VALUES(?, ?)
      SQL

      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, grade FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
  end

  def update
    sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @grade, @id)
  end
end
