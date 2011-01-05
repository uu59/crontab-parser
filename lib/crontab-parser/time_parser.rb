# -- coding: utf-8

class CrontabParser
  class TimeParser
    CACHE = {}

    def self.parse(column, first=0, last=59)
      base = column + "_#{first}-#{last}"
      if CACHE[base]
        return CACHE[base]
      end
      column = column.gsub(%r!/1$!,"").gsub('*', "#{first}-#{last}")
      if column.index('/')
        times,filter = *column.split("/")
      else
        times = column
        filter = nil
      end

      result = if times.index(',')
        times.split(',').map{|col| separetor(col)}
      else
        separetor(times)
      end.flatten

      if filter
        result = result.find_all{|n| n % filter.to_i == 0}
      end

      CACHE[base] = result
    end

    def self.separetor(col)
      if col.index('-')
        m,n = *col.split("-").map{|n| n.to_i}
        (m..n).to_a
      else
        [col.to_i]
      end
    end
  end
end
