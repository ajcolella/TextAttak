class Images < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.string :image_url
      t.integer :attak_id
    end
  end

  def down
    drop_table :images
  end
end
