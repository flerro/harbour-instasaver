/*
    The MIT License (MIT)

    Copyright (c) 2014 Francesco Lerro

    Work derived from:
     - Steffen Förster (https://github.com/steffen-foerster/sailfish-diigo)

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

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/LocalStorage.js" as Settings
import "../js/UrlUtils.js" as Utils
import "../pages"
import "../components"

CoverBackground {
    id: cover

    property alias hint: lblUrlHint.text
    property alias url: lblUrl.text

    onStatusChanged: {
        if (status === PageStatus.Active) {
            resetCover()
        }
    }

    CoverPlaceholder {
        anchors.centerIn: parent
        text: qsTr("Read later via\nInstapaper")
    }

    Label {
        id: lblUrlHint
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        anchors {
            top: parent.top
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width - (Theme.paddingMedium * 2)
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: lblUrl
        height: lblUrl.paintedHeight
        width: parent.width - (Theme.paddingMedium * 2)
        anchors {
            top: lblUrlHint.bottom
            horizontalCenter: parent.horizontalCenter
        }
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    Timer {
        id: resetTimer
        triggeredOnStart: false
        repeat: false
        interval: 5000
        onTriggered: resetCover()
    }

    InstapaperClient {
        id: client
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: readLater()
        }
    }

    function resetCover() {
        hint = qsTr("Add from clipboard")
        url = ""
    }

    function refreshUrlFromClipboard() {
        var hasUrlInClipboard = Clipboard.hasText &&
                                    Utils.textContainsUrl(Clipboard.text)
        if (!hasUrlInClipboard) return

        url = Utils.extractUrl(Clipboard.text)
        hint = (url) ? qsTr("URL in clipboard") : ""
    }

    function readLater() {
        try {
            refreshUrlFromClipboard()

            var prefs = Settings.read()

            if (!url && prefs.activateIfNoUrlInClipboard) {
                var page = app.toMainPage()
                page.pasteUrlAndNotify(qsTr("No URL in clipboard"))
                return
            }

            if (!url && !prefs.activateIfNoUrlInClipboard) {
                hint = qsTr("No URL in Clipboard")
                resetTimer.restart()
                return
            }

            if (prefs.confirmUrlFromCover) {
                var page = app.toMainPage()
                page.pasteUrl()
                return
            }

            hint = qsTr("Adding...")

            client.success.connect(function() {
                hint = qsTr("Success")
                resetTimer.restart()
            })

            client.failure.connect(function(message) {
                hint = message
            })

            var prefs = Settings.read();
            client.add(url, prefs.user, prefs.password)

        } catch(error) {
            hint = error.toString()
        }
    }

}


