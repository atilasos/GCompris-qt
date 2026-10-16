// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:"EqualityPortugueseTitle"
 when:activity.visible
 function test_title_describes_equality_not_inequality(){wait(1600);compare(activity.activityInfo.title,"Igualdade do Gnumch");}
 function cleanupTestCase(){console.log("NATIVE_GNUMCH_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,title:activity.activityInfo.title}));}
}
