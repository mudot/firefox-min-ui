@echo off
setlocal
set "MINUI_SELF=%~f0"
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$identity=[Security.Principal.WindowsIdentity]::GetCurrent(); $principal=New-Object Security.Principal.WindowsPrincipal($identity); if(-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){Start-Process -FilePath $env:MINUI_SELF -Verb RunAs; exit}; $src=Get-Content -LiteralPath $env:MINUI_SELF -Raw -Encoding UTF8; $mark='__MINUI_PAYLOAD_BELOW__'; $idx=$src.LastIndexOf($mark); if($idx -lt 0){throw 'Payload não encontrado'}; & ([ScriptBlock]::Create($src.Substring($idx+$mark.Length)))"
exit /b
__MINUI_PAYLOAD_BELOW__
$ErrorActionPreference = 'Stop'
$Version = '0.19.0-beta'
$Owner = 'Firefox Min UI v0.19'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$PrefSource = @'
// Firefox Min UI v0.19
pref("general.config.filename", "minui.cfg");
pref("general.config.obscure_value", 0);
pref("general.config.sandbox_enabled", false);
'@
$ConfigSource = @'
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
'@
$UiSource = @'
/* Firefox Min UI v0.19 */
(() => {
  'use strict';
  const w = window, d = w.document, root = d.documentElement;
  if (w.__minuiV19 || !String(d.documentURI || '').startsWith('chrome://browser/content/browser.xhtml')) return;
  w.__minuiV19 = true;
  const S = w.Services || ChromeUtils.importESModule('resource://gre/modules/Services.sys.mjs').Services;
  const stage = (value) => {
    try {
      S.prefs.setStringPref('extensions.minui.runtime.stage', value);
      const old = S.prefs.getStringPref('extensions.minui.runtime.trace', '');
      S.prefs.setStringPref('extensions.minui.runtime.trace',
        (old + ' | ' + value).slice(-1800));
    } catch (_) {}
  };
  const note = (message) => { try { w.console.warn('[Min UI v0.19]', message); } catch (_) {} };
  stage('v19-script-inicializado');
  const style = d.createElementNS('http://www.w3.org/1999/xhtml', 'style');
  style.setAttribute('data-minui-v19', '');
  style.textContent = ":root[minui-v19-mounted=\"true\"] {\n  --minui-css-ready: yes;\n  --minui-row: 42px;\n  --minui-duration: 310ms;\n  --minui-ease: cubic-bezier(.22,.75,.20,1);\n  --tab-border-radius: 0px !important;\n}\n@media (min-width: 1100px) {\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar {\n    display: flex !important;\n    flex-direction: row !important;\n    flex-wrap: nowrap !important;\n    align-items: center !important;\n    gap: 0 !important;\n    position: relative !important;\n    box-sizing: border-box !important;\n    width: 100% !important;\n    height: var(--minui-row) !important;\n    min-height: var(--minui-row) !important;\n    max-height: var(--minui-row) !important;\n    padding: 0 !important;\n    margin: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > .toolbar-items {\n    display: flex !important;\n    flex: 1 1 0px !important;\n    width: 0 !important;\n    min-width: 0 !important;\n    max-width: none !important;\n    overflow: hidden !important;\n    align-items: center !important;\n    opacity: 1 !important;\n    transform: translateX(0) !important;\n    transition: flex-grow var(--minui-duration) var(--minui-ease),\n      opacity 180ms ease, background-color var(--minui-duration) var(--minui-ease) !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar #tabbrowser-tabs,\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar #tabbrowser-arrowscrollbox {\n    min-width: 0 !important;\n    max-width: 100% !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar {\n    display: flex !important;\n    flex: 0 0 auto !important;\n    align-items: center !important;\n    width: max-content !important;\n    min-width: max-content !important;\n    max-width: none !important;\n    height: var(--minui-row) !important;\n    min-height: var(--minui-row) !important;\n    max-height: var(--minui-row) !important;\n    box-sizing: border-box !important;\n    margin: 0 !important;\n    padding: 0 4px !important;\n    border: 0 !important;\n    box-shadow: none !important;\n    background: transparent !important;\n    position: relative !important;\n    overflow: visible !important;\n    z-index: 3 !important;\n    transition: flex-grow var(--minui-duration) var(--minui-ease) !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target {\n    display: flex !important;\n    flex: 0 0 auto !important;\n    align-items: center !important;\n    flex-wrap: nowrap !important;\n    gap: 0 !important;\n    width: max-content !important;\n    min-width: max-content !important;\n    max-width: none !important;\n    overflow: visible !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target > :not(#urlbar-container),\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar > :not(#nav-bar-customization-target):not(.titlebar-buttonbox-container) {\n    flex: 0 0 auto !important;\n    flex-shrink: 0 !important;\n    min-width: max-content !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar .toolbarspring,\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > .titlebar-spacer {\n    display: none !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #nav-bar .titlebar-buttonbox-container,\n  :root[minui-v19-mounted=\"true\"] #nav-bar #window-controls,\n  :root[minui-v19-mounted=\"true\"] #toolbar-menubar > .titlebar-buttonbox-container,\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #window-controls {\n    display: none !important;\n    visibility: collapse !important;\n    flex: 0 0 0px !important;\n    width: 0 !important;\n    min-width: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > .titlebar-buttonbox-container {\n    display: flex !important;\n    flex: 0 0 auto !important;\n    order: 99 !important;\n    position: static !important;\n    min-width: max-content !important;\n    height: var(--minui-row) !important;\n    margin: 0 !important;\n    padding: 0 !important;\n    background: transparent !important;\n    z-index: 5 !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > .titlebar-buttonbox-container .titlebar-buttonbox {\n    display: flex !important;\n    height: 100% !important;\n    padding: 0 !important;\n    margin: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > .titlebar-buttonbox-container .titlebar-button {\n    height: 100% !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar toolbarbutton {\n    align-self: center !important;\n    margin-block: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar .toolbarbutton-icon,\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar .toolbarbutton-badge-stack {\n    align-self: center !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target > #urlbar-container {\n    position: relative !important;\n    inset: auto !important;\n    top: auto !important;\n    left: auto !important;\n    right: auto !important;\n    flex: 0 0 0px !important;\n    box-sizing: border-box !important;\n    width: 0 !important;\n    min-width: 0 !important;\n    max-width: 0 !important;\n    margin: 0 !important;\n    padding: 0 !important;\n    border: 0 !important;\n    opacity: 0 !important;\n    transform: none !important;\n    transform-origin: center !important;\n    overflow: hidden !important;\n    pointer-events: none !important;\n    transition: flex-grow var(--minui-duration) var(--minui-ease),\n      max-width var(--minui-duration) var(--minui-ease),\n      opacity 160ms ease, background-color var(--minui-duration) var(--minui-ease) !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > .toolbar-items {\n    flex: 0 1 0px !important;\n    opacity: 0 !important;\n    transform: translateX(-6px) !important;\n    pointer-events: none !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar {\n    flex: 1 1 0px !important;\n    width: auto !important;\n    min-width: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target {\n    flex: 1 1 0px !important;\n    width: auto !important;\n    min-width: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target > #urlbar-container {\n    flex: 1 1 0px !important;\n    width: auto !important;\n    min-width: 200px !important;\n    max-width: 100vw !important;\n    margin-inline: 8px !important;\n    padding: 0 !important;\n    opacity: 1 !important;\n    transform: none !important;\n    overflow: visible !important;\n    pointer-events: auto !important;\n  }\n  :root[minui-v19-mounted=\"true\"] .tabbrowser-tab .tab-background,\n  :root[minui-v19-mounted=\"true\"] .tabbrowser-tab .tab-content {\n    border-radius: 0 !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #urlbar-background { border-radius: 5px !important; }\n  :root[minui-v19-mounted=\"true\"] #urlbar { z-index: 15 !important; }\n}\n@media (prefers-reduced-motion: reduce) {\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > .toolbar-items,\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar > #nav-bar,\n  :root[minui-v19-mounted=\"true\"] #TabsToolbar #urlbar-container {\n    transition: none !important;\n  }\n}\n\n@media (min-width: 1100px) {\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > .toolbar-items {\n    flex: 1 1 auto !important;\n    opacity: 0 !important;\n    pointer-events: none !important;\n    visibility: hidden !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar {\n    position: absolute !important;\n    inset-inline-start: 0 !important;\n    inset-inline-end: var(--minui-caption-width, 138px) !important;\n    top: 0 !important;\n    bottom: auto !important;\n    width: auto !important;\n    min-width: 0 !important;\n    max-width: none !important;\n    height: var(--minui-row) !important;\n    margin: 0 !important;\n    padding: 0 4px !important;\n    flex: none !important;\n    z-index: 4 !important;\n    overflow: visible !important;\n    box-sizing: border-box !important;\n    background: transparent !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target {\n    display: flex !important;\n    flex: 1 1 0px !important;\n    width: auto !important;\n    min-width: 0 !important;\n    max-width: none !important;\n    align-items: center !important;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target > #urlbar-container {\n    flex: 1 1 0px !important;\n    min-width: 180px !important;\n    max-width: none !important;\n    width: auto !important;\n    margin-inline: 8px !important;\n    opacity: 1 !important;\n    transform: none !important;\n    animation: minui-url-fade 220ms ease-out both;\n  }\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > .titlebar-buttonbox-container {\n    z-index: 6 !important;\n  }\n}\n@keyframes minui-url-fade {\n  from { opacity: .3; }\n  to { opacity: 1; }\n}\n@media (prefers-reduced-motion: reduce) {\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #TabsToolbar > #nav-bar > #nav-bar-customization-target > #urlbar-container {\n    animation: none !important;\n  }\n}\n\n@media (min-width: 1100px) {\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #urlbar[breakout-extend] > .urlbar-input-container,\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #urlbar:popover-open > .urlbar-input-container,\n  :root[minui-v19-mounted=\"true\"][minui-v19-open=\"true\"] #urlbar[popover-open] > .urlbar-input-container {\n    min-height: var(--urlbar-height, 32px) !important;\n    flex: 0 0 auto !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #urlbar[minui-popup-repair=\"true\"]:is(:popover-open, [breakout-extend], [open]) {\n    position: fixed !important;\n    inset: auto !important;\n    left: var(--minui-popup-left) !important;\n    top: var(--minui-popup-top) !important;\n    width: var(--minui-popup-width) !important;\n    min-width: var(--minui-popup-width) !important;\n    max-width: var(--minui-popup-width) !important;\n    margin: 0 !important;\n    transform: none !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #urlbar[minui-popup-repair=\"true\"] .urlbarView {\n    width: 100% !important;\n    max-width: 100% !important;\n    box-sizing: border-box !important;\n  }\n  :root[minui-v19-mounted=\"true\"] .urlbarView[minui-popup-repair=\"true\"]:popover-open {\n    position: fixed !important;\n    inset: auto !important;\n    left: var(--minui-popup-left) !important;\n    top: var(--minui-popup-view-top) !important;\n    width: var(--minui-popup-width) !important;\n    max-width: var(--minui-popup-width) !important;\n    min-width: var(--minui-popup-width) !important;\n    box-sizing: border-box !important;\n    transform: none !important;\n  }\n  :root[minui-v19-mounted=\"true\"] #urlbar[minui-popup-repair=\"true\"] .urlbarView-results,\n  :root[minui-v19-mounted=\"true\"] .urlbarView[minui-popup-repair=\"true\"] .urlbarView-results {\n    max-height: min(58vh, 560px) !important;\n    overflow-y: auto !important;\n  }\n}\n\n";
  (d.head || root).appendChild(style);
  const mountedAttr = 'minui-v19-mounted', openAttr = 'minui-v19-open';
  let n = null, mounted = false, pending = 0, retry = 0, failed = false, observed = null, pointer = null;
  const newTabs = new WeakSet();
  const secondaryNewTabs = new WeakSet();
  let newTabSequenceConsumed = false;
  let firstNewTab = null;
  let firstFocusPending = false;
  let manualFocusTab = null;
  let newTabFocusJob = 0;
  let suppressFocusJob = 0;
  function find() {
    const tabs = d.getElementById('TabsToolbar');
    const nav = d.getElementById('nav-bar');
    const controls = tabs?.querySelector(':scope > .titlebar-buttonbox-container');
    const strip = w.gBrowser?.tabContainer;
    const input = w.gURLBar?.inputField;
    if (!tabs || !nav || !controls || !strip || !input) return null;
    return { tabs, nav, controls, strip, input, parent: nav.parentNode, next: nav.nextSibling };
  }
  function allowed() {
    return !!n && !failed && w.innerWidth >= 1100 &&
      !root.hasAttribute('customizing') && !root.hasAttribute('inFullscreen') &&
      !String(root.getAttribute('chromehidden') || '').includes('toolbar');
  }
  function hasFocus() { return d.activeElement === n?.input || !!d.getElementById('urlbar')?.contains(d.activeElement); }
  function open(focus = true) {
    if (!mounted) return;
    widths();
    root.setAttribute(openAttr, 'true');
    w.setTimeout(validateLayout, 410);
    w.setTimeout(schedulePopupCheck, 380);
    if (focus) w.requestAnimationFrame(() => {
      if (!mounted) return;
      try { w.gURLBar.focus(); n.input.select(); } catch (e) { note(e); }
    });
  }
  function close(content = false) {
    if (!mounted) return;
    clearPopupRepair();
    root.removeAttribute(openAttr);
    if (content && hasFocus()) {
      try { n.input.blur(); w.gBrowser.selectedBrowser.focus(); } catch (_) {}
    }
  }
  function visible(el) {
    if (!el || el.hidden) return false;
    const cs = w.getComputedStyle(el);
    return cs.display !== 'none' && cs.visibility !== 'hidden' && cs.visibility !== 'collapse';
  }
  function collisionReason() {
    if (!n || !mounted) return '';
    const tabsBox = n.tabs.getBoundingClientRect();
    const navBox = n.nav.getBoundingClientRect();
    const capBox = n.controls.getBoundingClientRect();
    const tabsRegion = n.tabs.querySelector(':scope > .toolbar-items');
    const tabRegionBox = tabsRegion?.getBoundingClientRect();
    if (w.getComputedStyle(root).getPropertyValue('--minui-css-ready').trim() !== 'yes') return 'css-ausente';
    if (Math.abs(tabsBox.y - navBox.y) > 12) return 'nav-desalinhada';
    if (navBox.width < 40 || navBox.right > capBox.left + 3) return 'nav-colide-controles-janela';
    if (root.hasAttribute(openAttr)) {
      if (navBox.left > tabsBox.left + 32) return 'edicao-nao-ocupa-inicio-da-faixa';
      if (navBox.right < capBox.left - 32) return 'edicao-nao-ocupa-final-da-faixa';
    }
    if (!root.hasAttribute(openAttr) && tabRegionBox && tabRegionBox.right > navBox.left + 3) return 'abas-colidem-nav';
    const duplicates = [...n.nav.querySelectorAll('.titlebar-buttonbox-container,#window-controls')];
    if (duplicates.some(visible)) return 'controles-janela-duplicados';
    const target = d.getElementById('nav-bar-customization-target');
    if (!target) return 'barra-sem-container';
    const siblings = [...target.children].filter(el =>
      el.id !== 'urlbar-container' && visible(el) && el.getBoundingClientRect().width > 1);
    for (let i = 1; i < siblings.length; i++) {
      const a = siblings[i-1].getBoundingClientRect();
      const b = siblings[i].getBoundingClientRect();
      if (a.right > b.left + 3 && a.width > 1 && b.width > 1) return 'botoes-navegacao-sobrepostos';
    }
    const navSiblings = [...n.nav.children].filter(el =>
      el.id !== 'urlbar-container' && !el.matches('.titlebar-buttonbox-container,#window-controls') &&
      visible(el) && el.getBoundingClientRect().width > 1);
    for (let i = 1; i < navSiblings.length; i++) {
      const a = navSiblings[i-1].getBoundingClientRect();
      const b = navSiblings[i].getBoundingClientRect();
      if (a.right > b.left + 3) return 'regioes-navegacao-sobrepostas';
    }
    if (root.hasAttribute(openAttr)) {
      const address = d.getElementById('urlbar-container')?.getBoundingClientRect();
      if (!address || address.width < 190 || address.left < navBox.left - 4 ||
          address.right > capBox.left - 4) return 'address-not-in-center-flow';
      const ordered = [...target.children].filter(el => visible(el) &&
        el.getBoundingClientRect().width > 1);
      const index = ordered.findIndex(el => el.id === 'urlbar-container');
      if (index < 0) return 'address-not-in-toolbar';
      const previous = index > 0 ? ordered[index - 1].getBoundingClientRect() : null;
      const next = index + 1 < ordered.length ? ordered[index + 1].getBoundingClientRect() : null;
      if ((previous && address.left < previous.right - 3) ||
          (next && address.right > next.left + 3)) return 'address-overlaps-actions';
    }
    if (navBox.left < tabsBox.left - 3) return 'nav-fora-da-tela';
    return '';
  }
  function validateLayout() {
    if (!mounted) return;
    try {
      const error = collisionReason();
      if (error) {
        failed = true;
        restore();
        stage('falha-layout-autorrevertido:' + error);
        note('Interface restaurada: ' + error);
      } else {
        const addressWidth = Math.round(d.getElementById('urlbar-container')?.getBoundingClientRect().width || 0);
        const navLeft = Math.round(n.nav.getBoundingClientRect().left);
        stage('interface-ativa:sem-sobreposicao' + (root.hasAttribute(openAttr) ? ':endereco=' + addressWidth + ':inicio=' + navLeft : ''));
      }
    } catch (e) { failed = true; restore(); stage('falha-validacao-layout'); note(e); }
  }
  function widths() {
    if (!mounted || !n?.controls) return;
    const r = n.controls.getBoundingClientRect();
    const width = Math.ceil(r.width);
    if (width >= 70 && width < w.innerWidth / 3) {
      root.style.setProperty('--minui-caption-width', width + 'px');
    }
  }
  let popupObserver = null, popupRaf = 0, popupTimer = 0, popupFailures = 0;
  function clearPopupRepair() {
    const urlbar = d.getElementById('urlbar');
    urlbar?.removeAttribute('minui-popup-repair');
    urlbar?.querySelector('.urlbarView')?.removeAttribute('minui-popup-repair');
    root.style.removeProperty('--minui-popup-left');
    root.style.removeProperty('--minui-popup-top');
    root.style.removeProperty('--minui-popup-view-top');
    root.style.removeProperty('--minui-popup-width');
    popupFailures = 0;
  }
  function popupIsVisible(urlbar) {
    return !!urlbar && (!!w.gURLBar?.view?.isOpen ||
      urlbar.matches(':popover-open') || urlbar.hasAttribute('breakout-extend') ||
      !!urlbar.querySelector('.urlbarView')?.matches(':popover-open'));
  }
  function popupGeometryIsInvalid(container, urlbar, view) {
    const a = container.getBoundingClientRect();
    const b = urlbar.getBoundingClientRect();
    const c = view?.getBoundingClientRect();
    if (a.width < 210) return false;
    const narrow = b.width < Math.max(160, a.width * .67) ||
      (c && c.width > 1 && c.width < Math.max(150, a.width * .62));
    const displaced = b.width > 5 && Math.abs(b.left - a.left) > 65;
    const strip = c && c.width < 170 && c.height > 280;
    return narrow || displaced || strip;
  }
  function checkPopup() {
    popupRaf = 0;
    if (!mounted || !root.hasAttribute(openAttr)) { clearPopupRepair(); return; }
    const urlbar = d.getElementById('urlbar');
    const container = d.getElementById('urlbar-container');
    const view = urlbar?.querySelector('.urlbarView');
    if (!container || !popupIsVisible(urlbar)) { clearPopupRepair(); return; }
    if (!popupGeometryIsInvalid(container, urlbar, view)) {
      if (urlbar.hasAttribute('minui-popup-repair') || view?.hasAttribute('minui-popup-repair'))
        stage('autocomplete-geometria-corrigida');
      popupFailures = 0;
      return;
    }
    const rect = container.getBoundingClientRect();
    root.style.setProperty('--minui-popup-left', Math.round(rect.left) + 'px');
    root.style.setProperty('--minui-popup-top', Math.round(rect.top) + 'px');
    root.style.setProperty('--minui-popup-view-top', Math.round(rect.bottom) + 'px');
    root.style.setProperty('--minui-popup-width', Math.round(rect.width) + 'px');
    if (view?.matches(':popover-open')) view.setAttribute('minui-popup-repair', 'true');
    else urlbar.setAttribute('minui-popup-repair', 'true');
    stage('autocomplete-ajuste-' + (++popupFailures));
    if (popupFailures >= 4) {
      stage('autocomplete-fallback-layout-nativo');
      failed = true;
      try { w.gURLBar?.view?.close(); } catch (_) {}
      restore();
      try { w.gURLBar?.focus(); } catch (_) {}
    } else {
      w.clearTimeout(popupTimer);
      popupTimer = w.setTimeout(schedulePopupCheck, 90);
    }
  }
  function schedulePopupCheck() {
    if (popupRaf) return;
    popupRaf = w.requestAnimationFrame(checkPopup);
  }
  function restore() {
    w.clearTimeout(newTabFocusJob);
    w.clearTimeout(suppressFocusJob);
    w.clearTimeout(popupTimer);
    clearPopupRepair();
    root.removeAttribute(openAttr);
    root.removeAttribute(mountedAttr);
    root.style.removeProperty('--minui-caption-width');
    if (!n) return;
    try {
      if (n.nav.parentNode !== n.parent) {
        if (n.next?.parentNode === n.parent) n.parent.insertBefore(n.nav, n.next);
        else n.parent.appendChild(n.nav);
      }
    } catch (e) { note(e); }
    mounted = false;
  }
  function mount() {
    if (!allowed() || mounted) return;
    try {
      if (n.nav.parentNode !== n.parent) throw new Error('A barra de navegacao foi alterada por outra personalizacao.');
      n.tabs.insertBefore(n.nav, n.controls);
      root.setAttribute(mountedAttr, 'true');
      mounted = true;
      widths();
      stage('montado-pendente-validacao');
      if (hasFocus() && !shouldSuppressAutoFocus(w.gBrowser?.selectedTab)) open(false);
      w.setTimeout(validateLayout, 450);
    } catch (e) {
      failed = true; restore(); stage('falha-montagem'); note(e);
    }
  }
  function reconcile() {
    pending = 0;
    if (allowed()) { mount(); widths(); }
    else if (mounted) restore();
    else if (!failed && n) stage('layout-inativo:largura-ou-modo');
  }
  function queue() { if (!pending) pending = w.requestAnimationFrame(reconcile); }
  function isDormant(tab) {
    return !tab || tab.closing || tab.linkedPanel === null ||
      !!tab.hasAttribute?.('pending') || !!tab.hasAttribute?.('discarded') ||
      !!tab.hasAttribute?.('restoring');
  }
  function isBlankNewTab(tab) {
    if (isDormant(tab)) return false;
    const uri = String(tab.linkedBrowser?.currentURI?.spec || '');
    return /^(?:about:newtab|about:blank|about:home)(?:[?#]|$)/.test(uri) ||
      (newTabs.has(tab) && uri.startsWith('moz-extension://'));
  }
  function shouldSuppressAutoFocus(tab) {
    if (!tab || manualFocusTab === tab) return false;
    return isDormant(tab) ||
      (isBlankNewTab(tab) && (secondaryNewTabs.has(tab) ||
      !(tab === firstNewTab && firstFocusPending)));
  }
  function suppressNativeAutoFocus(tab) {
    w.clearTimeout(suppressFocusJob);
    suppressFocusJob = w.setTimeout(() => {
      if (!mounted || w.gBrowser?.selectedTab !== tab || manualFocusTab === tab) return;
      if (hasFocus()) close(true);
      else root.removeAttribute(openAttr);
    }, 75);
  }
  function focusFirstNewTab(tab) {
    if (!mounted || !firstFocusPending || firstNewTab !== tab ||
        w.gBrowser?.selectedTab !== tab || !isBlankNewTab(tab)) return;
    firstFocusPending = false;
    manualFocusTab = tab;
    if (hasFocus()) open(false);
    else open(true);
    stage('primeira-nova-aba-endereco-aberto');
  }
  function onTabOpen(event) {
    const prior = w.gBrowser?.selectedTab;
    const tab = event.target;
    if (!tab || !tab.matches?.('.tabbrowser-tab') || isDormant(tab) ||
        event.detail?.adoptedTab || event.detail?.fromExternal) return;
    newTabs.add(tab);
    if (!isBlankNewTab(tab)) return;
    if (prior && prior !== tab && !isDormant(prior) && !isBlankNewTab(prior))
      newTabSequenceConsumed = false;
    if (!newTabSequenceConsumed) {
      newTabSequenceConsumed = true;
      firstNewTab = tab;
      firstFocusPending = true;
      w.clearTimeout(newTabFocusJob);
      newTabFocusJob = w.setTimeout(() => focusFirstNewTab(tab), 45);
    } else {
      secondaryNewTabs.add(tab);
      stage('nova-aba-adicional-sem-autofoco');
      suppressNativeAutoFocus(tab);
    }
  }
  function onTabSelect(event) {
    const tab = event.target;
    manualFocusTab = null;
    close();
    if (tab !== firstNewTab) {
      w.clearTimeout(newTabFocusJob);
      firstFocusPending = false;
    }
    if (isDormant(tab)) {
      stage('aba-adormecida-sem-autofoco');
      suppressNativeAutoFocus(tab);
    } else if (secondaryNewTabs.has(tab) || isBlankNewTab(tab) &&
               !(tab === firstNewTab && firstFocusPending)) {
      suppressNativeAutoFocus(tab);
    } else if (!isBlankNewTab(tab)) {
      newTabSequenceConsumed = false;
      firstNewTab = null;
      firstFocusPending = false;
    }
  }
  function isEditableTarget(target) {
    if (!target || !target.closest) return false;
    return !!target.closest('input,textarea,select,[contenteditable="true"],[role="textbox"],[role="searchbox"]');
  }
  function typeIntoAddress(character) {
    open(false);
    try {
      w.gURLBar.focus();
      const input = n.input;
      const start = input.selectionStart ?? input.value.length;
      const end = input.selectionEnd ?? start;
      input.setRangeText(character, start, end, 'end');
      input.dispatchEvent(new w.InputEvent('input', {
        bubbles: true, cancelable: false, data: character, inputType: 'insertText'
      }));
      stage('nova-aba-digitacao-iniciada');
      return true;
    } catch (error) {
      note(error);
      return false;
    }
  }
  function isAction(element) {
    return !!element?.closest?.('.tab-close-button,.tab-icon-overlay,.tab-audio-button,.tab-icon-sound,.tab-sharing-icon-overlay,.tab-group-label,.tab-group-overflow-button');
  }
  function pointerDown(e) {
    pointer = null;
    if (!mounted || e.button !== 0 || e.ctrlKey || e.shiftKey || e.metaKey || e.altKey || isAction(e.target)) return;
    const tab = e.target?.closest?.('.tabbrowser-tab');
    if (!tab) return;
    pointer = { tab, selected: tab === w.gBrowser.selectedTab, x: e.clientX, y: e.clientY };
  }
  function clicked(e) {
    const p = pointer; pointer = null;
    if (!mounted || !p || !p.selected || e.button !== 0 || e.detail !== 1 || isAction(e.target)) return;
    if (e.ctrlKey || e.shiftKey || e.metaKey || e.altKey) return;
    if (e.target?.closest?.('.tabbrowser-tab') !== p.tab || p.tab !== w.gBrowser.selectedTab) return;
    if (Math.abs(e.clientX - p.x) > 6 || Math.abs(e.clientY - p.y) > 6) return;
    manualFocusTab = w.gBrowser?.selectedTab;
    open();
  }
  function key(e) {
    if (!mounted) return;
    if ((e.ctrlKey || e.metaKey) && !e.altKey && String(e.key).toLowerCase() === 'l') {
      manualFocusTab = w.gBrowser?.selectedTab;
      open(false);
      return;
    }
    if (e.key === 'Escape' && root.hasAttribute(openAttr) && !w.gURLBar?.view?.isOpen) {
      close(true);
      return;
    }
    if (e.defaultPrevented || e.isComposing || e.ctrlKey || e.altKey || e.metaKey ||
        e.key?.length !== 1 || isEditableTarget(e.target) || hasFocus() ||
        !firstFocusPending || w.gBrowser?.selectedTab !== firstNewTab ||
        !isBlankNewTab(firstNewTab)) return;
    if (typeIntoAddress(e.key)) {
      e.preventDefault();
      e.stopPropagation();
    }
  }
  function bind() {
    n.strip.addEventListener('pointerdown', pointerDown, true);
    n.strip.addEventListener('click', clicked, true);
    n.strip.addEventListener('TabOpen', onTabOpen);
    n.strip.addEventListener('TabSelect', onTabSelect);
    n.input.addEventListener('focus', () => {
      const tab = w.gBrowser?.selectedTab;
      if (shouldSuppressAutoFocus(tab)) {
        suppressNativeAutoFocus(tab);
        return;
      }
      open(false);
    });
    n.input.addEventListener('input', () => {
      schedulePopupCheck();
      w.clearTimeout(popupTimer);
      popupTimer = w.setTimeout(schedulePopupCheck, 75);
    });
    const urlbar = d.getElementById('urlbar');
    if (urlbar) {
      popupObserver = new w.MutationObserver(schedulePopupCheck);
      popupObserver.observe(urlbar, { attributes: true,
        attributeFilter: ['open', 'breakout-extend', 'popover-open'] });
    }
    n.input.addEventListener('blur', () => w.setTimeout(() => {
      if (mounted && !hasFocus() && !w.gURLBar?.view?.isOpen) close();
      else schedulePopupCheck();
    }, 100));
    w.addEventListener('keydown', key, true);
    w.addEventListener('resize', () => {
      queue();
      if (mounted) w.setTimeout(() => {
        validateLayout();
      }, 360);
    });
    w.addEventListener('beforecustomization', restore);
    w.addEventListener('aftercustomization', queue);
    observed = new w.MutationObserver(queue);
    observed.observe(root, { attributes: true, attributeFilter: ['customizing','inFullscreen','chromehidden'] });
    w.addEventListener('unload', () => { popupObserver?.disconnect(); observed?.disconnect(); restore(); }, { once: true });
    stage('controles-encontrados');
    queue();
  }
  function waitForControls() {
    if (n) return;
    n = find();
    if (n) { stage('controles-localizados'); bind(); return; }
    if (++retry < 70) w.setTimeout(waitForControls, 200);
    else { failed = true; stage('erro-controles-nao-encontrados'); note('Controles nao encontrados apos 14 segundos.'); }
  }
  if (d.readyState === 'complete') waitForControls();
  else { w.addEventListener('load', waitForControls, { once: true }); w.setTimeout(waitForControls, 450); }
})();
'@

$script:Locale = 'en'
$script:I18n = @{
  en = @{
    title='Firefox Min UI'; subtitle='Minimal navigation for Firefox  •  v0.19 beta'; language='Language'; what='Designed to simplify';
    card1='One toolbar'; card1Body='Tabs, address and actions share a single, compact row.';
    card2='Controlled install'; card2Body='Backups, conflict checks and clear diagnostics.';
    card3='One-click rollback'; card3Body='Remove the interface using this same installer.';
    card4='Before you start'; card4Body='Close Firefox completely. A test profile is recommended.';
    setup='Configuration'; firefox='Firefox installation'; profile='Firefox profile'; choose='Browse...'; refresh='Refresh'; folder='Open folder';
    ack='I closed Firefox and understand this version is experimental.';
    install='Install / Update'; uninstall='Uninstall / Restore'; diagnose='Diagnostics'; close='Close'; status='Status'; log='Activity log';
    footer='Independent experimental project. Not affiliated with Mozilla.'; ready='Select Firefox and the profile to continue.';
    profilesUpdated='Firefox installations and profiles refreshed.'; selectFirst='Choose a Firefox installation and a profile.';
    selectedFirefox='Selected Firefox: '; selectedProfile='Selected profile: '; selectValidProfile='Select a valid profile first.';
    selectValidFirefox='Select a valid Firefox installation.'; selectValidProfileForInstall='Select a valid Firefox profile.';
    confirmAck='Confirm Firefox is closed and acknowledge the experimental version.';
    confirmInstall='Firefox: {0}`nProfile: {1}`n`nInstall or update Firefox Min UI?'; confirmInstallTitle='Confirm installation';
    confirmUninstall='Firefox: {0}`nProfile: {1}`n`nRemove Firefox Min UI and restore the normal toolbar?'; confirmUninstallTitle='Confirm removal';
    installing='Installing files...'; installed='Files updated. Start Firefox, then close it and run Diagnostics.';
    installDone='Files installed.`n`nBackup: {0}`n`nLaunch Firefox to test. Then close it and use Diagnostics to confirm activation.';
    installTitle='Firefox Min UI'; installationFailed='Installation failed.'; uninstalling='Removing files...'; uninstalled='Removal completed.';
    uninstallDone='Firefox Min UI was removed. Firefox will use its standard toolbar after restarting.'; uninstallFailed='Removal failed.';
    diagnosing='Checking installation...'; diagnoseTitle='Firefox Min UI diagnostics'; diagnoseUnavailable='Diagnostics unavailable.';
    diagnosticHeader='--- MIN UI DIAGNOSTICS v0.19 ---'; expectedScript='Expected script: profile chrome folder, not Firefox program folder.';
    present='present'; missing='MISSING'; integrity='Profile script integrity: '; yes='YES'; no='NO - file differs from installer';
    missingScript='Profile script is missing. Reinstall before launching Firefox.';
    legacyScript='Obsolete script detected in Firefox folder; current release does not use it.';
    loaderMismatch='Installed loader does not point to the v0.15 profile script.';
    loaderOld='Installed loader is missing the Firefox local-script permission fix.';
    loaderReady='Local script loader is configured correctly.';
    statusRecorded='Recorded stage: '; trace='Trace: '; noTrace='No runtime trace saved.';
    firefoxOpen='Firefox is running; prefs.js may not contain the latest state yet.';
    staleTrace='Trace is from an earlier launch. Restart Firefox after installation.';
    startupPending='Browser-window event not reached. Confirm the selected Firefox is the one you launched.';
    scriptFailure='The script could not be found or executed in this profile.';
    uiNotReady='The window was found but Firefox controls were not ready.';
    uiActive='Firefox Min UI was active and passed the last layout check.';
    diagnosisStatus='Diagnostics: '; diagResult='Last recorded stage: {0}`n`nTrace: {1}`n`nClose Firefox before diagnosing; runtime state is saved in prefs.js.';
    initialLog='Installer v0.15 is ready. File installation does not guarantee the browser interface has activated.';
    helpLog='Use Install / Update, Uninstall / Restore, or Diagnostics.';
    scriptInstalled='Files installed and backed up to: '; installStart='Installing into: '; profileStart='Selected profile: ';
    rollbackStart='Removing from: '; rollbackSuccess='Firefox Min UI removed successfully.';
    errorOpen='Firefox is open. Close every Firefox window before proceeding.';
    errorPrefdir='Firefox defaults/pref folder not found: ';
    errorUnknownPref='Existing minui-prefs.js is not recognized as a Min UI file. No changes were made.';
    errorOtherAuto='Another AutoConfig installation was found: ';
    errorUnknownFile='Unknown existing file. Not overwriting: ';
    errorScriptVerify='Installed UI script verification failed.';
    errorLoaderVerify='Installed loader verification failed.';
    errorPrefVerify='Installed AutoConfig verification failed.';
    errorRestore='Could not restore a file. Check backup: ';
    errorInstallStopped='Installation stopped and rollback attempted: ';
    errorBackup=' Backup: ';
    errorOtherProfile='Another Firefox profile still uses Min UI: ';
    errorDisableOther='. Disable it before uninstalling the global loader.';
    errorRemoveUnknown='Removal stopped: unknown existing file: ';
    fileDialogTitle='Select firefox.exe'; fileDialogFilter='Firefox (firefox.exe)|firefox.exe|Applications (*.exe)|*.exe|All files (*.*)|*.*';
    folderDialogTitle='Choose your Firefox profile folder'; errorPaths='Select Firefox and a profile first.'
  }
  pt = @{
    title='Firefox Min UI'; subtitle='Navegação minimalista para Firefox  •  v0.19 beta'; language='Idioma'; what='Criado para simplificar';
    card1='Barra única'; card1Body='Abas, endereço e ações na mesma faixa compacta.';
    card2='Instalação controlada'; card2Body='Backup, verificação de conflitos e diagnóstico claro.';
    card3='Reversão simples'; card3Body='Remova a interface usando este mesmo instalador.';
    card4='Antes de começar'; card4Body='Feche totalmente o Firefox. Recomendamos um perfil de testes.';
    setup='Configuração'; firefox='Instalação do Firefox'; profile='Perfil do Firefox'; choose='Escolher...'; refresh='Atualizar'; folder='Abrir pasta';
    ack='Fechei o Firefox e entendo que esta versão é experimental.';
    install='Instalar / Atualizar'; uninstall='Desinstalar / Reverter'; diagnose='Diagnosticar'; close='Fechar'; status='Status'; log='Registro de atividades';
    footer='Projeto experimental independente. Sem vínculo com a Mozilla.'; ready='Selecione o Firefox e o perfil para continuar.';
    profilesUpdated='Instalações do Firefox e perfis atualizados.'; selectFirst='Escolha o Firefox e o perfil desejado.';
    selectedFirefox='Firefox selecionado: '; selectedProfile='Perfil selecionado: '; selectValidProfile='Selecione primeiro um perfil válido.';
    selectValidFirefox='Selecione uma instalação válida do Firefox.'; selectValidProfileForInstall='Selecione um perfil válido do Firefox.';
    confirmAck='Confirme que o Firefox está fechado e aceite o aviso da versão experimental.';
    confirmInstall='Firefox: {0}`nPerfil: {1}`n`nInstalar ou atualizar o Firefox Min UI?'; confirmInstallTitle='Confirmar instalação';
    confirmUninstall='Firefox: {0}`nPerfil: {1}`n`nRemover o Firefox Min UI e restaurar a barra padrão?'; confirmUninstallTitle='Confirmar remoção';
    installing='Instalando arquivos...'; installed='Arquivos atualizados. Abra o Firefox, feche e execute Diagnosticar.';
    installDone='Arquivos instalados.`n`nBackup: {0}`n`nAbra o Firefox para testar. Depois feche e use Diagnosticar para confirmar a ativação.';
    installTitle='Firefox Min UI'; installationFailed='Falha na instalação.'; uninstalling='Removendo arquivos...'; uninstalled='Remoção concluída.';
    uninstallDone='Firefox Min UI removido. Após reiniciar, o Firefox usará sua barra padrão.'; uninstallFailed='Falha na remoção.';
    diagnosing='Verificando instalação...'; diagnoseTitle='Diagnóstico do Firefox Min UI'; diagnoseUnavailable='Diagnóstico indisponível.';
    diagnosticHeader='--- DIAGNÓSTICO MIN UI v0.19 ---'; expectedScript='Script esperado: pasta chrome do perfil, não a pasta do Firefox.';
    present='presente'; missing='AUSENTE'; integrity='Integridade do script do perfil: '; yes='SIM'; no='NÃO - arquivo diferente do instalador';
    missingScript='O script do perfil está ausente. Reinstale antes de abrir o Firefox.';
    legacyScript='Script antigo detectado na pasta do Firefox; a versão atual não o utiliza.';
    loaderMismatch='O carregador instalado não aponta para o script v0.15 do perfil.';
    loaderOld='O carregador não possui a correção de permissão de arquivo local do Firefox.';
    loaderReady='Carregador de script local configurado corretamente.';
    statusRecorded='Estado registrado: '; trace='Etapas: '; noTrace='Nenhuma trilha de execução salva.';
    firefoxOpen='Firefox aberto; prefs.js pode não conter o estado mais recente.';
    staleTrace='A trilha é de uma execução anterior. Reinicie o Firefox após instalar.';
    startupPending='A janela do navegador não foi detectada. Verifique a instalação selecionada.';
    scriptFailure='O script não foi encontrado ou executado neste perfil.';
    uiNotReady='A janela foi encontrada, mas os controles do Firefox não estavam prontos.';
    uiActive='Firefox Min UI ativado e validado na última execução.';
    diagnosisStatus='Diagnóstico: '; diagResult='Estado na última execução: {0}`n`nEtapas: {1}`n`nFeche o Firefox antes do diagnóstico; o estado fica salvo em prefs.js.';
    initialLog='Instalador v0.15 pronto. Instalar arquivos não garante a ativação da interface no navegador.';
    helpLog='Use Instalar / Atualizar, Desinstalar / Reverter ou Diagnosticar.';
    scriptInstalled='Arquivos instalados e backup em: '; installStart='Instalando em: '; profileStart='Perfil selecionado: ';
    rollbackStart='Removendo de: '; rollbackSuccess='Firefox Min UI removido com sucesso.';
    errorOpen='Firefox está aberto. Feche todas as janelas antes de continuar.';
    errorPrefdir='Pasta defaults/pref do Firefox não encontrada: ';
    errorUnknownPref='O arquivo minui-prefs.js não foi reconhecido como pertencente ao Min UI. Nenhuma alteração foi feita.';
    errorOtherAuto='Outro AutoConfig encontrado: ';
    errorUnknownFile='Arquivo existente desconhecido. Não será sobrescrito: ';
    errorScriptVerify='Falha na verificação do script de interface instalado.';
    errorLoaderVerify='Falha na verificação do carregador instalado.';
    errorPrefVerify='Falha na verificação do AutoConfig instalado.';
    errorRestore='Não foi possível restaurar um arquivo. Verifique o backup: ';
    errorInstallStopped='Instalação interrompida e reversão tentada: ';
    errorBackup=' Backup: ';
    errorOtherProfile='Outro perfil do Firefox ainda usa Min UI: ';
    errorDisableOther='. Desative-o antes de remover o carregador global.';
    errorRemoveUnknown='Remoção interrompida: arquivo desconhecido: ';
    fileDialogTitle='Escolha o firefox.exe'; fileDialogFilter='Firefox (firefox.exe)|firefox.exe|Executáveis (*.exe)|*.exe|Todos os arquivos (*.*)|*.*';
    folderDialogTitle='Escolha a pasta do perfil do Firefox'; errorPaths='Selecione o Firefox e um perfil primeiro.'
  }
}
function T([string]$key) { if ($script:I18n[$script:Locale].ContainsKey($key)) { return [string]$script:I18n[$script:Locale][$key] }; return $key }
function TF([string]$key, [object[]]$values) {
    $format = T $key
    $format = $format.Replace('`n', [Environment]::NewLine)
    return [string]::Format($format, $values)
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:LogBox = $null
$script:StatusLabel = $null
$script:Progress = $null

function Write-Log([string]$Message, [string]$Level = 'INFO') {
    $prefix = '[' + (Get-Date -Format 'HH:mm:ss') + '] [' + $Level + '] '
    $line = $prefix + $Message
    if ($script:LogBox) {
        $script:LogBox.AppendText($line + [Environment]::NewLine)
        $script:LogBox.SelectionStart = $script:LogBox.TextLength
        $script:LogBox.ScrollToCaret()
    }
}
function Set-Status([string]$Text, [bool]$Busy = $false) {
    if ($script:StatusLabel) { $script:StatusLabel.Text = $Text }
    if ($script:Progress) {
        if ($Busy) { $script:Progress.Style = 'Marquee'; $script:Progress.MarqueeAnimationSpeed = 25 }
        else { $script:Progress.Style = 'Continuous'; $script:Progress.Value = 0; $script:Progress.MarqueeAnimationSpeed = 0 }
    }
}
function With-LF([string]$s) { return (($s -replace "`r`n", "`n") -replace "`r", "`n") }
function SaveUtf8([string]$path, [string]$data) { [System.IO.File]::WriteAllText($path, (With-LF $data), $utf8) }

function Get-Profiles {
    $file = Join-Path $env:APPDATA 'Mozilla\Firefox\profiles.ini'
    $ret = @()
    if (-not (Test-Path -LiteralPath $file)) { return $ret }
    $content = [System.IO.File]::ReadAllText($file)
    $blocks = [regex]::Matches($content, '(?ms)^\[Profile\d+\]\s*\r?\n(.*?)(?=^\[|\z)')
    foreach ($b in $blocks) {
        $dict = @{}
        foreach ($line in ($b.Groups[1].Value -split "`r?`n")) {
            if ($line -match '^([^=\s]+)=(.*)$') { $dict[$matches[1]] = $matches[2].Trim() }
        }
        if (!$dict.ContainsKey('Path')) { continue }
        $base = Join-Path $env:APPDATA 'Mozilla\Firefox'
        $pth = if ($dict['IsRelative'] -eq '1') { Join-Path $base ($dict['Path'] -replace '/', '\\') } else { $dict['Path'] }
        if (Test-Path -LiteralPath $pth -PathType Container) {
            $ret += [pscustomobject]@{ Name = $dict['Name']; Path = [System.IO.Path]::GetFullPath($pth); Default = ($dict['Default'] -eq '1') }
        }
    }
    return $ret
}

function Get-FirefoxInstallations {
    $ret = New-Object System.Collections.Generic.List[object]
    foreach ($candidate in @(
        "$env:ProgramFiles\Mozilla Firefox\firefox.exe",
        "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe",
        "$env:LOCALAPPDATA\Mozilla Firefox\firefox.exe"
    )) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            $ret.Add([pscustomobject]@{ Label = $candidate; Exe = $candidate; ProgramDir = [System.IO.Path]::GetDirectoryName($candidate) })
        }
    }
    foreach ($key in @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe')) {
        try {
            $val = (Get-Item -LiteralPath $key -ErrorAction Stop).GetValue('')
            if ($val -and (Test-Path -LiteralPath $val)) {
                $ret.Add([pscustomobject]@{ Label = $val; Exe = $val; ProgramDir = [System.IO.Path]::GetDirectoryName((Resolve-Path -LiteralPath $val).Path) })
            }
        } catch {}
    }
    return @($ret | Group-Object Exe | ForEach-Object { $_.Group[0] })
}

function Require-Closed {
    if (Get-Process -Name firefox -ErrorAction SilentlyContinue) {
        throw (T 'errorOpen')
    }
}

function Get-MinUIFileSha256([string]$path) {
    $value = [System.IO.File]::ReadAllText($path)
    $normalized = With-LF $value
    $bytes = $utf8.GetBytes($normalized)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-','') }
    finally { $sha.Dispose() }
}

function Test-MinUIOwned([string]$path,[string]$kind) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $true }
    $value = [System.IO.File]::ReadAllText($path)
    $version = 'Firefox Min UI v0\.(?:4|6|7|8|9|10|11|12|13|14|15|16|17|18|19)(?![0-9])'
    $filehash = Get-MinUIFileSha256 $path
    switch ($kind) {
      'pref' {
        if ($filehash -eq '1A8838AEAFE97AE93B4F32B8BB3D09BE3D3848D91D40BC190CBDC0A011262080') { return $true }
        $rules = @($value -split '[
]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and -not $_.StartsWith('//') })
        $allowedRules = @(
          'pref("general.config.filename", "minui.cfg");',
          'pref("general.config.obscure_value", 0);',
          'pref("general.config.sandbox_enabled", false);'
        )
        if ($rules.Count -eq 3 -and @($rules | Where-Object { $allowedRules -notcontains $_ }).Count -eq 0) { return $true }
        if ($value -notmatch $version) { return $false }
        return ($value -match 'pref\("general\.config\.filename",\s*"minui\.cfg"\);' -and
                $value -match 'pref\("general\.config\.obscure_value",\s*0\);' -and
                $value -match 'pref\("general\.config\.sandbox_enabled",\s*false\);')
      }
      'cfg' {
        if ($filehash -eq 'D776D84007A24AF7FA81C75CC396F31D92835CE89A856DB5971BD0DF16EA773A') { return $true }
        return ($value -match $version -and $value -match 'scriptloader' -and $value -match 'minui-')
      }
      'script' {
        if ($filehash -eq 'B683A427E428CBD1AC20E8FEEECC8AD9BD2662A056AD8E9054B454A677EF77A2') { return $true }
        return ($value -match $version -and $value -match 'minui-')
      }
      'marker' { return ($value -match $version -and $value -match 'enabled') }
      default { return $false }
    }
}

