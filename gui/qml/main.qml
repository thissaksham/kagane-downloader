import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    minimumWidth: 900
    minimumHeight: 600
    title: "Kagane Downloader"
    color: theme.background

    // ======================= Theme =======================
    QtObject {
        id: theme

        readonly property color background: "#1a1a2e"
        readonly property color surface: "#16213e"
        readonly property color surfaceAlt: "#233252"
        readonly property color surfaceHover: "#2a3f5f"
        readonly property color border: "#2e3d5c"
        readonly property color accent: "#e94560"
        readonly property color accentHover: "#d63850"
        readonly property color success: "#4ade80"
        readonly property color warning: "#fbbf24"
        readonly property color danger: "#ef4444"
        readonly property color textPrimary: "#f1f5f9"
        readonly property color textSecondary: "#aab2c5"
        readonly property color textMuted: "#6d7691"

        readonly property int radiusSm: 8
        readonly property int radiusLg: 12
        readonly property int animFast: 150

        // Lucide-style stroke icons as data URIs, tintable per state
        function iconSource(name, tint) {
            var paths = {
                "search": "<circle cx='11' cy='11' r='8'/><line x1='21' y1='21' x2='16.65' y2='16.65'/>",
                "download": "<path d='M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'/><polyline points='7 10 12 15 17 10'/><line x1='12' y1='15' x2='12' y2='3'/>",
                "sliders": "<line x1='4' y1='21' x2='4' y2='14'/><line x1='4' y1='10' x2='4' y2='3'/><line x1='12' y1='21' x2='12' y2='12'/><line x1='12' y1='8' x2='12' y2='3'/><line x1='20' y1='21' x2='20' y2='16'/><line x1='20' y1='12' x2='20' y2='3'/><line x1='1' y1='14' x2='7' y2='14'/><line x1='9' y1='8' x2='15' y2='8'/><line x1='17' y1='16' x2='23' y2='16'/>",
                "info": "<circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/>",
                "book-open": "<path d='M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z'/><path d='M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z'/>",
                "check": "<polyline points='20 6 9 17 4 12'/>",
                "check-circle": "<path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.27'/>",
                "alert-triangle": "<path d='M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'/><line x1='12' y1='9' x2='12' y2='13'/><line x1='12' y1='17' x2='12.01' y2='17'/>",
                "x": "<line x1='18' y1='6' x2='6' y2='18'/><line x1='6' y1='6' x2='18' y2='18'/>",
                "clock": "<circle cx='12' cy='12' r='10'/><polyline points='12 6 12 12 16 14'/>",
                "zap": "<polygon points='13 2 3 14 12 14 11 22 21 10 12 10'/>",
                "folder": "<path d='M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z'/>",
                "image": "<rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/>",
                "loader": "<line x1='12' y1='2' x2='12' y2='6'/><line x1='12' y1='18' x2='12' y2='22'/><line x1='4.93' y1='4.93' x2='7.76' y2='7.76'/><line x1='16.24' y1='16.24' x2='19.07' y2='19.07'/><line x1='2' y1='12' x2='6' y2='12'/><line x1='18' y1='12' x2='22' y2='12'/><line x1='4.93' y1='19.07' x2='7.76' y2='16.24'/><line x1='16.24' y1='7.76' x2='19.07' y2='4.93'/>",
                "arrow-up-down": "<path d='m3 16 4 4 4-4'/><path d='M7 20V4'/><path d='m21 8-4-4-4 4'/><path d='M17 4v16'/>",
                "eye": "<path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/>",
                "layers": "<polygon points='12 2 2 7 12 12 22 7 12 2'/><polyline points='2 17 12 22 22 17'/><polyline points='2 12 12 17 22 12'/>",
                "activity": "<polyline points='22 12 18 12 15 21 9 3 6 12 2 12'/>",
                "external-link": "<path d='M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6'/><polyline points='15 3 21 3 21 9'/><line x1='10' y1='14' x2='21' y2='3'/>"
            }
            var svg = "<svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='"
                    + String(tint)
                    + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"
                    + (paths[name] || "") + "</svg>"
            return "data:image/svg+xml;utf8," + encodeURIComponent(svg)
        }
    }

    // ======================= Reusable components =======================
    component Icon: Item {
        id: iconRoot
        property string name
        property color tint: theme.textSecondary
        property int size: 18
        implicitWidth: size
        implicitHeight: size

        Image {
            anchors.fill: parent
            sourceSize: Qt.size(iconRoot.size * 2, iconRoot.size * 2)
            source: theme.iconSource(iconRoot.name, iconRoot.tint)
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }

    component PrimaryButton: Button {
        id: pbtn
        hoverEnabled: true
        padding: 12
        background: Rectangle {
            radius: theme.radiusSm
            color: !pbtn.enabled ? theme.surfaceAlt
                 : pbtn.down ? Qt.darker(theme.accent, 1.3)
                 : pbtn.hovered ? theme.accentHover : theme.accent
            border.width: pbtn.visualFocus ? 2 : 0
            border.color: theme.textPrimary
            Behavior on color { ColorAnimation { duration: theme.animFast } }
        }
        contentItem: Text {
            text: pbtn.text
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: pbtn.enabled ? "white" : theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: pbtn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    component OutlineButton: Button {
        id: obtn
        property string iconName: ""
        property color tintColor: theme.accent
        hoverEnabled: true
        padding: 8
        leftPadding: 12
        rightPadding: 12
        background: Rectangle {
            radius: 6
            color: obtn.down ? Qt.darker(theme.surfaceHover, 1.2)
                 : obtn.hovered ? theme.surfaceHover : "transparent"
            border.color: obtn.tintColor
            border.width: 1
            Behavior on color { ColorAnimation { duration: theme.animFast } }
        }
        contentItem: RowLayout {
            spacing: 6
            Icon {
                visible: obtn.iconName !== ""
                name: obtn.iconName
                tint: obtn.tintColor
                size: 14
            }
            Text {
                text: obtn.text
                font.pixelSize: 12
                color: obtn.tintColor
                verticalAlignment: Text.AlignVCenter
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    component NavButton: Button {
        id: nb
        property string iconName
        property bool active: false
        Layout.fillWidth: true
        Layout.preferredHeight: 42
        hoverEnabled: true
        background: Rectangle {
            radius: theme.radiusSm
            color: nb.active ? theme.accent : nb.hovered ? theme.surfaceHover : "transparent"
            border.width: nb.visualFocus ? 1 : 0
            border.color: theme.textPrimary
            Behavior on color { ColorAnimation { duration: theme.animFast } }
        }
        contentItem: RowLayout {
            spacing: 12
            Item { implicitWidth: 4 }
            Icon {
                name: nb.iconName
                tint: nb.active ? "white" : theme.textSecondary
                size: 18
            }
            Text {
                text: nb.text
                font.pixelSize: 14
                font.weight: nb.active ? Font.DemiBold : Font.Normal
                color: nb.active ? "white" : theme.textSecondary
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    component ThemedField: TextField {
        id: tf
        color: theme.textPrimary
        placeholderTextColor: theme.textMuted
        selectionColor: theme.accent
        selectedTextColor: "white"
        font.pixelSize: 14
        padding: 10
        background: Rectangle {
            radius: theme.radiusSm
            color: theme.background
            border.color: tf.activeFocus ? theme.accent : theme.border
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: theme.animFast } }
        }
    }

    component ThemedSwitch: Switch {
        id: sw
        hoverEnabled: true
        indicator: Rectangle {
            implicitWidth: 44
            implicitHeight: 24
            x: sw.leftPadding
            y: parent.height / 2 - height / 2
            radius: 12
            color: sw.checked ? theme.accent : theme.surfaceAlt
            border.color: sw.checked ? theme.accent : theme.border
            Behavior on color { ColorAnimation { duration: theme.animFast } }
            Rectangle {
                x: sw.checked ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                width: 18
                height: 18
                radius: 9
                color: "white"
                Behavior on x { NumberAnimation { duration: theme.animFast; easing.type: Easing.OutCubic } }
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    component ThemedSlider: Slider {
        id: sl
        Layout.preferredWidth: 320
        background: Rectangle {
            x: sl.leftPadding
            y: sl.topPadding + sl.availableHeight / 2 - height / 2
            width: sl.availableWidth
            height: 6
            radius: 3
            color: theme.surfaceAlt
            Rectangle {
                width: sl.visualPosition * parent.width
                height: parent.height
                radius: 3
                color: theme.accent
            }
        }
        handle: Rectangle {
            x: sl.leftPadding + sl.visualPosition * (sl.availableWidth - width)
            y: sl.topPadding + sl.availableHeight / 2 - height / 2
            width: 18
            height: 18
            radius: 9
            color: sl.pressed ? theme.accentHover : theme.accent
            border.color: "white"
            border.width: sl.activeFocus ? 2 : 0
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    component SectionLabel: Text {
        font.pixelSize: 12
        font.weight: Font.DemiBold
        font.letterSpacing: 1.2
        color: theme.textMuted
        text: ""
    }

    component HelperText: Text {
        font.pixelSize: 11
        color: theme.textMuted
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    // ======================= App state =======================
    property int currentScreen: 0  // 0: Browse, 1: Downloads, 2: Settings, 3: About
    property bool isLoading: false
    property bool isDownloading: false

    property string statusMessage: ""
    property string downloadProgressMsg: ""
    property int downloadCurrent: 0
    property int downloadTotal: 0
    property int downloadPageCurrent: 0
    property int downloadPageTotal: 0
    property bool isCancelling: false

    // Overall progress including partial progress through the current chapter
    readonly property real downloadFraction: downloadTotal > 0
        ? (downloadCurrent + (downloadPageTotal > 0 ? downloadPageCurrent / downloadPageTotal : 0)) / downloadTotal
        : 0

    property string mangaTitle: ""
    property string mangaAuthor: ""
    property string mangaDescription: ""
    property string mangaSource: ""
    property string mangaStatus: ""
    property string mangaViews: ""
    property string mangaChapters: ""
    property string mangaCover: ""
    property var mangaGenres: []
    property var chaptersList: []

    property int selectedCount: 0
    property string chapterFilter: ""

    // Shift-click range selection anchor (index into the visible chapterModel)
    property int lastChapterClickIndex: -1

    // ---- Toast notifications ----
    property string toastText: ""
    property string toastKind: "info"  // info | success | warning | error

    function showToast(text, kind) {
        toastText = text
        toastKind = kind
        toast.opacity = 1
        toastTimer.restart()
    }

    // ---- Chapter selection helpers (master list = chaptersList) ----
    function recountSelected() {
        var c = 0
        for (var i = 0; i < chaptersList.length; i++)
            if (chaptersList[i].selected)
                c++
        selectedCount = c
    }

    function applyChapterFilter() {
        chapterModel.clear()
        lastChapterClickIndex = -1
        var q = chapterFilter.toLowerCase()
        for (var i = 0; i < chaptersList.length; i++) {
            var c = chaptersList[i]
            if (!q
                || String(c.number).toLowerCase().indexOf(q) >= 0
                || String(c.title).toLowerCase().indexOf(q) >= 0)
                chapterModel.append(c)
        }
    }

    function selectChapterRange(fromIndex, toIndex, state) {
        var lo = Math.max(0, Math.min(fromIndex, toIndex))
        var hi = Math.min(chapterModel.count - 1, Math.max(fromIndex, toIndex))
        for (var i = lo; i <= hi; i++) {
            var bi = chapterModel.get(i).bookIndex
            for (var j = 0; j < chaptersList.length; j++) {
                if (chaptersList[j].bookIndex === bi) {
                    chaptersList[j].selected = state
                    break
                }
            }
            chapterModel.setProperty(i, "selected", state)
        }
        recountSelected()
    }

    function setChapterSelected(bookIndex, modelIndex, sel) {
        for (var i = 0; i < chaptersList.length; i++) {
            if (chaptersList[i].bookIndex === bookIndex) {
                chaptersList[i].selected = sel
                break
            }
        }
        if (modelIndex >= 0 && modelIndex < chapterModel.count)
            chapterModel.setProperty(modelIndex, "selected", sel)
        recountSelected()
    }

    function setVisibleSelected(sel) {
        for (var i = 0; i < chapterModel.count; i++) {
            var bi = chapterModel.get(i).bookIndex
            for (var j = 0; j < chaptersList.length; j++) {
                if (chaptersList[j].bookIndex === bi) {
                    chaptersList[j].selected = sel
                    break
                }
            }
            chapterModel.setProperty(i, "selected", sel)
        }
        recountSelected()
    }

    function allVisibleSelected() {
        if (chapterModel.count === 0)
            return false
        for (var i = 0; i < chapterModel.count; i++)
            if (!chapterModel.get(i).selected)
                return false
        return true
    }

    function collectSelectedIndices() {
        var out = []
        for (var i = 0; i < chaptersList.length; i++)
            if (chaptersList[i].selected)
                out.push(chaptersList[i].bookIndex)
        return out
    }

    // ======================= Backend signals =======================
    Connections {
        target: appController

        function onMangaLoaded(title, author, description, source, status, views, chapters, cover, genres, chapterNums) {
            mangaTitle = title
            mangaAuthor = author
            mangaDescription = description
            mangaSource = source
            mangaStatus = status
            mangaViews = views
            mangaChapters = chapters
            mangaCover = cover
            mangaGenres = genres
        }

        function onChaptersLoaded(chapters) {
            chaptersList = chapters
            chapterFilter = ""
            applyChapterFilter()
            recountSelected()
        }

        function onLoadingStarted() {
            isLoading = true
            statusMessage = "Loading series..."
        }

        function onLoadingFinished() {
            isLoading = false
            statusMessage = ""
        }

        function onLoadingError(error) {
            statusMessage = ""
            showToast(error, "error")
        }

        function onLoadingProgress(msg) {
            statusMessage = msg
        }

        function onDownloadStarted() {
            isDownloading = true
            isCancelling = false
            downloadProgressMsg = "Starting download..."
            downloadCurrent = 0
            downloadTotal = 0
            downloadPageCurrent = 0
            downloadPageTotal = 0
            currentScreen = 1
        }

        function onDownloadProgress(current, total, msg) {
            downloadCurrent = current
            downloadTotal = total
            downloadProgressMsg = msg
            statusMessage = msg
            // New phase (next chapter / conversion): reset page counters
            downloadPageCurrent = 0
            downloadPageTotal = 0
        }

        function onDownloadPageProgress(current, total) {
            downloadPageCurrent = current
            downloadPageTotal = total
        }

        function onDownloadFinished(success, total) {
            isDownloading = false
            isCancelling = false
            statusMessage = ""
            showToast("Downloaded " + success + " of " + total + " chapters",
                      success === total ? "success" : "warning")
            downloadHistoryModel.insert(0, {
                title: mangaTitle,
                success: success,
                total: total,
                time: new Date().toLocaleString(),
                cover: mangaCover
            })
        }

        function onDownloadError(error) {
            isDownloading = false
            isCancelling = false
            statusMessage = ""
            showToast(error, "error")
        }
    }

    ListModel { id: chapterModel }
    ListModel { id: downloadHistoryModel }

    // ======================= Layout =======================
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---- Sidebar ----
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: theme.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 8
                    spacing: 10

                    Icon { name: "book-open"; tint: theme.accent; size: 26 }

                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: "Kagane"
                            font.pixelSize: 20
                            font.bold: true
                            color: theme.accent
                        }
                        Text {
                            text: "Downloader"
                            font.pixelSize: 11
                            color: theme.textMuted
                        }
                    }
                }

                Item { implicitHeight: 16 }

                NavButton { iconName: "search"; text: "Browse"; active: currentScreen === 0; onClicked: currentScreen = 0 }
                NavButton { iconName: "download"; text: "Downloads"; active: currentScreen === 1; onClicked: currentScreen = 1 }
                NavButton { iconName: "sliders"; text: "Settings"; active: currentScreen === 2; onClicked: currentScreen = 2 }
                NavButton { iconName: "info"; text: "About"; active: currentScreen === 3; onClicked: currentScreen = 3 }

                Item { Layout.fillHeight: true }

                Text {
                    text: statusMessage
                    font.pixelSize: 11
                    color: theme.textSecondary
                    wrapMode: Text.WordWrap
                    visible: statusMessage !== ""
                    Layout.fillWidth: true
                }

                ProgressBar {
                    id: progressBar
                    Layout.fillWidth: true
                    visible: isDownloading
                    value: downloadFraction

                    background: Rectangle {
                        implicitHeight: 6
                        radius: 3
                        color: theme.surfaceAlt
                    }

                    contentItem: Item {
                        Rectangle {
                            width: progressBar.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: theme.accent
                        }
                    }
                }
            }
        }

        // ---- Content ----
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: theme.background

            Loader {
                id: screenLoader
                anchors.fill: parent
                anchors.margins: 20
                sourceComponent: {
                    switch (currentScreen) {
                        case 0: return browseScreen
                        case 1: return downloadsScreen
                        case 2: return settingsScreen
                        case 3: return aboutScreen
                        default: return browseScreen
                    }
                }
                onSourceComponentChanged: screenFade.restart()

                NumberAnimation {
                    id: screenFade
                    target: screenLoader
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // ======================= Toast =======================
    Rectangle {
        id: toast
        z: 1000
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        width: Math.min(toastRow.implicitWidth + 32, 560)
        height: toastRow.implicitHeight + 24
        radius: theme.radiusSm
        color: theme.surface
        border.width: 1
        border.color: toastKind === "error" ? theme.danger
                    : toastKind === "warning" ? theme.warning
                    : toastKind === "success" ? theme.success : theme.border
        opacity: 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 200 } }

        Timer {
            id: toastTimer
            interval: toastKind === "error" ? 8000 : 5000
            onTriggered: toast.opacity = 0
        }

        RowLayout {
            id: toastRow
            anchors.centerIn: parent
            width: parent.width - 32
            spacing: 10

            Icon {
                name: toastKind === "error" ? "alert-triangle"
                    : toastKind === "warning" ? "alert-triangle"
                    : toastKind === "success" ? "check-circle" : "info"
                tint: toastKind === "error" ? theme.danger
                    : toastKind === "warning" ? theme.warning
                    : toastKind === "success" ? theme.success : theme.textSecondary
                size: 18
            }

            Text {
                text: toastText
                font.pixelSize: 13
                color: theme.textPrimary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Icon {
                name: "x"
                tint: theme.textMuted
                size: 14

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toast.opacity = 0
                }
            }
        }
    }

    // ======================= Browse screen =======================
    Component {
        id: browseScreen

        ColumnLayout {
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ThemedField {
                    id: urlInput
                    Layout.fillWidth: true
                    placeholderText: "Paste a kagane.to series URL and press Enter..."
                    onAccepted: if (!isLoading && text.length > 0) appController.fetchManga(text)
                    Component.onCompleted: forceActiveFocus()
                }

                Icon {
                    name: "loader"
                    tint: theme.accent
                    size: 20
                    visible: isLoading

                    RotationAnimation on rotation {
                        running: isLoading
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }

                PrimaryButton {
                    text: isLoading ? "Loading..." : "Fetch"
                    enabled: !isLoading && urlInput.text.length > 0
                    onClicked: appController.fetchManga(urlInput.text)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16
                visible: mangaTitle !== ""

                // Series info panel
                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.fillHeight: true
                    radius: theme.radiusLg
                    color: theme.surface

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 380
                            radius: theme.radiusSm
                            color: theme.surfaceAlt
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: mangaCover
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: mangaCover !== ""
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "image"
                                tint: theme.textMuted
                                size: 48
                                visible: mangaCover === ""
                            }
                        }

                        Text {
                            text: mangaTitle
                            font.pixelSize: 16
                            font.bold: true
                            color: theme.textPrimary
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "By " + mangaAuthor
                            font.pixelSize: 12
                            color: theme.textSecondary
                            visible: mangaAuthor !== ""
                        }

                        Text {
                            text: "Format: " + mangaSource
                            font.pixelSize: 12
                            color: theme.textSecondary
                            visible: mangaSource !== ""
                        }

                        RowLayout {
                            spacing: 14

                            RowLayout {
                                spacing: 5
                                visible: mangaStatus !== ""
                                Icon {
                                    name: "activity"
                                    tint: mangaStatus.toLowerCase() === "ongoing" ? theme.success : theme.warning
                                    size: 13
                                }
                                Text {
                                    text: mangaStatus
                                    font.pixelSize: 12
                                    color: mangaStatus.toLowerCase() === "ongoing" ? theme.success : theme.warning
                                }
                            }

                            RowLayout {
                                spacing: 5
                                Icon { name: "layers"; tint: theme.textSecondary; size: 13 }
                                Text {
                                    text: mangaChapters + " ch"
                                    font.pixelSize: 12
                                    color: theme.textSecondary
                                }
                            }

                            RowLayout {
                                spacing: 5
                                visible: mangaViews !== ""
                                Icon { name: "eye"; tint: theme.textSecondary; size: 13 }
                                Text {
                                    text: mangaViews
                                    font.pixelSize: 12
                                    color: theme.textSecondary
                                }
                            }
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: mangaGenres

                                Rectangle {
                                    width: genreText.width + 16
                                    height: 24
                                    radius: 12
                                    color: theme.surfaceAlt
                                    border.color: theme.border
                                    border.width: 1

                                    Text {
                                        id: genreText
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 10
                                        color: theme.textSecondary
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                // Chapters panel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: theme.radiusLg
                    color: theme.surface

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Chapters"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                            }

                            Text {
                                text: selectedCount > 0
                                      ? selectedCount + " of " + chaptersList.length + " selected"
                                      : chapterModel.count + " of " + chaptersList.length + " shown"
                                font.pixelSize: 12
                                color: selectedCount > 0 ? theme.accent : theme.textMuted
                            }

                            Item { Layout.fillWidth: true }

                            OutlineButton {
                                text: "Invert Sort"
                                iconName: "arrow-up-down"
                                onClicked: {
                                    chaptersList = chaptersList.slice().reverse()
                                    applyChapterFilter()
                                }
                            }

                            OutlineButton {
                                text: allVisibleSelected() ? "Deselect All" : "Select All"
                                iconName: "check"
                                onClicked: setVisibleSelected(!allVisibleSelected())
                            }
                        }

                        ThemedField {
                            Layout.fillWidth: true
                            placeholderText: "Filter by chapter number or title..."
                            text: chapterFilter
                            onTextChanged: {
                                chapterFilter = text
                                applyChapterFilter()
                            }
                        }

                        HelperText {
                            text: "Tip: click a chapter, then Shift-click another to select the whole range."
                        }

                        ListView {
                            id: chapterListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: chapterModel
                            spacing: 4

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                visible: size < 1.0
                                contentItem: Rectangle {
                                    implicitWidth: 6
                                    radius: 3
                                    color: theme.surfaceHover
                                }
                            }

                            delegate: Rectangle {
                                width: chapterListView.width - 12
                                height: 46
                                radius: 6
                                color: model.selected ? theme.surfaceAlt
                                     : rowMouse.containsMouse ? Qt.lighter(theme.background, 1.25)
                                     : theme.background
                                border.color: model.selected ? theme.accent : "transparent"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    CheckBox {
                                        id: chapterCheck
                                        checked: model.selected
                                        onToggled: {
                                            setChapterSelected(model.bookIndex, index, checked)
                                            lastChapterClickIndex = index
                                        }

                                        indicator: Rectangle {
                                            implicitWidth: 20
                                            implicitHeight: 20
                                            x: chapterCheck.leftPadding
                                            y: parent.height / 2 - height / 2
                                            radius: 4
                                            color: chapterCheck.checked ? theme.accent : "transparent"
                                            border.color: chapterCheck.checked ? theme.accent : theme.textMuted
                                            border.width: 1
                                            Behavior on color { ColorAnimation { duration: 100 } }

                                            Icon {
                                                anchors.centerIn: parent
                                                name: "check"
                                                tint: "white"
                                                size: 13
                                                visible: chapterCheck.checked
                                            }
                                        }
                                    }

                                    Text {
                                        text: "Ch. " + model.number
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: theme.accent
                                        Layout.preferredWidth: 64
                                    }

                                    Text {
                                        text: model.title
                                        font.pixelSize: 12
                                        color: theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: model.pages + " pg"
                                        font.pixelSize: 11
                                        color: theme.textMuted
                                    }

                                    Text {
                                        text: model.date
                                        font.pixelSize: 11
                                        color: theme.textMuted
                                    }
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        // Shift-click always SELECTS the range; deselecting stays
                                        // per-chapter or via Deselect All (predictable beats clever)
                                        if ((mouse.modifiers & Qt.ShiftModifier)
                                            && lastChapterClickIndex >= 0
                                            && lastChapterClickIndex < chapterModel.count) {
                                            selectChapterRange(lastChapterClickIndex, index, true)
                                        } else {
                                            setChapterSelected(model.bookIndex, index, !model.selected)
                                        }
                                        lastChapterClickIndex = index
                                    }
                                }
                            }
                        }

                        PrimaryButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            enabled: !isDownloading && selectedCount > 0
                            text: isDownloading ? "Downloading..."
                                : selectedCount === 0 ? "Select chapters to download"
                                : "Download " + selectedCount + (selectedCount === 1 ? " Chapter" : " Chapters")
                            onClicked: appController.downloadChapters(collectSelectedIndices())
                        }
                    }
                }
            }

            // Empty state
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: theme.radiusLg
                color: theme.surface
                visible: mangaTitle === ""

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Icon {
                        name: "book-open"
                        tint: theme.textMuted
                        size: 56
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Find a series to download"
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                        color: theme.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Paste a kagane.to series URL above and press Enter"
                        font.pixelSize: 13
                        color: theme.textMuted
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    // ======================= Downloads screen =======================
    Component {
        id: downloadsScreen

        ColumnLayout {
            spacing: 16

            Text {
                text: "Downloads"
                font.pixelSize: 24
                font.bold: true
                color: theme.textPrimary
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: isDownloading ? 200 : 80
                radius: theme.radiusLg
                color: theme.surface

                Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        spacing: 10

                        Icon {
                            name: "zap"
                            tint: isDownloading ? theme.accent : theme.textMuted
                            size: 16
                        }

                        Text {
                            text: "Active Download"
                            font.pixelSize: 16
                            font.bold: true
                            color: isDownloading ? theme.textPrimary : theme.textSecondary
                        }

                        Rectangle {
                            visible: isDownloading
                            width: 8
                            height: 8
                            radius: 4
                            color: theme.success

                            SequentialAnimation on opacity {
                                running: isDownloading
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 0.3; duration: 500 }
                                NumberAnimation { from: 0.3; to: 1.0; duration: 500 }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: isDownloading
                        spacing: 8

                        Text {
                            text: mangaTitle
                            font.pixelSize: 14
                            color: theme.textPrimary
                            font.bold: true
                        }

                        Text {
                            text: isCancelling
                                  ? "Cancelling - finishing the current chapter..."
                                  : downloadProgressMsg
                            font.pixelSize: 12
                            color: isCancelling ? theme.warning : theme.textSecondary
                        }

                        RowLayout {
                            spacing: 10

                            ProgressBar {
                                id: downloadProgressBar
                                Layout.preferredWidth: 400
                                from: 0
                                to: 1
                                value: downloadFraction

                                background: Rectangle {
                                    implicitHeight: 8
                                    radius: 4
                                    color: theme.surfaceAlt
                                }

                                contentItem: Item {
                                    Rectangle {
                                        width: downloadProgressBar.visualPosition * parent.width
                                        height: parent.height
                                        radius: 4
                                        color: theme.accent

                                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                    }
                                }
                            }

                            Text {
                                text: "Chapter " + Math.min(downloadCurrent + 1, downloadTotal) + " of " + downloadTotal
                                font.pixelSize: 12
                                color: theme.accent
                                font.bold: true
                            }

                            Text {
                                visible: downloadPageTotal > 0
                                text: downloadPageCurrent + " / " + downloadPageTotal + " pages"
                                font.pixelSize: 12
                                color: theme.textSecondary
                            }
                        }

                        OutlineButton {
                            text: isCancelling ? "Cancelling..." : "Cancel"
                            iconName: "x"
                            tintColor: theme.danger
                            enabled: !isCancelling
                            onClicked: {
                                isCancelling = true
                                appController.stopDownload()
                            }
                        }
                    }

                    Text {
                        visible: !isDownloading
                        text: "No active downloads"
                        font.pixelSize: 13
                        color: theme.textMuted
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: theme.radiusLg
                color: theme.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        spacing: 8
                        Icon { name: "clock"; tint: theme.textSecondary; size: 16 }
                        Text {
                            text: "Download History"
                            font.pixelSize: 16
                            font.bold: true
                            color: theme.textPrimary
                        }
                    }

                    ListView {
                        id: historyListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: downloadHistoryModel
                        spacing: 8

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            visible: size < 1.0
                            contentItem: Rectangle {
                                implicitWidth: 6
                                radius: 3
                                color: theme.surfaceHover
                            }
                        }

                        delegate: Rectangle {
                            width: historyListView.width - 12
                            height: 70
                            radius: theme.radiusSm
                            color: theme.background

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                spacing: 15

                                Rectangle {
                                    width: 50
                                    height: 60
                                    radius: 4
                                    color: theme.surfaceAlt
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: model.cover || ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        visible: model.cover !== ""
                                    }

                                    Icon {
                                        anchors.centerIn: parent
                                        name: "image"
                                        tint: theme.textMuted
                                        size: 18
                                        visible: !model.cover || model.cover === ""
                                    }
                                }

                                ColumnLayout {
                                    spacing: 4

                                    Text {
                                        text: model.title || "Unknown"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: theme.textPrimary
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 400
                                    }

                                    Text {
                                        text: model.success + " / " + model.total + " chapters"
                                        font.pixelSize: 12
                                        color: model.success === model.total ? theme.success : theme.warning
                                    }

                                    Text {
                                        text: model.time || ""
                                        font.pixelSize: 11
                                        color: theme.textMuted
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                Icon {
                                    name: model.success === model.total ? "check-circle" : "alert-triangle"
                                    tint: model.success === model.total ? theme.success : theme.warning
                                    size: 20
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            visible: downloadHistoryModel.count === 0
                            spacing: 10

                            Icon {
                                name: "clock"
                                tint: theme.textMuted
                                size: 32
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "Chapters you download will show up here"
                                font.pixelSize: 13
                                color: theme.textMuted
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // ======================= Settings screen =======================
    Component {
        id: settingsScreen

        Rectangle {
            radius: theme.radiusLg
            color: theme.surface

            FolderDialog {
                id: folderDialog
                onAccepted: {
                    var p = decodeURIComponent(selectedFolder.toString())
                    if (p.indexOf("file:///") === 0)
                        p = p.substring(8)
                    else if (p.indexOf("file://") === 0)
                        p = p.substring(7)
                    settings.downloadDirectory = p
                    downloadDirField.text = p
                }
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: 24
                contentWidth: availableWidth

                ColumnLayout {
                    width: parent.width
                    spacing: 24

                    Text {
                        text: "Settings"
                        font.pixelSize: 24
                        font.bold: true
                        color: theme.textPrimary
                    }

                    // ---- Output ----
                    SectionLabel { text: "OUTPUT" }

                    ColumnLayout {
                        spacing: 8

                        Text {
                            text: "Download Format"
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        RowLayout {
                            spacing: 10

                            Repeater {
                                model: ["images", "pdf", "cbz"]

                                Rectangle {
                                    width: 80
                                    height: 36
                                    radius: 6
                                    color: settings.downloadFormat === modelData ? theme.accent
                                         : formatMouse.containsMouse ? theme.surfaceHover : theme.surfaceAlt
                                    Behavior on color { ColorAnimation { duration: theme.animFast } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.toUpperCase()
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: settings.downloadFormat === modelData ? "white" : theme.textSecondary
                                    }

                                    MouseArea {
                                        id: formatMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: settings.downloadFormat = modelData
                                    }
                                }
                            }
                        }

                        HelperText { text: "CBZ works best with comic readers. PDF is convenient for general reading." }
                    }

                    RowLayout {
                        spacing: 15

                        Text {
                            text: "Keep images after conversion"
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        ThemedSwitch {
                            checked: settings.keepImages
                            onToggled: settings.keepImages = checked
                        }
                    }

                    ColumnLayout {
                        spacing: 8

                        Text {
                            text: "Download Directory"
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        RowLayout {
                            spacing: 10

                            ThemedField {
                                id: downloadDirField
                                Layout.preferredWidth: 400
                                font.pixelSize: 13
                                Component.onCompleted: text = settings.downloadDirectory
                                onEditingFinished: settings.downloadDirectory = text
                            }

                            OutlineButton {
                                text: "Browse"
                                iconName: "folder"
                                onClicked: folderDialog.open()
                            }
                        }
                    }

                    // ---- Downloads ----
                    SectionLabel { text: "DOWNLOADS" }

                    ColumnLayout {
                        spacing: 8

                        Text {
                            text: "Concurrent image downloads: " + settings.maxConcurrentImages
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        ThemedSlider {
                            from: 1
                            to: 10
                            stepSize: 1
                            value: settings.maxConcurrentImages
                            onMoved: settings.maxConcurrentImages = value
                        }
                    }

                    ColumnLayout {
                        spacing: 8

                        Text {
                            text: "Page load delay: " + settings.imageLoadDelay + "s"
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        ThemedSlider {
                            from: 5
                            to: 60
                            stepSize: 1
                            value: settings.imageLoadDelay
                            onMoved: settings.imageLoadDelay = value
                        }

                        HelperText { text: "How long to wait for pages to load when the fast method fails. Increase if chapters come back empty." }
                    }

                    ColumnLayout {
                        spacing: 8

                        Text {
                            text: "Max retries per image: " + settings.maxRetries
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        ThemedSlider {
                            from: 1
                            to: 5
                            stepSize: 1
                            value: settings.maxRetries
                            onMoved: settings.maxRetries = value
                        }
                    }

                    // ---- Browser ----
                    SectionLabel { text: "BROWSER" }

                    ColumnLayout {
                        spacing: 4

                        RowLayout {
                            spacing: 15

                            Text {
                                text: "Hide browser window (headless)"
                                font.pixelSize: 14
                                color: theme.textSecondary
                            }

                            ThemedSwitch {
                                checked: settings.headlessMode
                                onToggled: settings.headlessMode = checked
                            }
                        }

                        HelperText { text: "Downloads use a Chrome window in the background. Turn this on to keep it hidden. If downloads fail, turn it off so Cloudflare checks can complete." }
                    }

                    ColumnLayout {
                        spacing: 4

                        RowLayout {
                            spacing: 15

                            Text {
                                text: "Use legacy headless engine"
                                font.pixelSize: 14
                                color: theme.textSecondary
                            }

                            ThemedSwitch {
                                checked: settings.useLegacyHeadless
                                onToggled: settings.useLegacyHeadless = checked
                            }
                        }

                        HelperText { text: "Only relevant when headless is on. Try this if headless downloads fail to start." }
                    }

                    // ---- Advanced ----
                    SectionLabel { text: "ADVANCED" }

                    RowLayout {
                        spacing: 15

                        Text {
                            text: "Enable logs"
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }

                        ThemedSwitch {
                            checked: settings.enableLogs
                            onToggled: settings.enableLogs = checked
                        }
                    }

                    Item { implicitHeight: 20 }
                }
            }
        }
    }

    // ======================= About screen =======================
    Component {
        id: aboutScreen

        Rectangle {
            radius: theme.radiusLg
            color: theme.surface

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                Icon {
                    name: "book-open"
                    tint: theme.accent
                    size: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Kagane Downloader"
                    font.pixelSize: 28
                    font.bold: true
                    color: theme.accent
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Version 2.1.0"
                    font.pixelSize: 14
                    color: theme.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "A manga downloader for kagane.to"
                    font.pixelSize: 14
                    color: theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Built with PyQt6 + QML"
                    font.pixelSize: 12
                    color: theme.textMuted
                    Layout.alignment: Qt.AlignHCenter
                }

                OutlineButton {
                    text: "View on GitHub"
                    iconName: "external-link"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: Qt.openUrlExternally("https://github.com/thissaksham/kagane-downloader")
                }
            }
        }
    }
}
