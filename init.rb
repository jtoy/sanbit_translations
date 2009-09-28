I18n.backend = I18n::Backend::Sanbit.new

RAILS_DEFAULT_LOGGER.info "** sanbit translations: initialized properly."

require 'action_view/helpers/tag_helper'

module ::ActionView
  class Base
    def translate_with_translation_mode key,options={}
      options[:css] = true unless options.has_key?(:css)
      if I18n::Backend::Sanbit.translation_mode && options[:css]
        if key.respond_to?(:to_translation_key)
          content_tag('span',I18n.translate(scope_key_by_partial(key), options),{:class => I18n::Backend::Sanbit.translation_class, :key => key.to_translation_key})
        else
          content_tag('span',I18n.translate(scope_key_by_partial(key), options),{:class => I18n::Backend::Sanbit.translation_class, :key => key})
        end
      else
        I18n.translate(scope_key_by_partial(key), options)
      end
    end
    alias_method_chain :translate, :translation_mode
    alias :t :translate
  end
end

