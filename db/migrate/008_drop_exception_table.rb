class DropExceptionTable < ActiveRecord::Migration
  def self.up
    drop_table :logged_exceptions
  end

  def self.down
    create_table :logged_exceptions, :force => true do |t|
      t.column :exception_class, :string
      t.column :controller_name, :string
      t.column :action_name,     :string
      t.column :message,         :text
      t.column :backtrace,       :text
      t.column :environment,     :text
      t.column :request,         :text
      t.column :created_at,      :datetime
    end
  end
end
