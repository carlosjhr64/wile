# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  class NvimFiles
    attr_reader :info

    def initialize(project = Info.info.project)
      @project = project
    end

    # :reek:TooManyStatements
    def nvim_files
      bin = File.directory?('bin') ? nvim_bin_files : []
      lib = nvim_lib_files
      ranks = nvim_ranks(lib)
      if (more = more_ranks(lib))
        ranks -= more # remove the duplicates
        ranks += more # append the more
      end
      lib -= ranks
      ['README.md'] + bin + ranks + lib
    end

    private

    def nvim_bin_files
      find('bin').select { File.executable? it }.sort
    end

    # :reek:FeatureEnvy :reek:UncommunicativeVariableName
    def nvim_lib_files
      find('lib').grep(/\.rb$/).sort do |a, b|
        (c = a.count('/') <=> b.count('/')).zero? ? a <=> b : c
      end
    end

    def find(dir)
      Find.find(dir).select { File.file? it }
    end

    # :reek:TooManyStatements
    def more_ranks(lib, rqs = "lib/#{@project}/requires.rb")
      return nil unless File.exist?(rqs)

      rgx = /'(\w([-\w]*)+)'/
      ranks = file_ranks(rqs, rgx).map { "lib/#{@project}/#{it}.rb" }
                                  .select { lib.include?(it) }
      ranks.sort_by! { it.count('/') }
    end

    # :reek:TooManyStatements
    def nvim_ranks(lib, prb = "lib/#{@project}.rb")
      rgx = %r{'(#{@project}(/\w[-\w]*)+)'}
      ranks = file_ranks(prb, rgx, auto: true).map { "lib/#{it}.rb" }
                                              .select { lib.include?(it) }
      # add the lib/project.rb file
      ranks.unshift prb
      ranks.sort_by! { it.count('/') }
    end

    # :reek:BooleanParameter :reek:ControlParameter
    def file_ranks(filename, rgx, auto: false)
      grep = auto ? /require_relative|auto/ : /require_relative/
      File.readlines(filename)
          .grep(grep).grep(rgx)
          .map { it.scan(rgx)[0][0] }
    end
  end
end
