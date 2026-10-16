import QtTest
/* GCompris - renewable_energy.qml
 *
 * SPDX-FileCopyrightText: 2015 Sagar Chand Agarwal <atomsagar@gmail.com>
 * SPDX-FileCopyrightText: 2022 Timothée Giet <animtim@gmail.com>
 *
 * Authors:
 *   Bruno Coudoin <bruno.coudoin@gcompris.net> (GTK+ version)
 *   Sagar Chand Agarwal <atomsagar@gmail.com> (Qt Quick port)
 *   Timothée Giet <animtim@gmail.com> (Big refactoring)
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0
import "../../core"
import "qrc:/gcompris/src/core/core.js" as Core

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    property string url: "qrc:/gcompris/src/activities/renewable_energy/resource/"
    property string url2: "qrc:/gcompris/src/activities/watercycle/resource/"

    pageComponent: Image {
        id: activityBackground
        anchors.fill: parent
        source: "qrc:/gcompris/src/activities/chess/resource/background-wood.svg"
        sourceSize.width: width
        sourceSize.height: height

        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Needed to get keyboard focus on IntroMessage
        Keys.forwardTo: [message]

        QtObject {
            id: items
            property Item main: activity.main
            property alias activityBackground: activityBackground
            property alias bonus: bonus
            property alias harbor1Sound: harbor1Sound
            property alias harbor2Sound: harbor2Sound
            property alias waterSound: waterSound
            // we initialize it to -1, so onStart it forces a layout refresh when it's set to 0
            property int currentLevel: -1
            onCurrentLevelChanged: activity.currentLevel = currentLevel
            property int numberOfLevel: 3
            onNumberOfLevelChanged: activity.numberOfLevel = numberOfLevel
            property bool sunIsUp: true
            property color consumeColor: "#E09C4C"
            property color consumeColorBorder: "#81531E"
            property color produceColor: "#E9E87F"
            property color produceColorBorder: "#82811E"
            property bool hasWon: false

            onSunIsUpChanged: {
                if(sunIsUp)
                    sun.state = "sunUp"
                else
                    sun.state = "sunDown"
            }
        }

        onStart: {
            activity.numberOfLevel = items.numberOfLevel;
            items.currentLevel = Core.getInitialLevel(items.numberOfLevel);
        }
        onStop: {
            harbor1Sound.stop()
            harbor2Sound.stop()
            waterSound.stop()
            hydro.item.stop()
            hydro.item.stopTimer();
            if(wind.item)
                wind.item.stopTimer();
        }

        function initLevel() {
            if(message.visible)
                return;
            residentSmallSwitch.on = false
            residentBigSwitch.on = false
            tuxSwitch.on = false
            stepDown.started = false
            hydro.item.stop()
            if(wind.item)
                wind.item.stop()
            if(solar.item)
                solar.item.stop()
        }

        function nextLevel() {
            if(items.numberOfLevel <= ++items.currentLevel) {
                // Stay on the last level
                items.currentLevel = items.numberOfLevel - 1
            }
        }

        function previousLevel() {
            items.currentLevel = Core.getPreviousLevel(items.currentLevel, items.numberOfLevel);
        }

        function checkForNextLevel() {
            switch(items.currentLevel) {
                case 0:
                    if(tuxSwitch.on)
                        win()
                    break
                case 1:
                    if(tuxSwitch.on && residentSmallSwitch.on)
                        win()
                    break
                case 2:
                    if(!items.hasWon &&
                            tuxSwitch.on && residentSmallSwitch.on && residentBigSwitch.on) {
                        items.hasWon = true
                        win()
                    }
                    break
            }
        }

        GCSoundEffect {
            id: harbor1Sound
            source: "qrc:/gcompris/src/activities/watercycle/resource/harbor1.wav"
        }

        GCSoundEffect {
            id: harbor2Sound
            source: "qrc:/gcompris/src/activities/watercycle/resource/harbor2.wav"
        }

        GCSoundEffect {
            id: waterSound
            source: "qrc:/gcompris/src/core/resource/sounds/water.wav"
        }

        GCSoundEffect {
            id: bleepSound
            source: "qrc:/gcompris/src/core/resource/sounds/bleep.wav"
        }

        Item {
            id: layoutArea
            width: Math.min(parent.height - bar.height * 1.2, parent.width)
            height: width
            anchors.horizontalCenter: activityBackground.horizontalCenter
            anchors.verticalCenter: activityBackground.verticalCenter
            anchors.verticalCenterOffset: -bar.height * 0.6
        }

        Image {
            id: sky
            anchors.top: layoutArea.top
            anchors.left: layoutArea.left
            width: layoutArea.width
            height: layoutArea.height * 0.305
            sourceSize.width: width
            sourceSize.height: height
            source: activity.url2 + "sky.svg"
            visible: true
        }

        Image {
            id: sun
            source: activity.url2 + "sun.svg"
            width: layoutArea.width * 0.1
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width
            anchors {
                left: layoutArea.left
                top: layoutArea.top
                leftMargin: layoutArea.width * 0.056
                topMargin: layoutArea.height * 0.256
            }

            MouseArea {
                id: sun_area
                anchors.fill: sun
                onClicked: {
                    if(hydro.item.cloudOpacity == 0)
                        items.sunIsUp = true;
                }
            }
            state: "sunUp"
            states: [
                State {
                    name: "sunDown"
                    PropertyChanges {
                        sun {
                            anchors.topMargin: layoutArea.height * 0.256
                        }
                    }
                },
                State {
                    name: "sunUp"
                    PropertyChanges {
                        sun {
                            anchors.topMargin: layoutArea.height * 0.056
                        }
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "sunUp"; to: "sunDown";
                    NumberAnimation { property: "sun.anchors.topMargin"; easing.type: Easing.InOutQuad; duration: 5000 }
                },
                Transition {
                    from: "sunDown"; to: "sunUp";
                    ScriptAction { script: {
                            bleepSound.play();
                            hydro.item.vaporAnimLoop = true;
                            hydro.item.vaporIsUp = true;
                            hydro.item.cloudIsUp = true;
                        }
                    }
                    NumberAnimation { property: "sun.anchors.topMargin"; easing.type: Easing.InOutQuad; duration: 5000 }
                }
            ]
        }

        Image {
            id: sea
            anchors.left: layoutArea.left
            anchors.bottom: layoutArea.bottom
            width: layoutArea.width
            height: layoutArea.height * 0.7
            sourceSize.width: width
            sourceSize.height: height
            source: activity.url2 + "sea.svg"
        }

        Image {
            id: landscape
            anchors.fill: layoutArea
            sourceSize.width: width
            sourceSize.height: height
            source: activity.url2 + "landscape.svg"
        }

        Loader {
            id: wind
            anchors.fill: layoutArea
            source: items.currentLevel > 0 ? "Wind.qml" : ""
        }

        Loader {
            id: solar
            anchors.fill: layoutArea
            source: items.currentLevel > 1 ? "Solar.qml" : ""
        }

        Loader {
            id: hydro
            anchors.fill: layoutArea
            source: "Hydro.qml"
        }

        IntroMessage {
            id: message
            z: 100
            onIntroDone: {
                hydro.item.start()
            }
            intro: ListModel {
                ListElement {
                    text: qsTr("Tux has come back from fishing on his boat. Bring the electrical system back up so he can have light in his home.")
                }
                ListElement {
                    text: qsTr("Click on different active elements: sun, cloud, dam, solar array, wind farm and transformers, in order to reactivate the entire electrical system.")
                }
                ListElement {
                    text: qsTr("When the system is back up and Tux is in his home, push the light button for him. To win you must switch on all the consumers while all the producers are up.")
                }
                ListElement {
                    text: qsTr("Learn about an electrical system based on renewable energy. Enjoy.")
                }
            }
        }

        Rectangle {
            id: check
            opacity: 0
            width: activityBackground.width * 0.9
            height: layoutArea.height * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: layoutArea.verticalCenter
            z: 100
            border.color: GCStyle.darkBorder
            border.width: GCStyle.thinnestBorder
            radius: GCStyle.halfMargins
            color: GCStyle.lightBg
            property bool shown: false

            GCText {
                id: warning
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: parent.height * 0.9
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr( "It is not possible to consume more electricity " +
                           "than what is produced. There is a key limitation in the " +
                           "distribution of electricity, with minor exceptions, " +
                           "electrical energy cannot be stored, and therefore it " +
                           "must be generated as it is needed. A sophisticated " +
                           "system of control is therefore required to ensure electric " +
                           "generation very closely matches the demand. If supply and demand " +
                           "are not in balance, generation plants and transmission equipment " +
                           "can shut down which, in the worst cases, can lead to a major " +
                           "regional blackout.")
                fontSizeMode: Text.Fit
                minimumPointSize: 7
                wrapMode: Text.WordWrap
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: check.opacity > 0
                onClicked: check.opacity = 0
            }
        }

        Image {
            id: stepDown
            z: 50
            source: activity.url + "transformer_off.svg"
            width: layoutArea.width * 0.07
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                top: layoutArea.top
                left: layoutArea.left
                topMargin: layoutArea.width * 0.462
                leftMargin: layoutArea.width * 0.727
            }
            MouseArea {
                anchors.centerIn: parent
                // Size the area for a touch screen
                width: parent.width * 1.2
                height: parent.height * 1.2
                onClicked: {
                    onClicked: parent.started = !parent.started
                }
            }
            property bool started: false
            property int powerIn:
                started ? (hydro.item.power +
                           (wind.item ? wind.item.power : 0) +
                           (solar.item ? solar.item.power : 0)) : 0
            property int powerOut:
                started ? (tux.powerConsumed +
                           residentSmallLights.powerConsumed +
                           residentBigLights.powerConsumed) : 0

            onPowerInChanged: checkPower()

            // Check powerOut does not exceed powerIn. Cut some consumers in case.
            function checkPower() {
                if(powerOut > powerIn && residentBigSwitch.on) {
                    residentBigSwitch.on = false
                    if(!check.shown && powerIn) check.opacity = 1
                }

                if(!started || (powerOut > powerIn && residentSmallSwitch.on)) {
                    residentSmallSwitch.on = false
                    if(!check.shown && powerIn) check.opacity = 1
                }

                if(!started || (powerOut > powerIn && tuxSwitch.on)) {
                    tuxSwitch.on = false
                    if(!check.shown && powerIn) check.opacity = 1
                }
            }
        }

        Image {
            id: stepDownOn
            z: 50
            source: activity.url + "transformer_on.svg"
            anchors.fill: stepDown
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            visible: stepDown.started
        }

        Rectangle {
            id: produceMeter
            width: pow.width + GCStyle.halfMargins
            height: pow.height + GCStyle.tinyMargins
            border.color: items.produceColorBorder
            radius: GCStyle.tinyMargins
            color: items.produceColor
            anchors {
                bottom: stepDown.top
                left: stepDown.horizontalCenter
            }
            GCText {
                id: pow
                anchors.centerIn: parent
                fontSize: smallSize * 0.5
                text: stepDown.powerIn.toString() + "W"
            }
        }

        Image {
            id: stepDownWire
            source: activity.url + "hydroelectric/stepdownwire_off.svg"
            width: layoutArea.width * 0.154
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                left: layoutArea.left
                top: layoutArea.top
                leftMargin: layoutArea.width * 0.623
                topMargin: layoutArea.width * 0.503
            }
        }

        Image {
            id: stepDownWireOn
            source: activity.url + "hydroelectric/stepdownwire_on.svg"
            anchors.fill: stepDownWire
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            visible: stepDown.powerIn > 0
        }

        Image {
            id: consumerPole
            source: activity.url + "consumer_pole.svg"
            width: layoutArea.width * 0.037
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                top: layoutArea.top
                left: layoutArea.left
                leftMargin: layoutArea.width * 0.681
                topMargin: layoutArea.width * 0.514
            }
        }

        Rectangle {
            id: consumeMeter
            width: stepdown_info.width + GCStyle.halfMargins
            height: stepdown_info.height + GCStyle.tinyMargins
            border.color: items.consumeColorBorder
            radius: GCStyle.tinyMargins
            color: items.consumeColor
            anchors {
                bottom: consumerPole.top
                right: consumerPole.horizontalCenter
            }
            GCText {
                id: stepdown_info
                anchors.centerIn: parent
                fontSize: smallSize * 0.5
                text: stepDown.powerOut.toString() + "W"
            }
        }

        Image {
            id: tuxHouse
            source: activity.url2 + "tuxHouse.svg"
            width: layoutArea.width * 0.036
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                top: layoutArea.top
                left: layoutArea.left
                topMargin: layoutArea.height * 0.638
                leftMargin: layoutArea.width * 0.765
            }
        }

        Image {
            id: tuxHouseOn
            source: activity.url + "tux_house_on.svg"
            anchors.fill: tuxHouse
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            visible: tuxSwitch.on
        }

        Image {
            id: city
            source: activity.url2 + "city.svg"
            width: layoutArea.width * 0.202
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                top: layoutArea.top
                left: layoutArea.left
                topMargin: layoutArea.height * 0.465
                leftMargin: layoutArea.width * 0.44
            }
        }

        Image {
            id: residentSmallLights
            source: activity.url + "resident_smallon.svg"
            anchors.fill: city
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            visible: items.currentLevel > 0 && powerConsumed
            property int power: 1000
            property int powerConsumed: on ? power : 0
            property bool on: residentSmallSwitch.on
        }

        Image {
            id: residentSmallSwitch
            visible: items.currentLevel > 0
            source: activity.url + (on ? "on.svg" : "off.svg")
            width: layoutArea.width * 0.053
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                left: layoutArea.left
                top: layoutArea.top
                leftMargin: layoutArea.width * 0.535
                topMargin: layoutArea.height * 0.608
            }
            property bool on: false
            MouseArea {
                id: small_area
                enabled: parent.visible
                anchors.centerIn: parent
                // Size the area for a touch screen
                width: parent.width * 1.2
                height: width
                onClicked: {
                    if(stepDown.powerIn - stepDown.powerOut >= residentSmallLights.power)
                        parent.on = !parent.on
                    else
                        parent.on = false

                    checkForNextLevel()
                }
            }
        }

        Rectangle {
            id: smallConsumeRect
            width: small_consume.width + GCStyle.halfMargins
            height: small_consume.height + GCStyle.tinyMargins
            border.color: items.consumeColorBorder
            radius: GCStyle.tinyMargins
            color: items.consumeColor
            anchors {
                top: residentSmallSwitch.bottom
                horizontalCenter: residentSmallSwitch.horizontalCenter
            }
            GCText {
                id: small_consume
                anchors.centerIn: parent
                text: residentSmallLights.powerConsumed.toString() + "W"
                fontSize: smallSize * 0.5
            }
            visible: items.currentLevel > 0
        }

        Image {
            id: residentBigSwitch
            visible: items.currentLevel > 1
            source: activity.url + (on ? "on.svg" : "off.svg")
            width: layoutArea.width * 0.053
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                left: layoutArea.left
                top: layoutArea.top
                leftMargin: layoutArea.width * 0.629
                topMargin: layoutArea.height * 0.608
            }
            property bool on: false
            MouseArea {
                id: big_area
                visible: parent.visible
                anchors.centerIn: parent
                // Size the area for a touch screen
                width: parent.width * 1.2
                height: width
                onClicked: {
                    if(stepDown.powerIn - stepDown.powerOut >= residentBigLights.power)
                        parent.on = !parent.on
                    else
                        parent.on = false

                    checkForNextLevel()
                }
            }
        }

        Rectangle {
            id: bigConsumeRect
            width: bigConsume.width + GCStyle.halfMargins
            height: bigConsume.height + GCStyle.tinyMargins
            border.color: items.consumeColorBorder
            radius : GCStyle.tinyMargins
            color: items.consumeColor
            anchors {
                top: residentBigSwitch.bottom
                horizontalCenter: residentBigSwitch.horizontalCenter
            }
            GCText {
                id: bigConsume
                anchors.centerIn: parent
                text: residentBigLights.powerConsumed.toString() + "W"
                fontSize: smallSize * 0.5
            }
            visible: items.currentLevel > 1
        }

        Image {
            id: residentBigLights
            source: activity.url + "resident_bigon.svg"
            anchors.fill: city
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            visible: items.currentLevel > 0 && powerConsumed
            property int power: 2000
            property int powerConsumed: on ? power : 0
            property bool on: residentBigSwitch.on
        }

        // Tux is visible when tuxboat animation stops
        // It's light can be activated after stepdown is on

        Image {
            id: tux
            source: activity.url + (on ? "lightson.svg" : "lightsoff.svg")
            width: layoutArea.width * 0.184
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            anchors {
                top: layoutArea.top
                left: layoutArea.left
                leftMargin: layoutArea.width * 0.79
                topMargin: layoutArea.width *  0.557
            }
            visible: false
            property int power: 100
            property int powerConsumed: on ? power : 0
            property bool on: tuxSwitch.on
        }

        Image {
            id: tuxSwitch
            source: activity.url + (on ? "on.svg" : "off.svg")
            width: layoutArea.width * 0.053
            sourceSize.width: width
            fillMode: Image.PreserveAspectFit
            property bool on: false
            visible: tux.visible
            anchors {
                top: layoutArea.top
                left: layoutArea.left
                leftMargin: layoutArea.width * 0.868
                topMargin: layoutArea.width * 0.722
            }
            MouseArea {
                id: off_area
                anchors.centerIn: parent
                // Size the area for a touch screen
                width: parent.width * 1.2
                height: width
                enabled: tuxSwitch.visible
                onClicked: {
                    if(stepDown.powerIn - stepDown.powerOut >= tux.power)
                        parent.on = !parent.on
                    else
                        parent.on = false
                    checkForNextLevel()
                }
            }
        }

        Rectangle {
            id: tuxMeter
            width: tuxConsume.width + GCStyle.halfMargins
            height: tuxConsume.height + GCStyle.tinyMargins
            border.color: items.consumeColorBorder
            radius : GCStyle.tinyMargins
            color: items.consumeColor
            anchors {
                top: tuxSwitch.bottom
                horizontalCenter: tuxSwitch.horizontalCenter
            }
            GCText {
                id: tuxConsume
                anchors.centerIn: parent
                fontSize: smallSize * 0.5
                text: tux.powerConsumed.toString() + "W"
            }
            visible: tux.visible
        }

        function win() {
            items.bonus.good("flower")
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            level: items.currentLevel + 1
            content: BarEnumContent { value: help | home | level | reload }
            onHelpClicked: displayDialog(dialogHelp)
            onPreviousLevelClicked: previousLevel()
            onNextLevelClicked: nextLevel()
            onHomeClicked: home();
            onReloadClicked: initLevel()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(nextLevel)
        }
// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'RenewableEnergyByVisibleGeneratorsAndMeters'
 when:activity.visible&&hydro.item!==null
 property var levels: []
 property var evidence:({intro:[]})
 function all(root){var result=[root];if(root.children)for(var c of root.children)result=result.concat(all(c));return result;}
 function image(root,suffix){var found=all(root).find(c=>c.source!==undefined&&String(c.source).endsWith(suffix));ensure(found!==undefined,'Drawn image '+suffix);return found;}
 function ensure(value,message){if(!value){console.log('ENERGY_ASSERT',message);evidence.failure={message:message,view:view()};grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-water-energy/.scratch/pt-pt/functional-cycles/energy-pilot/failure.png');}verify(value,message||'');}
 function point(item){var p=item.mapToItem(activityBackground,item.width/2,item.height/2);return {x:p.x,y:p.y,width:item.width,height:item.height,opacity:item.opacity,visible:item.visible,source:item.source!==undefined?String(item.source):null};}
 function click(item){ensure(item.visible&&item.width>0&&item.height>0,'Visible input');var p=item.mapToItem(pageView,item.width/2,item.height/2);ensure(p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<pageView.height,'Input on screen');mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);}
 function meter(root){var labels=all(root).filter(c=>c.visible&&c.text!==undefined&&/^\d+W$/.test(String(c.text))).map(c=>String(c.text));ensure(labels.length===1,'One painted power reading');return {text:labels[0],watts:Number(labels[0].slice(0,-1))};}
 function generator(root){var labels=all(root).filter(c=>c.visible&&c.text!==undefined&&/^\d+W$/.test(String(c.text))).map(c=>String(c.text));return labels.map(t=>({text:t,watts:Number(t.slice(0,-1))}));}
 function view(){return {level:activity.currentLevel,total:activity.numberOfLevel,produced:meter(produceMeter),consumed:meter(consumeMeter),hydro:generator(hydro.item),wind:wind.item?generator(wind.item):[],solar:solar.item?generator(solar.item):[],switches:[point(tuxSwitch),point(residentSmallSwitch),point(residentBigSwitch)],lights:[point(tuxHouseOn),point(residentSmallLights),point(residentBigLights)]};}
 function waitGeometry(item){var last=point(item),stable=0,start=Date.now();while(stable<6&&Date.now()-start<22000){wait(100);var next=point(item);stable=Math.abs(next.x-last.x)<0.001&&Math.abs(next.y-last.y)<0.001&&Math.abs(next.width-last.width)<0.001?stable+1:0;last=next;}ensure(stable>=6,'Drawn producer settles');}
 function success(level){tryCompare(bonus,'isPlaying',true,1500);tryVerify(()=>bonus.opacity>0.5,1500);ensure(String(bonus.source).indexOf('good')>=0,'Natural energy Bonus');var result=view(),sum=result.hydro.concat(result.wind,result.solar).reduce((a,r)=>a+r.watts,0);ensure(result.produced.watts===sum,'Independent sum of painted generation');ensure(result.consumed.watts<=sum,'Consumption does not exceed generation');grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-water-energy/.scratch/pt-pt/functional-cycles/energy-pilot/level-'+level+'.png');return {view:result,bonus:String(bonus.source)};}
 function test_levels(){
  wait(1300);compare(activity.numberOfLevel,3);compare(activity.currentLevel,0);
  for(var page=0;page<4;page++){var text=all(message).filter(c=>c.visible&&c.text!==undefined&&String(c.text).length>35).map(c=>String(c.text));compare(text.length,1);evidence.intro.push(text[0]);keyClick(Qt.Key_Space);wait(300);}
  tryCompare(message,'visible',false,2000);click(sun);var cloud=image(hydro.item,'watercycle/resource/cloud.svg');tryVerify(()=>cloud.opacity>0.9&&cloud.width>10,8000);waitGeometry(cloud);click(cloud);var river=image(hydro.item,'watercycle/resource/river.svg');tryCompare(river,'opacity',1,12000);tryVerify(()=>tuxSwitch.visible,20000);click(stepDown);click(tuxSwitch);ensure(String(tuxSwitch.source).endsWith('/off.svg')&&meter(consumeMeter).watts===0,'Tux cannot consume without supply');var wrong=view();
  click(image(hydro.item,'hydroelectric/dam_off.svg'));click(image(hydro.item,'transformer_off.svg'));tryVerify(()=>meter(produceMeter).watts>0,2000);click(tuxSwitch);var first=success(1);levels.push({level:1,wrong:wrong,success:first});tryCompare(activity,'currentLevel',1,10000);tryCompare(bonus,'isPlaying',false,3000);
  tryVerify(()=>wind.item!==null,2000);click(residentSmallSwitch);ensure(String(residentSmallSwitch.source).endsWith('/off.svg'),'Small consumers refuse insufficient remaining supply');wrong=view();click(image(wind.item,'wind/cloud_quiet.svg'));click(image(wind.item,'transformer_off.svg'));tryVerify(()=>generator(wind.item).some(r=>r.watts>0),2000);click(residentSmallSwitch);var second=success(2);levels.push({level:2,wrong:wrong,success:second});tryCompare(activity,'currentLevel',2,10000);tryCompare(bonus,'isPlaying',false,3000);
  tryVerify(()=>solar.item!==null,2000);click(residentBigSwitch);ensure(String(residentBigSwitch.source).endsWith('/off.svg'),'Large consumers refuse insufficient remaining supply');wrong=view();click(image(solar.item,'solar/solar_panel_off.svg'));click(image(solar.item,'transformer_off.svg'));tryCompare(cloud,'opacity',0,15000);click(sun);tryVerify(()=>generator(solar.item).some(r=>r.watts>0),3000);click(residentBigSwitch);var third=success(3);levels.push({level:3,wrong:wrong,success:third});tryCompare(bonus,'isPlaying',false,7000);compare(activity.currentLevel,2);evidence.lastLevelStays=true;
  tryVerify(()=>!image(wind.item,'wind/cloud_blowing.svg').visible,35000);var after=view();ensure(after.consumed.watts<=after.produced.watts&&String(residentBigSwitch.source).endsWith('/off.svg'),'Natural wind expiry sheds overload');evidence.windExpiry=after;grabImage(pageView).save('/home/proteu/Projetos/GCompris-qt-worktrees/pt-water-energy/.scratch/pt-pt/functional-cycles/energy-pilot/wind-expiry.png');
 }
 function cleanupTestCase(){console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,levels:levels,evidence:evidence}));}
}

    }
}
