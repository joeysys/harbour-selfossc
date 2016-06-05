import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property string checkedType: type
    property bool needReload: false

    SilicaFlickable {
        width: parent.width
        anchors.fill: parent

        DialogHeader { id: dialogHeader }

        Column {
            id: dialogColumn
            width: parent.width
            anchors.top: dialogHeader.bottom

            SectionHeader {
                text: qsTr("Type")
            }

            TextSwitch {
                id: newestSwitch
                text: qsTr("Newest")
                checked: checkedType === 'newest'
                automaticCheck: false
                onClicked: {
                    if (checkedType !== 'newest') {
                        checkedType = 'newest';
                    }
                }
            }

            TextSwitch {
                id: unreadSwitch
                text: qsTr("Unread")
                checked: checkedType === 'unread'
                automaticCheck: false
                onClicked: {
                    if (checkedType !== 'unread') {
                        checkedType = 'unread';
                    }
                }
            }

            TextSwitch {
                id: starredSwitch
                text: qsTr("Starred")
                checked: checkedType === 'starred'
                automaticCheck: false
                onClicked: {
                    if (checkedType !== 'starred') {
                        checkedType = 'starred';
                    }
                }
            }

            SectionHeader {
                text: qsTr("Filter")
            }

            ComboBox {
                id: tagsCombo
                width: parent.width
                label: qsTr("Tags")
                currentIndex: tagIndex
                menu: ContextMenu {
                    MenuItem { text: qsTr("All") }
                    Repeater {
                        id: tagsRepeater
                        model: tagList
                        delegate: MenuItem {
                            text: modelData.tag
                        }
                    }
                }
                onValueChanged: {
                    if (debug) console.log('tag changed', currentIndex, value)
                    // FIXME
                    // This will reset sourceCombs* index to 0
                    // How to set these to sourceIndex?
                    sourceModel.clear();
                    for (var i=0; i<sources.length; i++) {
                        if (currentIndex === 0 || sources[i].tags.split(',').indexOf(value) >= 0) {
                            sourceModel.append(sources[i]);
                        }
                    }
                    if (debug) console.log('model count', sourceModel.count)
                    if (sourceModel.count > 6) {
                        sourceCombo1.currentIndex = 0;
                    } else {
                        sourceCombo2.currentIndex = 0;
                    }
                }
            }

            // Workaround to show dynamic ContextMenu of ComboBox,
            // ComboBox will set its menu.height to 0 when MenuItems > 6.
            ComboBox {
                id: sourceCombo1
                width: parent.width
                label: qsTr("Source")
                currentIndex: sourceIndex
                menu: ContextMenu {
                    MenuItem { text: qsTr("All") }
                    Repeater {
                        id: srcsRepeater1
                        model: sourceModel
                        delegate: MenuItem {
                            text: title
                        }
                    }
                }
                visible: sourceModel.count > 6
            }
            ComboBox {
                id: sourceCombo2
                width: parent.width
                label: qsTr("Source")
                currentIndex: sourceIndex
                menu: ContextMenu {
                    MenuItem { text: qsTr("All") }
                    Repeater {
                        id: srcsRepeater2
                        model: sourceModel
                        delegate: MenuItem {
                            text: title
                        }
                    }
                }
                visible: sourceModel.count <= 6
            }
        }
    }

    onAccepted: {
        if (sourceModel.count > 6) {
            if (debug) console.log('src index 1:', sourceCombo1.currentIndex, sourceIndex);
            if (sourceCombo1.currentIndex !== sourceIndex) {
                sourceIndex = sourceCombo1.currentIndex;
                needReload = true;
                if (debug) console.log('Change src index 1 to:', sourceIndex);
            }
            if (sourceCombo1.currentIndex > 0) {
                subtitle = sourceCombo1.value;
            } else {
                subtitle = tagsCombo.value;
            }
        } else {
            if (debug) console.log('src index 2:', sourceCombo2.currentIndex, sourceIndex);
            if (sourceCombo2.currentIndex !== sourceIndex) {
                sourceIndex = sourceCombo2.currentIndex;
                needReload = true;
                if (debug) console.log('Change src index 2 to:', sourceIndex);
            }
            if (sourceCombo2.currentIndex > 0) {
                subtitle = sourceCombo2.value;
            } else {
                subtitle = tagsCombo.value;
            }
        }
        if (debug) console.log('Tag index:', tagsCombo.currentIndex, tagIndex)
        if (tagsCombo.currentIndex !== tagIndex) {
            tagIndex = tagsCombo.currentIndex;
            needReload = true;
            if (debug) console.log('Change tag index to:', tagIndex);
        }

        if (debug) console.log('Accept:', checkedType, tagIndex, sourceIndex);
        if (type !== checkedType) {
            type = checkedType;
            if (debug) console.log('Change type:', type);
            switch (type) {
                case 'newest':
                    currentModel = newestModel;
                    break;
                case 'unread':
                    currentModel = unreadModel;
                    break;
                case 'starred':
                    currentModel = starredModel;
                    break;
            }
            if (currentModel.count === 0) {
                needReload = true;
            }
        }
        if (debug) console.log('need reload:', needReload);
        if (needReload) {
            pageStack.previousPage().reloadItems();
        }
        pageStack.popAttached();
    }
}

