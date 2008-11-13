class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :username
      t.string   :phone
      t.string   :crypted_password
      t.string   :salt
      t.string   :activation_code
      t.string   :state, :null => :no, :default => 'passive'
      t.datetime :activated_at
      t.datetime :deleted_at
      t.datetime :last_login_at
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
