/* GCompris - ActivityConfig.qml
 *
* SPDX-FileCopyrightText: 2020 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Johnny Jazeix <jazeix@gmail.com>
 *
 *   SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import core 1.0

import "../../core"

Item {
    id: activityConfiguration
    property Item configBackground
    property alias speedSlider: speedSlider
    property alias noTimeLimitBox: noTimeLimitBox
    property int speedSetting: 5
    // "on" or "off": a string, because Algebra.qml reads saved values by truthiness.
    property string timeLimit: "off"
    width: flick.width
    height: childrenRect.height
    Column {
        spacing: GCStyle.baseMargins
        width: activityConfiguration.width
        GCDialogCheckBox {
            id: noTimeLimitBox
            text: qsTr("Sem limite de tempo")
            checked: activityConfiguration.timeLimit !== "on"
        }
        GCText {
            id: timeLimitHint
            text: qsTr("Cada criança calcula ao seu ritmo. Para treinar a rapidez de cálculo, desmarca esta opção para ligar o limite de tempo e escolhe a velocidade.")
            width: parent.width
            fontSize: regularSize
            wrapMode: Text.WordWrap
        }
        GCText {
            id: speedSliderText
            text: qsTr("Speed")
            width: parent.width
            fontSize: mediumSize
            wrapMode: Text.WordWrap
            opacity: speedSlider.enabled ? 1 : 0.5
        }
        GCSlider {
            id: speedSlider
            width: 250 * ApplicationInfo.ratio
            value: speedSetting
            to: 5
            from: 1
            wheelEnabled: false
            enabled: !noTimeLimitBox.checked
            opacity: enabled ? 1 : 0.5
        }
    }

    property var dataToSave
    function setDefaultValues() {
        speedSlider.value = Qt.binding(function() {return activityConfiguration.speedSetting;})
        noTimeLimitBox.checked = Qt.binding(function() {return activityConfiguration.timeLimit !== "on";})
        if(dataToSave.speedSetting) {
            activityConfiguration.speedSetting = dataToSave.speedSetting
        }
        else {
            activityConfiguration.speedSetting = 5
        }
        // Same rule as Algebra.qml onLoadData: a configuration saved before
        // this option existed keeps its timer.
        if(dataToSave.timeLimit === "on" || dataToSave.timeLimit === "off") {
            activityConfiguration.timeLimit = dataToSave.timeLimit
        }
        else {
            activityConfiguration.timeLimit = dataToSave.speedSetting ? "on" : "off"
        }
    }
    function saveValues() {
        speedSetting = speedSlider.value
        timeLimit = noTimeLimitBox.checked ? "off" : "on"
        dataToSave = {"speedSetting": speedSetting, "timeLimit": timeLimit}
    }
}
