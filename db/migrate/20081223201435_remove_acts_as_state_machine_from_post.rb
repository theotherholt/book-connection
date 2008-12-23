class RemoveActsAsStateMachineFromPost < ActiveRecord::Migration
  def self.up
    Post.find(:all).each do |post|
      if post.state == 'passive' || post.state == 'for_sale' || post.state == 'unavailable'
        post.sold_at = nil
      else
        post.sold_at ||= Time.now
      end
    end
    
    change_table :posts do |t|
      t.remove :state
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
