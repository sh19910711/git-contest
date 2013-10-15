require 'mechanize'
require 'nokogiri'
require 'trollop'
require 'git/contest/driver/base'

module Git
  module Contest
    module Driver
      module Utils
        def self.resolve_path path
          path = `ls #{path} | cat | head -n 1`
          path.strip
        end

        def self.resolve_language path
          regexp = /\.([a-z0-9]+)$/
          if path.match(regexp)
            return path.match(regexp)[1]
          else
            return nil
          end
        end
      end
    end
  end
end


