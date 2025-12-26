Gem::Specification.new do |s|
  ## INFO ##
  s.name     = 'wile'
  s.version  = '0.0.251226'
  s.homepage = 'https://github.com/carlosjhr64/wile'
  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'
  s.date     = '2025-12-26'
  s.licenses = ['MIT']
  ## DESCRIPTION ##
  s.summary  = <<~SUMMARY
    `Wile` is a tasks dispatch manager
    for ruby gem projects that uses it's project template.
  SUMMARY
  s.description = <<~DESCRIPTION
    `Wile` is a tasks dispatch manager
    for ruby gem projects that uses it's project template.
    
    Generate a new project from scratch using it's template.
    Compare current project with template.
    Automate `gemspec` maintenance.
    And many other tasks!
  DESCRIPTION
  ## FILES ##
  s.require_paths = ['lib']
  s.files = %w[
    CREDITS.md
    README.md
    bin/wile
    cache/.bin/pane
    cache/.bin/panes
    cache/.config.fish
    cache/.dictionary
    cache/.gemignore
    cache/.gitignore
    cache/.greeting.erb
    cache/.irbrc
    cache/.lexicon
    cache/.prompt.erb
    cache/.reek-strict.yml
    cache/.reek.yml
    cache/.rubocop-strict.yml
    cache/.rubocop.yml
    cache/.ruby-version.erb
    cache/.title.erb
    cache/.version
    cache/.wileignore
    cache/CREDITS.md
    cache/Gemfile.erb
    cache/Gemfile.lock
    cache/History.txt
    cache/README.md.erb
    cache/TODO.md
    cache/bin/project.erb
    cache/cucumber.yml
    cache/examples/README.md
    cache/features/help.feature.erb
    cache/features/step_definitions/command_steps.rb
    cache/features/support/env.rb
    cache/features/version.feature.erb
    cache/git/hooks/pre-commit
    cache/lib/project.rb.erb
    cache/test/cons.gz
    cache/test/tc_comments
    cache/test/tc_cucumber
    cache/test/tc_dictionary
    cache/test/tc_lexicon
    cache/test/tc_lib_tests
    cache/test/tc_long_chains
    cache/test/tc_readme_rocket_check
    cache/test/tc_rubocop
    cache/test/tc_ruby_syntax
    cache/test/tc_version
    cache/test/test_module.rb
    lib/wile.rb
    lib/wile/autoloads/cache.rb
    lib/wile/autoloads/code_content.rb
    lib/wile/autoloads/code_data.rb
    lib/wile/autoloads/code_data_function.rb
    lib/wile/autoloads/code_data_valuation.rb
    lib/wile/autoloads/code_stats.rb
    lib/wile/autoloads/command_version.rb
    lib/wile/autoloads/content.rb
    lib/wile/autoloads/dependencies.rb
    lib/wile/autoloads/gem_utils.rb
    lib/wile/autoloads/gemspec.rb
    lib/wile/autoloads/git.rb
    lib/wile/autoloads/info.rb
    lib/wile/autoloads/nvim_files.rb
    lib/wile/autoloads/order_optimizer.rb
    lib/wile/autoloads/order_swap.rb
    lib/wile/autoloads/project.rb
    lib/wile/autoloads/readme.rb
    lib/wile/autoloads/responds.rb
    lib/wile/autoloads/smell.rb
    lib/wile/autoloads/test.rb
    lib/wile/help.rb
    lib/wile/refinement.rb
    lib/wile/requires.rb
    lib/wile/tasks.rb
    lib/wile/tasks/build.rb
    lib/wile/tasks/bump.rb
    lib/wile/tasks/compare.rb
    lib/wile/tasks/content.rb
    lib/wile/tasks/cp.rb
    lib/wile/tasks/dependencies.rb
    lib/wile/tasks/dictionary.rb
    lib/wile/tasks/gemcheck.rb
    lib/wile/tasks/gemfile.rb
    lib/wile/tasks/help.rb
    lib/wile/tasks/info.rb
    lib/wile/tasks/install.rb
    lib/wile/tasks/lexicon.rb
    lib/wile/tasks/list.rb
    lib/wile/tasks/mkdir.rb
    lib/wile/tasks/note.rb
    lib/wile/tasks/nvim.rb
    lib/wile/tasks/order.rb
    lib/wile/tasks/publish.rb
    lib/wile/tasks/requirements.rb
    lib/wile/tasks/review.rb
    lib/wile/tasks/ruby.rb
    lib/wile/tasks/smell.rb
    lib/wile/tasks/tc.rb
    lib/wile/tasks/test.rb
    lib/wile/tasks/todo.rb
    lib/wile/tasks/update.rb
    lib/wile/usage.rb
  ]
    s.executables << 'wile'
  ## REQUIREMENTS ##
  s.add_runtime_dependency 'colorize', '~> 1.1', '>= 1.1.0'
  s.add_runtime_dependency 'cucumber', '~> 10.2', '>= 10.2.0'
  s.add_runtime_dependency 'help_parser', '~> 9.0', '>= 9.0.240926'
  s.add_runtime_dependency 'parser', '~> 3.3', '>= 3.3.10'
  s.add_runtime_dependency 'rubocop', '~> 1.82', '>= 1.82.1'
  s.add_runtime_dependency 'test-unit', '~> 3.7', '>= 3.7.6'
  s.requirements << 'cat: 9.1'
  s.requirements << 'clear: 6.4'
  s.requirements << 'colora: 1.0'
  s.requirements << 'colordiff: 3.8'
  s.requirements << 'egrep: 3.8'
  s.requirements << 'gem: 4.0'
  s.requirements << 'git: 2.39'
  s.requirements << 'ls: 9.1'
  s.requirements << 'man: 2.11'
  s.requirements << 'md5sum: 9.1'
  s.requirements << 'ncal: 2019'
  s.requirements << 'rbenv: 1.3'
  s.requirements << 'reek: 6.5'
  s.required_ruby_version = '>= 4.0'
  s.requirements << 'ruby-parse: 3.3'
  s.requirements << 'tmux: 3.3'
  s.requirements << 'tput: 6.4'
  s.requirements << 'which: 2016'
end
