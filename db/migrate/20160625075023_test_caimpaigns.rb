class TestCaimpaigns < ActiveRecord::Migration
  def change
    create_table :test_caimpaigns do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
