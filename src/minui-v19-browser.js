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


