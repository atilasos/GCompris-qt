# SPDX-License-Identifier: GPL-3.0-or-later
"""Interpret authored question wording using Python's Gregorian calendar.

This module never receives or reads an activity answer. Runtime tests match
visible translated wording to these independently computed expectations.
"""
import calendar
import datetime as dt
import re

MONTHS=list(calendar.month_name)[1:]
WEEKDAYS=list(calendar.day_name)
ORDINALS={'first':1,'second':2,'third':3,'fourth':4,'fifth':5,'last':-1}
NUMBERS={'one':1,'two':2,'three':3,'four':4,'five':5}


def number(text): return NUMBERS[text] if text in NUMBERS else int(text)

def result(date,weekday=False):
    return {'weekdays':[(date.weekday()+1)%7]} if weekday else {'dates':[[date.year,date.month,date.day]]}


def nth_weekday(year,month,name,ordinal):
    dates=[dt.date(year,month,n) for n in range(1,calendar.monthrange(year,month)[1]+1)
           if dt.date(year,month,n).weekday()==WEEKDAYS.index(name)]
    return dates[-1] if ordinal==-1 else dates[ordinal-1]


def shift(base,months,days):
    index=base.year*12+base.month-1+months
    year,zero_month=divmod(index,12)
    month=zero_month+1
    # Questions use valid same-day month offsets; reject ambiguous clipping.
    return dt.date(year,month,base.day)+dt.timedelta(days=days)


def solve(question,year,month):
    match=re.fullmatch(r'Find the (\w+) (\w+) of (\w+) in the year (\d+)',question)
    if match:
        ordinal,day,mon,yr=match.groups()
        return result(nth_weekday(int(yr),MONTHS.index(mon)+1,day,ORDINALS[ordinal]))
    match=re.fullmatch(r'Find the (date|day of the week) (.+) (after|before) (\w+) (\d+)(?:st|nd|rd|th)\.',question)
    if match:
        kind,offset,direction,mon,day=match.groups()
        values={'month':0,'week':0,'day':0}
        terms=re.findall(r'(\d+|one|two|three|four|five) (month|week|day)s?',offset)
        if not terms:raise ValueError(question)
        for count,unit in terms:values[unit]+=number(count)
        sign=1 if direction=='after' else -1
        base=dt.date(year,MONTHS.index(mon)+1,int(day))
        return result(shift(base,sign*values['month'],sign*(values['week']*7+values['day'])),kind=='day of the week')
    match=re.fullmatch(r'Select the (\d+)(?:st|nd|rd|th)',question)
    if match:return result(dt.date(year,month,int(match[1])))
    match=re.fullmatch(r'Which day of the week is the (\d+)(?:st|nd|rd|th) of the given month\?',question)
    if match:return result(dt.date(year,month,int(match[1])),True)
    match=re.fullmatch(r'Select a (\w+) between days (\d+) and (\d+) of the given month',question)
    if match:
        name,low,high=match.groups()
        dates=[dt.date(year,month,n) for n in range(int(low),int(high)+1) if dt.date(year,month,n).weekday()==WEEKDAYS.index(name)]
        if len(dates)!=1:raise ValueError('Ambiguous question: '+question)
        return result(dates[0])
    match=re.fullmatch(r'Select the (\w+) (\w+) of the given month',question)
    if match:return result(nth_weekday(year,month,match[2],ORDINALS[match[1]]))
    match=re.fullmatch(r'Select the (second|third) day (before|after) (?:the )?(\d+)(?:st|nd|rd|th) of the given month',question)
    if match:return result(dt.date(year,month,int(match[3]))+dt.timedelta(days=ORDINALS[match[1]]*(1 if match[2]=='after' else -1)))
    match=re.fullmatch(r'Select the day one week after (\d+)(?:st|nd|rd|th) of the given month',question)
    if match:return result(dt.date(year,month,int(match[1]))+dt.timedelta(days=7))
    match=re.fullmatch(r'Find (?:a|the) month starting a (\w+)(?: and having (\d+) days)?',question)
    if match:
        weekday=WEEKDAYS.index(match[1]);length=int(match[2]) if match[2] else None
        return {'months':[m for m in range(1,13) if dt.date(year,m,1).weekday()==weekday and (length is None or calendar.monthrange(year,m)[1]==length)]}
    match=re.fullmatch(r'Find a month having (\d+) days',question)
    if match:return {'months':[m for m in range(1,13) if calendar.monthrange(year,m)[1]==int(match[1])]}
    match=re.fullmatch(r'Find the month between (\w+) and (\w+)',question)
    if match:
        first,last=MONTHS.index(match[1])+1,MONTHS.index(match[2])+1
        if last-first!=2:raise ValueError('Ambiguous middle month')
        return {'months':[first+1]}
    match=re.search(r'is celebrated (\w+) days? (after|before) (\w+) (\d+)',question)
    if match:
        count,direction,mon,day=match.groups()
        target_year=re.search(r'in (\d{4})',question)
        if not target_year:raise ValueError(question)
        return result(dt.date(int(target_year[1]),MONTHS.index(mon)+1,int(day))+dt.timedelta(days=number(count)*(1 if direction=='after' else -1)))
    match=re.search(r"birthday is on (\w+) (\d+)\. In (\d{4}) his party was exactly (\w+) weeks later",question)
    if match:
        mon,day,yr,weeks=match.groups()
        return result(dt.date(int(yr),MONTHS.index(mon)+1,int(day))+dt.timedelta(weeks=number(weeks)))
    match=re.search(r'held on last (\w+) of (\w+) (\d{4})',question)
    if match:return result(nth_weekday(int(match[3]),MONTHS.index(match[2])+1,match[1],-1))
    raise ValueError('Unsupported question: '+question)
