class Users < ActiveRecord::Migration
  def up
    create_table :users do |u|
      u.integer :shopify_id
      u.integer :phone
      u.boolean :opt_out
    end
  end

  def down
    drop_table :users
  end
end
