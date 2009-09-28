Gem::Specification.new do |s|
  s.name = "i18n"
  s.version = "0.0.4"
  s.date = "2009-08-09"
  s.summary = "Facebook Style Internationalization support for Rails"
  s.email = "jtoy@jtoy.net"
  s.homepage = "http://github.com/jtoy/sanbit_translations"
  s.description = "Add Facebook Style Internationalization support to your Rails application."
  s.has_rdoc = false
  s.authors = ['Jason Toy']
  s.files = [
    'i18n.gemspec',
    'lib/i18n/backend/sanbit.rb',
    'lib/i18n/exceptions.rb',
    'lib/i18n.rb',
    'MIT-LICENSE',
    'README.textile'
  ]
  s.test_files = [
    'test/all.rb',
    'test/i18n_exceptions_test.rb',
    'test/i18n_test.rb',
    'test/locale/en.rb',
    'test/locale/en.yml',
    'test/backend_test.rb',
    'test/fast_backend_test.rb',
    'test/pluralization_compiler_test.rb'
  ]
end
