require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CrontabRuby" do
  it 'should parse time column' do
    CrontabParser::TimeParser.parse('3').should == [3]
    CrontabParser::TimeParser.parse('3,4,5').should == [3,4,5]
    CrontabParser::TimeParser.parse('3,4,5/2').should == [4]
    CrontabParser::TimeParser.parse('0-10/3').should == [0,3,6,9]
    CrontabParser::TimeParser.parse('0-10,20-23/3').should == [0,3,6,9,21]
    CrontabParser::TimeParser.parse('0-3,4-6,9').should == [0,1,2,3,4,5,6,9]
    CrontabParser::TimeParser.parse('*/9').should == [0,9,18,27,36,45,54]
    CrontabParser::TimeParser.parse('*/9', 0, 23).should == [0,9,18]
  end

  it 'should parse each row' do
    # min,hour,day,mon,week,cmd
    record = CrontabParser::Record.new(<<-CRON)
      * * * * * foo
    CRON
    record.cmd.should == 'foo'
    record.times.should == {
      :month => (1..12).to_a,
      :day => (1..31).to_a,
      :hour => (0..23).to_a,
      :min => (0..59).to_a,
      :week => (0..6).to_a,
    }
    record.should_run?(Time.now).should be_true

    record = CrontabParser::Record.new(<<-CRON)
      1,2,3,5-10,21-27/5 2-5 */3 * * bar
    CRON
    record.cmd.should == 'bar'
    record.times.should == {
      :month => (1..12).to_a,
      :day => [3,6,9,12,15,18,21,24,27,30],
      :hour => [2,3,4,5],
      :min => [5,10,25],
      :week => (0..6).to_a,
    }
    record.should_run?(Time.utc(2010,1,1,0,0,0)).should be_false
    record.should_run?(Time.utc(2010,1,3,2,5,0)).should be_true

    record = CrontabParser::Record.new(<<-CRON)
      @daily baz
    CRON
    record.cmd.should == 'baz'
    record.times.should == {
      :month => (1..12).to_a,
      :day => (1..31).to_a,
      :hour => [0],
      :min => [0],
      :week => (0..6).to_a,
    }
  end

  it 'should parse annotations' do
    c = CrontabParser.new(<<-CRON)
      @yearly 1/1 only
      @annually 1/1 only
      @monthly day 1 only
      @weekly week==0 only
      @daily 00:00 only
      @midnight 00:00 only
      @hourly *:00 only
    CRON
    rows = c.to_a
    rows[0].times.should == {
      :month => [1],
      :day => [1],
      :hour => [0],
      :min => [0],
      :week => (0..6).to_a,
    }
    rows[1].times.should == rows[0].times
    rows[2].times.should == {
      :month => (1..12).to_a,
      :day => [1],
      :hour => [0],
      :min => [0],
      :week => (0..6).to_a,
    }
    rows[3].times.should == {
      :month => (1..12).to_a,
      :day => (1..31).to_a,
      :hour => [0],
      :min => [0],
      :week => [0],
    }
    rows[4].times.should == {
      :month => (1..12).to_a,
      :day => (1..31).to_a,
      :hour => [0],
      :min => [0],
      :week => (0..6).to_a,
    }
    rows[5].times.should == rows[4].times
    rows[6].times.should == {
      :month => (1..12).to_a,
      :day => (1..31).to_a,
      :hour => (0..23).to_a,
      :min => [0],
      :week => (0..6).to_a,
    }
  end

  it 'should parse crontab' do
    c = CrontabParser.new(<<-CRON)
      # should ignore comment only line and blank line

      #m h d m w cmd
       * * * * * foo # always run. this comment was ignored
       3 * * * * bar
       */1 0-22 * * * baz
    CRON
    now = Time.utc(2010,1,1,0,0,0)
    c.find_all{|row|
      row.should_run?(now)
    }.map{|row| row.cmd}.should == ["foo","baz"]

    c = CrontabParser.new(<<-CRON)
    should raise invalid line
    CRON
    lambda {
      c.each{|r| r.cmd}
    }.should raise_error

    c = CrontabParser.new(<<-CRON, :silent => true)
    should raise invalid line
    CRON
    lambda {
      c.each{|r| r.cmd}
    }.should_not raise_error
  end
end
