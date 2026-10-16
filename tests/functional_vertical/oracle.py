# SPDX-License-Identifier: GPL-3.0-or-later
"""Integer column arithmetic derived only from the displayed operands."""
def columns(operands, operator, method):
    if len(operands)<2 or any(n<0 for n in operands):
        raise ValueError('At least two nonnegative operands are required')
    result=sum(operands) if operator=='+' else operands[0]-sum(operands[1:])
    if operator not in ('+','-') or method not in ('regrouping','compensation') or result<0:
        raise ValueError('Unsupported operation or negative difference')
    width=max(len(str(n)) for n in operands)+1
    adjustments=[]
    debt=0
    for column in range(width):
        digits=[n//10**column%10 for n in operands]
        if operator=='+':
            debt=(sum(digits)+debt)//10
            if debt:adjustments.append([0,column+1,debt])
        else:
            difference=digits[0]-sum(digits[1:])-debt
            debt=max(0,(-difference+9)//10)
            if debt:
                adjustments.append([0,column,10*debt])
                adjustments.append([0 if method=='regrouping' else len(operands)-1,
                                    column+1,-debt if method=='regrouping' else debt])
    return {'result':result,'adjustments':adjustments}
