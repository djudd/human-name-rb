require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :benchmark do
  require 'people'
  require 'namae'
  require 'human_name_parser'
  require 'benchmark'
  require 'humanname'
  require 'open-uri'

  input = open("https://raw.githubusercontent.com/djudd/human-name/master/tests/benchmark-names.txt").each_line.to_a

  puts "people gem:"
  parser = People::NameParser.new
  result = Benchmark.measure do
    input.each { |i| parser.parse(i)['surname'.freeze] }
  end
  puts result

  puts "namae gem:"
  result = Benchmark.measure do
    input.each { |i| (o = Namae.parse(i).first) && o.family }
  end
  puts result

  puts "human_name_parser gem:"
  result = Benchmark.measure do
    input.each { |i| HumanNameParser.parse(i).last }
  end
  puts result

  puts "this gem:"
  result = Benchmark.measure do
    input.each { |i| (o = HumanName.parse(i)) && o.surname }
  end
  puts result

end
