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

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FishUI 1.0 as FishUI
import Pisces.TextEditor 1.0

FishUI.Window {
    id: root
    width: 640
    height: 480
    minimumWidth: 300
    minimumHeight: 300
    visible: true
    title: qsTr("Text Editor")

    FileHelper {
        id: fileHelper

        onNewPath: {
            _tabView.addTab(textEditorComponent, { fileUrl: path })
        }
    }

    ExitPromptDialog {
        id: exitPrompt

        property var index: -1

        onOkBtnClicked: {
            if(index != -1)
                closeTab(index)
            else
                Qt.quit()
        }
    }

    headerItem: Item {
        Rectangle {
            anchors.fill: parent
            color: FishUI.Theme.backgroundColor
        }

        FishUI.TabBar {
            id: _tabbar
            anchors.fill: parent
            anchors.margins: FishUI.Units.smallSpacing / 2
            anchors.rightMargin: FishUI.Units.largeSpacing * 4

            model: _tabView.count
            currentIndex : _tabView.currentIndex

            onNewTabClicked: {
                addTab()
            }

            delegate: FishUI.TabButton {
                id: _tabBtn
                text: _tabView.contentModel.get(index).tabName
                implicitHeight: _tabbar.height
                implicitWidth: Math.min(_tabbar.width / _tabbar.count,
                                        _tabBtn.contentWidth)

                ToolTip.delay: 1000
                ToolTip.timeout: 5000

                checked: _tabView.currentIndex === index

                ToolTip.visible: hovered
                ToolTip.text: _tabView.contentModel.get(index).fileUrl

                onClicked: {
                    _tabView.currentIndex = index
                    _tabView.currentItem.forceActiveFocus()
                }

                onCloseClicked: {
                    closeProtection(index)
                }
            }
        }
    }

    DropArea {
        id: _dropArea
        anchors.fill: parent

        onDropped: {
            if (drop.hasUrls) {
                for (var i = 0; i < drop.urls.length; ++i) {
                    fileHelper.addPath(drop.urls[i])
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        FishUI.TabView {
            id: _tabView
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            id: _bottomItem
            z: 999
            Layout.fillWidth: true
            Layout.preferredHeight: 20 + FishUI.Units.smallSpacing

            Rectangle {
                anchors.fill: parent
                color: FishUI.Theme.backgroundColor
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: FishUI.Units.smallSpacing
                anchors.rightMargin: FishUI.Units.smallSpacing
                anchors.bottomMargin: FishUI.Units.smallSpacing

                Label {
                    text: _tabView.currentItem ? qsTr("Characters %1").arg(_tabView.currentItem.characterCount)
                                               : ""
                }
            }
        }
    }

    function addPath(path) {
        _tabView.addTab(textEditorComponent, { fileUrl: path })
    }

    function addTab() {
        _tabView.addTab(textEditorComponent, {})
        _tabView.currentItem.forceActiveFocus()
    }

    onClosing: {
        for (var i = 0; i < _tabView.contentModel.count; i++) {
            var obj = _tabView.contentModel.get(i)
            if (obj.documentModified) {
                exitPrompt.index = i
                exitPrompt.visible = true
                close.accepted = false
                return
            }
        }
        close.accepted = true
    }

    function closeProtection(index) {
        var obj = _tabView.contentModel.get(index)
        if (obj.documentModified) {
            exitPrompt.index = index
            exitPrompt.visible = true
            return
        }

        closeTab(index)
    }

    function closeTab(index) {
        _tabView.closeTab(index)

        if (_tabView.contentModel.count === 0)
            Qt.quit()

        _tabView.currentItem.forceActiveFocus()
    }

    function closeCurrentTab() {
        closeProtection(_tabView.currentIndex)
    }

    function toggleTab(arg) { //arg = -1 (forward) or 1 (backward)
        var nextIndex = _tabView.currentIndex + arg
        if (nextIndex > _tabView.contentModel.count - 1)
            nextIndex = 0
        if (nextIndex < 0)
            nextIndex = _tabView.contentModel.count - 1

        _tabView.currentIndex = nextIndex
        _tabView.currentItem.forceActiveFocus()
    }

    Component {
        id: textEditorComponent

        TextEditor {
            fileUrl: ""
            fileName: "Untitled"
            newFile: true
        }
    }

    Component.onCompleted: {
        // addTab()
    }
}
