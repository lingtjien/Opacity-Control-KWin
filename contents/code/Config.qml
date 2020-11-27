import QtQuick 2.0

Item {
  property bool blur: KWin.readConfig('blur', true)

  property bool opacityShow: KWin.readConfig('opacityShow', true)
  property double opacityValue: KWin.readConfig('opacityValue', 0.9)
  property double opacityNormal: opacityShow ? opacityValue : 1
  property double opacityInverse: !opacityShow ? opacityValue : 1

  property var ignored: Item {
    property var names: splitTrim(KWin.readConfig('ignoredNames', 'ksmserver, latte-dock, Plasma, plasma, plasma-desktop, plasmashell, plugin-container, inkscape, gimp, krita, gwenview, vlc'))
    property var captions: splitTrim(KWin.readConfig('ignoredCaptions', ''))
  }

  function splitTrim(data) {
    return data.split(',').map(i => i.trim()).filter(i => i);
  }
}
