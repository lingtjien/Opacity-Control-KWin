import QtQuick 2.0

Item {
  Config {
    id: config
  }

  Manager {
    id: manager
  }

  readonly property string saveName: 'Callback'
  function connectSave(obj, prop, callback) {
    obj[prop + saveName] = callback;
    obj[prop].connect(callback);
  }
  function disconnectRemove(obj, prop) {
    obj[prop].disconnect(obj[prop + saveName]);
    delete obj[prop + saveName];
  }

  Component.onCompleted: {
    manager.init();

    connectSave(workspace, 'clientRemoved', manager.remove);
    connectSave(workspace, 'clientActivated', manager.render);
    connectSave(workspace, 'clientAdded', manager.render);

    KWin.registerShortcut('Opacity Control: Toggle Active', 'Opacity Control: Toggle Active', 'Meta+O', () => {
      manager.toggle(workspace.activeClient);
    });

    KWin.registerShortcut('Opacity Control: Toggle All', 'Opacity Control: Toggle All', 'Ctrl+Meta+O', () => {
      config.opacityShow = !config.opacityShow;
      manager.init();
    });
  }

  Component.onDestruction: {
    disconnectRemove(workspace, 'clientAdded');
    disconnectRemove(workspace, 'clientActivated');
    disconnectRemove(workspace, 'clientRemoved');
  }
}
