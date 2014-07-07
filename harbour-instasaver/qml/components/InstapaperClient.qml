/*
    The MIT License (MIT)

    Copyright (c) 2014 Francesco Lerro

    Ideas on how to handle http request from:
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

Item {

    Timer {
        id: timer
        interval: 8000; //ms
        running: false;
        repeat: false;
        signal timeout;
        onTriggered: timeout();
    }

    readonly property string endpoint: "https://www.instapaper.com/api/add";
    signal success;
    signal failure(string message);

    function add(webpage, username, password) {
        if (!webpage) {
            failure(qsTr("No URL provided."))
        } else {
            var requestParams = { url: this.endpoint, params: { url: webpage, username: username, password: password} }
            var request = ajax(requestParams);

            timer.timeout.connect(function() {
                request.abort()
                failure("Timed out")
            });

            timer.start()
        }
    }

    function ajax(req) {

        var methods = { GET: "GET", POST: "POST" };
        var errorMessages = {
                        400: "Rate limit exceeded",
                        404: "Url NOT found",
                        403: "Invalid user or password",
                        500: "Server error",
                        default: "Service request failed"
                    };

        var buildQueryString =  function(queryParams) {
            var content = "";
            for (var paramKey in queryParams) {
                if (content.length > 0) {
                    content += "&";
                }
                content += (paramKey + "=" + encodeURIComponent(queryParams[paramKey]));
            }
            return content;
        };

        var qs = buildQueryString(req.params);
        var dest = req.url
        if (req.method != methods.POST && qs.length > 0) {
            dest = dest + (dest.indexOf('?') > 0 ? '&' : '?') + qs
        }

//        console.log("URL: ", dest);

        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                timer.stop()

                if (request.status == 200 || request.status == 201) {
                    success();
                 } else {
                    var msg = errorMessages[request.status] || errorMessages.default
                    failure(msg);
                }
            }
//            else {
//                console.log("Running... ", new Date(), request.readyState);
//            }
         };


        request.open(req.method || methods.GET, dest, true, req.user || "", req.password || "");

        if (req.method == methods.POST) {
            request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setRequestHeader('Content-Length', qs.length);
        }

        request.send((req.method == methods.POST) ? qs : "");

        return request
    }
}
