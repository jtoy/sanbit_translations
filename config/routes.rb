
ActionController::Routing::Routes.draw do |map|
  map.resources :translations, :collection => { :vote=> :get,:mine => :get, :set_tr_mode => [:get, :post], :untranslated => :get, :to_translate => :get, :to_vote => :get, :search => :get }
  map.resources :translation_keys, :collection => {:tk_destroy => :get, :translation_destroy => :get, :add_translation => :get, :translation_create => :post, :set_override_true => :get,:search => :get, :not_used => :get}
end
