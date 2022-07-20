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
import QtQml 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1
import FishUI 1.0 as FishUI
import Pisces.TextEditor 1.0

Item {
    id: control

    property var tabName: document.fileName + (document.modified ? " *" : "")
    property var documentModified: document.modified

    property alias fileUrl: document.fileUrl
    property alias fileName: document.fileName
    property bool newFile: false
    property bool showLineNumbers: true
    property int characterCount: body.text.length

    height: ListView.view ? ListView.view.height : 0
    width: ListView.view ? ListView.view.width : 0

    DocumentHandler {
        id: document
        document: body.textDocument
        cursorPosition: body.cursorPosition
        selectionStart: body.selectionStart
        selectionEnd: body.selectionEnd
        backgroundColor: FishUI.Theme.backgroundColor
        enableSyntaxHighlighting: true
        theme: FishUI.Theme.darkMode ? "Breeze Dark" : "Breeze Light"

        onSearchFound: {
            body.select(start, end)
        }

        onFileSaved: {
            root.showPassiveNotification(qsTr("Saved successfully"), 3000)
        }
    }

    // Global Menu
    MenuBar {
        id: appMenu

        Menu {
            title: qsTr("File")

            MenuItem {
                text: qsTr("New")
                onTriggered: root.addTab()
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Open...")
                onTriggered: root.open()
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Save")
                onTriggered: control.save()
                enabled: document.modified
            }
            MenuItem {
                text: qsTr("Save as...")
                onTriggered: control.saveas()
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Quit")
                onTriggered: {
                    if (root.closeAll())
                        Qt.quit()
                }
            }
        }

        Menu {
            title: qsTr("Edit")

            MenuItem {
                text: qsTr("Select All")
                onTriggered: body.selectAll()
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Cut")
                onTriggered: body.cut()
                enabled: !(body.selectedText === "")
            }
            MenuItem {
                text: qsTr("Copy")
                onTriggered: body.copy()
                enabled: !(body.selectedText === "")
            }
            MenuItem {
                text: qsTr("Paste")
                onTriggered: body.paste()
                enabled: body.canPaste
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Undo")
                onTriggered: body.undo()
                enabled: body.canUndo
            }
            MenuItem {
                text: qsTr("Redo")
                onTriggered: body.redo()
                enabled: body.canRedo
            }
        }

        Menu {
            title: qsTr("Help")

            MenuItem {
                text: qsTr("About")
                onTriggered: _aboutDialog.show()
            }
        }
    }

    FishUI.AboutDialog {
        id: _aboutDialog
        name: qsTr("Text Editor")
        description: qsTr("A simple text editor designed for Piscesys.")
        iconSource: "image://icontheme/pisces-texteditor"
    }

    ScrollView {
        id: _scrollView
        anchors.fill: parent

        Keys.enabled: true
        Keys.forwardTo: body

        contentWidth: availableWidth

        Flickable {
            id: _flickable

            FishUI.WheelHandler {
                id: wheelHandler
                target: _flickable
            }

            boundsBehavior: Flickable.StopAtBounds
            boundsMovement: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

            TextArea.flickable: TextArea {
                id: body
                text: document.text
                selectByKeyboard: true
                selectByMouse: true
                persistentSelection: true
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.WrapAnywhere

                activeFocusOnPress: true
                activeFocusOnTab: true

                leftPadding: _linesCounter.width + FishUI.Units.smallSpacing
                padding: FishUI.Units.smallSpacing
                color: FishUI.Theme.textColor

                font.family: "Noto Mono"

                background: Rectangle {
                    color: FishUI.Theme.backgroundColor
                }

                Keys.enabled: true
                Keys.onPressed: {
                    if ((event.key === Qt.Key_S)
                            && (event.modifiers & Qt.ControlModifier)
                            && !(event.modifiers & Qt.ShiftModifier)) {
                        control.save()
                        event.accepted = true
                    }
                    if ((event.key === Qt.Key_S)
                            && (event.modifiers & Qt.ControlModifier)
                            && (event.modifiers & Qt.ShiftModifier)) {
                        control.saveas()
                        event.accepted = true
                    }
                    if (((event.key === Qt.Key_T) || (event.key === Qt.Key_N))
                            && (event.modifiers & Qt.ControlModifier)) {
                        root.addTab()
                        event.accepted = true
                    }
                    if ((event.key === Qt.Key_W)
                            && (event.modifiers & Qt.ControlModifier)) {
                        root.closeCurrentTab()
                        event.accepted = true
                    }
                    if((event.key === Qt.Key_O)
                            && (event.modifiers & Qt.ControlModifier)) {
                        root.open()
                        event.accepted = true
                    }
                    if ((event.key === Qt.Key_Tab) && (event.modifiers & Qt.ControlModifier)) {
                        root.toggleTab(1)
                        event.accepted = true
                    }
                    if ((event.key === Qt.Key_Backtab) && (event.modifiers & Qt.ControlModifier)) {
                        root.toggleTab(-1)
                        event.accepted = true
                    }
                }

                Loader {
                    id: _linesCounter
                    active: control.showLineNumbers && !document.isRich
                    asynchronous: true

                    anchors.left: body.left
                    anchors.top: body.top
                    anchors.topMargin: body.topPadding + body.textMargin

                    height: _flickable.contentHeight
                    width: active ? 32 : 0

                    sourceComponent: _linesCounterComponent
                }
            }
        }
    }

    Component {
        id: _linesCounterComponent

        ListView {
            id: _linesCounterList
            model: document.lineCount
            clip: true

            Binding on currentIndex {
                value: document.currentLineIndex
                restoreMode: Binding.RestoreBindingOrValue
            }

            Timer {
                id: _lineIndexTimer
                interval: 250
                onTriggered: _linesCounterList.currentIndex = document.currentLineIndex
            }

            Connections {
                target: document

                function onLineCountChanged() {
                    _lineIndexTimer.restart()
                }
            }

            orientation: ListView.Vertical
            interactive: false
            snapMode: ListView.NoSnap

            boundsBehavior: Flickable.StopAtBounds
            boundsMovement :Flickable.StopAtBounds

            preferredHighlightBegin: 0
            preferredHighlightEnd: width

            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 0
            highlightFollowsCurrentItem: false
            highlightResizeDuration: 0
            highlightMoveVelocity: -1
            highlightResizeVelocity: -1

            maximumFlickVelocity: 0

            delegate: Row {
                id: _delegate

                readonly property int line : index
                // property bool foldable : control.document.isFoldable(line)

                width:  ListView.view.width
                height: document.lineHeight(line)

                readonly property bool isCurrentItem: ListView.isCurrentItem

//                Connections {
//                    target: control.body

//                    function onContentHeightChanged() {
//                        if (_delegate.isCurrentItem) {
//                            console.log("Updating line height")
//                            _delegate.height = control.document.lineHeight(_delegate.line)
//                            _delegate.foldable = control.document.isFoldable(_delegate.line)
//                        }
//                    }
//                }

                Label {
                    width: 32
                    height: parent.height
                    opacity: isCurrentItem ? 1 : 0.7
                    color: isCurrentItem ? FishUI.Theme.highlightColor
                                         : FishUI.Theme.textColor
                    font.pointSize: body.font.pointSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Monospace"
                    text: index + 1
                }
            }
        }
    }

    function forceActiveFocus() {
        body.forceActiveFocus()
    }

    function goToLine(line) {
        if (line > 0 && line <= body.lineCount) {
            body.cursorPosition = document.goToLine(line - 1)
            body.forceActiveFocus()
        }
    }

    FileSelectDialog {
        id: fileSaveAsDialog
        title: qsTr("Save as...")
        displayText: qsTr("Save as...")
        
        onOkBtnClicked: {
            document.fileUrl = fileUrl
            newFile = false
            save()
        }
    }

    function saveas() {
        var fUrl = ""
        if(newFile)
            fUrl = StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]+"/Untitled.txt"
        else
            fUrl = document.fileUrl.toString()
        fileSaveAsDialog.fileUrl = fUrl.substr(7)
        fileSaveAsDialog.visible = true
    }

    function save() {
        if(newFile)
            saveas()
        else if(documentModified)
            document.saveAs(document.fileUrl) 
    }
}
