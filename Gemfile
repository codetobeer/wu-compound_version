#vim: fdm=syntax et
ruby "~> 3.0"

source 'https://rubygems.org'

gemspec

group :development do 
  PRIVATE_REPO_URL='http://geminabox.porter/private/'
  source PRIVATE_REPO_URL do 
    gem "wu-gem-tasks", '~>0.13.0'
  end
end

group :test, :development do
  gem 'rubygems-tasks', '~>0.2'
  gem "stackprof", "~> 0.2.12"
  #gem "ruby-prof", "~> 1.6"
  #gem "ruby-prof", "~> 0.18.0"
  #gem "pry-doc" #, "~> 0.13.0"
  ##gem "pry-inline", "~> 1.0" #issue with 0.12
  gem "pry-rescue", "~> 1.5"
  ##gem "pry-rails", "~>0.3.9"
  #gem "pry-state", "~> 0.1"   #issue with 0.12
  #gem "pry", "~> 0.13.0", "<0.14"
  gem "pry", "~> 0.14"
  gem "pry-byebug", "~> 3.10"
  gem "byebug", "~> 11.1"
  # for https://github.com/ConradIrwin/pry-rescue/issues/124
  #gem 'pry-byebug', github: 'cygnuseducation/pry-byebug', ref: '6adc5899b34c24dbd4d63ef4d4724b29ef907206'
  gem "pry-stack_explorer", "~> 0.6.0" #req ruby 2.6
  ##gem "pry-remote", "~>0.1.8"

  #gem "power_p"
  #gem "power_assert", '~>2.0.0'
  #gem "pry-power_assert", '~>0.0.2'
  #gem "pry-byebug-power_assert", '~> 0.1.1'

  #gem "minitest", "~> 5.18"
  #gem "minitest-power_assert", "~> 0.3.1"

  #gem "binding_of_caller", "~> 0.8.0"
  #gem "minitest-reporters", "~> 1.6"
  #gem "minitest-unordered", "~> 1.0.2"
  gem 'ripper-tags', '~>1.0'
  # Avoid ReLine
  gem 'readline'
  gem 'readline-ext'
end
