ActiveRecord::Schema.define(:version => 0) do
  drop_table :users rescue nil
  create_table :users do |t|
    t.string :login
    t.timestamps
  end
  
  drop_table :translations rescue nil
  create_table :translations do |t|
    t.text   :content
    t.string :locale,:key
    t.integer :user_id
    t.boolean :override ,:default => false
    t.timestamps
  end
    
  drop_table :translation_keys rescue nil
  create_table :translation_keys do |t|
    t.string :key
    t.text :default
    t.timestamps
  end
    
  drop_table :translation_votes rescue nil
  create_table :translation_votes do |t|
    t.integer :translation_id, :user_id, :vote
    t.timestamps
  end
  add_index :translation_votes, ["user_id",  "translation_id"], :unique => true, :name => "uniq_one_translation_vote_only"
end