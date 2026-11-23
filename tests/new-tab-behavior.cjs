const fs=require('fs'), vm=require('vm'), assert=require('assert'), path=require('path');
const script=fs.readFileSync(path.join(__dirname,'..','src','minui-v19-browser.js'),'utf8');
function setup(){
 const events=new Map(), timers=[]; let nextTimer=1;
 class El{
  constructor(id=''){this.id=id;this.attrs=new Map();this.listeners=new Map();this.children=[];this.parentNode=null;this.hidden=false;this.style={setProperty(){},removeProperty(){}};}
  setAttribute(k,v){this.attrs.set(k,v)} removeAttribute(k){this.attrs.delete(k)} hasAttribute(k){return this.attrs.has(k)} getAttribute(k){return this.attrs.get(k)||null}
  addEventListener(name,handler){let handlers=this.listeners.get(name)||[];handlers.push(handler);this.listeners.set(name,handlers)}
  emit(name,obj={}){for(const h of this.listeners.get(name)||[])h(obj)}
  appendChild(el){el.parentNode=this;this.children.push(el)}
  insertBefore(el,before){if(el.parentNode)el.parentNode.children=el.parentNode.children.filter(x=>x!==el);el.parentNode=this;let i=this.children.indexOf(before); if(i<0)this.children.push(el);else this.children.splice(i,0,el)}
  querySelector(sel){if(sel===':scope > .titlebar-buttonbox-container')return cap; if(sel==='.urlbarView')return null;return null}
  querySelectorAll(){return []}
  matches(selector){return selector===':popover-open'?false:false}
  contains(el){return el===this}
  getBoundingClientRect(){return {left:0,right:1600,top:0,bottom:42,width:1600,height:42,y:0}}
 }
 const root=new El('root'), head=new El('head'), tabs=new El('TabsToolbar'),nav=new El('nav-bar'),cap=new El('caption'),parent=new El('parent');
 parent.appendChild(nav); tabs.appendChild(cap);
 const strip=new El('strip'),urlbar=new El('urlbar'),input=new El('urlbar-input');input.value='';input.selectionStart=0;input.selectionEnd=0;
 input.setRangeText=(v,a,b)=>{input.value=input.value.slice(0,a)+v+input.value.slice(b);input.selectionStart=input.selectionEnd=a+v.length};
 input.select=()=>{input.selectionStart=0;input.selectionEnd=input.value.length};
 input.dispatchEvent=()=>{};
 input.blur=()=>{doc.activeElement=root;input.emit('blur')};
 const doc={documentURI:'chrome://browser/content/browser.xhtml',readyState:'complete',documentElement:root,head,
 getElementById(id){return ({TabsToolbar:tabs,'nav-bar':nav,urlbar})[id]||null},
 createElementNS(ns,tag){return new El(tag)},activeElement:root};
 let prefs=new Map();
 const win={document:doc,innerWidth:1500,console,Services:{prefs:{setStringPref(k,v){prefs.set(k,v)},getStringPref(k,d=''){return prefs.get(k)||d}}},
 gBrowser:{selectedTab:null,tabContainer:strip,selectedBrowser:{focus(){doc.activeElement=root}}},
 gURLBar:{inputField:input,view:{isOpen:false,close(){}},focus(){doc.activeElement=input;input.emit('focus')}},
 MutationObserver:class{observe(){} disconnect(){}},InputEvent:class{constructor(type,props){this.type=type;Object.assign(this,props)}},
 requestAnimationFrame(fn){fn();return 1},setTimeout(fn,ms){let id=nextTimer++;timers.push({id,fn,ms});return id},clearTimeout(id){let t=timers.find(x=>x.id===id);if(t)t.cancelled=true},
 getComputedStyle(){return {getPropertyValue(){return 'yes'},display:'flex',visibility:'visible'}},
 addEventListener(k,h){let a=events.get(k)||[];a.push(h);events.set(k,a)},
 emit(k,obj){for(const f of events.get(k)||[])f(obj)}
 };
 vm.runInNewContext(script,{window:win,ChromeUtils:{importESModule(){return {Services:win.Services}}}}, {timeout:1000});
 const run=(max=100)=>{let iterations=0;while(true){const i=timers.findIndex(t=>!t.done&&!t.cancelled&&t.ms<=max);if(i<0)break;const t=timers[i];t.done=true;t.fn();if(++iterations>1000)throw new Error('timer loop')}};
 function makeTab(uri,attributes=[]){return {linkedPanel:'panel', linkedBrowser:{currentURI:{spec:uri}}, matches(s){return s==='.tabbrowser-tab'}, hasAttribute(a){return attributes.includes(a)}, closing:false}}
 return {win,root,strip,doc,input,prefs,run,makeTab};
}

