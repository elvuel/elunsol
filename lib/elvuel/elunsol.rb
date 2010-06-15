module Elvuel
  module Elunsol
    VERSION = "0.1".freeze
    class ElunsolException < Exception;end
    class ElunsolArgumentError < ElunsolException;end
    class ElunsolDateRangeError < ElunsolException;end

    class Solar
      attr_accessor :_date
      attr_reader :solar_date
      
      # 日期数据定义  摘自网上
      # 前12个字节代表1-12月为大月或是小月，1为大月30天，0为小月29天； 
      # 第13位为闰月的情况，1为大月30天，0为小月29天； 
      # 第14位为闰月的月份，如果不是闰月为0，否则给出月份，10、11、12分别用A、B、C来表示，即使用16进制； 
      # 最后4位为当年家农历新年-即农历1月1日所在公历的日期，如0131代表1月31日。
      @@lunar_month_ftv_hash = { 1900 => '010010111101180131', 1901 => '010010101110000219', 1902 => '101001010111000208', 1903 => '010101001101050129', 1904 => '110100100110000216', 1905 => '110110010101000204', 1906 => '011001010101040125', 1907 => '010101101010000213', 1908 => '100110101101000202', 1909 => '010101011101120122', 1910 => '010010101110000210', 1911 => '101001011011160130', 1912 => '101001001101000218', 1913 => '110100100101000206', 1914 => '110100100101050126', 1915 => '101101010100000214', 1916 => '110101101010000203', 1917 => '101011011010020123', 1918 => '100101011011000211', 1919 => '010010010111070201', 1920 => '010010010111000220', 1921 => '101001001011000208', 1922 => '101101001011050128', 1923 => '011010100101000216', 1924 => '011011010100000205', 1925 => '101010110101040124', 1926 => '001010110110000213', 1927 => '100101010111000202', 1928 => '010100101111120123', 1929 => '010010010111000210', 1930 => '011001010110160130', 1931 => '110101001010000217', 1932 => '111010100101000206', 1933 => '011011101001150126', 1934 => '010110101101000214', 1935 => '001010110110000204', 1936 => '100001101110030124', 1937 => '100100101110000211', 1938 => '110010001101070131', 1939 => '110010010101000219', 1940 => '110101001010000208', 1941 => '110110001010060127', 1942 => '101101010101000215', 1943 => '010101101010000205', 1944 => '101001011011040125', 1945 => '001001011101000213', 1946 => '100100101101000202', 1947 => '110100101011120122', 1948 => '101010010101000210', 1949 => '101101010101070129', 1950 => '011011001010000217', 1951 => '101101010101000206', 1952 => '010100110101050127', 1953 => '010011011010000214', 1954 => '101001011011000203', 1955 => '010001010111030124', 1956 => '010100101011000212', 1957 => '101010011010180131', 1958 => '111010010101000218', 1959 => '011010101010000208', 1960 => '101011101010160128', 1961 => '101010110101000215', 1962 => '010010110110000205', 1963 => '101010101110040125', 1964 => '101001010111000213', 1965 => '010100100110000202', 1966 => '111100100110130121', 1967 => '110110010101000209', 1968 => '010110110101170130', 1969 => '010101101010000217', 1970 => '100101101101000206', 1971 => '010011011101150127', 1972 => '010010101101000215', 1973 => '101001001101000203', 1974 => '110101001101140123', 1975 => '110100100101000211', 1976 => '110101010101180131', 1977 => '101101010100000218', 1978 => '101101101010000207', 1979 => '100101011010160128', 1980 => '100101011011000216', 1981 => '010010011011000205', 1982 => '101010010111040125', 1983 => '101001001011000213', 1984 => '1011001001111a0202', 1985 => '011010100101000220', 1986 => '011011010100000209', 1987 => '101011110100160129', 1988 => '101010110110000217', 1989 => '100101010111000206', 1990 => '010010101111150127', 1991 => '010010010111000215', 1992 => '011001001011000204', 1993 => '011101001010130123', 1994 => '111010100101000210', 1995 => '011010110101180131', 1996 => '010101011100000219', 1997 => '101010110110000207', 1998 => '100101101101050128', 1999 => '100100101110000216', 2000 => '110010010110000205', 2001 => '110110010101140124', 2002 => '110101001010000212', 2003 => '110110100101000201', 2004 => '011101010101120122', 2005 => '010101101010000209', 2006 => '101010111011170129', 2007 => '001001011101000218', 2008 => '100100101101000207', 2009 => '110010101011150126', 2010 => '101010010101000214', 2011 => '101101001010000203', 2012 => '101110101010140123', 2013 => '101011010101000210', 2014 => '010101011101190131', 2015 => '010010111010000219', 2016 => '101001011011000208', 2017 => '010100010111060128', 2018 => '010100101011000216', 2019 => '101010010011000205', 2020 => '011110010101140125', 2021 => '011010101010000212', 2022 => '101011010101000201', 2023 => '010110110101120122', 2024 => '010010110110000210', 2025 => '101001101110160129', 2026 => '101001001110000217', 2027 => '110100100110000206', 2028 => '111010100110150126', 2029 => '110101010011000213', 2030 => '010110101010000203', 2031 => '011101101010130123', 2032 => '100101101101000211', 2033 => '010010111101170131', 2034 => '010010101101000219', 2035 => '101001001101000208', 2036 => '110100001011060128', 2037 => '110100100101000215', 2038 => '110101010010000204', 2039 => '110111010100150124', 2040 => '101101011010000212', 2041 => '010101101101000201', 2042 => '010101011011120122', 2043 => '010010011011000210', 2044 => '101001010111070130', 2045 => '101001001011000217', 2046 => '101010100101000206', 2047 => '101100100101050126', 2048 => '011011010010000214', 2049 => '101011011010000202' }

      def initialize(date)
        date_valid_for_ruby date
        solar
      end

      # 阴历转阳历
      def solar(date=@_date)
        date_valid_for_ruby date
        solar_dates = []
        year = date.year
        month = date.month
        day = date.day
        spring_festival_month = @@lunar_month_ftv_hash[year][14..15].to_i
        spring_festival_day = @@lunar_month_ftv_hash[year][16..17].to_i

        leapmonth_days = (@@lunar_month_ftv_hash[year][12].chr == "0") ? 29 : 30
        leap_month = @@lunar_month_ftv_hash[year][13].chr
        case leap_month
        when "a"
          leap_month = 10
        when "b"
          leap_month = 11
        when "c"
          leap_month = 12
        else
          leap_month = leap_month.to_i
        end
        
        # 起始年份 1902的春节
        ftv_date = Time.mktime(year, spring_festival_month, spring_festival_day)
        
        (1..(month - 1)).to_a.each do |d|
          day = day + 29 + @@lunar_month_ftv_hash[year][d-1].chr.to_i
        end

        if leap_month != 0
          if month > leap_month
            # 双闰 +
            solar_date = ftv_date + (day + leapmonth_days - 2) * 24 * 3600
            solar_dates << solar_date
          elsif month == leap_month
            # 如 2001年2个闰4月 2004年2个闰2月 等
            solar_date = ftv_date + (day - 1) * 24 * 3600
            solar_dates << solar_date
            solar_dates << (ftv_date + (day + leapmonth_days - 1) * 24 * 3600)
          else
            solar_date = ftv_date + (day - 1) * 24 * 3600  
            solar_dates << solar_date
          end
        else
          solar_date = ftv_date + (day - 1) * 24 * 3600
          solar_dates << solar_date
        end
        @solar_date = solar_dates
      end
      
      private
      def date_valid_for_ruby(date)
        raise ElunsolArgumentError, "Argument #{date} is not Time" unless date.is_a? Time
        raise ElunsolDateRangeError, "Argument 'date' out off range." if date < Time.mktime(1902, 1 ,1) or date > Time.mktime(2037, 12, 15)
        raise ElunsolDateRangeError, "Argument 'date' out off range, lunar date no 31!" if date.day == 31
        @_date = date
      end
      
    end
    
    class Lunar
      attr_accessor :_date
      @@lunar_data = [0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
      0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
      0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
      0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
      0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
      0x06ca0,0x0b550,0x15355,0x04da0,0x0a5b0,0x14573,0x052b0,0x0a9a8,0x0e950,0x06aa0,
      0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
      0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b6a0,0x195a6,
      0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
      0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
      0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
      0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
      0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
      0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
      0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0,
      0x14b63]

      @@solar_month_days = [31,28,31,30,31,30,31,31,30,31,30,31]

      # 生肖属相
      @@animals_sign_hash = {'鼠' => 'Rat', '牛' => 'Ox', '虎' => 'Tiger', '兔' => 'Hare', '龙' => 'Dragon', '蛇' => 'Snake', '马' => 'Horse', '羊' => 'Sheep', '猴' => 'Monkey', '鸡' => 'Cock', '狗' => 'Dog', '猪' => 'Boar'}
      @@animals_sign = ["鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"]

      # 天干
      @@heavenly_stems = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
      # 地支
      @@earthly_branches = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]

      # 24节气
      @@solar_terms_hash = {'立春' => 'Spring begins', '雨水' => 'The rains', '惊蛰' => 'Insects awaken', '春分' => 'Vernal Equinox ', '清明' => 'Clear and bright', '谷雨' => 'Grain rain', '立夏' => 'Summer begins', '小满' => 'Grain buds', '芒种' => 'Grain in ear', '夏至' => 'Summer solstice', '小暑' => 'Slight heat', '大暑' => 'Great heat', '立秋' => 'Autumn begins', '处暑' => 'Stopping the heat', '白露' => 'White dews', '秋分' => 'Autumn Equinox', '寒露' => 'Cold dews', '霜降' => 'Hoar-frost falls', '立冬' => 'Winter begins', '小雪' => 'Light snow', '大雪' => 'Heavy snow', '冬至' => 'Winter Solstice', '小寒' => 'Slight cold', '大寒' => 'Great cold'}
      @@solar_terms = ["小寒","大寒","立春","雨水","惊蛰","春分","清明","谷雨","立夏","小满","芒种","夏至","小暑","大暑","立秋","处暑","白露","秋分","寒露","霜降","立冬","小雪","大雪","冬至"]
      
      # 中文数值
      @@num_chinese_hash = { '0' => '零', '1' => '一', '2' => '二', '3' => '三', '4' => '四', '5' => '五', '6' => '六', '7' => '七', '8' => '八', '9' => '九'
      }
      # 中文数值
      @@num_chinese = ['*','一','二','三','四','五','六','七','八','九','十']
      @@day_chinese_prefix = ['初','十','廿','卅','　']
      @@month_chinese = ['*','一','二','三','四','五','六','七','八','九','十','十一','腊']
      

      # 24节气信息
      @@solar_terms_info = [0,21208,42467,63836,85337,107014,128867,150921,173149,195551,218072,240693,263343,285989,308563,331033,353350,375494,397447,419210,440795,462224,483532,504758]

      def initialize(date = Time.now)
        date_valid_for_ruby date
        lunar
      end
      
      def _date=(date)
        date_valid_for_ruby date
      end
      
      # 阳历转阴历
      def lunar(date=@_date)
        date_valid_for_ruby date
        i, leap, temp = 1900, 0, 0
        # offset days 距离 1900-1-31 有多少天
        offset = ((Time.utc(date.strftime("%Y"), date.strftime("%b"), date.strftime("%d")).to_i * 1000) + 2206396800000) / 86400000

        @cyclical_day = offset + 40
        @cyclical_month = 14

        while (i < 2050 and offset > 0)
          temp = lunar_year_days(i)
          offset -= temp
          @cyclical_month += 12
          i += 1
        end

        if offset < 0
          offset += temp
          i -= 1
          @cyclical_month -= 12
        end

        @year = i
        @is_lunar_leap_year = leap_year?(@year)
        @cyclical_year = i-1864 #(- 1900 + 36) 1900年立春后为庚子年(60进制36) 1864年1月0日是农历癸亥年

        leap = leap_month(i) # 闰哪个月
        @is_lunar_leap_month = false # 当月是否闰月
        i = 1
        while (i < 13 and offset > 0)
          if (leap > 0 and (i == (leap + 1))) and !@is_lunar_leap_month
            i -= 1
            @is_lunar_leap_month = true
            temp = leap_month_days(@year)
          else
            temp = lunar_month_days(@year, i)
          end
          # 解除 闰月
          @is_lunar_leap_month = false if @is_lunar_leap_month and (i == (leap + 1))
          offset -= temp
          @cyclical_month += 1 if !@is_lunar_leap_month
          i += 1
        end

        if (offset == 0) and (leap > 0) and (i == (leap + 1))
          if @is_lunar_leap_month
            @is_lunar_leap_month = false
          else
            @is_lunar_leap_month = true
            i -= 1
            @cyclical_month -= 1
          end
        end

        if offset < 0
          offset += temp;
          i -= 1
          @cyclical_month -= 1
        end

        @month = i
        @day = offset + 1
      end
      
      #返回当前查询日期农历 年
      def lunar_year
        @year
      end

      #返回当前查询日期农历 月
      def lunar_month
        @month
      end

      #返回当前查询日期农历 日
      def lunar_day
        @day
      end

      #返回当前查询日期农历 y年m月是否为闰月
      def lunar_leap_month?
        @is_lunar_leap_month
      end

      #返回农历 y年是否闰年
      def lunar_leap_year?
        @is_lunar_leap_year
      end

      #农历年份 干支
      def cyclical_year
        cyclical(@cyclical_year)
      end

      #农历月份 干支
      def cyclical_month
        cyclical(@cyclical_month)
      end

      #农历日 干支
      def cyclical_day
        cyclical(@cyclical_day)
      end

      #返回农历 y年生肖属相
      def animal_sign(y=@year)
        @@animals_sign[(y - 4) % 12]
      end

      #返回农历 y年是否闰年
      def leap_year?(y)
        ((y % 4 == 0) && (y % 100 != 0) || (y % 400 == 0)) ? true : false
      end

      #返回农历 y年的总天数
      def lunar_year_days(y)
        sum = 348
        i = 0x8000 
        while i > 0x8
          sum += ((@@lunar_data[y - 1900] & i) > 0) ? 1 : 0
          i >>= 1
        end
        return (sum + leap_month_days(y))
      end

      #返回农历 y年闰月的天数
      def leap_month_days(y)
        unless leap_month(y) == 0
          ((@@lunar_data[y - 1900] & 0x10000) > 0) ? 30 : 29
        else
          0
        end
      end

      #返回农历 y年m月的总天数 m (1..12)
      def lunar_month_days(y, m)
        ((@@lunar_data[y - 1900] & (0x10000 >> m)) > 0) ? 30 : 29
      end

      #返回农历 y年闰哪个月 1-12 , 没闰返回 0
      def leap_month(y)
        @@lunar_data[y - 1900] & 0xf
      end

      #传入 offset 返回干支, 0=甲子
      def cyclical(num)
        @@heavenly_stems[num % 10] + @@earthly_branches[num % 12]
      end

      # 某年的第n个节气为几日(从0小寒起算) 公历几号
      def solar_term(y, n, d=true)
        @@solar_terms_info[n] = 43467 if (y == 2009 && n == 2)
        seconds = (31556925974.7*(y-1900) + @@solar_terms_info[n]*60000 - 2208549300000).to_f / 1000.0
        offdate = Time.at(seconds)
        if d
          offdate.utc.strftime("%d").to_i
        else
          offdate.utc
        end
      end

      #返回阳历 某月的天数 月 份 1。。12(JS 版本 m 0..11)
      def solar_days(y, m)
        if (m == 2)
          ((y % 4 == 0) && (y % 100 != 0) || (y % 400 == 0)) ? 29: 28
        else
          @@solar_month_days[m - 1]
        end
      end
      
      # 中文农历日期
      def chinese_lunar_day(d=@day)
        str = ""
        case d
        when 10
          str = '初十'
        when 20
          str = "二十"
        when 30
          str = "三十"
        else
          str = @@day_chinese_prefix[(d / 10).to_i]
          str += @@num_chinese[d % 10]
        end
        str
      end
      
      # 中文农历年份
      def chinese_lunar_year(y=@year)
        s = y.to_s.gsub(/#{@@num_chinese_hash.keys.join("|")}/) { |n| @@num_chinese_hash[n] }
        "农历 #{s}年"
      end
      
      # 中文农历月份
      def chinese_lunar_month(m=@month)
        "#{@@month_chinese[m]}月"
      end

      def to_s(option = :all, delimiter = "\n")
        case option
        when :short
          "#{lunar_year}年#{lunar_month}月#{lunar_day}号"
        when :chin
          "#{chinese_lunar_year}#{chinese_lunar_month}#{chinese_lunar_day}"
        when :cyclical
          "#{cyclical_year}年#{cyclical_month}月#{cyclical_day}日"
        when :ani
          cyclical_year + animal_sign + "年"
        when :all
          "#{lunar_year}年#{lunar_month}月#{lunar_day}号#{delimiter}#{cyclical_year}[#{animal_sign}]年#{cyclical_month}月#{cyclical_day}日#{delimiter}#{chinese_lunar_year}#{chinese_lunar_month}#{chinese_lunar_day}"
        end
      end
      
      private
      def date_valid_for_ruby(date)
        raise ElunsolArgumentError, "Argument #{date} is not Time" unless date.is_a? Time
        if RUBY_VERSION =~ /1.8/
          raise ElunsolDateRangeError, "Argument 'date' out off range." if date < Time.mktime(1901, 12 ,15) or date > Time.mktime(2038, 1, 19)
        elsif RUBY_VERSION =~ /1.9/
          raise ElunsolDateRangeError, "Argument 'date' out off range." if date < Time.mktime(1901, 12 ,14) or date > Time.mktime(2038, 1, 19)
        end
        @_date = date
      end
      
    end
    
    class << self
      def solar_to_lunar(date, option = :all, delimiter="\n")
        l = Lunar.new(date)
        l.to_s(option, delimiter)
      end
      
      def lunar_to_solar(date)
        s = Solar.new(date)
        s.solar_date
      end  
      
      def version;VERSION;end
    end
    
  end
end