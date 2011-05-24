ActiveRecord::Schema.define(:version => 0) do
  create_table :posts do |t|
    t.text :text
    t.datetime
    t.text :type
    t.integer :flags_count, :default => 0
  end

  create_table :users do |u|
    u.string :name
  end

  create_table :replies do |w|
    w.string :text
  end

end
