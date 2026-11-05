# frozen_string_literal: true

# wile: require 'irbtools'

# Project-local .irbrc for template projects. Provides a zero-setup REPL by
# automatically requiring the gem and printing its version banner.
# Loaded by ~/.irbrc when executing irb from the project root:
#   if not Dir.home == Dir.pwd and File.exist? '.irbrc'
#     load '.irbrc'
#   end

begin
  project = File.basename __dir__
  require project
  klass = project.split('_').map { it.capitalize }.join
  version = Object.const_get("#{klass}::VERSION")
  message = "### #{klass}:#{version} Ruby:#{RUBY_VERSION} ###"
rescue StandardError => e
  message = e.message
end

begin
  require 'colorize'
  require 'irbtools/configure'
  msg = message.respond_to?(:blue) ? message.blue : message
  Irbtools.welcome_message = msg
  Irbtools.start
rescue LoadError
  warn message if defined?(message)
end
