class Attaks < ActiveRecord::Migration
  def up
    create_table :attaks do |a|
      a.string :name
      a.date :last_sent
      a.integer :count
    end
  end

  def down
    drop_table :attaks
  end
end
