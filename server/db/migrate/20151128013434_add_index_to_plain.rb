class AddIndexToPlain < ActiveRecord::Migration
  def change
    add_index :plains, :boke_origin
  end
end
