import sxtwl
import argparse
import collections

TianGan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
DiZhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

# 使用 argparse 库，获取用户生日信息。
description = ''' 
-------------------------------
八字排盘：排出天干地支。
调用的例子： 

> 使用公历计算
  python ganzhi.py 年 月 日 时 -g
  python ganzhi.py 1949 10 1 21 -g

> 使用农历计算
  python ganzhi.py 年 月 日 时
-------------------------------

'''

parser = argparse.ArgumentParser(description=description,
                                 formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('year', action="store", help=u'year（年）', type=int)
parser.add_argument('month', action="store", help=u'month（月）', type=int)
parser.add_argument('day', action="store", help=u'day（日）', type=int)
parser.add_argument('time', action="store", help=u'time（时）', type=float)
parser.add_argument('-g', action="store_true", default=False, help=u'是否采用公历')
parser.add_argument('-r', action="store_true", default=False, help=u'是否为闰月，仅仅使用于农历')
parser.add_argument('--version', action='version',
                    version='查八字 - 第一版(修改于2021年3月)')

options = parser.parse_args()

# 获得输入的用户生日，转换为天干地支。
# 判断是否带参数"-g"，带参数用阳历计算；不带参数，用阴历计算。
lunar = sxtwl.Lunar()
if options.g:
    day = lunar.getDayBySolar(options.year, options.month, options.day)
else:
    day = lunar.getDayByLunar(options.year, options.month, options.day, options.r)

gz = lunar.getShiGz(day.Lday2.tg, int(options.time))

# 　计算天干与地支
Gans = collections.namedtuple("Gans", "year month day time")
TianGans = Gans(year=TianGan[day.Lyear2.tg],
                month=TianGan[day.Lmonth2.tg],
                day=TianGan[day.Lday2.tg],
                time=TianGan[gz.tg])
Zhis = collections.namedtuple("Zhis", "year month day time")
DiZhis = Zhis(year=DiZhi[day.Lyear2.dz],
              month=DiZhi[day.Lmonth2.dz],
              day=DiZhi[day.Lday2.dz],
              time=DiZhi[gz.dz])

'''
上面的DiZhis和TianGans是类，用后面带点的方法调用。
print(DiZhis.year)
'''
# 打印天干地支
# TianGans.year 为年的天干，DiZhis.year 为年的地支，TianGans.month 为月的天干，DiZhis.month 为月的地支 ··· ···
print("\t您输入的日期是： {} 年 {} 月 {} 日 \n".format(day.y, day.m, day.d))
print("天干（年月日时）： " + TianGans.year, TianGans.month, TianGans.day, TianGans.time)
print("地支（年月日时）： " + DiZhis.year, DiZhis.month, DiZhis.day, DiZhis.time)
