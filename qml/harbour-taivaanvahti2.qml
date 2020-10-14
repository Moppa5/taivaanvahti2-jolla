/*
  Copyright (C) 2013 Kalle Vahlman, <zuh@iki.fi>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"
import Configuration 1.0

ApplicationWindow
{
    id: taivas

    ConfigReader {
        /* ConfigReader for reading and writing application data
         * Take a look at config.cpp and config.h for better info
         */
        id: config
    }

    initialPage: Qt.createComponent("pages/Observations.qml")
    cover: Qt.createComponent("cover/CoverPage.qml")

    // Error flags
    property bool commentError: false // couldn't fetch comments
    property bool fetchError: false // couldn't fetch observations
    property bool observationError: false // couldn't fetch observation data

    // general data structures
    property int havainto: 0
    property var havainnot: ListModel {}
    property var kommentit: ListModel {}
    property var viimeiset: ListModel {}

    // Config related parameters
    property bool configurable: false
    property bool configured: false
    property bool landscape: true
    property bool searchRunning: false
    property bool detailedSearchRunning: false
    property bool commentSearchRunning: false

    // Search parameters
    property string searchCity: ""
    property string configurequery: ""
    property string userName: ""
    property string copyright: "© 2020 "
    property string searchUser: ""

    // URLS
    property string searchUrl: "https://www.taivaanvahti.fi/app/api/search.php?format=json"
    property string defaultColumns: "&columns=id,title,start,city,category,thumbnails,comments"
    property string detailedColumns: "&columns=user,team,description,details,link,equipment,images"
    property string commentUrl: "https://www.taivaanvahti.fi/app/api/comment_search.php?format=json"

    // Date related parameters
    property int dateOffset: 7
    property var startDate: makeOffsetDate()
    property var endDate: new Date()

    // Category and parameters
    property string searchObserver: ""
    property string searchTitle: ""
    property var searchCategories: {
        "all": true,
        "tahtikuva": false,
        "pimennys": false,
        "tulipallo": false,
        "revontuli": false,
        "yopilvi": false,
        "myrsky": false,
        "halo": false,
        "muu": false
    }

    // JavaScript functions start

    function resetDates() {
        config.resetDate()
    }

    function saveDate(date, dateType) {
        config.setDate(date,dateType)
    }

    function setParameters(user, title, city) {
        config.setSearchParameters(user,title,city)
    }

    function writeStatus() {
        // method to call from other qml files
        config.writeStatus()
    }

    function setConfigureStatus(object, status) {
        // Method to call from other qml files
        config.setStatus(object,status)
    }

    function reset() {
        havainnot.clear()
        kommentit.clear()
        viimeiset.clear()

        taivas.havaitse()
    }

    function isConfigurable() {
        return config.isConfigurable()
    }

    function setConfigurable(status) {
        config.setConfigurable(status)
    }

    function setLandScape(status) {
        config.notLandScape(status)
    }

    function configure() {
        // Application launch configuration

        if (config.readStatus() ) {

            if (config.isConfigurable()) {
            // Update searchCategories from file
                for (var p in searchCategories) {
                    searchCategories[p] = config.fetchStatus(p)
                }

                if (config.fetchSearchUser() !== "") {
                    searchUser += "&user=" + config.fetchSearchUser()
                    searchObserver = config.fetchSearchUser()
                }

                if (config.fetchSearchCity() !== "") {
                    searchUser += "&city=" + config.fetchSearchCity()
                    searchCity = config.fetchSearchCity()
                }

                if (config.fetchSearchTitle() !== "") {
                    searchUser += "&title=" + config.fetchSearchTitle()
                    searchTitle = config.fetchSearchTitle()
                }

                if (config.fetchDate()) {
                    // Dates have been saved earlier
                    startDate = config.fetchRealDate("start")

                    if (endDate <= config.fetchRealDate("end")) {
                        endDate = config.fetchRealDate("end")
                    }
                }

                // Update categories for query
                for (var i in searchCategories) {
                    if (searchCategories[i]) {
                        configurequery += "&category=" + i
                    }
                }
            }
        } else {
            /* No data file found for taivaanvahti
             * Generating new using Config class
             */
            for (var object in searchCategories) {
                // Set the current default state for QMap
                config.setStatus(object,searchCategories[object]);
            }

            config.writeStatus();
        }

        if (!config.isLandScape())
            // If user wants to use Portrait or LandScape
            landscape = false

        taivas.havaitse()
    }

    function makeOffsetDate() {
        var d = new Date();
        d.setDate(d.getDate() - dateOffset)
        return d;
    }

    function havaitseTarkemmin() {

        if (observationError) {
            observationError = false
        }

        detailedSearchRunning = true
        var xhr = new XMLHttpRequest
        var query = searchUrl + searchUser + detailedColumns + "&id=" + havainnot.get(havainto).id
        xhr.open("GET", query);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                userName = ""
                detailedSearchRunning = false
                if (xhr.responseText.match("^No") !== null)
                    return
                var results = JSON.parse(xhr.responseText)

                userName = results.observation[0].user[0]

                if (results.observation[0].images) {
                    var photos = results.observation[0].images
                    results.observation[0].photos = []
                    for (var p in photos) {
                        results.observation[0].photos[p] = { "url" : photos[p] }
                    }
                }

                havainnot.set(havainto, results.observation[0])
            }
        }
        xhr.send();
    }

    function havaitse() {

        if (fetchError) {
            fetchError = false
        }

        searchRunning = true
        havainnot.clear()
        viimeiset.clear()
        var xhr = new XMLHttpRequest
        var query = searchUrl + configurequery + searchUser + defaultColumns

        query += "&start=" + Qt.formatDate(startDate, "yyyy-MM-dd")
        query += "&end=" + Qt.formatDate(endDate, "yyyy-MM-dd")
        xhr.open("GET", query);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {

                searchRunning = false
                if (xhr.responseText.match("^No") !== null)
                    return
                var results = JSON.parse(xhr.responseText)
                for (var i in results.observation) {
                    if (results.observation[i].thumbnails) {
                        var thumbs = results.observation[i].thumbnails
                        results.observation[i].thumbs = []
                        for (var p in thumbs) {
                            results.observation[i].thumbs[p] = { "url" : thumbs[p] }
                        }
                    }

                    havainnot.append(results.observation[i])
                }

                if (havainnot.count > 0)
                    viimeiset.append({
                                         "category": havainnot.get(0).title, // instead title
                                         "start": havainnot.get(0).start
                                     })
                if (havainnot.count > 1)
                    viimeiset.append({
                                         "category": havainnot.get(1).title, // instead title
                                         "start": havainnot.get(1).start
                                     })
            }

            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status !== 200) {
                fetchError = true
            }
        }
        xhr.send();
    }

    function kommentoi() {

        if (commentError) {
            commentError = false
        }

        kommentit.clear()
        if (havainnot.get(havainto).comments && havainnot.get(havainto).comments === "0")
            return
        commentSearchRunning = true
        var xhr = new XMLHttpRequest;
        xhr.open("GET", commentUrl + "&observation=" + havainnot.get(havainto).id)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                commentSearchRunning = false
                if (xhr.responseText.match("^No") !== null)
                    return
                var results = JSON.parse(xhr.responseText)
                for (var i in results.comment) {
                    kommentit.append(results.comment[i])
                }
            }

            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status !== 200) {
                commentError = true
            }
        }
        xhr.send();
    }

}
