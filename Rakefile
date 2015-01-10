require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:spec_current) do |t|
  t.rspec_opts = [
    "--format documentation",
    "--color",
    "--tag current",
  ]
end
