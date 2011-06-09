class ChangeShopLngToDecimal < ActiveRecord::Migration
  def self.up
    change_column :shops, :lng, :decimal, :precision => 17, :scale => 14,
    :default => 0.0
  end

  def self.down
    change_column :shops, :lng, :decimal
  end
end