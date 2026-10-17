// SPDX-FileCopyrightText: NONE
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Window
import core 1.0

// Use the available window, not the primary monitor, to size board-game text.
GCText {
    readonly property real windowScale: Math.max(0.9, Math.min(1.4, Math.min(Window.window ? Window.window.width / 1100 : 1, Window.window ? Window.window.height / 740 : 1)))
    font.pointSize: NaN
    font.pixelSize: Math.max(12, Math.min(36, fontSize) * windowScale + ApplicationSettings.baseFontSize * 0.65)
    fontSizeMode: Text.Fit
    minimumPixelSize: 12
}
