TestCase {
    name: "CalendarFromVisibleQuestionAndDate"
    when: activity.visible && grid.width>0
    property var fixture: [{"level": 1, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the date 13 days after May 3rd.", "portuguese": "Descobrir a data de 13 dias a seguir ao 3 de maio.", "expected": {"dates": [[2018, 5, 16]]}}, {"question": "Find the date 7 days after October 1st.", "portuguese": "Descobrir a data de 7 dias a seguir ao 1 de outubro.", "expected": {"dates": [[2018, 10, 8]]}}, {"question": "Find the date 31 days after July 12th.", "portuguese": "Descobrir a data de 31 dias a seguir ao 12 de julho.", "expected": {"dates": [[2018, 8, 12]]}}, {"question": "Find the date two weeks after November 27th.", "portuguese": "Descobrir a data duas semanas depois do 27 de novembro.", "expected": {"dates": [[2018, 12, 11]]}}, {"question": "Find the date 19 days before September 1st.", "portuguese": "Descobrir a data de 19 dias antes do 1 de setembro.", "expected": {"dates": [[2018, 8, 13]]}}, {"question": "Find the date 5 days before December 8th.", "portuguese": "Descobrir a data de 5 dias antes do 8 de dezembro.", "expected": {"dates": [[2018, 12, 3]]}}]}, {"level": 2, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findDayOfWeek"}, "questions": [{"question": "Find the day of the week 3 days after December 5th.", "portuguese": "Descobrir o dia da semana de 3 dias depois do 5 de dezembro.", "expected": {"weekdays": [6]}}, {"question": "Find the day of the week 12 days before November 12th.", "portuguese": "Descobrir o dia da semana de 12 dias antes do 12 de novembro.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 32 days after January 5th.", "portuguese": "Descobrir o dia da semana de 32 dias depois do 5 de janeiro.", "expected": {"weekdays": [2]}}, {"question": "Find the day of the week 5 days after February 23rd.", "portuguese": "Descobrir o dia da semana de 5 dias depois do 23 de fevereiro.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 17 days before August 16th.", "portuguese": "Descobre o dia da semana 17 dias antes de 16 de agosto.", "expected": {"weekdays": [1]}}]}, {"level": 3, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the date 2 weeks and 3 days after January 12th.", "portuguese": "Descobrir a data de 2 semanas e 3 dias depois do 12 de janeiro.", "expected": {"dates": [[2018, 1, 29]]}}, {"question": "Find the date 3 weeks and 2 days after March 22nd.", "portuguese": "Descobrir a data de 3 semanas e 2 dias depois do 22 de março.", "expected": {"dates": [[2018, 4, 14]]}}, {"question": "Find the date 5 weeks and 6 days after October 5th.", "portuguese": "Descobrir a data de 5 semanas e 6 dias depois do 5 de outubro.", "expected": {"dates": [[2018, 11, 15]]}}, {"question": "Find the date 1 week and 1 day before August 8th.", "portuguese": "Descobrir a data de 1 semana e 1 dia antes do 8 de agosto.", "expected": {"dates": [[2018, 7, 31]]}}, {"question": "Find the date 2 weeks and 5 days before July 2nd.", "portuguese": "Descobrir a data de 2 semanas e 5 dias antes do 2 de julho.", "expected": {"dates": [[2018, 6, 13]]}}]}, {"level": 4, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findDayOfWeek"}, "questions": [{"question": "Find the day of the week 5 months and 2 days after July 3rd.", "portuguese": "Descobre o dia da semana 5 meses e 2 dias depois de 3 de julho.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 2 months and 4 days after October 8th.", "portuguese": "Descobrir o dia da semana de 2 meses e 4 dias depois do 8 de outubro.", "expected": {"weekdays": [3]}}, {"question": "Find the day of the week 1 month and 3 days before December 28th.", "portuguese": "Descobre o dia da semana 1 mês e 3 dias antes de 28 de dezembro.", "expected": {"weekdays": [0]}}, {"question": "Find the day of the week 8 months and 7 days after February 28th.", "portuguese": "Descobrir o dia da semana de 8 meses e 7 dias depois do 28 de fevereiro.", "expected": {"weekdays": [0]}}, {"question": "Find the day of the week 3 months and 3 days before September 15th.", "portuguese": "Descobrir o dia da semana de 3 meses e 3 dias antes do 15 de setembro.", "expected": {"weekdays": [2]}}]}, {"level": 5, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 7, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the date 2 months, 1 week and 5 days after January 12th.", "portuguese": "Descobre a data 2 meses, 1 semana e 5 dias depois de 12 de janeiro.", "expected": {"dates": [[2018, 3, 24]]}}, {"question": "Find the date 3 months, 2 weeks and 1 day after August 23rd.", "portuguese": "Descobrir a data de 3 meses, 2 semanas e 1 dia a seguir ao 23 de agosto.", "expected": {"dates": [[2018, 12, 8]]}}, {"question": "Find the date 5 months, 3 weeks and 2 days after March 20th.", "portuguese": "Descobrir a data de 5 meses, 3 semanas e 2 dias a seguir ao 20 de março.", "expected": {"dates": [[2018, 9, 12]]}}, {"question": "Find the date 1 month 1 week and 1 day before September 10th.", "portuguese": "Descobrir a data de 1 mês, 1 semana e 1 dia antes do 10 de setembro.", "expected": {"dates": [[2018, 8, 2]]}}, {"question": "Find the date 2 months, 1 week and 8 days before April 7th.", "portuguese": "Descobrir a data de 2 meses, 1 semana e 8 dias antes do 7 de abril.", "expected": {"dates": [[2018, 1, 23]]}}]}]
    property int firstLevel: 1
    property int levelCount: 5
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
            if(norm(item.choices.text)===weekdays[value])found=item;
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
    function test_complete(){
        wait(1200);checked(activity.currentLevel,firstLevel-1);checked(activity.numberOfLevel,fixture.length);
        for(var offset=0;offset<levelCount;offset++){
            var level=firstLevel+offset,questions=fixture[level-1].questions,seen={};
            checked(activity.currentLevel,level-1);header();
            for(var n=0;n<questions.length;n++){
                var text=String(instructionPanel.textItem.text),matches=questions.filter(function(q){return norm(q.portuguese)===norm(text);});
                checked(matches.length,1,"Visible question has an independent Gregorian interpretation: "+text);
                ensure(!seen[norm(text)],"Question appears once per authored level");seen[norm(text)]=true;
                // Current Portuguese orthography uses lowercase month and weekday names inside phrases.
                ensure(!/\b(Janeiro|Fevereiro|Março|Abril|Maio|Junho|Julho|Agosto|Setembro|Outubro|Novembro|Dezembro|Segunda-Feira|Terça-Feira|Quarta-Feira|Quinta-Feira|Sexta-Feira|Sábado|Domingo)\b/.test(text),"Current Portuguese orthography: "+text);
                var before=score.currentSubLevel;
                if(n===0){
                    choose(matches[0].expected,true);checked(score.currentSubLevel,before);
                    tryVerify(function(){return errorRectangle.opacity>0;},1000);wait(1600);
                    checked(score.currentSubLevel,before);checked(instructionPanel.textItem.text,text);wrong++;
                }
                choose(matches[0].expected,false);checked(score.currentSubLevel,before+1);
                answered.push({level:level,question:text,expected:matches[0].expected});
                if(n+1<questions.length)tryVerify(function(){return String(instructionPanel.textItem.text)!==text;},5000);
            }
            tryVerify(function(){return bonus.isPlaying;},5000);
            grabImage(activity).save("__QA_OUTPUT__/level-"+level+".png");
            completed.push({level:level,questions:questions.length});
            tryCompare(activity,"currentLevel",level%fixture.length,8000);wait(350);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,answered:answered,wrong:wrong}));}
}
