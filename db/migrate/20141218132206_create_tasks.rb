class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.datetime :deadline
      t.string :assigned_name
      t.string :assigned_phone
      t.string :state, :default => "pending"
      t.string :last_message_state
      t.string :last_message_sid
      t.text :last_message

      t.timestamps
    end
  end
end
