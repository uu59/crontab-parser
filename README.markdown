# Usage

    cron = CrontabParser.new(`crontab -l`)
    now = Time.now
    cron.find_all{|row|
      row.should_run?(now)
    }.each{|row|
      puts "#{row.cmd} goes run just now"
    }

    cron = CrontabParser.new(<<-CRON)
    * * * * * monitor-process
    @daily mailme
    @monthly full-backup
    CRON

    now = Time.now
    cron.find_all{|row|
      row.should_run?(now)
    }.each{|row|
      puts "#{row.cmd} goes run just now"
    }

