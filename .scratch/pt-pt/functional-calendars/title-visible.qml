TestCase {
    name: "CalendarMonthRemainsVisibleWhenNavigationIsLocked"
    when: activity.visible && calendar.width>0
    property var result: ({})
    function test_month_title() {
        wait(1200);
        result={title:dateText.text,titleVisible:dateText.visible,previousVisible:previousMonth.visible,nextVisible:nextMonth.visible};
        grabImage(activity).save("__QA_OUTPUT__/month-title.png");
        verify(dateText.visible,"The current month/year must be visible even when month navigation is locked");
        verify(/março.*2018/i.test(dateText.text),"Portuguese month and year");
        verify(!previousMonth.visible && !nextMonth.visible,"Month navigation remains locked");
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,title:result}));}
}
