# frozen_string_literal: true

# Load required libraries and stuff
require 'open3'
require 'json'
require 'digest'

# Ensure lib is on RUBYLIB even when running under rbenv shims
paths = ENV['RUBYLIB'].to_s.split(':')
ENV['RUBYLIB'] = (['lib'] + paths).reject(&:empty?).uniq.join(':')
