/*
The MIT License (MIT)

Copyright (c) 2014 Francesco Lerro

Work derived from:
 - Steffen Förster (https://github.com/steffen-foerster/sailfish-diigo)
 - Peter Tworek (https://github.com/tworaz/sailfish-ytplayer/pages/YoutubeClientV3.js)

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
import "cover"
import "pages"
import "components"

import "js/UrlUtils.js" as Utils
import "js/LocalStorage.js" as Settings

ApplicationWindow
{
    id: app
    initialPage: Component { Main { } }
    cover: coverPage

    property string submittingUrl: ""

    Component.onCompleted: {
        Settings.init();

        coverPage.addurl.connect(function(){
            readLaterFromCover()
        });

        if (!Settings.getUser()) {
            displaySettingsPage()
        }
    }

    CoverPage {
        id: coverPage
    }

    InstapaperClient {
        id: client
    }

    BusyOverlay {
        id: spinner
    }

    Banner {
        id: banner
    }

    function displaySettingsPage() {
        pageStack.push(Qt.resolvedUrl("pages/Settings.qml"))
    }

    function extractURLFromClipboard() {
        var url = ""
        var urlFound = false
        if (Clipboard.hasText) {
           url = Utils.extractUrl(Clipboard.text)
           urlFound = url && url.length > 10
        }

        if (!urlFound){
            banner.notify(qsTr("No URL in clipboard"))
        }

        return urlFound ? url : ""
    }

    function readLaterFromCover() {
        var url = ""
        var prefs = Settings.read();

        app.activate()
        pageStack.currentPage.url = extractURLFromClipboard()

        if (prefs.confirmUrlFromCover) return

        pageStack.currentPage.accept()
    }

    function readLater(url) {
        if (!url) return

        var successMessage = qsTr("Success!")
        var inprogressMessage = qsTr("In progress...")

        var notifySubmission = function(message, done) {
            spinner.running = !done
            coverPage.notify(message, url, done)
            if (done) {
                submittingUrl = ""
                banner.notify(message)
            } else {
                submittingUrl = url
            }
        }

        try {
            var prefs = Settings.read();

            client.success.connect(function() {
                notifySubmission(successMessage, true)
                if (prefs.deactivateOnSuccessfulSubmission) {
                    deactivate()
                }
            })

            client.failure.connect(function(message) {
                notifySubmission(message, true)
            })

            client.add(url, prefs.user, prefs.password)

            notifySubmission(inprogressMessage)

        } catch(error) {
            spinner.running = false;
            notifySubmission(error.toString())
            // console.error(error)
        }
    }

}


