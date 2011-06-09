class ChangeShopLatToDecimal < ActiveRecord::Migration
  def self.up
    change_column :shops, :lat, :decimal, :precision => 17, :scale => 14,
    :default => 0.0
  end

  def self.down
    change_column :shops, :lat, :decimal
  end
end