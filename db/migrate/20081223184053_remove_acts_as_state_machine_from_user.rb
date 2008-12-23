class RemoveActsAsStateMachineFromUser < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      if user.state == 'passive' || user.state == 'suspended' || user.state == 'pending'
        user.activated_at = nil
      else
        user.activated_at ||= Time.now
      end
    end
    
    change_table :users do |t|
      t.remove :state
      t.remove :deleted_at
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
