class CreateChangeOrders < ActiveRecord::Migration
  def change
    create_table :change_orders do |t|
      t.references :builder
      t.references :project
      t.references :categories_template
      t.string :name
      t.string :description
      t.decimal :qty, :scale => 2, :precision => 10
      t.string :unit
      t.decimal :cost, :scale => 2, :precision => 10
      t.decimal :margin, :scale => 2, :precision => 10
      t.text :notes

      t.timestamps
    end
    add_index :change_orders, :builder_id
    add_index :change_orders, :project_id
    add_index :change_orders, :categories_template_id
  end
end
