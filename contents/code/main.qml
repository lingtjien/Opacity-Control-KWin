import QtQuick 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore;
import org.kde.plasma.components 2.0 as Plasma;
import org.kde.kwin 2.0;

Item {
  Item {
    id: algorithm

    function trimSplitString (input) {
      var split = input.split(',');
      for (var i = 0; i < split.length; i++) {
        split[i] = split[i].trim();
        if (split[i] === '') {
          split.splice(i, 1);
          continue;
        }
      }
      return split;
    }
  }

  Item {
    id: parameters

    property bool blur: KWin.readConfig('blur', true)
    property bool opacityShow: KWin.readConfig('opacityShow', true)
    property double opacityValue: KWin.readConfig('opacityValue', 0.9)
    readonly property var ignored: ({
      types: algorithm.trimSplitString(KWin.readConfig('ignoredTypes', 'specialWindow')),
      clients: algorithm.trimSplitString(KWin.readConfig('ignoredClients', 'ksmserver')),
      captions: algorithm.trimSplitString(KWin.readConfig('ignoredCaptions', ''))
    })
  }

  Item {
    id: methods

    function validate (client) {
      if (client === null)
        return false;
      for (let type of parameters.ignored.types) {
        if (client[type])
          return false;
      }

      const clientClass = client.resourceClass.toString();
      const clientName = client.resourceName.toString();
      const clientCaption = client.caption.toString();

      if (parameters.ignored.captions.indexOf(clientCaption) !== -1) {return false;}
      for (let ignored of parameters.ignored.clients) {
        if (clientClass.indexOf(ignored) !== -1 || clientName.indexOf(ignored) !== -1) {
          return false;
        }
      }
      return true;
    }

    function blur (client) {
      if (!shell) return;
      shell.exec('xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id ' + client.windowId.toString());
    }

    function setClient (client) {
      if (!validate(client))
        return false;

      client.opacity = parameters.opacityShow ? parameters.opacityValue : 1;
      if (parameters.blur) {
        blur(client);
      }
      return true;
    }
    
    function refresh () {
      var clients = workspace.clientList();
      for (var i = 0; i < clients.length; i++) {
        methods.setClient(clients[i]);
      }
    }
  }

  PlasmaCore.DataSource {
    id: shell
    engine: "executable"
    connectedSources: []
    onNewData: {
      var stdout = data["stdout"]
      exited(sourceName, stdout)
      disconnectSource(sourceName) // cmd finished
    }

    function exec(cmd) {
      connectSource(cmd)
    }

    signal exited(string sourceName, string stdout)
  }

  // ----
  // main
  // ----
  Component.onCompleted: {
    methods.refresh();
    workspace.clientActivated.connect(methods.setClient);

    KWin.registerShortcut('Opacity Control: Toggle Active', 'Opacity Control: Toggle Active', 'Meta+O', function () {
      let client = workspace.activeClient;
      if (methods.validate(client)) {
        client.opacity = client.opacity < 1 ? 1 : parameters.opacityValue;
      }
    });

    KWin.registerShortcut('Opacity Control: Toggle All', 'Opacity Control: Toggle All', 'Ctrl+Meta+O', function () {
      parameters.opacityShow = !parameters.opacityShow;
      methods.refresh();
    });
  }
}
