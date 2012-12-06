class AddAnotherAtributeToCameras < ActiveRecord::Migration
  def self.up
    add_column :cameras, :asin, :string
    add_column :cameras, :page_url, :string
  end

  def self.down
    remove_column :cameras, :asin
    remove_column :cameras, :page_url
  end
end
