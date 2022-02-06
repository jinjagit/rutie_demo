class CreateAppConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :app_configs do |t|
      t.boolean :rust_enabled

      t.timestamps
    end
  end
end
