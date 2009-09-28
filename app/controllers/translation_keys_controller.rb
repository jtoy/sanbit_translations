class TranslationKeysController < Admin
  before_filter :admin_required
  def index
    @translation_keys = TranslationKey.hidden(false).paginate :page => @page, :per_page => @per_page, :order => 'updated_at DESC'
    @translations_count = Translation.all.size
  end
  
  def new
    @translation_key = TranslationKey.new(params[:translation_key])
  end
  
  #display all keys that are not used in any page
  def not_used
    #TODO this doesnt work
    @translation_keys = TranslationKey.all.paginate :page => @page, :per_page => @per_page, :order => 'updated_at DESC'
    @translations_count = 0
    render :index
  end
  
  #this updates a translation, not a translation_key
  def update
    @translation = Translation.find(params[:id])
    @translation.update_attributes(params[:translation])
    respond_to do |format|
      format.html { redirect_to :index }
      format.js { render :nothing => true }
    end
  end
  
  def create
    @translation_key = TranslationKey.new(params[:translation_key])
    respond_to do |format|
      if @translation_key.save
        format.html {redirect_to :action => 'index'}
        format.js { render :status => 200}
      else
        flash[:notice] = "Create failture!"
        format.html { render :action => 'new'}
        format.js {render :nothing => true}
      end
    end
  end
  
  def add_translation
    @translation_key = TranslationKey.find_by_key(params[:key])
    @translation = Translation.new(params[:translation]){|x| x.key = @translation_key.key}
    respond_to do |format|
      format.html
      format.js { render :layout => false}
    end
  end
  
  def translation_create
    @translation = Translation.new(params[:translation]){|x| x.user_id = current_user.id}
    respond_to do |format|
      if @translation.save
        format.html {redirect_to :action => 'index'}
        format.js { render :partial => "translation_key", :locals => { :tk => TranslationKey.find_by_key(@translation.key)}, :status => 200}
      else
        flash[:notice] = "Create translation failture!"
        format.html { render :action => 'add_translation'}
        format.js {render :nothing => true}
      end
    end
  end
  
  def translation_destroy
    @translation = Translation.find(params[:t_id])
    respond_to do |format|
      if @translation.destroy
        format.html {redirect_to :action => 'index'}
        format.js { render :partial => "translation_key", :locals => { :tk => TranslationKey.find_by_key(@translation.key)}, :status => 200}
      else
        flash[:notice] = "Delete failture!"
        format.html { redirect_to :action => 'index'}
        format.js {render :nothing => true}
      end
    end
  end
  
  def set_override_true
    @translation = Translation.find(params[:t_id])
    respond_to do |format|
      if @translation.set_override
        format.html {redirect_to :action => "index"}
        format.js {render :partial => "translation_key", :locals => { :tk => TranslationKey.find_by_key(@translation.key)}, :status => 200}
      else
        format.html
        format.js
      end
    end
  end
  
  def tk_destroy
    @translation_key = TranslationKey.find(params[:tk_id])
    respond_to do |format|
      if @translation_key.destroy
        format.html {redirect_to :action => 'index'}
        format.js { render :partial => "translation_key", :locals => { :tk => TranslationKey.find_by_id(@translation_key.id)}, :status => 200}
      else
        flash[:notice] = "Delete failture!"
        format.html { redirect_to :action => 'index'}
        format.js {render :nothing => true}
      end
    end
  end
  
  def search
    @translation_keys, @translations = [], []
    search_tk = params[:search_tk].strip if params[:search_tk]
    search_t = params[:search_t].strip if params[:search_t]
    @translation_keys = TranslationKey.find(:all, :conditions => ["key ilike ?", "%#{search_tk}%"]) unless search_tk.blank?
    if search_t
      if search_t.blank?
        @translations = Translation.find_all_by_content(search_t) 
      else
        @translations = Translation.find(:all, :conditions => ["content ilike ?", "%#{search_t}%"])
      end
    end
    if @translation_keys.blank? && !@translations.blank?
      @translations.each {|t| @translation_keys << TranslationKey.find_by_key(t.key)}
    end
    respond_to do |format|
      format.html
      format.js {render :partial => "search", :locals => {:translation_keys => @translation_keys}, :status => 200}
    end
  end
end
