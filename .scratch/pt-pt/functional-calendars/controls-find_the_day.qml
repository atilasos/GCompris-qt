TestCase {
    name: "CalendarFromVisibleQuestionAndDate"
    when: activity.visible && grid.width>0
    property var fixture: [{"level": 1, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the date 13 days after May 3rd.", "portuguese": "Descobrir a data de 13 dias a seguir ao 3 de maio.", "expected": {"dates": [[2018, 5, 16]]}}, {"question": "Find the date 7 days after October 1st.", "portuguese": "Descobrir a data de 7 dias a seguir ao 1 de outubro.", "expected": {"dates": [[2018, 10, 8]]}}, {"question": "Find the date 31 days after July 12th.", "portuguese": "Descobrir a data de 31 dias a seguir ao 12 de julho.", "expected": {"dates": [[2018, 8, 12]]}}, {"question": "Find the date two weeks after November 27th.", "portuguese": "Descobrir a data duas semanas depois do 27 de novembro.", "expected": {"dates": [[2018, 12, 11]]}}, {"question": "Find the date 19 days before September 1st.", "portuguese": "Descobrir a data de 19 dias antes do 1 de setembro.", "expected": {"dates": [[2018, 8, 13]]}}, {"question": "Find the date 5 days before December 8th.", "portuguese": "Descobrir a data de 5 dias antes do 8 de dezembro.", "expected": {"dates": [[2018, 12, 3]]}}]}, {"level": 2, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findDayOfWeek"}, "questions": [{"question": "Find the day of the week 3 days after December 5th.", "portuguese": "Descobrir o dia da semana de 3 dias depois do 5 de dezembro.", "expected": {"weekdays": [6]}}, {"question": "Find the day of the week 12 days before November 12th.", "portuguese": "Descobrir o dia da semana de 12 dias antes do 12 de novembro.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 32 days after January 5th.", "portuguese": "Descobrir o dia da semana de 32 dias depois do 5 de janeiro.", "expected": {"weekdays": [2]}}, {"question": "Find the day of the week 5 days after February 23rd.", "portuguese": "Descobrir o dia da semana de 5 dias depois do 23 de fevereiro.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 17 days before August 16th.", "portuguese": "Descobre o dia da semana 17 dias antes de 16 de agosto.", "expected": {"weekdays": [1]}}]}, {"level": 3, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the date 2 weeks and 3 days after January 12th.", "portuguese": "Descobrir a data de 2 semanas e 3 dias depois do 12 de janeiro.", "expected": {"dates": [[2018, 1, 29]]}}, {"question": "Find the date 3 weeks and 2 days after March 22nd.", "portuguese": "Descobrir a data de 3 semanas e 2 dias depois do 22 de março.", "expected": {"dates": [[2018, 4, 14]]}}, {"question": "Find the date 5 weeks and 6 days after October 5th.", "portuguese": "Descobrir a data de 5 semanas e 6 dias depois do 5 de outubro.", "expected": {"dates": [[2018, 11, 15]]}}, {"question": "Find the date 1 week and 1 day before August 8th.", "portuguese": "Descobrir a data de 1 semana e 1 dia antes do 8 de agosto.", "expected": {"dates": [[2018, 7, 31]]}}, {"question": "Find the date 2 weeks and 5 days before July 2nd.", "portuguese": "Descobrir a data de 2 semanas e 5 dias antes do 2 de julho.", "expected": {"dates": [[2018, 6, 13]]}}]}, {"level": 4, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findDayOfWeek"}, "questions": [{"question": "Find the day of the week 5 months and 2 days after July 3rd.", "portuguese": "Descobre o dia da semana 5 meses e 2 dias depois de 3 de julho.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 2 months and 4 days after October 8th.", "portuguese": "Descobrir o dia da semana de 2 meses e 4 dias depois do 8 de outubro.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 1 month and 3 days before December 28th.", "portuguese": "Descobre o dia da semana 1 mês e 3 dias antes de 28 de dezembro.", "expected": {"weekdays": [0]}}, {"question": "Find the day of the week 8 months and 7 days after February 28th.", "portuguese": "Descobrir o dia da semana de 8 meses e 7 dias depois do 28 de fevereiro.", "expected": {"weekdays": [0]}}, {"question": "Find the day of the week 3 months and 3 days before September 15th.", "portuguese": "Descobrir o dia da semana de 3 meses e 3 dias antes do 15 de setembro.", "expected": {"weekdays": [2]}}]}, {"level": 5, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the date 2 months, 1 week and 5 days after January 12th.", "portuguese": "Descobre a data 2 meses, 1 semana e 5 dias depois de 12 de janeiro.", "expected": {"dates": [[2018, 3, 24]]}}, {"question": "Find the date 3 months, 2 weeks and 1 day after August 23rd.", "portuguese": "Descobrir a data de 3 meses, 2 semanas e 1 dia a seguir ao 23 de agosto.", "expected": {"dates": [[2018, 12, 8]]}}, {"question": "Find the date 5 months, 3 weeks and 2 days after March 20th.", "portuguese": "Descobrir a data de 5 meses, 3 semanas e 2 dias a seguir ao 20 de março.", "expected": {"dates": [[2018, 9, 12]]}}, {"question": "Find the date 1 month 1 week and 1 day before September 10th.", "portuguese": "Descobrir a data de 1 mês, 1 semana e 1 dia antes do 10 de setembro.", "expected": {"dates": [[2018, 8, 2]]}}, {"question": "Find the date 2 months, 1 week and 8 days before April 7th.", "portuguese": "Descobrir a data de 2 meses, 1 semana e 8 dias antes do 7 de abril.", "expected": {"dates": [[2018, 1, 23]]}}]}]
    property int firstLevel: 1
    property int levelCount: 1
    property var completed: []
    property var answered: []
    property int wrong: 0
    property var months: ["janeiro","fevereiro","março","abril","maio","junho","julho","agosto","setembro","outubro","novembro","dezembro"]
    property var weekdays: ["domingo","segunda-feira","terça-feira","quarta-feira","quinta-feira","sexta-feira","sábado"]
    function checked(a,b,message){if(a!==b)console.log("CALENDAR_ASSERT",String(a),String(b),message||"",new Error().stack);compare(a,b,message||"");}
    function ensure(value,message){if(!value)console.log("CALENDAR_ASSERT",message||"",new Error().stack);verify(value,message||"");}
    function norm(text){return String(text).replace(/\s+/g," ").trim().toLowerCase();}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value!==null)return value;}return null;}
    function collect(root,predicate,result){if(predicate(root))result.push(root);if(root.children)for(var child of root.children)collect(child,predicate,result);}
    function header(){
        ensure(dateText.visible,"Month/year title is visible");
        var text=norm(dateText.text),match=text.match(/(\d{4})/);ensure(match!==null,"Visible year");
        var month=months.findIndex(function(name){return text.indexOf(name)>=0;});ensure(month>=0,"Portuguese month");
        return [Number(match[1]),month+1];
    }
    function showMonth(year,month){
        for(var guard=0;guard<40;guard++){
            var now=header();if(now[0]===year && now[1]===month)return;
            var forward=now[0]*12+now[1]<year*12+month,button=forward?nextMonth:previousMonth;
            ensure(button.visible,"Required month navigation is exposed");mouseClick(button);wait(70);
        }
        fail("Visible month navigation converges");
    }
    function selectDay(day){
        var delegates=[];collect(grid,function(o){return o.sameMonthDateTextColor!==undefined;},delegates);
        checked(delegates.length,42,"Actual MonthGrid cells");
        var candidates=[];
        for(var delegate of delegates){
            var label=find(delegate,function(o){return o.text!==undefined && String(o.text)===String(day);});
            if(label!==null && String(label.color)!==String(delegate.differentMonthDateTextColor))candidates.push(delegate);
        }
        checked(candidates.length,1,"One visible current-month date");mouseClick(candidates[0]);wait(60);
        var label=find(candidates[0],function(o){return o.text!==undefined && String(o.text)===String(day);});
        checked(String(label.color),String(candidates[0].selectedDateTextColor),"Selected date is highlighted");
    }
    function weekday(value){
        ensure(answerChoices.visible);var found=null;
        for(var i=0;i<7;i++){
            var item=answerChoices.itemAtIndex(i);ensure(item!==null);
            if(norm(item.choices.text).replace(/-feira$/," ").trim()===weekdays[value].replace(/-feira$/," ").trim())found=item;
        }
        ensure(found!==null,"Portuguese weekday answer is visible");mouseClick(found);wait(30);
    }
    function choose(expected,bad){
        if(expected.weekdays){weekday((expected.weekdays[0]+(bad?1:0))%7);return;}
        if(expected.months){
            var year=header()[0],month=expected.months[0];
            if(bad)for(var m=1;m<=12;m++)if(expected.months.indexOf(m)<0){month=m;break;}
            showMonth(year,month);
        } else if(bad){
            var now=header(),day=1;
            if(expected.dates.some(function(d){return d.join()===now.concat([day]).join();}))day=2;
            selectDay(day);
        } else {var target=expected.dates[0];showMonth(target[0],target[1]);selectDay(target[2]);}
        ensure(okButton.visible && okButton.enabled);mouseClick(okButton);wait(30);
    }
    property var controls: ({})
    function selectedDayText(){
        var delegates=[],found=[];collect(grid,function(o){return o.sameMonthDateTextColor!==undefined;},delegates);
        for(var delegate of delegates){
            var label=find(delegate,function(o){return o.text!==undefined && String(o.color)===String(delegate.selectedDateTextColor);});
            if(label!==null)found.push(String(label.text));
        }
        checked(found.length,1,"One date is visibly selected");return Number(found[0]);
    }
    function press(key,day){keyClick(key);wait(100);checked(selectedDayText(),day);}
    function icon(suffix){wait(1600);var button=find(bar,function(o){return o.source!==undefined && String(o.source).endsWith(suffix);});ensure(button!==null,suffix);mouseClick(button);wait(350);}
    function expected(){
        var text=norm(instructionPanel.textItem.text),rows=fixture[activity.currentLevel].questions.filter(function(q){return norm(q.portuguese)===text;});
        checked(rows.length,1);return rows[0].expected;
    }
    function keyboardWeekday(day,key){
        var target=weekdays[day].replace(/-feira$/," ").trim();
        for(var i=0;i<8;i++){
            if(norm(answerChoices.currentItem.choices.text).replace(/-feira$/," ").trim()===target){keyClick(key);wait(50);return;}
            keyClick(Qt.Key_Down);wait(70);
        }
        fail("Visible weekday selection converges");
    }
    function test_controls(){
        wait(1200);checked(activity.currentLevel,0);header();
        selectDay(15);press(Qt.Key_Right,16);press(Qt.Key_Left,15);press(Qt.Key_Down,22);press(Qt.Key_Up,15);
        press(Qt.Key_Home,1);press(Qt.Key_End,31);
        var name=activity.activityInfo.shortName();
        if(name==="calendar"){
            press(Qt.Key_Right,31);press(Qt.Key_PageDown,31);checked(header().join(),"2018,3");
            press(Qt.Key_Home,1);press(Qt.Key_Left,1);press(Qt.Key_PageUp,1);checked(header().join(),"2018,3");
        }else{
            showMonth(2018,1);selectDay(1);press(Qt.Key_Left,1);press(Qt.Key_PageUp,1);checked(header().join(),"2018,1");
            showMonth(2018,12);selectDay(31);press(Qt.Key_Right,31);press(Qt.Key_PageDown,31);checked(header().join(),"2018,12");
        }
        var text=String(instructionPanel.textItem.text);choose(expected(),false);checked(score.currentSubLevel,1);
        tryVerify(function(){return String(instructionPanel.textItem.text)!==text;},5000);
        icon("bar_next.svg");checked(activity.currentLevel,1);checked(score.currentSubLevel,0);
        icon("bar_previous.svg");checked(activity.currentLevel,0);checked(score.currentSubLevel,0);checked(selectedDayText(),1);
        icon("bar_previous.svg");checked(activity.currentLevel,fixture.length-1);icon("bar_next.svg");checked(activity.currentLevel,0);
        icon("bar_next.svg");checked(activity.currentLevel,1);ensure(answerChoices.visible);
        var target=expected().weekdays[0];keyboardWeekday((target+1)%7,Qt.Key_Return);checked(score.currentSubLevel,0);
        tryVerify(function(){return errorRectangle.opacity>0;},1000);wait(1600);
        text=String(instructionPanel.textItem.text);keyboardWeekday(target,Qt.Key_Space);checked(score.currentSubLevel,1);
        tryVerify(function(){return String(instructionPanel.textItem.text)!==text;},5000);
        target=expected().weekdays[0];text=String(instructionPanel.textItem.text);keyboardWeekday(target,Qt.Key_Enter);checked(score.currentSubLevel,2);
        tryVerify(function(){return String(instructionPanel.textItem.text)!==text;},5000);
        icon("bar_previous.svg");checked(activity.currentLevel,0);checked(selectedDayText(),1);
        var depth=pageView.depth;icon("bar_help.svg");tryCompare(pageView,"depth",depth+1,3000);wait(500);
        var help=pageView.currentItem;checked(help.title,activity.activityInfo.title);
        ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(help.content.indexOf("Select the required date")<0);
        grabImage(pageView).save("__QA_OUTPUT__/help.png");keyClick(Qt.Key_Escape);tryCompare(pageView,"depth",depth,3000);wait(500);
        press(Qt.Key_Right,2);
        controls={activity:name,arrowKeys:true,homeEnd:true,pageKeys:true,bounds:true,restart:true,weekdayKeyboard:true,helpEscape:true,keyAfterHelp:true,navigation:true};
        ActivityInfoTree.startingActivity="";icon("bar_home.svg");tryCompare(pageView,"depth",1,3000);ensure(pageView.currentItem.isMenu);
        grabImage(pageView).save("__QA_OUTPUT__/menu.png");
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,controls:controls}));}
}
