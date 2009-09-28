ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require 'test/unit'
require 'rubygems'
require 'ruby-debug'
require "active_record"
#require File.expand_path(File.join(ENV['RAILS_ROOT'],'config/environment.rb'))
def load_schema
  config = YAML::load(File.open(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log") 
  ActiveRecord::Base.establish_connection(config['postgresql'])
  load(File.dirname(__FILE__) + "/schema.rb")
  puts File.join(File.dirname(__FILE__), "/../lib/app/models", "translation")
  require File.join(File.dirname(__FILE__), "/../app/models", "translation")
  require File.join(File.dirname(__FILE__), "/../app/models", "translation_key")
  require File.join(File.dirname(__FILE__), "/../app/models", "translation_vote")
end