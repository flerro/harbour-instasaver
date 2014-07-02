/*
    The MIT License (MIT)

    Copyright (c) 2014 Francesco Lerro

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

import "../js/UrlUtils.js" as Utils
import "../js/LocalStorage.js" as Settings
import "../components"

Dialog {
    id: mainPage

    property alias url: href.text
    property alias user: username.text

    onStatusChanged: {
        if (status === PageStatus.Active) {
            user = Settings.getUser()

            if (!user) {
                app.displaySettingsPage()
            }
        }
    }

    canAccept: url && url.match(Utils.urlMatcher())

    onAccepted: {
        readLater()
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }
            MenuItem {
                text: qsTr("From Clipboard")
                onClicked: {
                    pasteUrl()
                    if (!url) {
                        banner.notify("No URL in clipboard")
                    }
                }
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge
            DialogHeader {
                acceptText: qsTr("Read later")
                title: qsTr("Instasaver")
            }

            TextField {
                id: href
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: qsTr("Enter URL")
                label: qsTr("URL")
                width: column.width
                focus: true
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: Utils.urlMatcher() }
                EnterKey.enabled: mainPage.canAccept
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: readLater()
            }

            Label {
                id: username
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }
    }

    Banner {
        id: banner
    }

    BusyOverlay {
        id: busyIndicator
    }

    InstapaperClient {
        id: client
    }

    function pasteUrl() {
        if (Clipboard.hasText) {
           url = Utils.extractUrl(Clipboard.text)
        }
    }

    function pasteUrlAndNotify(msg) {
        pasteUrl()
        if (msg) banner.notify(msg)
    }

    function readLater() {
        try {
            busyIndicator.running = true;

            client.success.connect(function() {
                busyIndicator.running = false;
                banner.notify(qsTr("Success"))
            })

            client.failure.connect(function(message) {
                busyIndicator.running = false;
                banner.notify(qsTr(message))
            })

            var prefs = Settings.read();
            client.add(url, prefs.user, prefs.password)

        } catch(error) {
            busyIndicator.running = false;
            banner.notify(error.toString())
        }
    }

}


