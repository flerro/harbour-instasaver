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

.pragma library

var httpGet = function (url, queryParams, onSuccess, onFailure, user, password) {
    var GET = "GET"
    var qs = queryString(queryParams);
    if (qs.length > 0) {
        url = url + (url.indexOf('?') > 0 ? '&' : '?') + qs
    }

//    console.log("URL: ", url);

    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        onready(request, onSuccess, onFailure, GET);
    }
    request.open(GET, url, true, user || "", password || "");
    request.send();
}

var httpPost = function(url, queryParams, onSuccess, onFailure, user, password) {
    var POST = "POST"
    var content = queryString(queryParams);

    var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        onready(request, onSuccess, onFailure, POST);
    }
    request.open(POST, url, true, user || "", password || "");
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Content-Length', content.length);
    request.send(content);
};

// Utils ---------------------------------------------------------------------


var queryString =  function(queryParams) {
    var content = "";
    for (var paramKey in queryParams) {
        if (content.length > 0) {
            content += "&";
        }
        content += (paramKey + "=" + encodeURIComponent(queryParams[paramKey]));
    }
    return content;
}

var onready = function(request, onSuccess, onFailure, method) {
    if (request.readyState === XMLHttpRequest.DONE) {
        if (request.status === 201) {
            if (onSuccess) {
                var response = JSON.parse(request.responseText);
                onSuccess(response);
            }
        } else {
            var errorResponse = "" + request.status;
            var errorMessage = "";

            switch (request.status) {
                case 400:
                    errorMessage = "Rate limit exceeded"
                    break;
                case 403:
                    errorMessage = "Invalid user or password"
                    break;
                case 500:
                    errorMessage = "Server error"
                    break;
                default:
                    errorMessage = "Service request failed"
                    break;
            }

//            console.log(method + " request FAILED: " + request.status);
            if (onFailure) {
                onFailure(errorMessage);
            }

        }
    }
};
