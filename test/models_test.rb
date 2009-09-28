require File.dirname(__FILE__)+'/test_helper'
class User < ActiveRecord::Base
  validates_uniqueness_of :login
  has_many :translations
  has_many :translation_votes
end

class ModelsTest < Test::Unit::TestCase
  load_schema 
  @@sequence = 0
  
  def setup
    User.delete_all
    Translation.delete_all
    TranslationKey.delete_all
    TranslationVote.delete_all
  end
  
  def test_translation_can_have_no_user
    translation = create_transaltion
    
    translation.user = nil
    assert_equal(translation.save, true)
    assert_equal(translation.errors.size, 0)
  end
  
  def test_translation_should_have_content
    translation = create_transaltion
    
    translation.content = nil
    assert_equal(translation.save, false)
  end
  
  def test_translation_should_have_locale
    translation = create_transaltion
    
    translation.locale = nil
    assert_equal(translation.save, false)
  end
  
  def test_translation_should_have_key
    translation = create_transaltion
    
    translation.key = nil
    assert_equal(translation.save, false)
  end
  
  def test_translation_to_s
    translation = create_transaltion

    content = translation.content
    assert_equal(translation.to_s, content)
  end
  
  def test_translation_should_not_have_two_same_override
    translation = create_transaltion(:override=> true)
    other_translation = Translation.new({:content => 'good', :locale => translation.locale, :translation_key => translation, :user => translation.user, :override => true})
    
    assert_equal(translation.key, other_translation.key)
    assert_equal(translation.locale,other_translation.locale)
    assert_equal(other_translation.save , false)
  end
  
  def test_translation_locale_scoped
    translation_1 = create_transaltion(:locale => 'en')
    translation_2 = create_transaltion(:locale => 'Zh')
    
    assert_equal(Translation.locale('en').include?(translation_1), true)
    assert_equal(Translation.locale('en').include?(translation_2), false)
    assert_equal(Translation.locale('Zh').include?(translation_1), false)
    assert_equal(Translation.locale('Zh').include?(translation_2), true)
    assert_equal(Translation.locale('Nothing').include?(translation_1), false)
    assert_equal(Translation.locale('Nothing').include?(translation_2), false)
  end
  
  def test_translation_key_should_not_have_the_same_key
    translation_key = create_transaltion_key
    same_translation_key = TranslationKey.new(:key => translation_key.key)
    
    assert_equal(same_translation_key.save, false)
  end
  
  def test_translation_key_should_have_key
    translation_key = create_transaltion_key
    translation_key.key = nil
    assert_equal(translation_key.save, false)
  end
  
  def test_translation_key_to_s
    translation_key = create_transaltion_key
    key = translation_key.key
    assert_equal(translation_key.to_s, key)
  end
  
  def test_translation_from_scoped
    james = create_user(:login => 'jemes')
    mat   = create_user(:login => 'mat')
    translation_1 = create_transaltion(:user => james)
    translation_2 = create_transaltion(:user => mat)
    assert_equal(Translation.from(mat).include?(translation_2), true)
    assert_equal(Translation.from(mat).include?(translation_1), false)
    
    user = create_user({:login => 'user'})
    assert_equal(Translation.from(user).size, 0)
  end
  
  def test_translation_vote_should_have_a_user
    translation_vote = create_transaltion_vote

    translation_vote.user = nil
    assert_equal(translation_vote.save, false)
    assert_equal(translation_vote.errors.size, 1)
  end
  
  def test_translation_vote_validate
    james = create_user(:login => 'jemes')
    mat   = create_user(:login => 'mat')
    translation = create_transaltion(:user => mat)

    translation_vote_1 = TranslationVote.new(:translation => translation, :user => mat, :vote => 1)
    assert_equal(translation_vote_1.save, false)
    
    translation_vote_2 = TranslationVote.new(:translation => translation, :user => james, :vote => 1)
    assert_equal(translation_vote_2.save, true)
  end
  
  def test_translation_voted_by?
    james = create_user(:login => 'jemes')
    mat   = create_user(:login => 'mat')
    translation = create_transaltion(:user => mat)
    transaltion_vote = create_transaltion_vote(:translation => translation, :user => james)
    
    assert_equal(translation.voted_by?(james), true)
    assert_equal(translation.voted_by?(mat), false)
  end
    
  def test_translation_content_should_match_default_variable
    james = create_user(:login => 'jemes')
    translation_key = create_transaltion_key
    translation = create_transaltion(:content => "{{ user }} is body", :translation_key => translation_key, :locale => 'en')
    
    translation_1 = Translation.new(:content => "{{ user }} 是个小男孩", :translation_key => translation_key, :locale => 'zh', :user => james)
    assert_equal(translation_1.save, true)
    
    translation_2 = Translation.new(:content => "{{ user1 }} 是个小男孩", :translation_key => translation_key, :locale => 'zh', :user => james)
    assert_equal(translation_2.save, false)
    
    translation_3 = Translation.new(:content => "{ user } 是个小男孩", :translation_key => translation_key, :locale => 'zh', :user => james)
    assert_equal(translation_3.save, false)
  end
  
  
  
  def next_sequence
    @@sequence += 1
  end
  
  def create_user(attributes = {})
    attributes.symbolize_keys!
    attributes.reverse_merge!(:login => "user#{next_sequence}")
    User.create!(attributes)
  end
  
  def create_transaltion_key(attributes = {})
    attributes.symbolize_keys!
    attributes.reverse_merge!(:key => "key#{next_sequence}")
    attributes.reverse_merge!(:default => "default#{next_sequence}")
    TranslationKey.create!(attributes)
  end
  
  def create_transaltion(attributes = {})
    attributes.symbolize_keys!
    attributes.reverse_merge!(:content => "content#{next_sequence}")
    attributes.reverse_merge!(:locale => "en")
    attributes.reverse_merge!(:translation_key => create_transaltion_key)
    attributes.reverse_merge!(:user => create_user)
    attributes.reverse_merge!(:override => false)
    Translation.create!(attributes)
  end
  
  def create_transaltion_vote(attributes = {})
    attributes.symbolize_keys!
    attributes.reverse_merge!(:translation => create_transaltion)
    attributes.reverse_merge!(:vote => 1)
    attributes.reverse_merge!(:user => create_user)
    TranslationVote.create!(attributes)
  end

end