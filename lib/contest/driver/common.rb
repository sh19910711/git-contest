#
# common.rb
#
# Copyright (c) 2013 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'mechanize'
require 'nokogiri'
require 'trollop'
require 'contest/driver/base'

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

      def self.normalize_language label
        case label
        when "c", "C"
          return "clang"
        when "cpp", "C++", "c++", "cc", "cxx"
          return "cpp"
        when "c++11", "C++11"
          return "cpp11"
        when "cs", "c#", "C#"
          return "cs"
        when "d", "D", "dlang"
          return "dlang"
        when "go", "golang"
          return "golang"
        when "hs", "haskell", "Haskell"
          return "haskell"
        when "java", "Java"
          return "java"
        when "ocaml", "ml", "OCaml"
          return "ocaml"
        when "Delphi", "delphi"
          return "delphi"
        when "pascal", "Pascal"
          return "pascal"
        when "perl", "Perl", "pl"
          return "perl"
        when "php", "PHP"
          return "php"
        when "python2"
          return "python2"
        when "python3", "python", "Python", "py"
          return "python3"
        when "ruby", "rb", "Ruby"
          return "ruby"
        when "scala", "Scala"
          return "scala"
        else
          abort "unknown language @ normalize language"
        end
      end
    end
  end
end
