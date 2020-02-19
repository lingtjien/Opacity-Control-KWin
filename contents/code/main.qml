import QtQuick 2.0;
import org.kde.plasma.core 2.0 as Core;

Item {
  Core.DataSource {
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

  Component.onCompleted: {
    const Algorithm = {
      trimSplitString: (input) => {
        let pieces = [];
        for (let piece of input.split(',')) {
          piece = piece.trim();
          if (piece.length > 0)
            pieces.push(piece);
        }
        return pieces;
      }
    };

    const Parameters = {
      blur: KWin.readConfig('blur', true),
      opacity: {
        show: KWin.readConfig('opacityShow', true),
        value: KWin.readConfig('opacityValue', 0.9)
      },
      ignored: {
        types: Algorithm.trimSplitString(KWin.readConfig('ignoredTypes', 'specialWindow')),
        names: Algorithm.trimSplitString(KWin.readConfig('ignoredNames', 'ksmserver, inkscape, gimp, krita, gwenview')),
        captions: Algorithm.trimSplitString(KWin.readConfig('ignoredCaptions', ''))
      }
    };

    const Added = {
      all: {},
      add: (client) => {
        if (Added.all.hasOwnProperty(client.windowId))
          return false;
        Added.all[client.windowId] = client.opacity === 1;
        return true;
      },
      toggle: (client) => {
        if (!Added.all.hasOwnProperty(client.windowId))
          return false;
        Added.all[client.windowId] = !Added.all[client.windowId];
        return true;
      },
      remove: (client) => {
        if (!Added.all.hasOwnProperty(client.windowId))
          return false;
        delete Added.all[client.windowId];
        return true;
      }
    };

    const Client = {
      validate: (client) => {
        if (client === null)
          return false;
        for (let type of Parameters.ignored.types) {
          if (client[type])
            return false;
        }

        if (Parameters.ignored.captions.includes(client.caption.toString()))
          return false;
        for (let ignored of Parameters.ignored.names) {
          if (client.resourceClass.toString().includes(ignored) || client.resourceName.toString().includes(ignored))
            return false;
        }
        return true;
      },
      blur: (client) => {
        if (!shell)
          return;
        shell.exec('xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id ' + client.windowId.toString());
      },
      render: (client) => {
        if (!Client.validate(client))
          return false;

        if (Added.all.hasOwnProperty(client.windowId))
          client.opacity = Added.all[client.windowId] ? Parameters.opacity.value : 1;
        else
          client.opacity = Parameters.opacity.show ? Parameters.opacity.value : 1;

        if (Parameters.blur)
          Client.blur(client);
        return true;
      }
    }

    function Render () {
      let clients = workspace.clientList();
      for (let i = 0; i < clients.length; i++) {
        Client.render(clients[i]);
      }
    }

    // ----
    // main
    // ----
    Render();
    workspace.clientAdded.connect(Client.render);
    workspace.clientActivated.connect(Client.render);
    workspace.clientRemoved.connect((client) => {
      return Added.remove(client);
    });

    KWin.registerShortcut('Opacity Control: Toggle Active', 'Opacity Control: Toggle Active', 'Meta+O', () => {
      let client = workspace.activeClient;
      if (Client.validate(client)) {
        if (!Added.add(client)) {
          if (Added.all[client.windowId] === Parameters.opacity.show) {
            Added.toggle(client);
          } else {
            Added.remove(client);
          }
        }
        Client.render(client);
      }
    });

    KWin.registerShortcut('Opacity Control: Toggle All', 'Opacity Control: Toggle All', 'Ctrl+Meta+O', () => {
      Parameters.opacity.show = !Parameters.opacity.show;
      Render();
    });
  }
}
