class CreateTaskLogs < ActiveRecord::Migration
  def change
    create_table :task_logs do |t|
      t.references :task, index: true
      t.string :state
      t.string :message_state
      t.text :message

      t.timestamps
    end
  end
end
