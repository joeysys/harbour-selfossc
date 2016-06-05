import QtQuick 2.2
import Sailfish.Silica 1.0

CoverBackground {
    transparent: true

    CoverPlaceholder {
        id: coverHolder
        icon.source: "../img/logo.png"
    }

    Label {
        id: totalNum
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        text: statsUnread + ''
        font.pixelSize: Theme.fontSizeHuge
    }

    Label {
        id: totalLabel
        anchors.bottom: totalNum.bottom
        anchors.bottomMargin: Theme.paddingSmall
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        horizontalAlignment: Text.AlignRight
        text: qsTr("Unread")
    }

    Column {
        id: column
        anchors.top: totalNum.bottom
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        width: parent.width - Theme.paddingMedium * 2
        Repeater {
            model: tagsModel
            delegate: Item {
                width: column.width
                height: childrenRect.height
                opacity: index > 2 ? ( 6 - index ) * .25 : 1.0
                Label {
                    id: tagLabel
                    anchors.left: parent.left
                    text: tag
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                }
                Label {
                    id: tagNum
                    anchors.right: parent.right
                    text: unread
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                }
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                updateStats();
            }
        }
    }
}


