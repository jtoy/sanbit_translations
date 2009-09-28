class TranslationVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :translation
  named_scope :vote_type, lambda{|type| {:conditions => {:vote => type.to_i}}}
  
  validates_presence_of :user,:translation
  def validate
    errors.add_to_base("Vote must be 1 or -1") unless (vote.to_i == 1 || vote.to_i == -1)
    errors.add_to_base("Voter should not be yourself!") unless user != translation.user
  end
end