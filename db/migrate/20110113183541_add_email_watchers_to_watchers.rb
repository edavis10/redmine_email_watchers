class AddEmailWatchersToWatchers < ActiveRecord::Migration
  def self.up
    add_column :watchers, :email_watchers, :text
  end

  def self.down
    remove_column :watchers, :email_watchers
  end
end
