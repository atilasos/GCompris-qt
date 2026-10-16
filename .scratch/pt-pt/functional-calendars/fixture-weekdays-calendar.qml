TestCase {
    name: "CalendarFromVisibleQuestionAndDate"
    when: activity.visible && grid.width>0
    property var fixture: [{"level": 1, "configuration": {"navigationBarVisible": false, "minimumDate": "2018-03-01", "maximumDate": "2018-03-31", "visibleMonth": 2, "visibleYear": 2018, "mode": "findDay"}, "questions": [{"question": "Select the 23rd", "portuguese": "Selecionar o dia 23", "expected": {"dates": [[2018, 3, 23]]}}, {"question": "Select the 1st", "portuguese": "Selecionar o dia 1", "expected": {"dates": [[2018, 3, 1]]}}, {"question": "Select the 16th", "portuguese": "Selecionar o dia 16", "expected": {"dates": [[2018, 3, 16]]}}, {"question": "Select the 28th", "portuguese": "Selecionar o dia 28", "expected": {"dates": [[2018, 3, 28]]}}, {"question": "Select the 11th", "portuguese": "Selecionar o dia 11", "expected": {"dates": [[2018, 3, 11]]}}, {"question": "Select the 20th", "portuguese": "Selecionar o dia 20", "expected": {"dates": [[2018, 3, 20]]}}]}, {"level": 2, "configuration": {"navigationBarVisible": false, "minimumDate": "2018-03-01", "maximumDate": "2018-03-31", "visibleMonth": 2, "visibleYear": 2018, "mode": "findDayOfWeek"}, "questions": [{"question": "Which day of the week is the 4th of the given month?", "portuguese": "Que dia da semana é o 4º do mês indicado?", "expected": {"weekdays": [0]}}, {"question": "Which day of the week is the 12th of the given month?", "portuguese": "Que dia da semana é o 12º do mês indicado?", "expected": {"weekdays": [1]}}, {"question": "Which day of the week is the 20th of the given month?", "portuguese": "Que dia da semana é o 20º do mês indicado?", "expected": {"weekdays": [2]}}, {"question": "Which day of the week is the 28th of the given month?", "portuguese": "Que dia da semana é o 28º do mês indicado?", "expected": {"weekdays": [3]}}, {"question": "Which day of the week is the 22nd of the given month?", "portuguese": "Que dia da semana é o 22º do mês indicado?", "expected": {"weekdays": [4]}}, {"question": "Which day of the week is the 16th of the given month?", "portuguese": "Que dia da semana é o 16º do mês indicado?", "expected": {"weekdays": [5]}}, {"question": "Which day of the week is the 10th of the given month?", "portuguese": "Que dia da semana é o 10º do mês indicado?", "expected": {"weekdays": [6]}}]}, {"level": 3, "configuration": {"navigationBarVisible": false, "minimumDate": "2018-03-01", "maximumDate": "2018-03-31", "visibleMonth": 2, "visibleYear": 2018, "mode": "findDay"}, "questions": [{"question": "Select a Monday between days 1 and 7 of the given month", "portuguese": "Seleciona uma segunda-feira entre os dias 1 e 7 do mês indicado", "expected": {"dates": [[2018, 3, 5]]}}, {"question": "Select a Tuesday between days 8 and 16 of the given month", "portuguese": "Seleciona uma terça-feira entre os dias 8 e 16 do mês indicado", "expected": {"dates": [[2018, 3, 13]]}}, {"question": "Select a Wednesday between days 15 and 22 of the given month", "portuguese": "Seleciona uma quarta-feira entre os dias 15 e 22 do mês indicado", "expected": {"dates": [[2018, 3, 21]]}}, {"question": "Select a Thursday between days 26 and 31 of the given month", "portuguese": "Seleciona uma quinta-feira entre os dias 26 e 31 do mês indicado", "expected": {"dates": [[2018, 3, 29]]}}, {"question": "Select a Friday between days 20 and 25 of the given month", "portuguese": "Seleciona uma sexta-feira entre os dias 20 e 25 do mês indicado", "expected": {"dates": [[2018, 3, 23]]}}, {"question": "Select a Saturday between days 13 and 23 of the given month", "portuguese": "Seleciona um sábado entre os dias 13 e 23 do mês indicado", "expected": {"dates": [[2018, 3, 17]]}}, {"question": "Select a Sunday between days 5 and 17 of the given month", "portuguese": "Seleciona um domingo entre os dias 5 e 17 do mês indicado", "expected": {"dates": [[2018, 3, 11]]}}]}, {"level": 4, "configuration": {"navigationBarVisible": false, "minimumDate": "2018-03-01", "maximumDate": "2018-03-31", "visibleMonth": 2, "visibleYear": 2018, "mode": "findDay"}, "questions": [{"question": "Select the second day before the 15th of the given month", "portuguese": "Seleciona o segundo dia antes do dia 15 do mês indicado", "expected": {"dates": [[2018, 3, 13]]}}, {"question": "Select the fourth Sunday of the given month", "portuguese": "Seleciona o quarto domingo do mês indicado", "expected": {"dates": [[2018, 3, 25]]}}, {"question": "Select the day one week after 13th of the given month", "portuguese": "Seleciona o dia que fica uma semana a seguir ao dia 13 do mês indicado", "expected": {"dates": [[2018, 3, 20]]}}, {"question": "Select the fifth Thursday of the given month", "portuguese": "Seleciona a quinta quinta-feira do mês indicado", "expected": {"dates": [[2018, 3, 29]]}}, {"question": "Select the third day after 27th of the given month", "portuguese": "Seleciona o terceiro dia a seguir ao dia 27 do mês indicado", "expected": {"dates": [[2018, 3, 30]]}}]}, {"level": 5, "configuration": {"navigationBarVisible": true, "minimumDate": "2018-01-01", "maximumDate": "2018-12-31", "visibleMonth": 1, "visibleYear": 2018, "mode": "findMonthOnly"}, "questions": [{"question": "Find the month starting a Thursday and having 28 days", "portuguese": "Descobre o mês que começa a uma quinta-feira e tem 28 dias", "expected": {"months": [2]}}, {"question": "Find a month starting a Monday and having 31 days", "portuguese": "Descobre um mês que começa a uma segunda-feira e tem 31 dias", "expected": {"months": [1, 10]}}, {"question": "Find the month between June and August", "portuguese": "Descobre o mês entre junho e agosto", "expected": {"months": [7]}}, {"question": "Find a month starting a Saturday", "portuguese": "Descobre um mês que começa num sábado", "expected": {"months": [9, 12]}}, {"question": "Find a month having 30 days", "portuguese": "Descobre um mês que tem 30 dias", "expected": {"months": [4, 6, 9, 11]}}]}, {"level": 6, "configuration": {"navigationBarVisible": true, "minimumDate": "2017-01-01", "maximumDate": "2019-12-31", "visibleMonth": 2, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Find the first Monday of January in the year 2019", "portuguese": "Descobre a primeira segunda-feira do mês de janeiro do ano 2019", "expected": {"dates": [[2019, 1, 7]]}}, {"question": "Find the second Wednesday of February in the year 2019", "portuguese": "Descobre a segunda quarta-feira do mês de fevereiro do ano 2019", "expected": {"dates": [[2019, 2, 13]]}}, {"question": "Find the third Friday of March in the year 2019", "portuguese": "Descobre a terceira sexta-feira do mês de março do ano 2019", "expected": {"dates": [[2019, 3, 15]]}}, {"question": "Find the fifth Sunday of April in the year 2018", "portuguese": "Descobre o quinto domingo do mês de abril do ano 2018", "expected": {"dates": [[2018, 4, 29]]}}, {"question": "Find the fourth Tuesday of July in the year 2018", "portuguese": "Descobre a quarta terça-feira do mês de julho do ano 2018", "expected": {"dates": [[2018, 7, 24]]}}, {"question": "Find the first Monday of August in the year 2018", "portuguese": "Descobre a primeira segunda-feira do mês de agosto do ano 2018", "expected": {"dates": [[2018, 8, 6]]}}, {"question": "Find the third Thursday of September in the year 2017", "portuguese": "Descobre a terceira quinta-feira do mês de setembro do ano 2017", "expected": {"dates": [[2017, 9, 21]]}}, {"question": "Find the fifth Sunday of October in the year 2017", "portuguese": "Descobre o quinto domingo do mês de outubro do ano 2017", "expected": {"dates": [[2017, 10, 29]]}}, {"question": "Find the second Friday of December in the year 2017", "portuguese": "Descobre a segunda sexta-feira do mês de dezembro do ano 2017", "expected": {"dates": [[2017, 12, 8]]}}]}, {"level": 7, "configuration": {"navigationBarVisible": true, "minimumDate": "2017-01-01", "maximumDate": "2019-12-31", "visibleMonth": 1, "visibleYear": 2018, "mode": "findYearMonthDay"}, "questions": [{"question": "Human Rights Day is celebrated five days after December 5.<br> Find the date of Human Rights Day in 2017.", "portuguese": "O Dia dos Direitos Humanos celebra-se cinco dias depois de 5 de dezembro.<br>Descobre a data do Dia dos Direitos Humanos em 2017.", "expected": {"dates": [[2017, 12, 10]]}}, {"question": "Braille Day is celebrated one day before January 5.<br> Find the date of Braille Day in 2018", "portuguese": "O Dia de Braille celebra-se um dia antes de 5 de janeiro.<br/>Descobre a data do Dia de Braille em 2018", "expected": {"dates": [[2018, 1, 4]]}}, {"question": "Mark's birthday is on November 4. In 2017 his party was exactly two weeks later.<br> Find the date of his party in 2017", "portuguese": "O aniversário do Marco é a 4 de novembro. Em 2017, a sua festa foi exatamente duas semanas depois.<br>Descobre a data da festa em 2017", "expected": {"dates": [[2017, 11, 18]]}}, {"question": "International Women's Day is celebrated two days before March 10.<br> Find the date of International Women's Day in 2018.", "portuguese": "O Dia Internacional da Mulher celebra-se dois dias antes de 10 de março.<br/>Descobre a data do Dia Internacional da Mulher em 2018.", "expected": {"dates": [[2018, 3, 8]]}}, {"question": "The sports competition was held on last Friday of September 2017.<br> Select the date of the sports competition on the calendar.", "portuguese": "A competição desportiva ocorreu na última sexta-feira de setembro de 2017.<br/>Seleciona a data da competição no calendário.", "expected": {"dates": [[2017, 9, 29]]}}]}]
    property int firstLevel: 1
    property int levelCount: 7
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
