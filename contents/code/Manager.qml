import QtQuick 2.0
import org.kde.plasma.core 2.0 as Core

Item {
  Core.DataSource {
    id: shell
    engine: "executable"
    connectedSources: []
    onNewData: {
      let stdout = data["stdout"]
      exited(sourceName, stdout)
      disconnectSource(sourceName) // cmd finished
    }

    function exec(cmd) {
      connectSource(cmd)
    }

    signal exited(string sourceName, string stdout)
  }

  function blur(client) {
    if (shell)
      shell.exec('xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id ' + client.windowId.toString());
  }

  property var added: Object()

  function ignored(client) {
    return config.ignored.captions.some(c => c === client.caption) ||
    config.ignored.names.some(n => client.name.includes(n));
  }

  function addProps(client) {
    client.name = String(client.resourceName);
    return client;
  }

  // public
  function render(client) {
    if (client && !ignored(addProps(client))) {
      client.opacity = added.hasOwnProperty(client.windowId) ? added[client.windowId] : config.opacityNormal;
      if (config.blur)
        blur(client);
      return client;
    }
  }

  function toggle(client) {
    if (client && !ignored(addProps(client))) {
      if (!added.hasOwnProperty(client.windowId))
        added[client.windowId] = config.opacityInverse;
      else
        delete added[client.windowId];
      render(client);
      return client;
    }
  }

  function remove(client) {
    if (client && added.hasOwnProperty(client.windowId)) {
      delete added[client.windowId];
      return true;
    }
  }

  function init() {
    for (const client of Object.values(workspace.clientList()))
      render(client);
  }
}
