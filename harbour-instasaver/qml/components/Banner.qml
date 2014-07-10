/*
    The MIT License (MIT)

    Copyright (c) 2014 Francesco Lerro

    Work derived from:
     - http://sailfishdev.tumblr.com/

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import QtQuick 2.1
import Sailfish.Silica 1.0

MouseArea {
    id: popup
    anchors.top: parent.top
    width: parent.width
    height: message.paintedHeight + hint.paintedHeight + Theme.paddingLarge
    property alias title: message.text
    property alias subTitle: hint.text
    property alias timeout: hideTimer.interval
    property alias background: bg.color
    visible: opacity > 0
    opacity: 0.0

    Behavior on opacity {
        FadeAnimation {}
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.secondaryHighlightColor
    }

    Timer {
        id: hideTimer
        triggeredOnStart: false
        repeat: false
        interval: 3000
        onTriggered: popup.hide()
    }

    function hide() {
        if (hideTimer.running)
            hideTimer.stop()
        popup.opacity = 0.0
    }

    function show() {
        popup.opacity = 1.0
        hideTimer.restart()
    }

    function notify(text, description) {
        popup.title = text
        if (description) {
            popup.subTitle = description
            hint.visible = true
        } else {
            hint.visible = false
        }

        show()
    }

    Label {
        id: message
        anchors.top: bg.top
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.primaryColor
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
        wrapMode: Text.Wrap
    }

    Label {
        id: hint
        font.pixelSize: Theme.fontSizeExtraSmall
        color: Theme.secondaryColor
        anchors.top: message.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }

    onClicked: hide()
}
