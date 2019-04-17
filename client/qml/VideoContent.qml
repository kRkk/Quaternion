import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtMultimedia 5.7

Attachment {
    property var thumbnailSize
    property var maxHeight
    property bool autoPlay

    onDownloadedChanged: {
        if (downloaded && autoPlay)
            videoContent.play()
    }

    function click() {
        autoPlay = true
        if (!downloaded) {
            room.downloadFile(eventId)
            return
        }

        if (videoContent.playbackState === MediaPlayer.PlayingState)
            videoContent.pause()
        else
            videoContent.play()
    }

    Video {
        id: videoContent
        source: progressInfo.localPath
        autoLoad: false
        audioRole: MediaPlayer.MusicRole
        height: thumbnailSize.height *
                Math.min(maxHeight / thumbnailSize.height * 0.9,
                         Math.min(width / thumbnailSize.width, 1))
        width: parent.width

        onPositionChanged: {
            pos.text = Math.floor(position / 60000) + ":" +
                       ('0' + Math.floor(position / 1000 % 60)).slice(-2)
            if (!timeSlider.pressed)
                timeSlider.value = position / duration
            maxpos.text = Math.floor(duration / 60000) + ":" +
                ('0' + Math.floor(duration / 1000 % 60)).slice(-2)

            if (hasVideo)
                height = metaData.resolution.height *
                         Math.min(maxHeight / metaData.resolution.height * 0.9,
                                  Math.min(width / metaData.resolution.width, 1))

        }

        onPlaying: playLabel.text = "▮▮"
        onPaused: playLabel.text = "▶ "
        onStopped: playLabel.text = "⟲ "

        MouseArea {
            acceptedButtons: Qt.LeftButton
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: click()
        }
    }

    RowLayout {
        id: controlls
        anchors.top: videoContent.bottom
        width: parent.width

        Label {
            id: playLabel
            text: "▶ "

            MouseArea {
                acceptedButtons: Qt.LeftButton
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: click()
            }
        }

        Label {
            id: pos
            text: "-:--"
        }

        Slider {
            id: timeSlider
            width: parent.width
            updateValueWhileDragging: false
            wheelEnabled: false
            Layout.fillWidth: true

            onValueChanged: videoContent.seek(value * videoContent.duration)
        }

        Label {
            id: maxpos
            text: "-:--"
        }
    }

    ProgressBar {
        visible: progressInfo && progressInfo.started
        width: parent.width
        anchors.left: timeSlider.right
        anchors.right: maxpos.left

        value: progressInfo ? progressInfo.progress / progressInfo.total : -1
        indeterminate: !progressInfo || progressInfo.progress < 0
    }

    RowLayout {
        anchors.top: controlls.bottom
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
            text: qsTr("Save as...")
            onClicked: controller.saveFileAs(eventId)
        }
    }
}
