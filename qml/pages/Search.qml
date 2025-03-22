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

Page {
    id: page
    property bool dialogRunning: false
    property bool reset: false
    property bool saveDate: false

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: header.height + col.height + Theme.paddingLarge
        ScrollDecorator { flickable: flick }

        PageHeader {
            id: header
            title: qsTr("Asetukset ja haku")
        }

        Column {
            id: col
            spacing: Theme.paddingLarge
            anchors.top: header.bottom
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: qsTr("Havaintokuvat")
            }

            Column {
                width: parent.width

                TextSwitch {
                    id: landscapemode
                    checked: taivas.landscape
                    property string category: "landscape"
                    text: qsTr("Näytä vaakatasossa (landscape)")
                    description: qsTr("Valitse näytetäänkö kuvat vaaka- vai pystytasossa (landscape/portrait)")
                }
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: qsTr("Tallennus")
            }

            Column {
                id: configuration
                width: parent.width

                TextSwitch {
                    id: isConfigurable
                    checked: taivas.configurable
                    property string category: "configurable"
                    text: qsTr("Tallenna hakuparametrit")
                    description: qsTr("Kaikki hakuparametrit tallennetaan käyttökertojen välillä")
                }

                TextSwitch {
                    id: dateSavingSwitch
                    checked: saveDate
                    property string category: "savedate"
                    text: qsTr("Tallenna haun aikaväli")
                    description: qsTr("Valittu aikaväli tallennetaan käyttökertojen välillä")
                }
            }

            Button {
                id: defaultTime
                text: qsTr("Alusta aikaväli")

                onClicked: {
                    start.date = taivas.makeOffsetDate()
                    end.date = new Date()
                }
            }

            Column {
                id: dates
                width: parent.width

                Label {
                    anchors.left: parent.left
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor
                    font.family: Theme.fontFamilyHeading
                    text: qsTr("Aikaväli")
                }

                ValueButton {
                    id: start
                    width: col.width
                    label: qsTr("Alku")
                    value: Qt.formatDate(date, "d.M.yyyy")
                    property var date: taivas.startDate

                    onClicked: {
                        page.dialogRunning = true
                        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: date })

                        dialog.accepted.connect(function() {
                            page.dialogRunning = false
                            if (dialog.date < end.date) {
                                taivas.startDate = dialog.date
                            }
                        })
                    }
                }

                ValueButton {
                    id: end
                    width: parent.width
                    label: qsTr("Loppu")
                    value: Qt.formatDate(date, "d.M.yyyy")
                    property var date: taivas.endDate

                    onClicked: {
                        page.dialogRunning = true
                        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", { date: date })
                        var currentDate = new Date()

                        dialog.accepted.connect(function() {
                            page.dialogRunning = false
                            if (dialog.date > start.date && dialog.date <= currentDate) {
                                taivas.endDate = dialog.date
                            }
                        })
                    }
                }
            }

            Button {
                id: defaultQuery
                anchors.horizontalCenter: parent.Center
                text: qsTr("Palauta oletushaku")

                onClicked: {
                    taivas.searchUser = ""
                    observer.text = ""
                    title.text = ""
                    city.text = ""
                    taivas.searchObserver = ""
                    taivas.searchTitle = ""
                    taivas.searchCity = ""
                    all.checked = true
                    end.date = new Date()
                    start.date = taivas.makeOffsetDate()

                    for (var p in taivas.searchCategories) {
                        if (p !== "all") {
                            taivas.searchCategories[p] = false
                        }
                    }

                    taivas.reset()
                    reset = true
                }
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: qsTr("Kategoria")
            }

            Column {
                id: category
                width: parent.width

                TextSwitch {
                    id: all
                    checked: true
                    property string category: "all"
                    text: qsTr("Kaikki")
                    description: qsTr("Kaikki taivaan ilmiöt")
                }

                TextSwitch {
                    id: tahtikuva
                    enabled: !all.checked
                    property string category: "tahtikuva"
                    text: qsTr("Syvä avaruus")
                    description: qsTr("Avaruuden kappaleet")
                }

                TextSwitch {
                    id: pimennys
                    enabled: !all.checked
                    property string category: "pimennys"
                    text: qsTr("Pimennys")
                    description: qsTr("Kuun tai auringon pimennykset")
                }

                TextSwitch {
                    id: tulipallo
                    enabled: !all.checked
                    property string category: "tulipallo"
                    text: qsTr("Tulipallo")
                    description: qsTr("Harvinaisen kirkkaat tähdenlennot")
                }

                TextSwitch {
                    id: revontuli
                    enabled: !all.checked
                    property string category: "revontuli"
                    text: qsTr("Revontulet")
                    description: qsTr("Aurinkotuulen hiukkaset ilmakehässä")
                }

                TextSwitch {
                    id: yopilvi
                    enabled: !all.checked
                    property string category: "yopilvi"
                    text: qsTr("Valaisevat yöpilvet")
                    description: qsTr("Pilvet avaruuden rajalla")
                }

                TextSwitch {
                    id: myrsky
                    enabled: !all.checked
                    property string category: "myrsky"
                    text: qsTr("Myrskyilmiö")
                    description: qsTr("Erityiset myrskyn ilmiöt")
                }

                TextSwitch {
                    id: halo
                    enabled: !all.checked
                    property string category: "halo"
                    text: qsTr("Haloilmiö")
                    description: qsTr("Kirkkaan valonlähteen heijastumat")
                }

                TextSwitch {
                    id: muu
                    enabled: !all.checked
                    property string category: "muu"
                    text: qsTr("Muu ilmiö")
                    description: qsTr("Muut valoilmiöt")
                }
            }

            Button {
                id: release
                text: qsTr("Tyhjennä tekstikentät")
                onClicked: {
                    city.text = ""
                    observer.text = ""
                    title.text = ""
                }
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: qsTr("Havainnon otsikko")
            }

            TextField {
                id: title
                width: parent.width
                focus: false
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: qsTr("Mikä tahansa")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: qsTr("Havainnon tekijä")
            }

            TextField {
                id: observer
                width: parent.width
                focus: false
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: qsTr("Kuka tahansa")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: qsTr("Kaupunki")
            }

            TextField {
                id: city
                width: parent.width
                focus: false
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: qsTr("Mikä tahansa")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
        }
    }

    Component.onCompleted: {
        // Load the config related data if it exists

        for (var i = 0; i < category.children.length; i++) {
            var child = category.children[i]
            child.checked = taivas.searchCategories[child.category]
        }

        observer.text = taivas.searchObserver
        title.text = taivas.searchTitle
        city.text = taivas.searchCity
    }

    onStatusChanged: {
        if (status !== PageStatus.Deactivating)
            return;

        if (page.dialogRunning)
            return;

        taivas.searchUser = ""
        taivas.searchCategories["all"] = all.checked

        if (!all.checked) {
            for (var i = 1; i < category.children.length; i++) {
                var child = category.children[i]
                taivas.searchCategories[child.category] = child.checked

                if (child.checked) {
                    taivas.searchUser += "&category=" + child.category
                    taivas.configurequery = ""
                }
            }
        }

        if (observer.text)
            taivas.searchUser += "&user=" + encodeURIComponent(observer.text)
        if (title.text)
            taivas.searchUser += "&title=" + encodeURIComponent(title.text)
        if (city.text)
            taivas.searchUser += "&city=" + encodeURIComponent(city.text)

        taivas.searchObserver = observer.text
        taivas.searchTitle = title.text
        taivas.searchCity = city.text

        taivas.startDate = start.date
        taivas.endDate = end.date

        // Update configuration values
        taivas.setLandScape(landscapemode.checked);
        taivas.setConfigurable(isConfigurable.checked);

        taivas.havaitse()
        reset = false
    }
}
