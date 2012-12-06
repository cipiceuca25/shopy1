class AddBrandIdToCamera < ActiveRecord::Migration
  def self.up
    add_column :cameras, :brand_id, :integer
  end

  def self.down
    remove_column :cameras, :brand_id
  end
end