function Get-MinUIFileKind([string]$path) {
    $name = [System.IO.Path]::GetFileName($path)
    if ($name -eq 'minui-prefs.js') { return 'pref' }
    if ($name -eq 'minui.cfg') { return 'cfg' }
    if ($name -eq 'minui-v04.enabled') { return 'marker' }
    return 'script'
}

function Check-Conflicts([string]$program,[string]$profile) {
    $prefdir = Join-Path $program 'defaults\pref'
    if (!(Test-Path -LiteralPath $prefdir -PathType Container)) {
        throw ((T 'errorPrefdir') + $prefdir)
    }
    foreach ($f in @(Get-ChildItem -LiteralPath $prefdir -Filter '*.js' -File -ErrorAction Stop)) {
        $content = [System.IO.File]::ReadAllText($f.FullName)
        if ($f.Name -eq 'minui-prefs.js') {
            if (-not (Test-MinUIOwned $f.FullName 'pref')) { throw ((T 'errorUnknownPref') + ' SHA256=' + (Get-MinUIFileSha256 $f.FullName)) }
            continue
        }
        if ($content -match 'general\.config\.filename') {
            throw ((T 'errorOtherAuto') + $f.FullName)
        }
    }
    $filesToCheck = @(
        (Join-Path $program 'minui.cfg'),
        (Join-Path $program 'minui-v04-browser.js'),
        (Join-Path $profile 'chrome\minui-v08-browser.js'),
        (Join-Path $profile 'chrome\minui-v09-browser.js'),
        (Join-Path $profile 'chrome\minui-v10-browser.js'),
        (Join-Path $profile 'chrome\minui-v11-browser.js'),
        (Join-Path $profile 'chrome\minui-v12-browser.js'),
        (Join-Path $profile 'chrome\minui-v13-browser.js'),
        (Join-Path $profile 'chrome\minui-v14-browser.js'),
        (Join-Path $profile 'chrome\minui-v15-browser.js'),
        (Join-Path $profile 'chrome\minui-v16-browser.js'),
        (Join-Path $profile 'chrome\minui-v17-browser.js'),
        (Join-Path $profile 'chrome\minui-v18-browser.js'),
        (Join-Path $profile 'chrome\minui-v19-browser.js'),
        (Join-Path $profile 'chrome\minui-v04.enabled')
    )
    foreach ($p in $filesToCheck) {
        if ((Test-Path -LiteralPath $p -PathType Leaf) -and
            -not (Test-MinUIOwned $p (Get-MinUIFileKind $p))) {
            throw ((T 'errorUnknownFile') + $p)
        }
    }
}

