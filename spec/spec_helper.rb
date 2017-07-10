require "bundler/setup"
require "I18ner"
require 'i18n'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def with_i18n_config(translations, &block)
  I18n.config.available_locales = :en
  I18n.locale = :en
  # I18n.defualt_locale = :en
  t = Tempfile.new(%w(foo .yml))
  t.write(YAML.dump(translations))
  t.close
  I18n.backend.load_translations(t)

  yield(translations)

  t.unlink
  I18n.backend.reload!
end
