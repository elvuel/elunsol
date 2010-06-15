require File.join(File.dirname(__FILE__), '..', 'lib/elvuel/elunsol')

include Elvuel
describe "Lunar Solar conversion." do
  
  it "Exception => ElunsolArgumentError." do
    lambda { Elunsol.lunar_to_solar("fdsa") }.should raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol::Lunar.new("fdsa") }.should raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol::Lunar.new(nil) }.should raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol::Lunar.new(Time.mktime(1980, 2, 15)) }.should_not raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol.solar_to_lunar("fdsa") }.should raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol::Solar.new(nil) }.should raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol::Solar.new(2010) }.should raise_exception(Elunsol::ElunsolArgumentError)
    lambda { Elunsol::Solar.new(Time.mktime(2012, 4, 15)) }.should_not raise_exception(Elunsol::ElunsolArgumentError)

  end
  
  it "Exception => Lunar to solar raise ElunsolDateRangeError." do
    lambda {Elunsol::Solar.new(Time.mktime(1901, 12, 25))}.should raise_exception(Elunsol::ElunsolDateRangeError)
    lambda {Elunsol::Solar.new(Time.mktime(1902, 1, 1))}.should_not raise_exception(Elunsol::ElunsolDateRangeError)
    lambda {Elunsol::Solar.new(Time.mktime(2037, 12, 16))}.should raise_exception(Elunsol::ElunsolDateRangeError)
    lambda {Elunsol::Solar.new(Time.mktime(2037, 12, 15))}.should_not raise_exception(Elunsol::ElunsolDateRangeError)
    lambda {Elunsol::Solar.new(Time.mktime(2010, 3, 31))}.should raise_exception(Elunsol::ElunsolDateRangeError)
  end
  
  it "Solar to lunar." do
    # 普通转换
    Elunsol.solar_to_lunar(Time.mktime(1980, 6, 20), :short).should == "1980年5月8号"
    Elunsol.solar_to_lunar(Time.mktime(1980, 6, 20), :chin).should == "农历 一九八零年五月初八"
    Elunsol.solar_to_lunar(Time.mktime(2027, 5, 16), :short).should == "2027年4月11号"
    Elunsol.solar_to_lunar(Time.mktime(2027, 5, 16), :chin).should == "农历 二零二七年四月十一"
    
    # 测试闰某月双
    Elunsol.solar_to_lunar(Time.mktime(2001, 5, 16), :short).should == "2001年4月24号"
    Elunsol.solar_to_lunar(Time.mktime(2001, 6, 15), :short).should == "2001年4月24号"# => 闰4
    
    Elunsol.solar_to_lunar(Time.mktime(2004, 2, 21), :short).should == "2004年2月2号"
    Elunsol.solar_to_lunar(Time.mktime(2004, 3, 22), :short).should == "2004年2月2号"# => 闰2  
  end
  
  it "Chinese year animal sign." do
    @year_cyc_hash = {1970 => '庚戌狗年',  1971 => '辛亥猪年',  1972 => '壬子鼠年',  1973 => '癸丑牛年',  1974 => '甲寅虎年',  1975 => '乙卯兔年',  1976 => '丙辰龙年',  1977 => '丁巳蛇年',  1978 => '戊午马年',  1979 => '己未羊年',  1980 => '庚申猴年',  1981 => '辛酉鸡年',  1982 => '壬戌狗年',  1983 => '癸亥猪年',  1984 => '甲子鼠年',  1985 => '乙丑牛年',  1986 => '丙寅虎年',  1987 => '丁卯兔年',  1988 => '戊辰龙年',  1989 => '己巳蛇年',  1990 => '庚午马年',  1991 => '辛未羊年',  1992 => '壬申猴年',  1993 => '癸酉鸡年',  1994 => '甲戌狗年',  1995 => '乙亥猪年',  1996 => '丙子鼠年',  1997 => '丁丑牛年',  1998 => '戊寅虎年',  1999 => '己卯兔年',  2000 => '庚辰龙年',  2001 => '辛巳蛇年',  2002 => '壬午马年',  2003 => '癸未羊年',  2004 => '甲申猴年',  2005 => '乙酉鸡年',  2006 => '丙戌狗年',  2007 => '丁亥猪年',  2008 => '戊子鼠年',  2009 => '己丑牛年',  2010 => '庚寅虎年',  2011 => '辛卯兔年',  2012 => '壬辰龙年',  2013 => '癸巳蛇年',  2014 => '甲午马年',  2015 => '乙未羊年',  2016 => '丙申猴年',  2017 => '丁酉鸡年',  2018 => '戊戌狗年',  2019 => '己亥猪年',  2020 => '庚子鼠年',  2021 => '辛丑牛年',  2022 => '壬寅虎年',  2023 => '癸卯兔年',  2024 => '甲辰龙年',  2025 => '乙巳蛇年',  2026 => '丙午马年',  2027 => '丁未羊年',  2028 => '戊申猴年'}
    (1970..2028).to_a.collect do |year|
      Elunsol.solar_to_lunar(Time.mktime(year, 3, 1), :ani).should == @year_cyc_hash[year]
    end
  end

  it "Lunar to solar." do
    Elunsol.lunar_to_solar(Time.mktime(2001, 4, 24)).is_a?(Array).should == true
    Elunsol.lunar_to_solar(Time.mktime(2001, 4, 24)).kind_of?(Array).should == true
    Elunsol.lunar_to_solar(Time.mktime(2027, 4, 11)).kind_of?(Array).should_not == false
    Elunsol.lunar_to_solar(Time.mktime(2001, 4, 24)).collect{ |time| time.strftime("%Y-%m-%d") }.should == ["2001-05-16", "2001-06-15"]
    Elunsol.lunar_to_solar(Time.mktime(2004, 2, 2)).collect{ |time| time.strftime("%Y-%m-%d") }.should == ["2004-02-21", "2004-03-22"]
    
    Elunsol.lunar_to_solar(Time.mktime(1980, 5, 8)).collect{ |time| time.strftime("%Y-%m-%d") }.should == ["1980-06-20"]
    Elunsol.lunar_to_solar(Time.mktime(2027, 4, 11)).collect{ |time| time.strftime("%Y-%m-%d") }.should == ["2027-05-16"]
  end
  
end