function Install-MinUI([string]$program,[string]$profile) {
    Require-Closed
    Check-Conflicts $program $profile
    $pref = Join-Path $program 'defaults\pref\minui-prefs.js'
    $cfg = Join-Path $program 'minui.cfg'
    $legacyScript = Join-Path $program 'minui-v04-browser.js'
    $chrome = Join-Path $profile 'chrome'
    $scriptFile = Join-Path $chrome 'minui-v19-browser.js'
    $previousScript = Join-Path $chrome 'minui-v08-browser.js'
    $previousV09 = Join-Path $chrome 'minui-v09-browser.js'
    $previousV10 = Join-Path $chrome 'minui-v10-browser.js'
    $previousV11 = Join-Path $chrome 'minui-v11-browser.js'
    $previousV12 = Join-Path $chrome 'minui-v12-browser.js'
    $previousV13 = Join-Path $chrome 'minui-v13-browser.js'
    $previousV14 = Join-Path $chrome 'minui-v14-browser.js'
    $previousV15 = Join-Path $chrome 'minui-v15-browser.js'
    $previousV16 = Join-Path $chrome 'minui-v16-browser.js'
    $previousV17 = Join-Path $chrome 'minui-v17-browser.js'
    $previousV18 = Join-Path $chrome 'minui-v18-browser.js'
    $marker = Join-Path $chrome 'minui-v04.enabled'
    $userCss = Join-Path $chrome 'userChrome.css'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    $backup = Join-Path $profile ('minui-backup-' + $stamp)
    $files = @($pref,$cfg,$legacyScript,$previousScript,$previousV09,$previousV10,$previousV11,$previousV12,$previousV13,$previousV14,$previousV15,$previousV16,$previousV17,$previousV18,$scriptFile,$marker,$userCss)
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    $existed = @{}
    try {
        for ($i = 0; $i -lt $files.Count; $i++) {
            $file = $files[$i]
            $existed[$file] = (Test-Path -LiteralPath $file -PathType Leaf)
            if ($existed[$file]) {
                Copy-Item -LiteralPath $file -Destination (Join-Path $backup ('original-' + $i)) -ErrorAction Stop
            }
        }
        New-Item -ItemType Directory -Path $chrome -Force | Out-Null
        if (Test-Path -LiteralPath $userCss -PathType Leaf) {
            $old = [System.IO.File]::ReadAllText($userCss)
            $rx='(?m)^\s*@import\s+url\(\s*["''](?:userChrome-min-ui|userChrome-min-ui-v02|minui-v03)\.css["'']\s*\)\s*;\s*\r?\n?'
            $new=[regex]::Replace($old,$rx,'')
            if($new -cne $old) { [System.IO.File]::WriteAllText($userCss,$new,$utf8) }
        }
        SaveUtf8 $scriptFile $UiSource
        SaveUtf8 $cfg $ConfigSource
        SaveUtf8 $pref $PrefSource
        SaveUtf8 $marker ('Firefox Min UI v0.19 enabled | ' + $Version + "`n")
        if ([System.IO.File]::ReadAllText($scriptFile) -cne (With-LF $UiSource)) {
            throw (T 'errorScriptVerify')
        }
        if ([System.IO.File]::ReadAllText($cfg) -cne (With-LF $ConfigSource)) {
            throw (T 'errorLoaderVerify')
        }
        if ([System.IO.File]::ReadAllText($pref) -cne (With-LF $PrefSource)) {
            throw (T 'errorPrefVerify')
        }
        foreach ($previous in @($legacyScript,$previousScript,$previousV09,$previousV10,$previousV11,$previousV12,$previousV13,$previousV14,$previousV15,$previousV16,$previousV17,$previousV18)) {
            if (Test-Path -LiteralPath $previous -PathType Leaf) {
                Remove-Item -LiteralPath $previous -Force -ErrorAction Stop
            }
        }
        return $backup
    } catch {
        $errorMessage = $_.Exception.Message
        for ($i = 0; $i -lt $files.Count; $i++) {
            $file = $files[$i]
            try {
                $original = Join-Path $backup ('original-' + $i)
                if (Test-Path -LiteralPath $original -PathType Leaf) {
                    Copy-Item -LiteralPath $original -Destination $file -Force -ErrorAction Stop
                } elseif ($existed.ContainsKey($file) -and -not $existed[$file] -and
                        (Test-Path -LiteralPath $file -PathType Leaf)) {
                    Remove-Item -LiteralPath $file -Force -ErrorAction Stop
                }
            } catch {
                Write-Log ((T 'errorRestore') + $file) 'ERROR'
            }
        }
        throw ((T 'errorInstallStopped') + $errorMessage + (T 'errorBackup') + $backup)
    }
}

