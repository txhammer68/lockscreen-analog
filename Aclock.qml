/*
 *   Copyright 2012 Viranch Mehta <viranch.mehta@gmail.com>
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *   Copyright 2013 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
// ** modified analog clock widget to use on lockscreen
// ** change clock imagepath for a different clock face
// ** copy clock face to component folder


import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents


Item {
    id: analogclock

    width: units.gridUnit * 15
    height: units.gridUnit * 15
    property int hours
    property int minutes
    property int seconds
    property bool showSecondsHand: false
    property bool showTimezone:false
    property int tzOffset


    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: "Local"
        interval: showSecondsHand ? 1000 : 30000
        onDataChanged: {
            var date = new Date(data["Local"]["DateTime"]);
            hours = date.getHours();
            minutes = date.getMinutes();
            seconds = date.getSeconds();
            var today = date
        }
        Component.onCompleted: {
            onDataChanged();
        }
    }

    function dateTimeChanged()
    {
        var currentTZOffset = dataSource.data["Local"]["Offset"] / 60;
        if (currentTZOffset !== tzOffset) {
            tzOffset = currentTZOffset;
            Date.timeZoneUpdated(); // inform the QML JS engine about TZ change
        }
    }

    Component.onCompleted: {
        tzOffset = new Date().getTimezoneOffset();
        dataSource.onDataChanged.connect(dateTimeChanged);
    }

     Item {
        id: representation
        Layout.minimumWidth: 300
        Layout.minimumHeight: 300
        PlasmaCore.Svg {
        
            id: clockSvg
            // imagePath: "/run/media/hammer/Data/projects/QML/org.kde.plasma.analogclock/contents/ui/clock"
           // imagePath: "/home/hammer/.local/share/plasma/look-and-feel/DigiTech2/contents/components/clock2.svgz"
           imagePath: "/home/hammer/.local/share/plasma/look-and-feel/DigiTech2/contents/components/boxygenclock.svgz"
            function estimateHorizontalHandShadowOffset() {
                var id = "hint-hands-shadow-offset-to-west";
                if (hasElement(id)) {
                    return -elementSize(id).width;
                }
                id = "hint-hands-shadows-offset-to-east";
                if (hasElement(id)) {
                    return elementSize(id).width;
                }
                return 0;
            }
            function estimateVerticalHandShadowOffset() {
                var id = "hint-hands-shadow-offset-to-north";
                if (hasElement(id)) {
                    return -elementSize(id).height;
                }
                id = "hint-hands-shadow-offset-to-south";
                if (hasElement(id)) {
                    return elementSize(id).height;
                }
                return 0;
            }
            property double naturalHorizontalHandShadowOffset: estimateHorizontalHandShadowOffset()
            property double naturalVerticalHandShadowOffset: estimateVerticalHandShadowOffset()
            onRepaintNeeded: {
                naturalHorizontalHandShadowOffset = estimateHorizontalHandShadowOffset();
                naturalVerticalHandShadowOffset = estimateVerticalHandShadowOffset();
            }
        }

        Item {
            id: clock
            width: parent.width
            antialiasing : true
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            readonly property double svgScale: face.width / face.naturalSize.width
            readonly property double horizontalShadowOffset:
                Math.round(clockSvg.naturalHorizontalHandShadowOffset * svgScale) + Math.round(clockSvg.naturalHorizontalHandShadowOffset * svgScale) % 2
            readonly property double verticalShadowOffset:
                Math.round(clockSvg.naturalVerticalHandShadowOffset * svgScale) + Math.round(clockSvg.naturalVerticalHandShadowOffset * svgScale) % 2
        
                
            PlasmaCore.SvgItem {
                id: face
                antialiasing : true
                smooth:true
                anchors.centerIn: parent
                width: 340
                height: 340
                svg: clockSvg
                opacity:.65
                elementId: "ClockFace"
            }

            Hand {
                elementId: "HourHandShadow"
                rotationCenterHintId: "hint-hourhandshadow-rotation-center-offset"
                horizontalRotationOffset: clock.horizontalShadowOffset
                verticalRotationOffset: clock.verticalShadowOffset
                rotation: 180 + hours * 30 + (minutes/2)
                svgScale: clock.svgScale
                antialiasing : true
                smooth:true

            }
            Hand {
                elementId: "HourHand"
                rotationCenterHintId: "hint-hourhand-rotation-center-offset"
                rotation: 180 + hours * 30 + (minutes/2)
                svgScale: clock.svgScale
                antialiasing : true
                smooth:true
            }

            Hand {
                elementId: "MinuteHandShadow"
                rotationCenterHintId: "hint-minutehandshadow-rotation-center-offset"
                horizontalRotationOffset: clock.horizontalShadowOffset
                verticalRotationOffset: clock.verticalShadowOffset
                rotation: 180 + minutes * 6
                svgScale: clock.svgScale
                z:201
                antialiasing : true
                smooth:true
            }
            Hand {
                elementId: "MinuteHand"
                rotationCenterHintId: "hint-minutehand-rotation-center-offset"
                rotation: 180 + minutes * 6
                svgScale: clock.svgScale
                antialiasing : true
                smooth:true
                z: 200
            }

            Hand {
                elementId: "SecondHandShadow"
                rotationCenterHintId: "hint-secondhandshadow-rotation-center-offset"
                horizontalRotationOffset: clock.horizontalShadowOffset
                verticalRotationOffset: clock.verticalShadowOffset
                rotation: 180 + seconds * 6
                visible: showSecondsHand
                svgScale: clock.svgScale
                antialiasing : true
                smooth:true
                z:101
            }
            Hand {
                elementId: "SecondHand"
                rotationCenterHintId: "hint-secondhand-rotation-center-offset"
                rotation: 180 + seconds * 6
                visible: showSecondsHand
                svgScale: clock.svgScale
                antialiasing : true
                smooth:true
                z: 100
            }

            PlasmaCore.SvgItem {
                id: center
                width: naturalSize.width * clock.svgScale
                // height: naturalSize.height * clock.svgScale
                height: naturalSize.height * clock.svgScale
                anchors.centerIn: clock
                svg: clockSvg
                antialiasing : true
                smooth:true
                elementId: "HandCenterScrew"
                z: 1000
            }

            PlasmaCore.SvgItem {
                anchors.fill: face
                svg: clockSvg
                antialiasing : true
                smooth:true
                elementId: "Glass"
                width: 800
                height: 800
            }
        }
        
        Text {
            id:day
            anchors.horizontalCenter:clock.horizontalCenter
            anchors.bottom:clock.bottom
            anchors.bottomMargin:-60
            property var cMonth:Qt.formatDate(dataSource.data["Local"]["DateTime"],"dddd")
            color: "white"
            antialiasing : true
            renderType: Text.QtRendering
            textFormat: Text.RichText
            text: cMonth+'\n'
            font {
            pointSize: 12
            family: "Noto Sans"
            bold:true
            }
        }
        Text {
            anchors.top:day.bottom
            anchors.horizontalCenter:day.horizontalCenter
            property var nth:getOrdinal(Qt.formatDate(dataSource.data["Local"]["DateTime"],"d"))
            property var cDate:Qt.formatDate(dataSource.data["Local"]["DateTime"],"MMMM  d")+"<sup>"+nth+"</sup>"
            function getOrdinal(n) {            // assigns superfix to date
            var s=["th","st","nd","rd"],
            v=n%100;
            return (s[(v-20)%10]||s[v]||s[0]);
            }
            color: "white"
            antialiasing : true
            renderType: Text.QtRendering
            textFormat: Text.RichText
            text: '\n'+cDate
            font {
            pointSize: 12
            family: "Noto Sans"
            bold:true
            }
        }
    }
}
