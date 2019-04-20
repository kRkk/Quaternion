import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Attachment {
    property var sourceSize
    property url source
    property var maxHeight
    property bool autoload

    onDownloadedChanged: if (downloaded) transferProgress.height = 0

    Image {
        readonly property real imageMaxHeight: maxHeight - buttons.height

        id: imageContent
        width: parent.width
        height: sourceSize.height *
                Math.min(imageMaxHeight / sourceSize.height * 0.9,
                         Math.min(width / sourceSize.width, 1))
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignLeft

        source: parent.source
        sourceSize: parent.sourceSize

//        Behavior on height { NumberAnimation {
//            duration: settings.fast_animations_duration_ms
//            easing.type: Easing.OutQuad
//        }}

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onContainsMouseChanged:
                controller.showStatusMessage(containsMouse
                                             ? room.fileSource(eventId) : "")
            onClicked: openExternally()
        }

        Component.onCompleted:
            if (visible && autoload && !(progressInfo && progressInfo.isUpload))
                room.downloadFile(eventId)
    }

    ProgressBar {
        id: transferProgress
        visible: progressInfo && progressInfo.started
        anchors.top: imageContent.bottom

        value: progressInfo ? progressInfo.progress / progressInfo.total : -1
        indeterminate: !progressInfo || progressInfo.progress < 0
    }

    RowLayout {
        id: buttons
        anchors.top: transferProgress.bottom
        width: parent.width
        spacing: 2

        Button {
            text: qsTr("Cancel")
            visible: progressInfo.started
            onClicked: room.cancelFileTransfer(eventId)
        }

        Button {
            text: qsTr("Open externally")
            onClicked: openExternally()
        }
        Button {
            text: qsTr("Download full size")
            visible: !autoload && !progressInfo.active

            onClicked: room.downloadFile(eventId)
        }
        Button {
            text: qsTr("Save as...")
            onClicked: controller.saveFileAs(eventId)
        }
    }
}
