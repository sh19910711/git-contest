#
# common.rb
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'mechanize'
require 'nokogiri'
require 'trollop'
require 'contest/driver/base'

module Contest
  module Driver
    module Utils
      # find all driver
      def self.get_all_drivers
        return [] unless defined? Contest::Driver
        Contest::Driver.constants.select {|class_name|
          /.*Driver$/ =~ class_name.to_s
        }.map {|driver_class_name|
          driver = Contest::Driver.const_get(driver_class_name).new
          {
            :class_name => driver_class_name,
            :site_info => {
              :name => driver.get_site_name(),
              :desc => driver.get_desc(),
            },
          }
        }
      end

      #
      # Load Plugins
      #
      def self.load_plugins
        # load drivers
        Dir.glob("#{$GIT_CONTEST_HOME}/plugins/**") do |path|
          require path if /\/.*_driver\.rb$/.match path
        end
      end

      def self.resolve_wild_card path
        `ls #{path} | cat | head -n 1`.strip
      end

      # resolve wild card
      def self.resolve_path src
        if src.match ','
          src.split(',').map do |path|
            resolve_wild_card(path)
          end
        else
          resolve_wild_card(src)
        end
      end

      def self.resolve_language path
        # set first element if path is array
        if path.is_a? Array
          path = path[0]
        end
        regexp = /\.([a-z0-9]+)$/
        if path.match(regexp)
          return path.match(regexp)[1]
        else
          return nil
        end
      end

      def self.get_file_ext filename
        File.extname(filename)[1..-1]
      end

      def self.check_file_map label, ext_map
        if ext_map.is_a? Hash
          ext = get_file_ext(label)
          ext_map.has_key?(ext)
        else
          false
        end
      end

      def self.resolve_file_map label, ext_map
        ext = get_file_ext(label)
        ext_map[ext]
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
        when "javascript", "js"
          return "javascript"
        when "objc", "m"
          return "objc"
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
        when "pl", "prolog"
          return "prolog"
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
