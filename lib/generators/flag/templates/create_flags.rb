class CreateFlags < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|
      t.text :comment
      t.references :flaggable, :polymorphic => true
      t.references :user
      # other roles could be spam, inappropriate, etc.
      t.string :role, :default => "abuse"
      t.timestamps
    end

    add_index :flags, [:flaggable_type, :flaggable_id]
    add_index :flags, :user_id
  end

  def self.down
    drop_table :flags
  end
end
