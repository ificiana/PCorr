import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Page {
    id: preview
    GridLayout {
        id: grid
        columns: 4
        anchors.centerIn: parent

        Label {
            text: "P-Corr"
            font.pixelSize: 32
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }

        Label {
            text: "Step 3: Pre-processing and Preview"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }

        Label {
            text: "Column 1: " + py.selectedHeaders[0]
            font.pixelSize: 16
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }

        Label {
            text: "Column 2: " + py.selectedHeaders[1]
            font.pixelSize: 16
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }

        Frame {
            implicitWidth: 225
            implicitHeight: 180
            Layout.columnSpan: 2

            TableView {
                id: tableView
                anchors.fill: parent
                model: pyModel
                clip: true

                delegate: Frame {
                    implicitWidth: 100
                    implicitHeight: 50
                    Label {
                        text: display
                        anchors.centerIn: parent
                    }
                }
            }
        }

        ColumnLayout {
            Layout.columnSpan: 2
            Label {
                text: "MAD Conformity"
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "Column 2:    " + py.madValue
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }

        RowLayout {
            spacing: 75
            Layout.columnSpan: 4
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: "Back"
                onClicked: stackView.pop()
                width: 200
                height: 40
                Layout.alignment: Qt.AlignLeft
            }

            Button {
                text: "Home"
                onClicked: stackView.pop(null)
                width: 200
                height: 40
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Proceed"
                onClicked: {
                    py.calculate_result(0)
                    stackView.push("result.qml")
                }
                width: 200
                height: 40
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
