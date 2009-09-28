class Translation < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :locale, :translation_key,:content
  has_many :translation_votes
  named_scope :from, lambda{|user| {:conditions => {:user_id => user.id }} }
  named_scope :locale, lambda{|locale| {:conditions => {:locale => locale }} }
  
  ORIGINAL_ENGLISH = 1
  TRANSLATE_PHRASES = 2
  TRANSLATE_OPTIONS = [ ["Original English", Translation::ORIGINAL_ENGLISH], ["Translated Phrases", Translation::TRANSLATE_PHRASES] ]
  
  def to_s
    content
  end
  
  def validate
    unless translation_key.blank?
      translation_key.get_vars_in_default.each do |var|
        errors.add("override","Must have the variable #{var}") unless !!content.gsub(' ', '').match(/#{var}/)
      end
    end
    if override
      #you can only have one override per key,locale
      if new_record?
        errors.add_to_base("you can only have one override per key,locale") unless Translation.count(:conditions => ["key = ? AND locale= ? AND override = ?",key,locale,true]) == 0
      else
       errors.add_to_base("you can only have one override per key,locale") unless Translation.count(:conditions => ["key = ? AND locale= ? AND override = ? AND id != ?",key,locale,true,id]) == 0
      end
    end
  end

  def translation_key
    TranslationKey.find_by_key(key)
  end

  def translation_key= translation_key
    update_attribute(:key, translation_key.key)
  end
  
  def voted_by? user
    translation_votes.any? {|tv| tv.user_id == user.id}
  end
  
  def set_override
    Translation.transaction do
      Translation.all(:conditions =>{:locale => locale, :key => key}).each {|t| t.update_attribute(:override,false)}
      update_attribute(:override,true)
    end
  end
end