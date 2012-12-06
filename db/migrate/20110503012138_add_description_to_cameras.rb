class AddDescriptionToCameras < ActiveRecord::Migration
  def self.up
    add_column :cameras, :description, :text
  end

  def self.down
    remove_column :cameras, :description
  end
end
