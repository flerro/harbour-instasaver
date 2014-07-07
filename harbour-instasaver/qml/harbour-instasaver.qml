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
import "pages"
import "components"

import "js/UrlUtils.js" as Utils
import "js/LocalStorage.js" as Settings

ApplicationWindow
{
    id: app
    initialPage: Component { Main { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Component.onCompleted: {
        Settings.init();

        Clipboard.text = "adsad sa dsa sa http://www.test.com/dasdsasadsa/dsadsadsadsadsadsa"
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
        var uri = "pages/Main.qml"
        pageStack.clear();
        pageStack.replace(Qt.resolvedUrl(uri));
        activate();
        return pageStack.currentPage
    }

    function toSettingsPage() {
        toMainPage()
        pageStack.push("pages/Settings.qml");
        return pageStack.currentPage
    }

    function activeCover() {
        app.cover = Qt.resolvedUrl("cover/CoverPage.qml")
    }

    function inactiveCover() {
        var cover = Qt.resolvedUrl("cover/CoverPage.qml")
        cover.hint = "ciao bello..."
        app.cover = cover
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

            console.log("Model: " + url)

            if (!url) return

            spinner.running = true;

            client.success.connect(function() {

                console.log("Success!")
                activeCover()
                banner.notify("Success!")
                spinner.running = false;
            })

            client.failure.connect(function(message) {
                console.log("Error: " + message)
                inactiveCover()
                banner.notify(message)
                spinner.running = false;
            })

            client.add(url, prefs.user, prefs.password)
            inactiveCover()
            if (prefs.deactivateOnSuccessfulSubmission) deactivate()


        } catch(error) {
            spinner.running = false;
            banner.notify(error.toString())
            console.error(error)
        }
    }


}


