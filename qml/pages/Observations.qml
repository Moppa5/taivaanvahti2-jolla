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
    id: havainnotPage

    Component.onCompleted: taivas.configure()

    property string hintMessage: ""
    property string message: {
        if (list.count == 0 && !taivas.searchRunning && !taivas.fetchError) {
            hintMessage = "Vedä alas päivittääksesi tai muuttaaksesi hakuehtoja"
            return "Ei havaintoja"
        } else if (taivas.fetchError) {
            hintMessage = "Rajapintahaku on voinut muuttua. Ota yhteyttä kehittäjään"
            return "Rajapintahaussa tapahtui virhe, tarkista verkkoyhteys"
        } else {
            hintMessage = ""
            return ""
        }

    }

    SilicaListView {
        id: list
        anchors.fill: parent
        contentHeight: parent.height

        ScrollDecorator { flickable: list }

        PullDownMenu {
            id: pulley
            busy: taivas.searchRunning

            MenuItem {
                text: "Tietoja"
                onClicked: pageStack.push("Info.qml")
            }

            MenuItem {
                text: "Asetukset"
                onClicked: pageStack.push("Search.qml")
            }

            MenuItem {
                text: "Päivitä"
                onClicked: {
                    pulley.close()
                    taivas.havainnot.clear()
                    taivas.havaitse()
                }
            }
        }

        header: PageHeader {
            id: header
            title: "Havainnot"
        }

        ViewPlaceholder {
            enabled: true
            text: message
            hintText: hintMessage
        }

        model: taivas.havainnot

        delegate: BackgroundItem {

            height: Theme.itemSizeExtraLarge // Standard was large

            Column {
                id: h
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge

                Label {
                    width: parent.width
                    text: title
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }

                Label {
                    width: parent.width
                    text: category
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    elide: Text.ElideRight
                }
                Label {
                    text: {
                        var txt = Format.formatDate(start, Formatter.TimeValue)
                        var time = new Date(start)
                        var month = time.getMonth()+1
                        var date = time.getDate()
                        var year = time.getFullYear()

                        return txt + " - " + date + "." + month + "." + year + " - " + city
                    }
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    elide: Text.ElideRight
                    width: parent.width
                }

                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    text: {
                        var total = ""

                        if (thumbnails.count === 0 && comments == "0") {
                            return "Ei kuvia / kommentteja"
                        } else {
                            if (thumbnails.count !== 0) {
                                if (thumbnails.count > 1) {
                                    total += thumbnails.count + " kuvaa "
                                } else {
                                    total += thumbnails.count + " kuva "
                                }
                            }

                            if (comments !== "0") {
                                if (comments === "1") {
                                    total += comments + " kommentti "
                                } else {
                                    total += comments + " kommenttia "
                                }
                            }
                        return total
                    }
                }
            }
        }

            onClicked: {
                taivas.havainto = index
                taivas.havaitseTarkemmin()
                taivas.kommentoi()
                pageStack.push("Observation.qml")
            }
        }

    }
}


