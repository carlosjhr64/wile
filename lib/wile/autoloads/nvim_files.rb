# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  class NvimFiles
    REQ_RGX = /'(\w([-\w]*)+)'/
    private_constant :REQ_RGX

    def initialize(project = Info.info.project)
      @project = project
    end

    def nvim_files
      lib = nvim_lib_files
      ranks = nvim_ranks(lib)
      more = more_ranks(lib)
      ranks = (ranks - more) + more if more
      ['README.md'] + nvim_bin_files + ranks + (lib - ranks)
    end

    private

    def nvim_bin_files
      return [] unless File.directory?('bin')

      find('bin').select { File.executable? it }.sort
    end

    def nvim_lib_files
      find('lib').grep(/\.rb$/).sort_by { [it.count('/'), it] }
    end

    def find(dir)
      Find.find(dir).select { File.file? it }
    end

    def more_ranks(lib, rqs = "lib/#{@project}/requires.rb")
      return nil unless File.exist?(rqs)

      (file_ranks(rqs, REQ_RGX).map { "lib/#{@project}/#{it}.rb" } & lib)
        .sort_by { it.count('/') }
    end

    def nvim_ranks(lib, prb = "lib/#{@project}.rb")
      rgx = %r{'(#{@project}(/\w[-\w]*)+)'}
      ranks = file_ranks(prb, rgx, /require_relative|auto/)
      ([prb] + (ranks.map { "lib/#{it}.rb" } & lib)).sort_by { it.count('/') }
    end

    def file_ranks(filename, rgx, pattern = /require_relative/)
      File.readlines(filename)
          .grep(pattern).grep(rgx)
          .map { it.scan(rgx)[0][0] }
    end
  end
end
