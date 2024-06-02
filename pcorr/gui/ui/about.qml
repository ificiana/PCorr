import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Page {
    id: about
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

        Label {
            text: `P-Corr is a scientific application designed to process data files, calculate correlation coefficients, and perform power law validation between two columns of data. This tool is particularly useful for researchers and scientists who need to analyze and interpret relationships within their datasets. 

Authored by Arkaprabha Sinha Roy with generous help and feedback from Farhan Jawaid, Manan Roy Choudhury, and Raghunath Sinha; Under the guidance of Dr. Krishan Kundu.

Department of Computer Science & Engineering
Govt. College of Engineering and Textile Technology, Serampore`
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 480
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            text: "Back"
            onClicked: stackView.pop()
            width: 200
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}