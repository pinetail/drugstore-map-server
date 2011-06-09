class AddUseFlagToShops < ActiveRecord::Migration
  def self.up
    add_column :shops, :use_flg, :boolean
  end

  def self.down
    remove_column :shops, :use_flg
  end
end
