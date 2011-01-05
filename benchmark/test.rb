# -- coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')
require "benchmark"
require "ruby-prof"

crontab = <<-CRON
  # should ignore comment only line and blank line

  #m h d m w cmd
   * * * * * foo # always run. this comment was ignored
   3 * * * * bar
   */1 0-22 * * * baz
CRON
crontab *= 64
range = {
  0 => 0..59,
  1 => 0..23,
  2 => 1..31,
  3 => 1..12,
  4 => 0..6,
}

5000.times{
  line = ""
  5.times {|n|
    ra = range[n].to_a.shuffle
    line << case rand(10)
      when 0..7
        ra.first.to_s
      when 8
        x,y = [ra.first, ra.last].sort
        "#{x}-#{y}"
      else
        ra.take(rand(ra.length - 1) + 1).sort.join(",")
    end
    if rand(2) == 1
      line << "/" + (rand(range[n].last) + 1).to_s
    end
    line << " "
  }
  line << "cmd" + Time.now.to_f.to_s
  line << "\n"
  crontab += line
}
crontab += "k k k k k"
File.open('foo.txt', 'w'){|f| f.puts crontab}

now = Time.utc(2010,1,1,0,0,0)
c = CrontabParser.new("foo.txt")

GC.disable
RubyProf.start
puts c.find_all{|row| row.times}.length
result = RubyProf.stop
GC.enable
RubyProf::FlatPrinter.new(result).print
