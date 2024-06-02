import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Page {
    id: headers
    ColumnLayout {
        spacing: 20
        anchors.centerIn: parent

        Label {
            text: "P-Corr"
            font.pixelSize: 32
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Step 2: Select the columns to evaluate"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Label {
                text: "Column 1: "
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: comboBox1
                width: 200
                model: py.headers
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Label {
                text: "Column 2: "
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: comboBox2
                width: 200
                model: py.headers
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 100
            Button {
                text: "Cancel"
                onClicked: stackView.pop(null)
                width: 200
                height: 40
                Layout.alignment: Qt.AlignLeft
            }

            Button {
                function initiateResult() {
                    py.initiate(1)
                    py.selectHeaders(comboBox1.currentText, comboBox2.currentText)
                    loading.close()
                    stackView.push("preview.qml")
                }
                text: "Proceed"
                onClicked: {
                    loading.open()
                    delay(1000, initiateResult)
                }
                width: 200
                height: 40
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
