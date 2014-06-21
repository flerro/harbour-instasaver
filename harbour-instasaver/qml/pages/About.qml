import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage

    PageHeader {
        id: header
        title: qsTrId("About Instasaver")
    }

    Column {
        anchors.top: header.bottom
        width: parent.width
        spacing: 36

        Label {
            id: lblDescription
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingLarge
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            font.family: Theme.fontFamily
            text: qsTrId("A minimal Instapaper client")
        }

        Rectangle {
            id: iconContainer
            height: 100
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: lblDescription.bottom
            anchors.topMargin: Theme.paddingLarge
            color: "transparent"
            Image {
                anchors.centerIn: parent
                source: "../../../icons/hicolor/86x86/apps/harbour-instasaver.png"
            }
        }

        Text {
             id: lblTagline
             width: parent.width - 2 * Theme.paddingLarge
             anchors.horizontalCenter: parent.horizontalCenter
             anchors.top: iconContainer.bottom
             anchors.margins: Theme.paddingLarge
             font.pixelSize: Theme.fontSizeMedium
             font.family: Theme.fontFamily
             color: Theme.primaryColor
             textFormat: Text.RichText
             text: "Read " + a("http://www.rolandfg.net/2014/06/22/instasaver-for-sailfish-os/","more info")
                      + " or " + a("https://github.com/flerro/harbour-instasaver","browse the source")
             onLinkActivated:  Qt.openUrlExternally(link)
         }

        Text {
             width: parent.width - 2 * Theme.paddingLarge
             anchors.horizontalCenter: parent.horizontalCenter
             anchors.top: lblTagline.bottom
             anchors.margins: Theme.paddingLarge
             font.pixelSize: Theme.fontSizeMedium
             font.family: Theme.fontFamily
             color: Theme.primaryColor
             textFormat: Text.RichText
             text: "Borrowed some ideas from:<ul>"
                   + "<li>" + a("https://github.com/steffen-foerster/sailfish-diigo", "sailfish-diigo") + " from Steffen Förster</li>"
                   + "<li>" + a("http://sailfishdev.tumblr.com/","Sailfish developer hints") + ", the blog</li>"+
                   "</ul>"
             onLinkActivated: Qt.openUrlExternally(link)
         }

    }

    function a(href, text) {
        return "<a style=\"text-decoration: none;color:"
                   + Theme.highlightColor + "\"  href=\"" + href + "\">" + text + "</a>"
    }
}