function Uninstall-MinUI([string]$program,[string]$profile) {
    Require-Closed
    $chrome = Join-Path $profile 'chrome'
    $marker = Join-Path $chrome 'minui-v04.enabled'
    $paths = @(
        (Join-Path $program 'defaults\pref\minui-prefs.js'),
        (Join-Path $program 'minui.cfg'),
        (Join-Path $program 'minui-v04-browser.js'),
        (Join-Path $chrome 'minui-v08-browser.js'),
        (Join-Path $chrome 'minui-v09-browser.js'),
        (Join-Path $chrome 'minui-v10-browser.js'),
        (Join-Path $chrome 'minui-v11-browser.js'),
        (Join-Path $chrome 'minui-v12-browser.js'),
        (Join-Path $chrome 'minui-v13-browser.js'),
        (Join-Path $chrome 'minui-v14-browser.js'),
        (Join-Path $chrome 'minui-v15-browser.js'),
        (Join-Path $chrome 'minui-v16-browser.js'),
        (Join-Path $chrome 'minui-v17-browser.js'),
        (Join-Path $chrome 'minui-v18-browser.js'),
        (Join-Path $chrome 'minui-v19-browser.js'),
        $marker
    )
    foreach ($other in @(Get-Profiles)) {
       if ($other.Path -ne $profile -and (Test-Path -LiteralPath (Join-Path $other.Path 'chrome\minui-v04.enabled'))) {
           throw ((T 'errorOtherProfile') + $other.Path + (T 'errorDisableOther'))
       }
    }
    foreach ($path in $paths) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            if (-not (Test-MinUIOwned $path (Get-MinUIFileKind $path))) {
                throw ((T 'errorRemoveUnknown') + $path)
            }
        }
    }
    foreach ($path in $paths) {
        if (Test-Path -LiteralPath $path -PathType Leaf) { Remove-Item -LiteralPath $path -Force -ErrorAction Stop }
    }
}

