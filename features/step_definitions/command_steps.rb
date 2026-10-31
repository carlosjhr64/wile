# frozen_string_literal: true

# Given command "<command>"
Given(/(?:Given )?command "([^"]*)"/) do |command|
  @command = command
end

# Given option "<options>"
Given(/(?:Given )?options? "([^"]*)"/) do |options|
  @options = options
end

# When we run command
When(/(?:When )?we run command/) do
  @stdout, @stderr, @status = Open3.capture3("#{@command} #{@options}")
  [@stdout, @stderr].each(&:chomp!)
end

# Then exit status is "<status>"
Then(/(?:Then )?exit status is "(\d+)"/) do |status|
  unless @status.exitstatus == status.to_i
    raise "Got exit status #{@status.exitstatus} instead of #{status}"
  end
end

# Then stdout is '<string>'
Then(/(?:Then )?stdout is '([^']*)'/) do |string|
  unless @stdout == string
    raise "stdout: Expected '#{string}'. Got '#{@stdout}'"
  end
end

# Then stdout is "<inspect>"
Then(/(?:Then )?stdout is ("[^"]*")/) do |string|
  unless @stdout.inspect == string
    raise "stdout: Expected '#{string}'. Got '#{@stdout}'"
  end
end

# Then stderr is "<string>"
Then(/(?:Then )?stderr is "([^"]*)"/) do |string|
  unless @stderr == string
    raise "stderr: Expected '#{string}'. Got '#{@stderr}'"
  end
end

# Then stderr is '<string>'
Then(/(?:Then )?stderr is '([^']*)'/) do |string|
  unless @stderr == string
    raise "stderr: Expected '#{string}'. Got '#{@stderr}'"
  end
end

# Then stdout includes "<string>"
Then(/(?:Then )?stdout includes "([^"]*)"/) do |string|
  raise "Stdout did not include '#{string}'" unless @stdout.include?(string)
end

# Then stdout does not include "<string>"
Then(/(?:Then )?stdout (?:not|does not) includes? "([^"]*)"/) do |string|
  raise "Stdout included '#{string}'" if @stdout.include?(string)
end

# Then stderr includes "<string>"
Then(/(?:Then )?stderr includes "([^"]*)"/) do |string|
  raise "Stderr did not include '#{string}'" unless @stderr.include?(string)
end

# Then stderr does not include "<string>"
Then(/(?:Then )?stderr (?:not|does not) includes? "([^"]*)"/) do |string|
  raise "Stderr included '#{string}'" if @stderr.include?(string)
end

# Then stdout matches /<pattern>/
Then %r{(?:Then )?stdout matches /([^/]*)/} do |string|
  unless Regexp.new(string).match?(@stdout)
    raise "Stdout did not match '#{string}'"
  end
end

# Then stdout does not match /<pattern>/
Then %r{(?:Then )?stdout (?:not|does not) match(?:es)? /([^/]*)/} do |string|
  raise "Stdout matched '#{string}'" if Regexp.new(string).match?(@stdout)
end

# Then stderr matches /<pattern>/
Then %r{(?:Then )?stderr matches /([^/]*)/} do |string|
  unless Regexp.new(string).match?(@stderr)
    raise "Stderr did not match '#{string}'"
  end
end

# Then stderr does not match /<pattern>/
Then %r{(?:Then )?stderr (?:not|does not) match(?:es)? /([^/]*)/} do |string|
  raise "Stderr matched '#{string}'" if Regexp.new(string).match?(@stderr)
end

# Then <key> => <value>
Then(/(?:Then )?(\w+) => (\S+)/) do |k, v|
  h = JSON.parse @stdout
  raise "#{k} is not #{v}, it's #{h[k]}" unless h[k] == v
end

# Then <key> maps to true
Then(/(?:Then )?(\w+) maps to true/) do |k|
  h = JSON.parse @stdout
  raise "#{k} is not true, it's #{h[k]}" unless h[k] == true
end

# Then <key> maps to nil
Then(/(?:Then )?(\w+) maps to nil/) do |k|
  h = JSON.parse @stdout
  raise "#{k} is not nil, it's #{h[k]}" unless h[k].nil?
end

# Then <key> is [<items>]
Then(/(?:Then )?(\w+) is \[(\S+)\]/) do |k, v|
  h = JSON.parse @stdout
  l = h[k].join(',')
  raise "#{k} is not #{v}, it's #{l}" unless l == v
end

# Then header is "<string>"
Then(/(?:Then )?header is "(.*)"/) do |v|
  header = @stdout.split("\n", 2).first
  raise "Header is not #{v}, it's #{header}" unless header == v
end

# Then digest is "<md5>"
Then(/(?:Then )?digest is "(.*)"/) do |v|
  # Ensure no changes to output occurred in future edits.
  # Note that stdout was stripped, so adding newline back in,
  # making the use of piped md5sum output possible.
  digest = Digest::MD5.hexdigest("#{@stdout}\n")
  raise "Digest is not #{v}, it's #{digest}" unless digest == v
end
