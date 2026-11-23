// Firefox Min UI v0.19
try {
  var _mi19Services = Services;
  var _mi19Pref = 'extensions.minui.runtime.';
  function _mi19Mark(value) {
    try {
      var s = String(value).slice(0, 240);
      _mi19Services.prefs.setStringPref(_mi19Pref + 'stage', s);
      var prior = _mi19Services.prefs.getStringPref(_mi19Pref + 'trace', '');
      var next = (prior ? prior + ' | ' : '') + s;
      _mi19Services.prefs.setStringPref(_mi19Pref + 'trace', next.slice(-1800));
    } catch (_) {}
  }
  _mi19Services.prefs.setStringPref(_mi19Pref + 'trace', '');
  _mi19Mark('v17-autoconfig-executado');
  if (!_mi19Services.appinfo.inSafeMode) {
    var _mi19Controller = {
      hooked: new WeakSet(),
      loaded: new WeakSet(),
      tryWindow(win, from) {
        try {
          if (!win || win.closed || this.loaded.has(win)) return;
          var doc = win.document;
          var uri = String(doc && doc.documentURI || '');
          if (!uri.startsWith('chrome://browser/content/browser.xhtml')) return;
          _mi19Mark('janela-browser:' + from);
          if (!win.gBrowser || !win.gURLBar) {
            _mi19Mark('janela-ainda-inicializando:' + from);
            return;
          }
          var profile = _mi19Services.dirsvc.get('ProfD', Ci.nsIFile);
          var marker = profile.clone();
          marker.append('chrome'); marker.append('minui-v04.enabled');
          if (!marker.exists() || !marker.isFile()) {
            _mi19Mark('perfil-sem-marcador'); return;
          }
          var source = profile.clone();
          source.append('chrome');
          source.append('minui-v19-browser.js');
          if (!source.exists() || !source.isFile()) {
            _mi19Mark('script-ausente:perfil-chrome'); return;
          }
          if (source.fileSize < 1000) {
            _mi19Mark('script-invalido:tamanho'); return;
          }
          _mi19Mark('script-localizado:perfil-chrome');
          _mi19Mark('injetando-script-local-com-autorizacao:' + from);
          this.loaded.add(win);
          try {
            _mi19Services.scriptloader.loadSubScriptWithOptions(
              _mi19Services.io.newFileURI(source).spec,
              { target: win, charset: 'UTF-8', allowUnsafeURL: true });
            if (!win.__minuiV17) _mi19Mark('subscript-carregado-mas-ui-nao-iniciou');
          } catch (e) {
            this.loaded.delete(win);
            _mi19Mark('erro-injecao:' + String(e).slice(0, 130));
            Cu.reportError(e);
          }
        } catch (e) {
          _mi19Mark('erro-janela:' + String(e).slice(0, 130));
          Cu.reportError(e);
        }
      },
      watchWindow(win, from) {
        try {
          if (!win || this.hooked.has(win)) {
            this.tryWindow(win, from); return;
          }
          this.hooked.add(win);
          _mi19Mark('janela-observada:' + from);
          var self = this;
          var trigger = function() { self.tryWindow(win, 'load'); };
          win.addEventListener('DOMContentLoaded', trigger, true);
          win.addEventListener('load', trigger, true);
          this.tryWindow(win, from);
        } catch (e) { _mi19Mark('erro-hook:' + String(e).slice(0, 130)); }
      },
      observe(subject, topic) {
        if (topic === 'domwindowopened') {
          this.watchWindow(subject, 'domwindowopened');
        } else if (topic === 'browser-delayed-startup-finished') {
          this.watchWindow(subject, 'delayed-startup');
          this.tryWindow(subject, 'delayed-startup');
        }
      }
    };
    _mi19Services.obs.addObserver(_mi19Controller, 'browser-delayed-startup-finished');
    _mi19Services.ww.registerNotification(_mi19Controller);
    _mi19Mark('ganchos-registrados');
    var _mi19Count = 0;
    var _mi19Windows = _mi19Services.wm.getEnumerator(null);
    while (_mi19Windows.hasMoreElements()) {
      _mi19Count++;
      _mi19Controller.watchWindow(_mi19Windows.getNext(), 'enumeracao');
    }
    if (_mi19Count === 0) _mi19Mark('aguardando-primeira-janela');
  } else _mi19Mark('modo-seguro');
} catch (error) {
  try { Services.prefs.setStringPref('extensions.minui.runtime.stage', 'erro-autoconfig:' + String(error).slice(0, 100)); Cu.reportError(error); }
  catch (_) {}
}