function New-Card([string]$title,[string]$body,[int]$top) {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point(24,$top)
    $panel.Size = New-Object System.Drawing.Size(250,88)
    $panel.BackColor = [System.Drawing.Color]::FromArgb(28,28,34)
    $t = New-Object System.Windows.Forms.Label
    $t.Text=$title; $t.ForeColor=[System.Drawing.Color]::White
    $t.Font=New-Object System.Drawing.Font('Segoe UI Semibold',11)
    $t.Location=New-Object System.Drawing.Point(14,12); $t.AutoSize=$true
    $b=New-Object System.Windows.Forms.Label
    $b.Text=$body; $b.ForeColor=[System.Drawing.Color]::FromArgb(190,190,200)
    $b.Font=New-Object System.Drawing.Font('Segoe UI',9)
    $b.Location=New-Object System.Drawing.Point(14,36)
    $b.Size=New-Object System.Drawing.Size(222,42)
    $panel.Controls.AddRange(@($t,$b))
    return $panel
}
function Add-Label($parent,$text,$x,$y,$size=10,$bold=$false) {
    $lbl=New-Object System.Windows.Forms.Label
    $lbl.Text=$text; $lbl.ForeColor=[System.Drawing.Color]::White
    $fontStyle=if($bold){[System.Drawing.FontStyle]::Bold}else{[System.Drawing.FontStyle]::Regular}
    $lbl.Font=New-Object System.Drawing.Font('Segoe UI',$size,$fontStyle)
    $lbl.Location=New-Object System.Drawing.Point($x,$y)
    $lbl.AutoSize=$true; $parent.Controls.Add($lbl)
    return $lbl
}
function Add-Button($parent,$text,$x,$y,$width,$height,$r,$g,$b) {
    $button=New-Object System.Windows.Forms.Button
    $button.Text=$text; $button.Location=New-Object System.Drawing.Point($x,$y)
    $button.Size=New-Object System.Drawing.Size($width,$height)
    $button.FlatStyle='Flat'; $button.BackColor=[System.Drawing.Color]::FromArgb($r,$g,$b)
    $button.ForeColor=[System.Drawing.Color]::White
    $button.FlatAppearance.BorderSize=0
    $button.Cursor=[System.Windows.Forms.Cursors]::Hand
    $parent.Controls.Add($button)
    return $button
}
$form=New-Object System.Windows.Forms.Form
$form.Text='Firefox Min UI'
$form.StartPosition='CenterScreen'
$form.Size=New-Object System.Drawing.Size(1060,720)
$form.MinimumSize=New-Object System.Drawing.Size(1060,720)
$form.BackColor=[System.Drawing.Color]::FromArgb(16,16,20)
$form.ForeColor=[System.Drawing.Color]::White
$form.Font=New-Object System.Drawing.Font('Segoe UI',9)
$form.FormBorderStyle='FixedSingle'
$form.MaximizeBox=$false
$form.AutoScaleMode=[System.Windows.Forms.AutoScaleMode]::Dpi

