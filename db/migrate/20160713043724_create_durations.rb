class CreateDurations < ActiveRecord::Migration
  def change
    create_table :durations do |t|
      t.string :sid
      t.string :start_time
      t.string :end_time
      t.string :duration

      t.timestamps
    end
  end
end
