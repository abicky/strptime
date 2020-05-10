require 'spec_helper'

describe Strptime do
  it 'has a version number' do
    expect(Strptime::VERSION).not_to be nil
  end

  describe '#new' do
    it 'raises ArgumentError without arguments' do
      expect{Strptime.new}.to raise_error(ArgumentError)
    end

    it 'returns a Strptime object' do
      pr = Strptime.new("%Y")
      expect(pr.class).to eq(Strptime)
    end
  end

  it 'parses %Y' do
    pr = Strptime.new("%Y")
    expect(pr.exec("2015").year).to eq(2015)
    expect(pr.exec("2025").year).to eq(2025)
  end

  it 'parses %y' do
    pr = Strptime.new("%y")
    expect(pr.exec("15").year).to eq(2015)
    expect(pr.exec("25").year).to eq(2025)
    expect(pr.exec("70").year).to eq(1970)
    pending "Windows doen't support negative time_t" if Gem.win_platform?
    pending "Darwin's localtime doen't support year 2038" if /darwin/ =~ RUBY_PLATFORM
    expect(pr.exec("68").year).to eq(2068)
    expect(pr.exec("69").year).to eq(1969)
  end

  it 'parses %m' do
    pr = Strptime.new("%m")
    expect(pr.exec("12").mon).to eq(12)
    expect(pr.exec("3").mon).to eq(3)
  end

  it 'parses %d' do
    expect(Strptime.new("%d").exec("28").mday).to eq(28)
    expect(Strptime.new(" %d").exec(" 28").mday).to eq(28)
  end

  it 'parses %B' do
    pr = Strptime.new("%B")
    h = pr.exec("May")
    expect(h.mon).to eq(5)
    h = pr.exec("January")
    expect(h.mon).to eq(1)
  end

  it 'parses %H' do
    pr = Strptime.new("%H")
    h = pr.exec("01")
    expect(h.hour).to eq(1)
    h = pr.exec("9")
    expect(h.hour).to eq(9)
    h = pr.exec("23")
    expect(h.hour).to eq(23)
    expect{pr.exec("24")}.to raise_error(ArgumentError)
  end

  it 'parses %M' do
    pr = Strptime.new("%M")
    h = pr.exec("00")
    expect(h.min).to eq(0)
    h = pr.exec("59")
    expect(h.min).to eq(59)
    expect{pr.exec("60")}.to raise_error(ArgumentError)
  end

  it 'parses %S' do
    pr = Strptime.new("%S")
    h = pr.exec("31")
    expect(h.sec).to eq(31)
    h = pr.exec("59")
    expect(h.sec).to eq(59)
    h = pr.exec("60")
    expect(h.sec).to eq(0) # verified
    expect{pr.exec("61")}.to raise_error(ArgumentError)
  end

  it 'parses %N' do
    pr = Strptime.new("%N")
    expect(pr.exec("123").nsec).to eq(123000000)
    expect(pr.exec("123456").nsec).to eq(123456000)
    expect(pr.exec("123456").usec).to eq(123456)
    expect(pr.exec("123456789").nsec).to eq(123456789)
    expect{pr.exec("a")}.to raise_error(ArgumentError)
  end

  it 'parses %Y%m%d%H%M%S with gmtoff' do
    pr = Strptime.new("%Y%m%d%H%M%S%z")
    expect(pr.exec("20150610102415+0").to_i).to eq(1433931855)
    expect(pr.exec("20150610102415+9").utc_offset).to eq(9*3600)
    expect(pr.exec("20150610102415+9").to_i).to eq(1433931855-9*3600)
    expect(pr.exec("20150610102415+09").to_i).to eq(1433931855-9*3600)
    expect(pr.exec("20150610102415+09:00").to_i).to eq(1433931855-9*3600)
    expect(pr.exec("20150610102415+09:0").to_i).to eq(1433931855-9*3600)
    expect(pr.exec("20150610102415+0900").to_i).to eq(1433931855-9*3600)
    expect(pr.exec("20150610102415+090").to_i).to eq(1433931855-9*3600)
    expect(pr.exec("20150610102415-0102").to_i).to eq(1433931855+1*3600+2*60)
    expect(pr.exec("20150610102415-1200").to_i).to eq(1433931855+12*3600)
    expect(pr.exec("20150610102415+1400").to_i).to eq(1433931855-14*3600)
    expect(pr.exec("20150610102415-1200").to_i).to eq(1433931855+12*3600)
  end

  it 'parses %Y%m%d%H%M%S' do
    pr = Strptime.new("%Y%m%d%H%M%S")
    expect(pr.exec("20150610102415").utc_offset).to eq(Time.now.utc_offset)
  end

  it 'parses %Y-%m-%d %H:%M:%S' do
    pr = Strptime.new("%Y-%m-%d %H:%M:%S")
    expect(pr.exec("2015-06-11 10:24:15").year).to eq(2015)
    expect(pr.exec("2015-06-11 10:24:15").month).to eq(6)
    expect(pr.exec("2015-06-11 10:24:15").day).to eq(11)
    expect(pr.exec("2015-06-11 10:24:15").hour).to eq(10)
    expect(pr.exec("2015-06-11 10:24:15").min).to eq(24)
    expect(pr.exec("2015-06-11 10:24:15").sec).to eq(15)
    expect(pr.exec("2015-06-11 10:24:15").nsec).to eq(0)
    expect(pr.exec("2015-06-11 10:24:15").utc_offset).to eq(Time.now.utc_offset)
  end

  it 'parses %d' do
    pr = Strptime.new("%d")
    expect(pr.exec("10").year).to eq(Time.now.year)
    expect(pr.exec("10").month).to eq(Time.now.month)
    expect(pr.exec("10").day).to eq(10)
    expect(pr.exec("10").hour).to eq(0)
    expect(pr.exec("10").min).to eq(0)
    expect(pr.exec("10").sec).to eq(0)
    expect(pr.exec("10").nsec).to eq(0)
    expect(pr.exec("10").utc_offset).to eq(Time.now.utc_offset)
  end

  it 'parses %S%z' do
    pr = Strptime.new("%S%z")
    expect(pr.exec("12-03:00").year).to eq(Time.now.localtime("-03:00").year)
    expect(pr.exec("12-03:00").month).to eq(Time.now.localtime("-03:00").month)
    expect(pr.exec("12-03:00").day).to eq(Time.now.localtime("-03:00").day)
    expect(pr.exec("12-03:00").hour).to eq(Time.now.localtime("-03:00").hour)
    expect(pr.exec("12-03:00").min).to eq(Time.now.localtime("-03:00").min)
    expect(pr.exec("12-03:00").sec).to eq(12)
    expect(pr.exec("12-03:00").nsec).to eq(0)
    expect(pr.exec("12-03:00").utc_offset).to eq(-3*3600)

    expect(pr.exec("12+09:00").year).to eq(Time.now.localtime("+09:00").year)
    expect(pr.exec("12+09:00").month).to eq(Time.now.localtime("+09:00").month)
    expect(pr.exec("12+09:00").day).to eq(Time.now.localtime("+09:00").day)
    expect(pr.exec("12+09:00").hour).to eq(Time.now.localtime("+09:00").hour)
    expect(pr.exec("12+09:00").min).to eq(Time.now.localtime("+09:00").min)
    expect(pr.exec("12+09:00").sec).to eq(12)
    expect(pr.exec("12+09:00").nsec).to eq(0)
    expect(pr.exec("12+09:00").utc_offset).to eq(9*3600)

    expect(pr.exec("12+11:00").year).to eq(Time.now.localtime("+11:00").year)
    expect(pr.exec("12+11:00").month).to eq(Time.now.localtime("+11:00").month)
    expect(pr.exec("12+11:00").day).to eq(Time.now.localtime("+11:00").day)
    expect(pr.exec("12+11:00").hour).to eq(Time.now.localtime("+11:00").hour)
    expect(pr.exec("12+11:00").min).to eq(Time.now.localtime("+11:00").min)
    expect(pr.exec("12+11:00").sec).to eq(12)
    expect(pr.exec("12+11:00").nsec).to eq(0)
    expect(pr.exec("12+11:00").utc_offset).to eq(11*3600)
  end

  it 'parses %z' do
    expect(Strptime.new("%z").exec("+09:00").utc_offset).to eq(32400)
    expect(Strptime.new("%z").exec("+09:30").utc_offset).to eq(34200)
    expect(Strptime.new("%z").exec("Z").utc_offset).to eq(0)
  end

  ## from test/test_time.rb
  it 'parses empty format' do
    expect{Strptime.new("%y").exec("")}.to raise_error(ArgumentError)
    expect(Strptime.new("").exec("").to_i).to eq(Time.now.to_i)
  end

  it 'parses %Y%d%m %z' do
    pr = Strptime.new('%Y%m%d %z')
    expect(pr.exec('20010203 -0200').year).to eq(2001)
    expect(pr.exec('20010203 -0200').mon).to eq(2)
    expect(pr.exec('20010203 -0200').day).to eq(3)
    expect(pr.exec('20010203 -0200').hour).to eq(0)
    expect(pr.exec('20010203 -0200').min).to eq(0)
    expect(pr.exec('20010203 -0200').sec).to eq(0)
    expect(pr.exec('20010203 -0200').utc_offset).to eq(-7200)
  end

  it 'raises when taking %A' do
    expect{Strptime.new('%A')}.to raise_error(ArgumentError)
  end

  it 'parses %Y%d%m %z' do
    pr = Strptime.new('%m/%d/%y %H:%M')
    expect(pr.exec('11/4/15 16:21')).to eq(Time.local(2015,11,4,16,21))
  end

  context 'America/Los_Angeles' do
    before do
      @tz = ENV['TZ']
      ENV['TZ'] = 'America/Los_Angeles'
    end
    after do
      ENV['TZ'] = @tz
    end
    it 'parses %Y-%d-%m %H:%M:%S' do
      pr = Strptime.new('%Y-%m-%d %H:%M:%S')
      expect(pr.exec('2016-12-11 00:00:00')).to eq(Time.local(2016,12,11,0,0,0))
    end
  end

  it 'raises with extra characters' do
    expect{Strptime.new('%Y-%m-%d %H:%M:%S').exec('2020-05-11 01:23:45+09:00')}.to raise_error
  end
end
