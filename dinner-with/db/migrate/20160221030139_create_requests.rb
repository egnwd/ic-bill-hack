class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :mondo_id
      t.string :transaction_id
      t.integer :amount
      t.string :who_from

      t.timestamps
    end
  end
end
