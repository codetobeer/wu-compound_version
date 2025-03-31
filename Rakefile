#!/usr/bin/env rake
require 'pry'
$: << File.expand_path('../lib', __FILE__)
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rubygems/tasks'
require 'minitest/test_task'

require 'wu/gem_repo_helper/define_tasks'
require 'wu/rake/tasks/tags'
require 'wu/rake/tasks/gem/define_tasks'

Rake.add_rakelib 'lib/tasks'

task  test: 'test:all'

namespace :test do #{{{1
  ENV["RB_TEST_VERBOSE"] = "1" if verbose

  all_tests = []

  Dir['test/*'].each do |test_dir|
    next unless Dir.exist? test_dir
    desc "Run tests for WU::Gem::Tasks"
    test_name = File.basename(test_dir)
    all_tests << test_name

    Minitest::TestTask.create(test_name) do |t|
      #require 'bundler'
      #Bundler.setup(:default)
      t.libs << 'test'
      #t.test_files = FileList['test/wu-gem-tasks/test*.rb']
      t.test_globs = ["#{test_dir}/test*.rb"]
      t.verbose = true
    end
  end

  desc "Run tests"
  task :all => all_tests
end #}}}1
