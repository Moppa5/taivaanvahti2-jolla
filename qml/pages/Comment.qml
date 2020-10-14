import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page

    function setResponse(message, success) {
        // Show error code in label
        errmsg.enabled = true
        errmsg.text = message

        if (success) {
            errmsg.color = Theme.highlightColor
        } else {
            errmsg.color = Theme.errorColor
        }
    }

    function clearFields() {
        namefield.text = ""
        emailfield.text = ""
        commentarea.text = ""
    }

    function leaveComment() {

        if (namefield.text === "" || emailfield.text === ""
                || commentarea.text === "") {
            setResponse("Täytä kaikki kentät")
        } else if (emailfield.text.indexOf("@")===-1) {
            setResponse("Sähköpostiosoite ei ole kelvollinen")
        } else {
            var xhr = new XMLHttpRequest
            var query = "https://www.taivaanvahti.fi/api"
            xhr.open("POST",query)
            var xmlrequest = "<?xml version='1.0'?>
                        <Request>
                        <source>Sailfish Client</source>
                        <Action>ObservationAddCommentRequest</Action>
                        <comment>
                            <observation_id>" + taivas.havainnot.get(havainto).id + "</observation_id>"
                            + "<user_email>" + emailfield.text + "</user_email>"
                            + "<user_name>" + namefield.text + "</user_name>"
                            + "<comment_message>" + commentarea.text + "</comment_message>"
                        + "</comment></Request>"

            xhr.onreadystatechange = function() {

                if (xhr.readyState === XMLHttpRequest.DONE) {
                    // success
                    setResponse("Kommentti lähetettiin onnistuneesti", true)
                    clearFields()
                } else {
                    setResponse("Kommentointi ei onnistunut, tarkista tiedot tai ilmoita
                        virheestä ylläpitäjälle")
                }
            }
            xhr.setRequestHeader('Content-Type','text/xml')
            xhr.send(xmlrequest)
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: header.height + col.height + Theme.paddingLarge

        ScrollDecorator { flickable: flick }

        PullDownMenu {
            id: pulley

            MenuItem {
                id: commentnow
                text: "Lähetä"
                onClicked: leaveComment()
            }
        }

        PageHeader {
            id: header
            title: "Jätä kommentti"
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
                id: sovellus
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                maximumLineCount: 1024
                text: "Täytä kaikki kentät ja anna kelvollinen sähköpostiosoite."
                    + " Kommentti tulee näkyväksi, kun Taivaanvahdin ylläpito hyväksyy sen."
            }

            Label {
                id: errmsg
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.errorColor
                font.family: Theme.fontFamilyHeading
                enabled: false
                text: ""
            }

            Label {
                id: name
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Nimi"
            }

            TextField {
                id: namefield
                width: parent.width
                focus: false
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: "Koko nimesi"

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Label {
                id: email
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Sähköposti"
            }

            TextField {
                id: emailfield
                width: parent.width
                focus: false
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: "Sähköpostisi"

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Label {
                id: comment
                anchors.left: parent.left
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                text: "Kommentti"
            }

            TextArea {
                id: commentarea
                width: parent.width
                focus: false
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: "Kommenttisi tähän"

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
        }
    }
}

