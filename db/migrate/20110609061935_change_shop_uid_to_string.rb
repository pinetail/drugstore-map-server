class ChangeShopUidToString < ActiveRecord::Migration
  def self.up
    change_column :shops, :uid, :string,
    :default => 0.0
  end

  def self.down
    change_column :shops, :uid, :integer
  end
end