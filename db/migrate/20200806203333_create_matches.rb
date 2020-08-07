class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.string :radiant
      t.string :dire
      t.integer :win
      t.boolean :predicted

      t.timestamps
    end
  end
end
