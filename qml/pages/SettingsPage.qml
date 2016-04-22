import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/storage.js" as Storage
import "../js/selfoss.js" as Selfoss

Page {
    id: settingsPage

    property string site: Storage.readSetting('site')
    property string user: Storage.readSetting('user')
    property string passwd: Storage.readSetting('passwd')

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
                label: qsTr("Username (Optional)")
                placeholderText: label
            }

            TextField {
                id: passwdField
                width: parent.width - Theme.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                label: qsTr("Password (Optional)")
                placeholderText: passwd ? "Password (unchanged)" : label
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
