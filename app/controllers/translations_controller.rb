class TranslationsController < ApplicationController
  before_filter :login_required
  before_filter :translation_mode_check, :except => [:set_tr_mode]
  before_filter :set_tr_locale
  
  def new
    @translation_key = TranslationKey.find_by_key(params[:key]) || TranslationKeyNotInDb.new(params[:key])
    @translation = Translation.new(params[:translation]){|x| x.key = @translation_key.key}
    @locale = Locale.find_by_value(@l)
    respond_to do |format|
      format.html
      format.js{ render :partial => "new", :layout => false }
    end
  end
  
  def create
    # #TODO set proper local from db
    @translation = Translation.new(params[:translation]){|x| x.user = current_user; x.locale =current_user.translation_locale}
    respond_to do |format|
      if @translation.save
        format.html
        format.js{ render :nothing => true ,:status => 200}
      else
        format.html {render :action => "new"}
        format.js {render :text => @translation.errors}
      end
    end
  end
  
  def edit
    @translation = Translation.find(params[:id])
  end
  
  def update
    @translation = current_user.translations.find(params[:id])
    if @translation.update_attributes(params[:translation])
    end
  end
  
  
  def index
    @total = TranslationKey.count
    @mine = current_user.translations.locale(@l).count
    @submitted = Translation.locale(@l).count
    @untranslated = TranslationKey.untranslated(@l).count
    @top_contributers = Translation.all(:conditions => ["user_id IS NOT NULL AND locale = ?", @l], :group => "user_id", :select => "user_id", :limit => 6, :order => "COUNT(*) DESC" ).collect {|tran_user_id| User.find(tran_user_id.user_id)}
  end
  
  def show
    @translation_key = TranslationKey.scoped_by_key(params[:key])
  end
  
  def untranslated
    @translation_keys = (TranslationKey.hidden(false) - TranslationKey.hidden(false).has_translations_in_locale(current_user.translation_locale).uniq)
    @translation_keys = @translation_keys.select{|tk| tk.default != nil }.paginate(:per_page => 10, :page => @page)
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def mine
    @translations = current_user.translations.locale(@l).paginate(:per_page => 10, :page => @page)
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  

  
  def vote
    @translation_vote = TranslationVote.new(:translation_id => params[:id],:user =>current_user,:vote =>params[:v])
    if @translation_vote.save
      respond_to do |format|
        format.js{ render :partial => "vote_translation", :locals => { :object => Translation.find(params[:id])}, :status => 200}
        format.html {redirect_to :action => :to_vote}
      end
    else
      respond_to do |format|
      end
    end
  end
  

  
  def to_vote
    @translation_keys = TranslationKey.hidden(false).has_translations_in_locale(current_user.translation_locale).paginate(:per_page => 10, :page => @page, :order => "updated_at DESC")
    respond_to do |format|
      format.html
      format.js {render :partial => "vote", :locals => {:translation_keys => @translation_keys}, :layout => false}
    end
  end
  
  def set_tr_mode
    if params[:translation_mode]
      current_user.translation_mode = params[:translation_mode]
      current_user.save
      redirect_to translations_path
    end
  end
  
  def search
    @translations = []
    @current_locale = Locale.find_by_value(@l)
    @per_page = 10
    @q = params[:q]
    @translate_type = params[:sf].to_i
    if !@q.blank? and !@translate_type.blank?
      if @translate_type == Translation::ORIGINAL_ENGLISH
        @translations = Translation.paginate(:page => @page, :per_page => @per_page, :conditions => ["locale = ? AND key iLIKE ?", 'en', "%#{@q}%"])
      elsif @translate_type == Translation::TRANSLATE_PHRASES
        translations = Translation.all(:conditions => ["locale != ? AND content iLIKE ?", 'en', "%#{@q}%"])
        @translations = translations.select{|x| Translation.find_by_locale_and_key('en', x.key) }.paginate(:page => @page, :per_page => @per_page)
      end
    end
    @translation_count = @translations.blank? ? 0 : @translations.total_entries
  end
  
  private
  
  def set_tr_locale
    @l = params['tr_locale'] || current_user.translation_locale
    current_user.update_attribute(:translation_locale,@l)
    @translate_options = Translation::TRANSLATE_OPTIONS
  end
  
  def translation_mode_check
    internal_redirect_to :action => 'set_tr_mode' unless current_user.translation_mode
  end
  
end 