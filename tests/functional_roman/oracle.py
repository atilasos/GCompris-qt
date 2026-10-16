# SPDX-License-Identifier: GPL-3.0-or-later
"""Canonical Roman notation by greedy denomination, independent of the UI."""
TOKENS=((1000,'M'),(900,'CM'),(500,'D'),(400,'CD'),(100,'C'),(90,'XC'),(50,'L'),(40,'XL'),(10,'X'),(9,'IX'),(5,'V'),(4,'IV'),(1,'I'))


def roman(number):
    if not isinstance(number,int) or isinstance(number,bool) or not 1<=number<=3999:raise ValueError('Roman number must be an integer from1 to3999')
    result=[]
    for amount,symbol in TOKENS:
        count,number=divmod(number,amount);result.extend([symbol]*count)
    return ''.join(result)


def arabic(text):
    source=text.upper();position=0;number=0
    for amount,symbol in TOKENS:
        while source.startswith(symbol,position):number+=amount;position+=len(symbol)
    if position!=len(source) or not 1<=number<=3999 or roman(number)!=source:raise ValueError('Noncanonical Roman numeral')
    return number