$header=New-Object System.Windows.Forms.Panel
$header.Dock='Top'; $header.Height=86
$header.BackColor=[System.Drawing.Color]::FromArgb(22,22,28)
$form.Controls.Add($header)
$title=Add-Label $header 'Firefox Min UI' 24 13 22 $true
$subtitle=Add-Label $header '' 26 53 10 $false
$badge=Add-Label $header 'BETA' 730 28 9 $true
$badge.ForeColor=[System.Drawing.Color]::FromArgb(248,175,139)
$lblLanguage=Add-Label $header 'Language' 792 32 10 $false
$cbLanguage=New-Object System.Windows.Forms.ComboBox
$cbLanguage.Location=New-Object System.Drawing.Point(865,27)
$cbLanguage.Size=New-Object System.Drawing.Size(166,30)
$cbLanguage.DropDownStyle='DropDownList'
$cbLanguage.BackColor=[System.Drawing.Color]::FromArgb(40,40,48)
$cbLanguage.ForeColor=[System.Drawing.Color]::White
[void]$cbLanguage.Items.Add('English')
[void]$cbLanguage.Items.Add('Português (Brasil)')
$header.Controls.Add($cbLanguage)

$left=New-Object System.Windows.Forms.Panel
$left.Location=New-Object System.Drawing.Point(0,86)
$left.Size=New-Object System.Drawing.Size(300,596)
$left.BackColor=[System.Drawing.Color]::FromArgb(18,18,24)
$form.Controls.Add($left)
$intro=Add-Label $left '' 24 18 13 $true
$cards=@(
    (New-Card '' '' 56),
    (New-Card '' '' 156),
    (New-Card '' '' 256),
    (New-Card '' '' 356)
)
foreach($card in $cards) { $left.Controls.Add($card) }

