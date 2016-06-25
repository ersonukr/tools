class TestCaimpaignStatuses < ActiveRecord::Migration
  def change
    create_table :test_caimpaign_statuses do |t|
      t.string :sid
      t.string :phone
      t.string :status
      t.integer :attempt_no
      t.string :sid_created_at
      t.integer :test_caimpaign_id

      t.timestamps null: false
    end
  end
end
