class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops do |t|
      t.integer :uid
      t.string :category
      t.string :name
      t.string :address
      t.string :tel
      t.string :access
      t.string :business_hours
      t.string :holiday
      t.decimal :lat
      t.decimal :lng
      t.string :pc_url
      t.string :mobile_url
      t.string :column01
      t.string :column02
      t.string :column03
      t.string :column04
      t.string :column05

      t.timestamps
    end
  end

  def self.down
    drop_table :shops
  end
end
