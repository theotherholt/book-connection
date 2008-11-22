class DropCourses < ActiveRecord::Migration
  def self.up
    drop_table :books_courses
    drop_table :courses
  end

  def self.down
    ActiveRecord::IrreversibleMigration
  end
end
