import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Page {
    id: results
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
            text: "Results"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }

        Label {
            text: py.result
            font.pixelSize: 16
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
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
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
