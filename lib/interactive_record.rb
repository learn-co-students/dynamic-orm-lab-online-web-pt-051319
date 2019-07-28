require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'


class InteractiveRecord
     
# creates  adowncased, plural table name based on the Class name 
def self.table_name
  self.to_s.downcase.pluralize
end 

# returns an array of SQL column names
# ["id", "name", "grade"]
def self.column_names
  # DB[:conn].results_as_hash = true 
  sql = "PRAGMA table_info('#{table_name}')"
  table_info = DB[:conn].execute(sql)
  column_names = []
  table_info.each do |column|
    column_names << column["name"]
  end
  column_names.compact
end

# creates a new instance of a student 
# creates a new student with attributes
def initialize(options={})
  options.each do |k, v|
    self.send("#{k}=", v)
  end
end

# return the table name when called on an instance of Student
# "students"
def table_name_for_insert
  self.class.table_name
end

# return the column names when called on an instace of Student
# does not include an id column
# expected nil to include "name, grade"
def col_names_for_insert
  self.class.column_names.delete_if {|col| col == "id"}.join(", ")
end

# formats  the column names to be use in a SQL statement
# expected: "'Sam', '11'"
def values_for_insert
  values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
      values.join(", ")
end

# saves the student to the db
# [{"grade"=>11, "id"=>1, "name"=>"Sam"}]
# sets the student's id
def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  
end

# executes the SQL to find a row by name
def self.find_by_name(name)
  sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
    
  DB[:conn].execute(sql)
end

# executes the SQL to find a row by the attribute passed into the method
# accounts for when an attribute value is an integer
def self.find_by(attributes) 
  sql = "SELECT * FROM #{self.table_name} WHERE #{attributes.keys[0].to_s} = '#{attributes.values[0].to_s}'"
  DB[:conn].execute(sql)
end


    
end # end of Class