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


function setUser(value) {
    storage.store("USER", value);
}

function setPassword(value) {
    storage.store("PWD", value);
}

function getUser() {
    return storage.read("USER") || "";
}

function getPassword() {
    return storage.read("PWD") || "";
}

function initStorage(){
    storage.setup()
}

// Utils ---------------------------------------------------------------------

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

    store: function(name, value) {
        var db = storage.open();
        db.transaction(function (tx) {
            try {
                tx.executeSql('INSERT OR REPLACE INTO settings VALUES(?, ?);', [name, value]);
//                console.debug("Inserted: ", name, " -> ", value)
            } catch (err) {
                console.warn("storage.store KO: " + err.toString())
            }
        });
    },

    read: function(name) {
        var db =  storage.open();
        var retval = undefined;
        db.transaction(function (tx) {
            try {
                var res = tx.executeSql('SELECT value FROM settings WHERE name = ?;', [name]);
                if (res.rows.length > 0) {
                    retval = res.rows.item(0).value;
                } else {
//                    console.warn("name ", name, " not found!");
                    retval = undefined;
                }
            } catch (err) {
                console.warn("storage.read KO: " + err.toString())
            }
        });
        return retval;
    }

};

