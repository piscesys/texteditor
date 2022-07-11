/*
 * Copyright (C) 2022 Piscesys Team.
 *
 * Author:     Reion Wong <reionwong@gmail.com>
 *             TsukuyomiToki <huangzimocp@126.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import FishUI 1.0 as FishUI

FishUI.Window {
    id: control

    property var contentWidth: _mainLayout.implicitWidth + FishUI.Units.largeSpacing * 2
    property var contentHeight: _mainLayout.implicitHeight + header.height + FishUI.Units.largeSpacing * 2

    flags: Qt.WindowStaysOnTopHint | Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.WindowModal
    visible: false

    width: contentWidth
    height: contentHeight
    minimumWidth: contentWidth
    minimumHeight: contentHeight
    maximumWidth: contentWidth
    maximumHeight: contentHeight
    minimizeButtonVisible: false

    background.color: FishUI.Theme.secondBackgroundColor

    signal okBtnClicked

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        spacing: FishUI.Units.largeSpacing
        anchors.margins: FishUI.Units.largeSpacing

        Label {
            text: qsTr("Document unsaved, are you sure you want to close it?")
        }

        RowLayout {
            spacing: FishUI.Units.largeSpacing

            Button {
                text: qsTr("Cancel")
                Layout.fillWidth: true
                onClicked: control.visible = false
            }

            Button {
                text: qsTr("OK")
                Layout.fillWidth: true
                flat: true
                onClicked: {
                    control.visible = false
                    control.okBtnClicked()
                }
            }
        }
    }
}
