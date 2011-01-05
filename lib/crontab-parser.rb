# -- coding: utf-8

require "stringio"
require "crontab-parser/record.rb"
require "crontab-parser/time_parser.rb"

class CrontabParser
  include Enumerable

  def initialize(crontab, options={})
    @crontab = crontab
    @options = options
  end

  def each
    io = if File.exists?(@crontab)
      open(@crontab, 'r')
    else
      StringIO.new(@crontab)
    end
    until io.eof?
      line = io.gets
      line.strip!
      if line.length > 0 && line.index('#') != 0
        yield Record.new(line, @options) 
      end
    end
  end
end
