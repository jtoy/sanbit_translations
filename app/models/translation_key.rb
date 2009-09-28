class TranslationKey < ActiveRecord::Base
  named_scope :untranslated,Proc.new {|locale|
    if locale.blank?
      {:joins => "LEFT JOIN translations ON translation_keys.key = translations.key",:select => "translation_keys.*",:conditions => ["translations.id IS NULL"]}
    else
      keys = TranslationKey.all.map(&:key) - Translation.all(:conditions => ["locale = ?", locale]).map(&:key).uniq
      {:select => "translation_keys.*",:conditions => ["key IN (?)",keys]}
    end
    #SELECT... FROM foo LEFT JOIN bar ON (foo.id=bar.foo_id) WHERE bar.foo_id IS NULL
  }
  named_scope :has_translations_in_locale, Proc.new {|locale|
      {:joins => "LEFT JOIN translations ON translation_keys.key = translations.key",:select => "DISTINCT translation_keys.*",:conditions => ["locale = ?",locale]}
  }
  named_scope :hidden, Proc.new{|h|
    {:conditions => ["translation_keys.hidden = ?", !!h]}
  }
  def to_s
    key
  end

  has_many :translations, :foreign_key => "key",:primary_key => "key", :dependent => :destroy
  validates_uniqueness_of :key
  validates_presence_of :key
  
  def default
    translations.locale(I18n.default_locale.to_s).first(:order => "override DESC")
  end
  
  
  def get_vars_in_default
    return [] if default.to_s.blank?
    vars = []
    default.to_s.gsub(' ', '').scan(/\{\{\w*\}\}/).each do |v|
      vars << v.gsub('{', '\{').gsub('}', '\}')
    end
    vars
  end
end

class TranslationKeyNotInDb
  attr_accessor :key
  def initialize key
    @key = key
  end
  
  def default
    ""
  end
  def description
    ""
  end
end
