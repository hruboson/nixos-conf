import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: root
		visible: true

		anchors {
			top: true
			bottom: true
			left: true
			right: true
		}

		color: "transparent"

        IpcHandler {
            target: "brightness-widget"
            function toggle() {
                root.visible = !root.visible
                if (root.visible) {
                    getBrightness.running = true
			        getTemp.running = true
                }
            }
        }

        Process {
            id: getBrightness
            command: ["brightness-widget-controller", "get"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    brightnessSlider.value = parseInt(data)
                }
            }
		}

        Process {
            id: setBrightness
        }

		Process {
			id: getTemp
			command: ["brightness-widget-controller", "get-temp"]
			stdout: SplitParser {
				onRead: data => {
					// map 3000–6500 → 0–100
					let temp = parseInt(data)
					bluelightSlider.value = (temp - 3000) / (6500 - 3000) * 100
				}
			}
		}

		Process {
			id: setTemp
		}

		MouseArea {
			anchors.fill: parent
			onClicked: { root.visible = false }
		}

        Rectangle {
			id: panel
			width: 220
			height: 150

			anchors.bottom: parent.bottom
			anchors.right: parent.right
			anchors.margins: 8

			/*property bool hovered: false

			HoverHandler {
				id: hoverHandler
				onHoveredChanged: panel.hovered = hovered
			}

			Timer {
				id: closeTimer
				interval: 200   // small delay feels nicer
				running: false
				repeat: false
				onTriggered: {
					if (!panel.hovered) {
						root.visible = false
					}
				}
			}

			onHoveredChanged: {
				if (!hovered) {
					closeTimer.start()
				} else {
					closeTimer.stop()
				}
			}*/

			color: "#141415"
			border.width: 1
			border.color: "#f3be7c"
			radius: 5

			MouseArea {
				anchors.fill: parent
				onClicked: {}
			}

			ColumnLayout {
				id: slidersGroup
				anchors.fill: parent
				anchors.margins: 12
				spacing: 3

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 3

					Text {
						text: "Blue light filter"
						color: "#aaaaaa"
						font.pixelSize: 11
						Layout.alignment: Qt.AlignHCenter
					}

					RowLayout {
						Layout.fillWidth: true
						spacing: 8

						Text { text: ""; color: "white" }

						Slider {
							id: bluelightSlider
							Layout.fillWidth: true
							from: 3
							to: 100
							stepSize: 1
							value: 50
							onMoved: {
								setTemp.command = [
									"brightness-widget-controller",
									"set-temp",
									Math.round(bluelightSlider.value).toString()
								]
								setTemp.running = true
							}
						}

						Text { text: ""; color: "white" }
					}

					Text {
						text: Math.round(bluelightSlider.value) + "%"
						color: "#aaaaaa"
						font.pixelSize: 11
						Layout.alignment: Qt.AlignHCenter
					}
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 3

					Text {
						text: "Brightness"
						color: "#aaaaaa"
						font.pixelSize: 11
						Layout.alignment: Qt.AlignHCenter
					}

					RowLayout {
						Layout.fillWidth: true
						spacing: 8

						Text { text: "󰃞"; color: "white" }

						Slider {
							id: brightnessSlider
							Layout.fillWidth: true
							from: 3 
							to: 100
							stepSize: 1
							value: 50
							onMoved: {
								setBrightness.command = [
									"brightness-widget-controller",
									"set",
									Math.round(brightnessSlider.value).toString()
								]
								setBrightness.running = true
							}
						}

						Text { text: "󰃠"; color: "white" }
					}

					Text {
						text: Math.round(brightnessSlider.value) + "%"
						color: "#aaaaaa"
						font.pixelSize: 11
						Layout.alignment: Qt.AlignHCenter
					}
				}
			}
        }
    }
}
