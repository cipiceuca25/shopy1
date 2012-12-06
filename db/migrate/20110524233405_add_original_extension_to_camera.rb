class AddOriginalExtensionToCamera < ActiveRecord::Migration
  def self.up
    add_column :cameras, :original_extension, :string
  end

  def self.down
    remove_column :cameras, :original_extension
  end
end
