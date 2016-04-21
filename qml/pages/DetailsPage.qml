import QtQuick 2.0
import Sailfish.Silica 1.0

import '../js/selfoss.js' as Selfoss

Page {
    id: page

    property var item

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: pageHeader.height + column.height + Theme.paddingLarge

        PullDownMenu {
            // TODO
            //MenuItem {
            //    text: qsTr("Share")
            //}
            MenuItem {
                text: item.unread === "0" ? qsTr("Mark as unread") : qsTr("Mark as read")
                onClicked: {
                    var stat = (item.unread === "0") ? 'unread' : 'read';
                    Selfoss.toggleStat(stat, item.id, function(resp) {
                        if (resp.success) {
                            if (item.unread === "0") {
                                item.unread = "1";
                                statsUnread += 1;
                            } else {
                                item.unread = "0";
                                statsUnread -= 1;
                            }
                        }
                    });
                }
            }
            MenuItem {
                text: item.starred === "0" ? qsTr("Star") : qsTr("Unstar")
                onClicked: {
                    var stat = (item.starred === "0") ? 'starr' : 'unstarr';
                    Selfoss.toggleStat(stat, item.id, function(resp) {
                        if (resp.success) item.starred = (item.starred === "0" ? "1" : "0")
                    });
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Open in Browser")
                onClicked: {
                    Qt.openUrlExternally(item.link);
                }
            }
        }

        PageHeader {
            id: pageHeader
            title: item.tags
        }

        Item {
            id: column
            height: childrenRect.height
            width: parent.width - Theme.paddingMedium * 2
            anchors {
                top: pageHeader.bottom
                left: parent.left
                leftMargin: Theme.paddingMedium
            }

            Item {
                id: authorBar
                height: childrenRect.height
                width: parent.width
                anchors.top: parent.top
                Image {
                    id: itemIcon
                    height: Theme.iconSizeSmall
                    width: height
                    anchors {
                        top: parent.top
                        left: parent.left
                        topMargin: Theme.paddingSmall
                    }
                    source: Selfoss.site + '/favicons/' + item.icon
                }

                Label {
                    id: authorLabel
                    width: parent.width - itemIcon.width - Theme.paddingSmall
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingSmall / 2
                        left: itemIcon.right
                        leftMargin: Theme.paddingSmall
                    }
                    text: item.author
                    elide: TruncationMode.Elide
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryHighlightColor
                }
            }

            Label {
                id: titleLabel
                anchors {
                    top: authorBar.bottom
                    left: parent.left
                    topMargin: Theme.paddingSmall
                }
                width: parent.width
                text: item.title
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                linkColor: Theme.secondaryColor
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
                Component.onCompleted: {
                    if (!item.title) titleLabel.height = 0;
                }
            }

            Separator {
                id: separator
                width: parent.width
                color: Theme.secondaryColor
                anchors {
                    top: titleLabel.bottom
                    left: parent.left
                    topMargin: Theme.paddingSmall
                }
                visible: item.content
            }

            // TODO image size
            Label {
                id: contentLabel
                anchors {
                    top: separator.bottom
                    left: parent.left
                    topMargin: Theme.paddingLarge
                }
                width: parent.width
                text: Selfoss.decodeCharCode(item.content)
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                font.pixelSize: Theme.fontSizeSmall
                linkColor: Theme.secondaryColor
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
                Component.onCompleted: {
                    if (!item.content) {
                        contentLabel.height = 0;
                        contentLabel.anchors.topMargin = 0;
                    }
                }
            }

            Item {
                id: infoBar
                width: parent.width
                height: childrenRect.height
                anchors {
                    top: contentLabel.bottom
                    left: parent.left
                }

                Label {
                    id: sourceLabel
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("via ") + item.sourcetitle
                }

                Label {
                    id: timeLabel
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: item.datetime
                }
            }

            Item {
                id: thumbWrapper
                width: parent.width
                height: childrenRect.height
                anchors {
                    top: infoBar.bottom
                    topMargin: Theme.paddingLarge
                }

                Image {
                    id: thumbImage
                    width: sourceSize.width < parent.width ? sourceSize.width : parent.width
                    height: width * sourceSize.height / sourceSize.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: item.thumbnail ? Selfoss.site + '/thumbnails/' + item.thumbnail : ''
                    fillMode: Image.Pad
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log(thumbImage.sourceSize)
                        }
                    }
                }

                BusyIndicator {
                    anchors.top: thumbImage.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: item.thumbnail !== '' && thumbImage.status === Image.Loading
                    size: BusyIndicatorSize.Large
                }
            }
        }
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached('WebViewPage.qml', {'initUrl': item.link})
        }
    }

    Component.onCompleted: {
        if (item.unread === "1") {
            Selfoss.toggleStat('read', item.id, function(resp) {
                if (resp.success) {
                    item.unread = "0";
                    statsUnread -= 1;
                }
            });
        }
    }
}

