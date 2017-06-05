import QtQuick 2.2
import Sailfish.Silica 1.0

import '../js/selfoss.js' as Selfoss

Page {
    id: page

    property var item
    property int currentIdx: -1

    property bool isRead: false
    property bool isStarred: false

    function updateTagUnread(item, delta) {
        if (item && item.tags && typeof(delta) === 'number') {
            var tags = item.tags.split(',');
            var tag, tmpItem;
            for (var j in tags) {
                tag = tags[j];
                for (var i=0; i < tagsModel.count; i++) {
                    tmpItem = tagsModel.get(i);
                    if (tmpItem.tag === tag) {
                        tagsModel.set(i, {
                            "unread": (parseInt(tmpItem.unread) + delta) + ''
                        });
                        break;
                    }
                }
            }
        }
    }

    function toggleRead(stat, itemId) {
        Selfoss.toggleStat(stat, itemId, function(resp) {
            if (resp.success) {
                var listItem = currentIdx >= 0 ? currentModel.get(currentIdx) : null;
                if (stat === "unread") {
                    item.unread = "1";
                    isRead = false;
                    statsUnread += 1;
                    updateTagUnread(item, 1);
                    if (listItem) listItem.unread = "1";
                } else {
                    item.unread = "0";
                    isRead = true;
                    if (statsUnread > 0) statsUnread -= 1;
                    updateTagUnread(item, -1);
                    if (listItem) listItem.unread = "0";
                }
            }
        });
    }

    function toggleStarr(stat, itemId) {
        Selfoss.toggleStat(stat, item.id, function(resp) {
            if (resp.success) {
                var listItem = currentIdx >= 0 ? currentModel.get(currentIdx) : null;
                if (stat === 'starr') {
                    item.starred = "1";
                    if (listItem) listItem.starred = "1";
                    isStarred = true;
                } else {
                    item.starred = "0";
                    if (listItem) listItem.starred = "0";
                    isStarred = false;
                }
            }
        });
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: pageHeader.height + column.height + Theme.paddingLarge

        PullDownMenu {
            // TODO
            //MenuItem {
            //    text: qsTr("Share")
            //}
            MenuItem {
                text: isRead ? qsTr("Mark as unread") : qsTr("Mark as read")
                onClicked: {
                    var stat = isRead ? 'unread' : 'read';
                    toggleRead(stat, item.id);
                }
            }
            MenuItem {
                text: isStarred ? qsTr("Unstar") : qsTr("Star")
                onClicked: {
                    var stat = isStarred ? 'unstarr' : 'starr';
                    toggleStarr(stat, item.id)
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
            title: (isStarred ? '★ ' : '☆ ') + item.tags
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

            RescalingRichText {
                id: contentLabel
                anchors {
                    top: separator.bottom
                    left: parent.left
                    topMargin: Theme.paddingMedium
                }
                width: parent.width
                text: Selfoss.decodeCharCode(item.content)
                fontSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                noScaling: settings.noScaling
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
                Component.onCompleted: {
                    if (!item.content) {
                        contentLabel.height = 0;
                        contentLabel.anchors.topMargin = -Theme.paddingMedium;
                    }
                }
            }

            Item {
                id: infoBar
                width: parent.width
                height: childrenRect.height
                anchors {
                    top: contentLabel.bottom
                    topMargin: Theme.paddingSmall
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
                    text: Selfoss.changeZone(item.datetime)
                }
            }

            Loader {
                id: thumbLoader
                anchors {
                    top: infoBar.bottom
                    topMargin: Theme.paddingLarge
                }
                width: parent.width
                height: childrenRect.height
            }
        }
        VerticalScrollDecorator {}
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached('WebViewPage.qml', {'item': item})
        }
    }

    Component.onCompleted: {
        isRead = item.unread === "0"
        isStarred = item.starred === "1"
        if (!settings.debug && !isRead) {
            toggleRead('read', item.id)
        }
        if (item.thumbnail) {
            thumbLoader.setSource('ThumbnailComponent.qml', {
                'thumbnail': item.thumbnail,
                'site': Selfoss.site
            });
        }
    }
}

