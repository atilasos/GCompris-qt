# SPDX-License-Identifier: GPL-3.0-or-later
import unittest
from oracle import solve


class CalendarMeaning(unittest.TestCase):
    def test_ordinal_weekday_uses_real_gregorian_calendar(self):
        self.assertEqual(solve('Find the fifth Sunday of April in the year 2018',2018,3),{'dates':[[2018,4,29]]})

    def test_months_are_added_before_days_across_year_end(self):
        self.assertEqual(solve('Find the date 3 months, 2 weeks and 1 day after August 23rd.',2018,8),{'dates':[[2018,12,8]]})

    def test_leap_year_and_weekday(self):
        self.assertEqual(solve('Find the day of the week 2 days after February 28th.',2020,2),{'weekdays':[0]})

    def test_month_question_returns_every_valid_month(self):
        self.assertEqual(solve('Find a month starting a Monday and having 31 days',2024,2),{'months':[1,7]})

    def test_bounded_weekday_is_unique(self):
        self.assertEqual(solve('Select a Saturday between days 13 and 23 of the given month',2018,3),{'dates':[[2018,3,17]]})


if __name__=='__main__':unittest.main()
