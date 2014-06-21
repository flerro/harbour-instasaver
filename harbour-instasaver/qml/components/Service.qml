import QtQuick 2.0

import "../js/HttpClient.js" as HttpClient
import "../js/LocalStorage.js" as Settings
import "../js/UrlUtils.js" as Utils

Item {
    id: service

    property String endpoint: "https://www.instapaper.com/api/add"

    function extractUrlFromClipboard() {
        var url = ""
        if (Clipboard.hasText) {
            url = Utils.extractUrl(Clipboard.text)
        }
        return url
    }

    function readLaterFromClipboard(ok, ko) {
        readLater(extractUrlFromClipboard(), ok, ko)
    }

    function readLater(url, ok, ko) {
        if (!url) {
            ko(qsTr("No URL provided."))
        } else {
            var params = {url: url, username: Settings.getUser(), password: Settings.getPassword()}
            HttpClient.performGetRequest(service.endpoint, params, ok, ko)
        }
    }

    function username() {
        return Settings.getUser()
    }

}
