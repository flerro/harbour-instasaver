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

    Component.onCompleted: {
        Settings.init();

        coverPage.addurl.connect(function(){
            readLaterFromCover()
        });

        pageStack.currentPage.addurl.connect(function(website){
            readLater(website)
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
        pageStack.push("pages/Settings.qml")
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

        return urlFound ? url : false
    }

    function readLaterFromCover() {
        var url = ""
        var prefs = Settings.read();

        app.activate()

        var url = extractURLFromClipboard()
        pageStack.currentPage.url = url

        if (prefs.confirmUrlFromCover) return

        readLater(url)
    }

    function readLater(url) {
        try {
            var prefs = Settings.read();

            var notify = function(message, done) {
                coverPage.notify(message, url, done)
                spinner.running = false;
                banner.notify(message)
            }

            if (!url) return

            spinner.running = true;

            client.success.connect(function() {
                if (prefs.deactivateOnSuccessfulSubmission) {
                    deactivate()
                }
                notify( qsTr("Success!"), true)
            })

            client.failure.connect(function(message) {
                notify(message, true)
            })

            client.add(url, prefs.user, prefs.password)

            coverPage.notify(qsTr("In progress..."), url)

        } catch(error) {
            spinner.running = false;
            banner.notify(error.toString())
            // console.error(error)
        }
    }

}


