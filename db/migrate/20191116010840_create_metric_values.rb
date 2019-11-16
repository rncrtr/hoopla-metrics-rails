class CreateMetricValues < ActiveRecord::Migration
  def change
    create_table :metric_values do |t|

      t.timestamps null: false
    end
  end
end
