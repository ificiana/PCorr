import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 600
    height: 450
    title: "P-Corr"

    font.family: "Segoe Print"
    Material.theme: Material.Dark

    minimumWidth: 600
    minimumHeight: 450
    maximumWidth: 600
    maximumHeight: 450

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: landing
    }

    Page {
        id: landing
        ColumnLayout {
            anchors.centerIn: parent
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 40

            Label {
                text: "P-Corr"
                font.pixelSize: 32
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                id: uploadButton
                text: "Upload File"
                onClicked: {
                    fileDialog.open()
                }
                width: 200
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter

                FileDialog {
                    id: fileDialog
                    title: "Choose a file to upload"
                    options: FileDialog.ReadOnly
                    nameFilters: [ "CSV or Excel files (*.csv *.xls *.xlsx)" ]
                    onAccepted: {
                        var fileUrl = fileDialog.selectedFile
                        if (!fileUrl) return
                        processingDialog.fileUrl = fileUrl
                        processingDialog.open()
                    }
                }
            }

            Label {
                text: `Instructions:

    1. Click the 'Upload File' button to upload your data file. (Excel / CSV)
    2. Select the columns to evaluate.
    3. Preview the data.
    4. View the results on the next screen.`
                wrapMode: Text.WordWrap
                width: parent.width * 0.8
            }

            Button {
                text: "About"
                onClicked: stackView.push("about.qml")
                width: 200
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    MessageDialog{
        property string fileUrl
        id: processingDialog
        modality: Qt.ApplicationModal
        title: "Start Processing?"
        informativeText: "Selected file: " + fileUrl
        buttons: MessageDialog.Yes | MessageDialog.No

        function processFile () {
            py.initiate(0)
            py.processFile(fileUrl)
            loading.close()
            stackView.push("headers.qml")
        }

        onButtonClicked: function (button, role) {
            switch (button) {
            case MessageDialog.Yes:
                loading.open()
                delay(1000, processFile)
                break;
            case MessageDialog.No:
                stackView.pop(null)
                break;
            }
        }
    }

    Popup {
        id: loading
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.NoAutoClose
        modal: true

        BusyIndicator {
            running: true
        }
    }

    Timer {
        id: timer
    }
    function delay(delayTime,cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }
}
