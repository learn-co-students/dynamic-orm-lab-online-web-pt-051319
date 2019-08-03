require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

	def self.table_name
		self.to_s.downcase.pluralize
	end

	def self.column_names
		table_info = DB[:conn].execute("PRAGMA table_info(#{table_name});")
		table_info.map{ |info| info["name"] }.compact
	end

	self.column_names.each{ |col_name| attr_accessor col_name.to_sym }

	def initialize(ops = {})
		ops.each{ |prop, value| self.send("#{prop}=", value) }
	end

	def table_name_for_insert
		self.class.table_name
	end

	def col_names_for_insert
		self.class.column_names.reject{ |col| col == 'id' }.join(', ')
	end

	def values_for_insert
		self.class.column_names.map{ |col| "'#{send(col)}'" unless send(col).nil? }.compact.join(', ')
	end

	def save
		sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});"
		# binding.pry
		DB[:conn].execute(sql)
	end

end