$right=New-Object System.Windows.Forms.Panel
$right.Location=New-Object System.Drawing.Point(300,86)
$right.Size=New-Object System.Drawing.Size(760,596)
$right.BackColor=[System.Drawing.Color]::FromArgb(16,16,20)
$form.Controls.Add($right)
$lblSetup=Add-Label $right '' 24 18 14 $true
$lblFirefox=Add-Label $right '' 24 64 10 $true
$cbFirefox=New-Object System.Windows.Forms.ComboBox
$cbFirefox.Location=New-Object System.Drawing.Point(24,88)
$cbFirefox.Size=New-Object System.Drawing.Size(520,30)
$cbFirefox.DropDownStyle='DropDownList'
$cbFirefox.BackColor=[System.Drawing.Color]::FromArgb(30,30,36)
$cbFirefox.ForeColor=[System.Drawing.Color]::White
$right.Controls.Add($cbFirefox)
$btnBrowseFirefox=Add-Button $right '' 556 87 110 32 46 46 56
$btnRefresh=Add-Button $right '' 676 87 70 32 46 46 56
$lblProfile=Add-Label $right '' 24 136 10 $true
$cbProfile=New-Object System.Windows.Forms.ComboBox
$cbProfile.Location=New-Object System.Drawing.Point(24,160)
$cbProfile.Size=New-Object System.Drawing.Size(520,30)
$cbProfile.DropDownStyle='DropDownList'
$cbProfile.BackColor=[System.Drawing.Color]::FromArgb(30,30,36)
$cbProfile.ForeColor=[System.Drawing.Color]::White
$right.Controls.Add($cbProfile)
$btnBrowseProfile=Add-Button $right '' 556 159 110 32 46 46 56
$btnOpenProfile=Add-Button $right '' 676 159 70 32 46 46 56
$chkAck=New-Object System.Windows.Forms.CheckBox
$chkAck.Location=New-Object System.Drawing.Point(24,210)
$chkAck.Size=New-Object System.Drawing.Size(720,24)
$chkAck.ForeColor=[System.Drawing.Color]::FromArgb(210,210,220)
$chkAck.Checked=$false
$right.Controls.Add($chkAck)
$btnInstall=Add-Button $right '' 24 248 190 44 105 92 254
$btnUninstall=Add-Button $right '' 228 248 190 44 192 89 76
$btnClose=Add-Button $right '' 432 248 114 44 46 46 56
$btnDiagnose=Add-Button $right '' 556 248 146 44 55 55 70
$lblStatus=Add-Label $right '' 24 316 10 $true
$script:StatusLabel=Add-Label $right '' 24 340 10 $false
$script:StatusLabel.ForeColor=[System.Drawing.Color]::FromArgb(180,200,255)
$script:Progress=New-Object System.Windows.Forms.ProgressBar
$script:Progress.Location=New-Object System.Drawing.Point(24,366)
$script:Progress.Size=New-Object System.Drawing.Size(722,10)
$script:Progress.Style='Continuous'; $script:Progress.Value=0
$right.Controls.Add($script:Progress)
$lblLog=Add-Label $right '' 24 392 10 $true
$script:LogBox=New-Object System.Windows.Forms.RichTextBox
$script:LogBox.Location=New-Object System.Drawing.Point(24,416)
$script:LogBox.Size=New-Object System.Drawing.Size(722,145)
$script:LogBox.BackColor=[System.Drawing.Color]::FromArgb(12,12,16)
$script:LogBox.ForeColor=[System.Drawing.Color]::FromArgb(220,220,230)
$script:LogBox.BorderStyle='FixedSingle'; $script:LogBox.ReadOnly=$true
$script:LogBox.Font=New-Object System.Drawing.Font('Consolas',9)
$right.Controls.Add($script:LogBox)
$footer=Add-Label $right '' 24 573 9 $false
$footer.ForeColor=[System.Drawing.Color]::FromArgb(156,156,170)
$github=New-Object System.Windows.Forms.LinkLabel
$github.Text='github.com/mudot'
$github.Location=New-Object System.Drawing.Point(427,573)
$github.Size=New-Object System.Drawing.Size(200,23)
$github.LinkColor=[System.Drawing.Color]::FromArgb(166,151,255)
$github.ActiveLinkColor=[System.Drawing.Color]::FromArgb(211,202,255)
$github.VisitedLinkColor=$github.LinkColor
$github.Font=New-Object System.Drawing.Font('Segoe UI',9)
$github.Cursor=[System.Windows.Forms.Cursors]::Hand
$right.Controls.Add($github)
$github.Add_LinkClicked({ Start-Process 'https://github.com/mudot' })

function Update-Language {
    $script:Locale=if($cbLanguage.SelectedIndex -eq 1){'pt'}else{'en'}
    $title.Text=T 'title'; $subtitle.Text=T 'subtitle'; $lblLanguage.Text=T 'language'
    $intro.Text=T 'what'
    for($i=0;$i -lt $cards.Count;$i++) {
        $cards[$i].Controls[0].Text=T ('card'+($i+1))
        $cards[$i].Controls[1].Text=T ('card'+($i+1)+'Body')
    }
    $lblSetup.Text=T 'setup'; $lblFirefox.Text=T 'firefox'; $lblProfile.Text=T 'profile'
    $btnBrowseFirefox.Text=T 'choose'; $btnBrowseProfile.Text=T 'choose'
    $btnRefresh.Text=T 'refresh'; $btnOpenProfile.Text=T 'folder'; $chkAck.Text=T 'ack'
    $btnInstall.Text=T 'install'; $btnUninstall.Text=T 'uninstall'; $btnDiagnose.Text=T 'diagnose'; $btnClose.Text=T 'close'
    $lblStatus.Text=T 'status'; $lblLog.Text=T 'log'; $footer.Text=T 'footer'
    if($script:Progress.Style -ne 'Marquee') { Set-Status (T 'ready') $false }
}
$cbLanguage.Add_SelectedIndexChanged({ Update-Language })
$cbLanguage.SelectedIndex=0

