class CreateCameras < ActiveRecord::Migration
  def self.up
    create_table :cameras do |t|
      t.string :name
      t.float :megapixels
      t.decimal :price
      t.float :zoom
      t.float :screensize

      t.timestamps
    end
  end

  def self.down
    drop_table :cameras
  end
end
