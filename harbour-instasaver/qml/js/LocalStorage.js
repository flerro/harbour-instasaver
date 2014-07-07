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

.pragma library

.import QtQuick.LocalStorage 2.0 as Sql


var keys = { user: "USER",
                    password: "PWD",
                    confirmUrlFromCover: "CONFIRMFROMCOVER",
                    deactivateOnSuccessfulSubmission: "MINIMIZE" };

function init() { storage.setup(); };

function read() {
    var prefs = storage.read();

    // name aliasing for preferences
    return {
            user: prefs[keys.user],
            password: prefs[keys.password],
            confirmUrlFromCover : asBool(prefs[keys.confirmUrlFromCover]),
            deactivateOnSuccessfulSubmission: asBool(prefs[keys.deactivateOnSuccessfulSubmission])
           }
}

function store(user, password, confirmUrlFromCover, deactivateOnSuccess) {
    var items = new Array();
    items[keys.user] = user
    items[keys.password] = password
    items[keys.confirmUrlFromCover] = confirmUrlFromCover
    items[keys.deactivateOnSuccessfulSubmission] = deactivateOnSuccess
    storage.store(items);
}

function getUser() {
    return storage.readPref(keys.user) || "";
}

function shouldConfirmUrlFromCover() {
    return asBool(storage.readPref(keys.confirmUrlFromCover));
}

function shouldDeactivateOnSuccess() {
    return asBool(storage.readPref(keys.deactivateOnSuccessfulSubmission));
}

// ------------------------------------------------------------ Private

var asBool = function(val) {
     return val == 1
}

var storage = {

    setup: function() {
        var db = storage.open();
        db.transaction(function (tx){
            try {
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings(name TEXT, value TEXT, PRIMARY KEY (name))');
            } catch (err) {
                console.warn("storage.setup KO: " + err.toString())
            }
        });
    },

    open: function() {
        return Sql.LocalStorage.openDatabaseSync("Instasaver", "1.0", "Settings DB", 1000000);
    },

    store: function(items) {
        var db = storage.open();
        db.transaction(function (tx) {
            for (var i in items) {
                try {
                    tx.executeSql('INSERT OR REPLACE INTO settings VALUES(?, ?);', [i, items[i]]);
                    // console.debug("Inserted: ", i, " -> ", items[i])
                } catch (err) {
                    console.warn("storage.store KO: " + err.toString())
                }
            }
        });
    },

    readPref: function(name) {
        var db =  storage.open();
        var retval = new Array();
        db.transaction(function (tx) {
            try {
                var res = tx.executeSql('SELECT value FROM settings where name = ?;', name);
                //console.debug("read: ", name, " -> ", res.rows.item(0).value)
                retval = res.rows.length > 0 ? res.rows.item(0).value : "";
            } catch (err) {
                console.warn("storage.read KO: " + err.toString())
            }
        });
        return retval;
    },

    read: function(name) {
        var db =  storage.open();
        var retval = new Array();
        db.transaction(function (tx) {
            try {
                var res = tx.executeSql('SELECT * FROM settings;');
                for ( var i = 0; i < res.rows.length; i++) {
                    var current = res.rows.item(i);
                    // console.debug("Read: ", current.name, " -> ", current.value)
                    retval[current.name] = current.value;
                }
            } catch (err) {
                console.warn("storage.read KO: " + err.toString())
            }
        });

        return retval;
    }

};





