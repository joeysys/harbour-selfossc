import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/storage.js" as Storage
import "../js/selfoss.js" as Selfoss

Page {
    id: settingsPage

    property string site: Storage.readSetting('site')
    property string user: Storage.readSetting('user')
    property string passwd: Storage.readSetting('passwd')
    property string timezone: Storage.readSetting('timezone')
    property bool _showThumbs: Storage.readSetting('thumb')

    function saveSettings() {
        if (site !== serverField.text) {
            Storage.writeSetting('site', serverField.text);
            forceReload = true;
        }
        if (user !== userField.text) {
            Storage.writeSetting('user', userField.text);
            forceReload = true;
        }
        if (passwdField.text && passwd !== passwdField.text) {
            Storage.writeSetting('passwd', passwdField.text);
            forceReload = true;
        }
        if (timezone !== timezoneField.text) {
            Storage.writeSetting('timezone', timezoneField.text);
            forceReload = true;
        }
        if (thumbSwitch.checked !== _showThumbs) {
            exportFns.toggleThumbs(thumbSwitch.checked);
            Storage.writeSetting('thumb', thumbSwitch.checked);
        }
        Selfoss.readSettings();
    }

    SilicaFlickable {
        contentHeight: settingsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: settingsColumn
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Server")
            }

            TextField {
                id: serverField
                width: parent.width - Theme.paddingLarge
                text: site
                label: qsTr("Server url")
                placeholderText: "https://selfoss.example.com"
            }

            TextField {
                id: userField
                width: parent.width - Theme.paddingLarge
                text: user
                label: qsTr("Username (optional)")
                placeholderText: label
                inputMethodHints: Qt.ImhNoAutoUppercase
            }

            TextField {
                id: passwdField
                width: parent.width - Theme.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                label: qsTr("Password (optional)")
                placeholderText: passwd ? "Password (unchanged)" : label
            }

            TextField {
                id: timezoneField
                width: parent.width - Theme.paddingLarge
                label: qsTr("Server timezone (optional)")
                text: timezone
                placeholderText: label
                inputMethodHints: Qt.ImhDigitsOnly
            }

            SectionHeader {
                text: qsTr("Behaviour")
            }

            TextSwitch {
                id: thumbSwitch
                text: qsTr("Always show thumbnails")
                checked: _showThumbs
            }

            TextSwitch {
                text: qsTr("Enable debugging")
                checked: false
                onCheckedChanged: {
                    debug = checked;
                }
                visible: false
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            saveSettings();
        }
    }
}
