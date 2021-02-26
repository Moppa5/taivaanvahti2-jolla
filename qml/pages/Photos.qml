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
    property int currentIndex: 0
    property real portraitScale: 2.0
    property real landscapeScale: 1.75

    allowedOrientations: {
        if (taivas.landscape)
            return Orientation.Landscape
        else
            return Orientation.Portrait
    }

    PageHeader {
        id: header
        title: qsTr("Sovitettu koko")
        z: 1
    }

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        visible: running
        running: true
    }

    SlideshowView {
        id: ss
        anchors.fill: parent
        model: taivas.havainnot.get(taivas.havainto).photos

        delegate: Image {
            id: photo
            width: ss.width
            height: ss.height
            asynchronous: true
            cache: true
            fillMode: Image.PreserveAspectFit
            source: url
            smooth: false
            property bool scaled: true

            onStatusChanged: {
                if (status != Image.Ready)
                    return
                busy.running = false
                initialSize()
            }

            onScaledChanged: {
                if (scaled)
                     header.title = qsTr("Sovitettu koko")
                else
                     header.title = qsTr("Zoomattu koko")
            }

            function initialSize() {
                width = ss.width
                height = ss.height
                panner.enabled = true
                scaled = true
                drag.target = null
            }

            function toggleSize(check) {
                if ((width > ss.width || height > ss.height ||
                        width >= 1.5*sourceSize.width ||
                        height >= 1.5*sourceSize.height) && scaled !== true) {
                    width = ss.width
                    height = ss.height
                    scaled = true
                } else {

                    if (isPortrait) {
                        width = portraitScale*width
                        height = portraitScale*height
                    } else {
                        width = landscapeScale*width
                        height = landscapeScale*height
                    }
                    scaled = false
                }

                if (check) {
                    scaled = true
                    drag.target = null
                }
            }

            MouseArea {
                id: panner
                anchors.fill: parent
                enabled: true
                hoverEnabled: true
                drag.maximumX: width / 4
                drag.maximumY: height / 4

                onClicked: {
                    photo.toggleSize(false)

                    if (photo.scaled) {
                        drag.target = null
                    } else {
                        drag.target = photo
                    }
                }
            }
        }

        function resetSize() {
            currentItem.initialSize()
        }

        function reset() {
            currentItem.initialSize()
            currentItem.toggleSize(true)
        }
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Theme.paddingLarge
        font.pixelSize: Theme.fontSizeTiny
        color: Theme.highlightColor
        font.family: Theme.fontFamilyHeading
        text: {
            if (taivas.havainnot.get(taivas.havainto).thumbs && taivas.havainnot.get(taivas.havainto).thumbs.count)
                return taivas.copyright + taivas.userName
            else
                return ""
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            ss.resetSize()
            var temp = currentIndex
            ss.model = null

            ss.currentIndex = temp
        }

        if (status === PageStatus.Activating) {
            ss.model = taivas.havainnot.get(taivas.havainto).photos
            ss.currentIndex = currentIndex
        }
    }

}
