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
    initialPage: Component { Main {} }
    cover: coverPage

    Component.onCompleted: {
        Settings.init();

        coverPage.addurl.connect(function(){
            readLaterFromCover()
        });

        pageStack.currentPage.addurl.connect(function(website){
            readLater(website)
        });
    }

    CoverPage {
        id: coverPage
    }

    InstapaperClient {
        id: client
    }

    Banner {
        id: banner
    }

    BusyOverlay {
        id: spinner
    }

    function toMainPage(msg) {
        pageStack.clear();
        pageStack.replace(Qt.resolvedUrl("pages/Main.qml"));
        activate();
        return pageStack.currentPage
    }

    function toSettingsPage() {
        toMainPage()
        pageStack.push("pages/Settings.qml");
        return pageStack.currentPage
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
        var main
        var url = ""
        var prefs = Settings.read();

        var url = extractURLFromClipboard()
        main = toMainPage()
        main.url = url
        if (prefs.confirmUrlFromCover) return

        readLater(url)
    }

    function readLater(url) {
        try {
            var prefs = Settings.read();
            var main = pageStack.currentPage
            var successMessage = qsTr("Success!")

            var notify = function(message, done) {
                coverPage.notify(message, url, done)
                banner.notify(message)
                spinner.running = false;
            }

            if (!url) return

            spinner.running = true;

            client.success.connect(function() {
                if (prefs.deactivateOnSuccessfulSubmission) {
                    deactivate()
                }
                notify(successMessage, true)
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