function sendKey(ctx,ch,extras={}) {
  let blocked=false;
  const e={key:ch,target:{closest(){return null}},defaultPrevented:false,
    ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,isComposing:false,
    preventDefault(){blocked=true},stopPropagation(){},...extras};
  ctx.win.emit('keydown',e);
  return blocked;
}
function add(ctx,uri='about:newtab',attrs=[]) {
  let t=ctx.makeTab(uri,attrs);ctx.strip.emit('TabOpen',{target:t});
  ctx.win.gBrowser.selectedTab=t;ctx.strip.emit('TabSelect',{target:t});
  ctx.run(100);return t;
}
function inactive(ctx,uri,attrs=[]) {
  const tab=ctx.makeTab(uri,attrs);
  ctx.win.gBrowser.selectedTab=tab;
  ctx.strip.emit('TabSelect',{target:tab});
  ctx.run(100);
  return tab;
}
// 1: first fresh new tab opens and focuses the address.
let ctx=setup();let a=add(ctx);
assert(ctx.root.hasAttribute('minui-v19-open'),'first fresh tab opens');
assert(ctx.doc.activeElement===ctx.input,'first fresh tab gets URL focus');
assert(ctx.prefs.get('extensions.minui.runtime.trace').includes('primeira-nova-aba-endereco-aberto'));

// 2: next fresh new tab remains in normal tab view even when Firefox itself focuses the URL bar.
let b=add(ctx);
assert(!ctx.root.hasAttribute('minui-v19-open'),'second new tab stays closed');
ctx.win.gURLBar.focus();ctx.run(100);
assert(!ctx.root.hasAttribute('minui-v19-open'),'native focus on secondary tab is suppressed');
assert(ctx.doc.activeElement!==ctx.input,'address does not retain stolen focus');

// 3: switching to old blank tab must not auto-open or steal focus.
let oldBlank=inactive(ctx,'about:newtab');
assert(!ctx.root.hasAttribute('minui-v19-open'));
ctx.win.gURLBar.focus();ctx.run(100);
assert(!ctx.root.hasAttribute('minui-v19-open'),'existing about:newtab stays closed');

// 4: sleeping/discarded tabs should not trigger it, even when their placeholder URI is about:blank.
let sleep=inactive(ctx,'about:blank',['pending','discarded']);
ctx.win.gURLBar.focus();ctx.run(100);
assert(!ctx.root.hasAttribute('minui-v19-open'),'sleeping tab does not open the URL bar');
assert(ctx.doc.activeElement!==ctx.input,'sleeping tab does not retain address focus');
// Explicit Ctrl+L still works even after a dormant tab is selected.
sendKey(ctx,'l',{ctrlKey:true});ctx.win.gURLBar.focus();ctx.run(100);
assert(ctx.root.hasAttribute('minui-v19-open'),'Ctrl+L manually opens on a dormant tab');
ctx.win.gBrowser.selectedBrowser.focus();ctx.root.removeAttribute('minui-v19-open');

// 5: pending restored tabs can emit TabOpen, but must never count as a newly-created normal tab.
let pending=ctx.makeTab('about:blank',['pending']);pending.linkedPanel=null;
ctx.strip.emit('TabOpen',{target:pending});ctx.win.gBrowser.selectedTab=pending;
ctx.strip.emit('TabSelect',{target:pending});ctx.run(100);
assert(!ctx.root.hasAttribute('minui-v19-open'),'pending restored TabOpen cannot focus');

// 6: select a regular page to reset the sequence; next newly-created blank tab is the first again.
inactive(ctx,'https://example.org/');
a=add(ctx);
assert(ctx.root.hasAttribute('minui-v19-open'),'first tab after returning to content opens');

// 7: on secondary tabs Ctrl+L and manual active-tab click are still permitted.
b=add(ctx);
assert(!ctx.root.hasAttribute('minui-v19-open'));
sendKey(ctx,'l',{ctrlKey:true});ctx.win.gURLBar.focus();ctx.run(100);
assert(ctx.root.hasAttribute('minui-v19-open'),'Ctrl+L explicitly opens on secondary tab');
ctx.win.gBrowser.selectedBrowser.focus();
ctx.root.removeAttribute('minui-v19-open');
ctx.strip.emit('pointerdown',{button:0,target:{closest(sel){return sel==='.tabbrowser-tab'?b:null}},x:30,y:20,clientX:30,clientY:20});
ctx.strip.emit('click',{button:0,detail:1,target:{closest(sel){return sel==='.tabbrowser-tab'?b:null}},clientX:30,clientY:20,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false});
ctx.run(100);
assert(ctx.root.hasAttribute('minui-v19-open'),'click on active secondary tab manually opens');

// 8: fallback typing no longer auto-expands on subsequent or dormant new tabs.
ctx=setup();let first=ctx.makeTab('about:newtab');ctx.strip.emit('TabOpen',{target:first});ctx.win.gBrowser.selectedTab=first;
assert(sendKey(ctx,'a'),'printable fallback works on first fresh tab before autofocus');
ctx.run(100);
let second=add(ctx);
assert(!sendKey(ctx,'b'),'printable fallback does not force subsequent new tab');
ctx.win.gBrowser.selectedTab=ctx.makeTab('about:blank',['discarded']);ctx.doc.activeElement=ctx.root;
ctx.strip.emit('TabSelect',{target:ctx.win.gBrowser.selectedTab});ctx.run(100);
assert(!sendKey(ctx,'c'),'printable fallback does not focus discarded tab');
ctx.win.gBrowser.selectedTab=ctx.makeTab('https://example.net');ctx.strip.emit('TabSelect',{target:ctx.win.gBrowser.selectedTab});
assert(!sendKey(ctx,'d'),'printable fallback does not hijack ordinary web page');
console.log('PASS v19: first-only autofocus, secondary suppression, existing/dormant tabs, explicit controls, reset, keyboard fallback');
