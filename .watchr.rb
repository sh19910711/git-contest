watch(/.*/) {|md|
  puts `bundle exec rake install`
}
