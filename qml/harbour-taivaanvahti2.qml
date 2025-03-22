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
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow
{
    id: taivas

    ConfigurationGroup {
        id: config
        path: "/apps/harbour-taivaanvahti2"

        // Generic controls
        property string landScapeKey: "landScape";
        property string saveQueryParams: "saveQuery";
        property string datesKey: "saveDates";

        // Date params
        property string startKey: "startDate";
        property string endKey: "endDate";
        property string categoriesKey: "queryCategories";

        // Categories
        property string allKey: "all";
        property string deepSpaceKey: "tahtikuva";
        property string eclipseKey: "pimennys";
        property string fireBallKey: "tulipallo";
        property string auroraKey: "revontuli";
        property string cloudKey: "yopilvi";
        property string stormKey: "myrsky";
        property string haloKey: "halo";
        property string otherKey: "muu";

        // Basic params
        property string searchKey: "searchUser";
        property string observerKey: "observer";
        property string titleKey: "title";
        property string cityKey: "city";
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
    property bool saveQueryParams: false
    property bool landscape: false
    property bool saveDates: false

    // Running booleans
    property bool searchRunning: false
    property bool detailedSearchRunning: false
    property bool commentSearchRunning: false

    // Search parameters
    property string searchCity: ""
    property string configurequery: ""
    property string userName: ""
    property string copyright: {
                                  var currentTime = new Date()
                                  return "© " + currentTime.getFullYear() + " "
                               }
    property string searchUser: ""

    // URLS
    property string searchUrl: "https://www.taivaanvahti.fi/app/api/search.php?format=json"
    property string defaultColumns: "&columns=id,title,start,city,category,thumbnails,comments"
    property string detailedColumns: "&columns=user,team,description,details,link,equipment,images"
    property string commentUrl: "https://www.taivaanvahti.fi/app/api/comment_search.php?format=json"

    // Date related parameters
    property int dateOffset: 10
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

    function reset() {
        havainnot.clear()
        kommentit.clear()
        viimeiset.clear()

        taivas.havaitse()
    }

    // Sets the landscape and stores the value into configuration
    function setLandScape(value) {
        landscape = value;
        config.setValue(config.landScapeKey, value);
        config.sync();
    }

    // Stores the query params
    function setSaveQueryParams(value) {
        saveQueryParams = value;
        config.setValue(config.saveQueryParams, value);

        if (value) {

            for (var category in searchCategories) {
                setCategoryValue(category);
            }

            config.setValue(config.observerKey, searchObserver);
            config.setValue(config.titleKey, searchTitle);
            config.setValue(config.cityKey, searchCity);
            config.setValue(config.searchKey, taivas.searchUser);
        }

        config.sync();
    }

    // Stores the current start and end date values
    function setSaveDates(value) {
        saveDates = value;
        config.setValue(config.datesKey, value);
        config.setValue(config.startKey, taivas.startDate);
        config.setValue(config.endKey, taivas.endDate);

        config.sync();
    }

    // Stores the current category value for the value key
    function setCategoryValue(valueKey) {
        config.setValue(valueKey, searchCategories[valueKey]);
    }

    // Reads the stored category value for the value key or reverts to default
    function readAndStoreCategoryValue(valueKey) {
        searchCategories[valueKey] = config.value(valueKey, searchCategories[valueKey]);
    }

    // Main initialization called when observation page is initalized
    function configure() {
        landscape = config.value(config.landScapeKey, false);
        saveQueryParams = config.value(config.saveQueryParams, false);
        saveDates = config.value(config.datesKey, false);

        // Read config values if config store is on
        if (saveQueryParams) {
            for (var category in searchCategories) {
               readAndStoreCategoryValue(category);
            }

            var query = config.value(config.searchKey, searchUser);
            var observer = config.value(config.observerKey, searchObserver);
            var title = config.value(config.titleKey, searchTitle);
            var city = config.value(config.cityKey, searchCity);

            searchObserver = observer;
            searchTitle = title;
            searchCity = city;
            searchUser = query;
        }

        if (saveDates) {
            taivas.startDate = config.value(config.startKey, taivas.startDate);
            taivas.endDate = config.value(config.endKey, taivas.endDate);
        }

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
            // Try again
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

    /// Parses the given comment and replaces character codes with their readable form
    function parseComment(comment) {

        // Fix the letters ä, ö, and some space
        const fixA = /&auml;/gi
        const fixO = /&ouml;/gi
        const space = /&nbsp;/gi
        comment.text = comment.text.replace(fixA, 'ä');
        comment.text = comment.text.replace(fixO, 'ö');
        comment.text = comment.text.replace(space, ' ');
    }

    function kommentoi() {

        if (commentError) {
            // Try again
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
                    var comment = results.comment[i];
                    parseComment(comment);
                    kommentit.append(comment)
                }
            }

            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status !== 200) {
                commentError = true
            }
        }
        xhr.send();
    }

}
