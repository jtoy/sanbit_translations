class SanbitMigration < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.text   :content
      t.string :locale,:key
      t.integer :user_id
      t.boolean :override ,:default => false
      t.boolean :hidden, :default => false
      t.timestamps
    end
    
    create_table :translation_keys do |t|
      t.string :key
      t.text :description
      t.boolean :hidden, :default => false
      t.timestamps
    end
    
    create_table :translation_votes do |t|
      t.integer :translation_id, :user_id, :vote
      t.timestamps
    end
    add_index :translation_votes, ["user_id",  "translation_id"], :unique => true, :name => "uniq_one_translation_vote_only"

    #add_index :votes, ["voter_id", "voter_type"],       :name => "fk_voters"
    #add_index :votes, ["voteable_id", "voteable_type"], :name => "fk_voteables"

    # If you want to enfore "One Person, One Vote" rules in the database, uncomment the index below
    # add_index :votes, ["voter_id", "voter_type", "voteable_id", "voteable_type"], :unique => true, :name => "uniq_one_vote_only"
  end

  def self.down
    drop_table :translations
    drop_table :translation_keys
    drop_table :translation_votes
  end

end
