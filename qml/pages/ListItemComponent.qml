import QtQuick 2.2
import Sailfish.Silica 1.0

import '../js/selfoss.js' as Selfoss

ListItem {
    id: listItem

    property bool _showThumb: false
    property var item

    width: parent.width
    contentHeight: itemContent.height + Theme.paddingMedium * 3

    menu: ContextMenu {
        MenuItem {
            text: starred === "0" ? qsTr("Star") : qsTr("Unstar")
            onClicked: {
                var stat = (starred === "0") ? 'starr' : 'unstarr';
                Selfoss.toggleStat(stat, id, function(resp) {
                    if (resp.success) {
                        starred = (starred === "0" ? "1" : "0")
                    }
                });
            }
        }
        MenuItem  {
            text: unread === "0" ? qsTr("Mark as unread") : qsTr("Mark as read")
            onClicked: {
                var stat = (unread === "0") ? 'unread' : 'read';
                Selfoss.toggleStat(stat, id, function(resp) {
                    if (resp.success) {
                        if (unread === "0") {
                            unread = "1";
                            statsUnread += 1;
                        } else {
                            unread = "0";
                            statsUnread -= 1;
                        }
                    }
                });
            }
        }
        MenuItem {
            text: qsTr("Open in Browser")
            onClicked: {
                Qt.openUrlExternally(link);
            }
        }
    }

    Item {
        id: itemContent
        width: parent.width - Theme.paddingMedium * 2
        height: childrenRect.height
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: itemIcon
            height: Theme.iconSizeSmall
            width: height
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingSmall
            source: Selfoss.site + '/favicons/' + icon
        }
        Image {
            id: thumbIcon
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingSmall
            anchors.right: parent.right
            height: Theme.iconSizeSmall
            width: height
            source: "image://theme/icon-m-image"
            visible: thumbnail && !_showThumb
        }
        Label {
            id: authorLabel
            anchors.left: itemIcon.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingSmall / 2
            width: parent.width - itemIcon.width - thumbIcon.width - Theme.paddingMedium
            height: Theme.fontSizeSmall
            text: author
            color: unread === "0" ? Theme.secondaryColor : Theme.primaryColor
            font.bold: true
            font.pixelSize: Theme.fontSizeSmall
            elide: TruncationMode.Elide
        }
        Label {
            id: titleLabel
            anchors.top: authorLabel.bottom
            anchors.left: parent.left
            anchors.topMargin: Theme.paddingMedium
            width: parent.width
            text: title
            wrapMode: Text.WordWrap
            textFormat: Text.StyledText
            font.pixelSize: Theme.fontSizeSmall
            color: unread === "0" ? Theme.secondaryColor : Theme.primaryColor
            linkColor: Theme.secondaryColor
            onLinkActivated: {
                // TODO confirm dialog
                Qt.openUrlExternally(link);
            }
            Component.onCompleted: {
                if (!title) titleLabel.height = 0;
            }
        }
        Label {
            id: sourceLabel
            anchors.top: titleLabel.bottom
            anchors.left: parent.left
            height: Theme.fontSizeSmall
            text: qsTr("via ") + sourcetitle
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }
        Label {
            id: timeLabel
            anchors.top: titleLabel.bottom
            anchors.right: parent.right
            height: Theme.fontSizeSmall
            text: datetime
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }

        Loader {
            id: thumbLoader
            anchors {
                top: timeLabel.bottom
                topMargin: Theme.paddingMedium
            }
            height: childrenRect.height
            width: parent.width
        }

    }

    onClicked: {
        pageStack.push('DetailsPage.qml', {'item': currentModel.get(index)})
    }

    //Component.onCompleted: setThumbSource()

    on_ShowThumbChanged: setThumbSource()

    function setThumbSource() {
        if (thumbnail && _showThumb) {
            thumbLoader.setSource('ThumbnailComponent.qml', {
                'thumbnail': thumbnail,
                'site': Selfoss.site
            });
        } else {
            thumbLoader.source = '';
        }
    }
}
