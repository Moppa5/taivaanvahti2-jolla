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

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: header.height + col.height + Theme.paddingLarge
        ScrollDecorator { flickable: flick }

        PageHeader {
            id: header
            title: "Taivaanvahti"
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
                id: sovellusotsikko
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Uudesta versiosta"
            }

            Label {
                id: sovellus
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 1024
                font.pixelSize: Theme.fontSizeSmall
                text: "Alkuperäistä Taivaanvahti-sovellusta on kehitetty eteenpäin. "
                      + "Sovelluksella on nyt tuki Sailfish 3 -versiolle ja lisäksi "
                      + "mukaan on lisätty uusia ominaisuuksia kuten havaintohakujen "
                      + "tallennus, kaupunkiparametri, valinta kuvien näyttöasennolle ja kommentin lähetys. "
                      + "Lisäksi on tehty pieniä tyylimuutoksia"
            }

            Label {
                id: tv
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Taivaanvahdista"
            }

            Label {
                id: blurb
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 1024
                font.pixelSize: Theme.fontSizeSmall
                text: "Taivaanvahti (taivaanvahti.fi) on Ursan havaintojärjestelmä, jonka tietokantaan "
                    + "kerätään tähtitieteellisten ja ilmakehän ilmiöiden havaintoja."
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 1024
                font.pixelSize: Theme.fontSizeSmall
                text: "Tämä sovellus ei ole virallinen osa Taivaanvahtijärjestelmää, "
                    + "mutta se on kehitetty Taivaanvahdin ylläpidon avulla. Tähän sovellukseen "
                    + "liittyvät ongelmat tai ehdotukset voi laittaa GitHub-palveluun issue-pyyntöinä. "
                    + "Palaute on sallittua ja toivottua"
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Tekijänoikeuksista"
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 1024
                font.pixelSize: Theme.fontSizeSmall
                text: "Havaintojen kuvien ja tekstien tekijänoikeudet säilyvät havaitsijalla. "
                    + "Lähettäessään havainnon Taivaanvahtiin tekijä luovuttaa vain oikeuden "
                    + "julkaista kuvat ja teksti havaintojärjestelmässä. Tämän vuoksi kuvia ei "
                    + "voi käyttää esimerkiksi taustakuvana ilman erillistä lupaa tekijältä."
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Kotisivu"
            }

            BackgroundItem {
                id: homepage
                height: Theme.itemSizeSmall
                property string url: "https://github.com/Moppa5/taivaanvahti2-jolla"

                Label {
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeTiny
                    text: homepage.url
                }

                onClicked: Qt.openUrlExternally(url)
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Alkuperäinen kehittäjä"
            }

            BackgroundItem {
                id: orgdev
                height: Theme.itemSizeSmall
                property string original: "Kalle Vahlman"
                property string originalmail: "zuh@iki.fi"
                property string originalurl: "mailto:" + originalmail

                Label {
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeSmall
                    text: orgdev.original + " <" + orgdev.originalmail + ">"
                }

                onClicked: Qt.openUrlExternally(originalurl)
            }

            Label {
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Nykyinen kehittäjä"
            }

            BackgroundItem {
                id: dev
                height: Theme.itemSizeSmall
                property string developer: "Santeri Kangas <katso GitHub>"

                Label {
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeSmall
                    text: dev.developer
                }
            }
        }
    }
}
