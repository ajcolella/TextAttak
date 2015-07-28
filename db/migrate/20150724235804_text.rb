class Texts < ActiveRecord::Migration
  def up
    create_table :texts do |t|
      t.string :message
      t.integer :attak_id
    end
  end

  def down
    drop_table :texts
  end
end
