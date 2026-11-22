# frozen_string_literal: true

# wile: os `git`

# Load required libraries and stuff
require 'open3'
require 'json'
require 'digest'
require 'fileutils'

# Ensure lib is on RUBYLIB even when running under rbenv shims
paths = ENV['RUBYLIB'].to_s.split(':')
ENV['RUBYLIB'] = (['lib'] + paths).reject(&:empty?).uniq.join(':')

Before('@local') do
  skip_this_scenario unless `git config user.name`.strip == 'CarlosJHR64'
end
