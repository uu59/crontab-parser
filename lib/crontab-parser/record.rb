# -- coding: utf-8

class CrontabParser
  class Record
    attr_reader :line

    def initialize(line, options={})
      @line = line
      @options = options
    end

    def cmd
      times
      @cmd
    end

    def to_s
      @line
    end

    def should_run?(time)
      time.utc
      times[:min].include?(time.min) &&
        times[:hour].include?(time.hour) &&
        times[:day].include?(time.day) &&
        times[:month].include?(time.month) &&
        times[:week].include?(time.wday)
    end

    def times
      @times ||= begin
        base = @line.strip.gsub(/#.*/, "").gsub(%r!^@(yearly|annually|monthly|weekly|daily|midnight|hourly)!){|m|
          case $1
            when 'yearly','annually'
              '0 0 1 1 *'
            when 'monthly'
              '0 0 1 * *'
            when 'weekly'
              '0 0 * * 0'
            when 'daily','midnight'
              '0 0 * * *'
            when 'hourly'
              '0 * * * *'
          end
        }.strip
        min,hour,day,month,week,@cmd = *base.split(/[\t\s]+/, 6)
        base = [min,hour,day,month,week].join(" ")
        if week.nil?
          if @options[:silent]
            return nil
          else
            raise "invalid line #{@line}" 
          end
        end
        {
          :month => TimeParser.parse(month, 1, 12),
          :day => TimeParser.parse(day, 1, 31),
          :hour =>  TimeParser.parse(hour, 0, 23),
          :min => TimeParser.parse(min, 0, 59),
          :week => TimeParser.parse(week, 0, 6),
        }
      end
    end
  end
end
