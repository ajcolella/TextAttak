class Attaks < ActiveRecord::Migration
  def up
    create_table :attaks do |a|
      a.string :name
      a.string :variant_id
      a.date :last_sent
      a.integer :count
      a.integer :ordered
      a.integer :paired  
    end
  end

  def down
    drop_table :attaks
  end
end
