class CreateTasklists < ActiveRecord::Migration
  def change
    create_table :tasklists do |t|

      t.timestamps
    end
  end
end
