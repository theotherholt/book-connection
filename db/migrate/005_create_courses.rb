class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string  :name
      t.timestamps
    end
    
    create_table :books_courses, :id => false do |t|
      t.references :book
      t.references :course
    end
  end

  def self.down
    drop_table :books_courses
    drop_table :courses
  end
end
