class CreatePlains < ActiveRecord::Migration
  def change
    create_table :plains do |t|
      t.string :boke_origin
      t.string :boke_basic
      t.string :tsukkomi_origin
      t.string :tsukkomi_basic

      t.timestamps null: false
    end
  end
end