function Get-SelectedFirefoxDir {
    $item=$cbFirefox.SelectedItem
    if($item -is [System.Management.Automation.PSCustomObject]) { return $item.ProgramDir }
    if($item -and (Test-Path -LiteralPath $item.ToString())) {
        $path=$item.ToString()
        if([System.IO.Path]::GetFileName($path).ToLower() -eq 'firefox.exe') { return [System.IO.Path]::GetDirectoryName($path) }
        return $path
    }
    return $null
}
function Get-SelectedProfileDir {
    $item=$cbProfile.SelectedItem
    if($item -is [System.Management.Automation.PSCustomObject]) { return $item.Path }
    if($item) { return $item.ToString() }
    return $null
}
function Refresh-Selections {
    $previousFirefox=Get-SelectedFirefoxDir
    $previousProfile=Get-SelectedProfileDir
    $cbFirefox.Items.Clear()
    foreach($ff in @(Get-FirefoxInstallations)) { [void]$cbFirefox.Items.Add($ff) }
    $cbFirefox.DisplayMember='Label'
    if($cbFirefox.Items.Count -gt 0) {
        $index=0
        for($i=0;$i -lt $cbFirefox.Items.Count;$i++) { if($cbFirefox.Items[$i].ProgramDir -eq $previousFirefox) { $index=$i; break } }
        $cbFirefox.SelectedIndex=$index
    }
    $cbProfile.Items.Clear()
    $profiles=@(Get-Profiles)
    foreach($pf in $profiles) { [void]$cbProfile.Items.Add($pf) }
    $cbProfile.DisplayMember='Name'
    if($profiles.Count -gt 0) {
        $index=0
        for($i=0;$i -lt $profiles.Count;$i++) { if($profiles[$i].Path -eq $previousProfile -or $profiles[$i].Default) { $index=$i; if($profiles[$i].Path -eq $previousProfile){break} } }
        $cbProfile.SelectedIndex=$index
    }
    Write-Log (T 'profilesUpdated')
    Set-Status (T 'ready') $false
}
$btnRefresh.Add_Click({ Refresh-Selections })
$btnBrowseFirefox.Add_Click({
    $dlg=New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter=T 'fileDialogFilter'; $dlg.Title=T 'fileDialogTitle'
    if($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        if([System.IO.Path]::GetFileName($dlg.FileName).ToLower() -ne 'firefox.exe') { [System.Windows.Forms.MessageBox]::Show((T 'selectValidFirefox')) | Out-Null; return }
        $obj=[pscustomobject]@{Label=$dlg.FileName;Exe=$dlg.FileName;ProgramDir=[System.IO.Path]::GetDirectoryName($dlg.FileName)}
        [void]$cbFirefox.Items.Add($obj); $cbFirefox.DisplayMember='Label'; $cbFirefox.SelectedItem=$obj
        Write-Log ((T 'selectedFirefox')+$dlg.FileName)
    }
})
$btnBrowseProfile.Add_Click({
    $dlg=New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description=T 'folderDialogTitle'
    if($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $obj=[pscustomobject]@{Name=$dlg.SelectedPath;Path=$dlg.SelectedPath;Default=$false}
        [void]$cbProfile.Items.Add($obj); $cbProfile.DisplayMember='Name'; $cbProfile.SelectedItem=$obj
        Write-Log ((T 'selectedProfile')+$dlg.SelectedPath)
    }
})
$btnOpenProfile.Add_Click({
    $path=Get-SelectedProfileDir
    if($path -and (Test-Path -LiteralPath $path)) { Start-Process explorer.exe -ArgumentList @($path) }
    else { [System.Windows.Forms.MessageBox]::Show((T 'selectValidProfile')) | Out-Null }
})
$btnClose.Add_Click({$form.Close()})

$btnDiagnose.Add_Click({
    try {
        $program=Get-SelectedFirefoxDir; $profile=Get-SelectedProfileDir
        if(-not $program -or -not $profile) { throw (T 'errorPaths') }
        Set-Status (T 'diagnosing') $true
        $pref=Join-Path $program 'defaults\pref\minui-prefs.js'
        $cfg=Join-Path $program 'minui.cfg'
        $scriptFile=Join-Path $profile 'chrome\minui-v19-browser.js'
        $legacy=Join-Path $program 'minui-v04-browser.js'
        $marker=Join-Path $profile 'chrome\minui-v04.enabled'
        Write-Log (T 'diagnosticHeader')
        Write-Log (T 'expectedScript')
        foreach($p in @($pref,$cfg,$scriptFile,$marker)) {
            $state=if(Test-Path -LiteralPath $p -PathType Leaf){T 'present'}else{T 'missing'}
            Write-Log ([System.IO.Path]::GetFileName($p)+': '+$state)
        }
        if(Test-Path -LiteralPath $scriptFile -PathType Leaf) {
            $expected=[System.Security.Cryptography.SHA256]::Create().ComputeHash($utf8.GetBytes((With-LF $UiSource)))
            $actual=(Get-FileHash -LiteralPath $scriptFile -Algorithm SHA256).Hash
            $matches=[BitConverter]::ToString($expected).Replace('-','') -eq $actual
            Write-Log ((T 'integrity')+$(if($matches){T 'yes'}else{T 'no'}))
        } else { Write-Log (T 'missingScript') 'ERROR' }
        if(Test-Path -LiteralPath $legacy -PathType Leaf) { Write-Log (T 'legacyScript') 'WARN' }
        if(Test-Path -LiteralPath $cfg -PathType Leaf) {
            $configData=[System.IO.File]::ReadAllText($cfg)
            if($configData -notmatch "source.append\('minui-v19-browser.js'\)") { Write-Log (T 'loaderMismatch') 'ERROR' }
            if($configData -notmatch 'loadSubScriptWithOptions' -or $configData -notmatch 'allowUnsafeURL: true') { Write-Log (T 'loaderOld') 'ERROR' }
            else { Write-Log (T 'loaderReady') 'OK' }
        }
        $prefs=Join-Path $profile 'prefs.js'
        $result='not-found'; $trace=''
        if(Test-Path -LiteralPath $prefs -PathType Leaf) {
            $data=[System.IO.File]::ReadAllText($prefs)
            $found=[regex]::Matches($data,'(?m)^user_pref\("extensions\.minui\.runtime\.stage",\s*"([^"]+)"\);')
            if($found.Count -gt 0){$result=$found[$found.Count-1].Groups[1].Value}
            $traceFound=[regex]::Matches($data,'(?m)^user_pref\("extensions\.minui\.runtime\.trace",\s*"((?:\\.|[^"\\])*)"\);')
            if($traceFound.Count -gt 0){$trace=$traceFound[$traceFound.Count-1].Groups[1].Value}
        }
        if(Get-Process -Name firefox -ErrorAction SilentlyContinue) { Write-Log (T 'firefoxOpen') 'WARN' }
        Write-Log ((T 'statusRecorded')+$result)
        if($trace -and $trace -notmatch 'v19-autoconfig-executado') { Write-Log (T 'staleTrace') 'WARN' }
        if($trace){Write-Log ((T 'trace')+$trace)}else{Write-Log (T 'noTrace') 'WARN'}
        if($result -match 'ganchos-registrados|aguardando-primeira-janela') { Write-Log (T 'startupPending') 'WARN' }
        if($result -match 'script-ausente|erro-injecao') { Write-Log (T 'scriptFailure') 'WARN' }
        if($result -match 'janela-ainda-inicializando|erro-controles') { Write-Log (T 'uiNotReady') 'WARN' }
        if($result -like 'interface-ativa:sem-sobreposicao*' -and $trace -match 'v19-autoconfig-executado'){Set-Status (T 'uiActive') $false}else{Set-Status ((T 'diagnosisStatus')+$result) $false}
        [System.Windows.Forms.MessageBox]::Show((TF 'diagResult' @($result,$trace)),(T 'diagnoseTitle'),[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Write-Log $_.Exception.Message 'ERROR'; Set-Status (T 'diagnoseUnavailable') $false
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,(T 'diagnoseTitle'),[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})
$btnInstall.Add_Click({
    try {
        if(-not $chkAck.Checked) { throw (T 'confirmAck') }
        $program=Get-SelectedFirefoxDir; $profile=Get-SelectedProfileDir
        if(-not $program -or -not(Test-Path -LiteralPath $program -PathType Container)) { throw (T 'selectValidFirefox') }
        if(-not $profile -or -not(Test-Path -LiteralPath $profile -PathType Container)) { throw (T 'selectValidProfileForInstall') }
        $message=TF 'confirmInstall' @($program,$profile)
        $response=[System.Windows.Forms.MessageBox]::Show($message,(T 'confirmInstallTitle'),[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
        if($response -ne [System.Windows.Forms.DialogResult]::Yes){return}
        Set-Status (T 'installing') $true
        Write-Log ((T 'installStart')+$program); Write-Log ((T 'profileStart')+$profile)
        $backup=Install-MinUI $program $profile
        Write-Log ((T 'scriptInstalled')+$backup) 'OK'; Set-Status (T 'installed') $false
        [System.Windows.Forms.MessageBox]::Show((TF 'installDone' @($backup)),(T 'installTitle'),[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Write-Log $_.Exception.Message 'ERROR'; Set-Status (T 'installationFailed') $false
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,(T 'installationFailed'),[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})
$btnUninstall.Add_Click({
    try {
        $program=Get-SelectedFirefoxDir; $profile=Get-SelectedProfileDir
        if(-not $program -or -not(Test-Path -LiteralPath $program -PathType Container)) { throw (T 'selectValidFirefox') }
        if(-not $profile -or -not(Test-Path -LiteralPath $profile -PathType Container)) { throw (T 'selectValidProfileForInstall') }
        $message=TF 'confirmUninstall' @($program,$profile)
        $response=[System.Windows.Forms.MessageBox]::Show($message,(T 'confirmUninstallTitle'),[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Warning)
        if($response -ne [System.Windows.Forms.DialogResult]::Yes){return}
        Set-Status (T 'uninstalling') $true
        Write-Log ((T 'rollbackStart')+$program)
        Uninstall-MinUI $program $profile
        Write-Log (T 'rollbackSuccess') 'OK'; Set-Status (T 'uninstalled') $false
        [System.Windows.Forms.MessageBox]::Show((T 'uninstallDone'),(T 'installTitle'),[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    } catch {
        Write-Log $_.Exception.Message 'ERROR'; Set-Status (T 'uninstallFailed') $false
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,(T 'uninstallFailed'),[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    }
})
Refresh-Selections
Write-Log (T 'initialLog')
Write-Log (T 'helpLog')
[void]$form.ShowDialog()
