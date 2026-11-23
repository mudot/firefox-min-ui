from pathlib import Path
from playwright.sync_api import sync_playwright

css = (Path(__file__).resolve().parents[1] / 'src' / 'minui-v16.css').read_text(encoding='utf-8')

def html(ext_count, openstate, caption=138):
    before = ''.join(f'<button id="nav-before-{i}">{s}</button>' for i,s in enumerate(['◀','▶','↻','▣']))
    after = ''.join(f'<button id="addon-{i}" class="addon">✦</button>' for i in range(ext_count))
    state=' minui-v16-open="true"' if openstate else ''
    return f'''<!DOCTYPE html><html minui-v16-mounted="true"{state} style="--minui-caption-width:{caption}px"><head><meta charset="utf-8"><style>
    html,body{{margin:0;background:#07080a;color:#eee;font:14px Segoe UI}} *{{box-sizing:border-box}}
    button{{color:#ccc;background:none;border:0;height:35px;width:36px;min-width:36px;flex:0 0 36px}}
    #TabsToolbar{{width:100%;background:#101015;}}
    .toolbar-items{{display:flex;align-items:center;}}
    .tabbrowser-tab{{height:36px;min-width:130px;padding:8px;border:1px solid #29292c;white-space:nowrap;}}
    #nav-bar{{background:#17171a}} #nav-bar-customization-target{{display:flex;align-items:center}}
    #urlbar-container{{display:flex;height:34px;background:#292b34;border-radius:5px;min-width:0;}}
    #urlbar{{display:flex;align-items:center;width:100%;padding:0 12px;white-space:nowrap;overflow:hidden;}}
    .titlebar-buttonbox-container{{width:{caption}px;min-width:{caption}px;display:flex;height:42px;}}
    .titlebar-buttonbox{{display:flex}} .titlebar-button{{width:{caption/3}px}}
    #PanelUI-button,#nav-bar-overflow-button{{height:35px;display:flex;align-items:center;}}
    </style><style>{css}</style></head><body><div id="TabsToolbar">
    <div class="toolbar-items"><div class="tabbrowser-tab">Sakura Mangás</div><div class="tabbrowser-tab">Configurações</div><div class="tabbrowser-tab">Extensões</div></div>
    <div id="nav-bar"><div id="nav-bar-customization-target">{before}
      <div id="urlbar-container"><div id="urlbar"><span>🔒 sakuramangas.org/obras/hunter-x-hunter/331/</span></div></div>
      {after}
    </div><div id="nav-bar-overflow-button"><button>⌄</button></div>
         <div id="PanelUI-button"><button>☰</button></div></div>
    <div class="titlebar-buttonbox-container"><div class="titlebar-buttonbox">
    <button class="titlebar-button">─</button><button class="titlebar-button">□</button><button class="titlebar-button">×</button></div></div>
    </div></body></html>'''

def rect(loc):
    b=loc.bounding_box()
    assert b
    return {x:round(v,2) for x,v in b.items()}

with sync_playwright() as p:
    browser=p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox'])
    try:
        tested=0
        for viewport in [1120,1280,1527,1907,1920]:
            for ext in [2,5,10]:
                page=browser.new_page(viewport={'width':viewport,'height':200},device_scale_factor=1)
                page.set_content(html(ext,True))
                page.wait_for_timeout(425)
                nav=rect(page.locator('#nav-bar'))
                cap=rect(page.locator('.titlebar-buttonbox-container'))
                leftlast=rect(page.locator('#nav-before-3'))
                url=rect(page.locator('#urlbar-container'))
                rightfirst=rect(page.locator('#addon-0'))
                rightlast=rect(page.locator(f'#addon-{ext-1}'))
                tabs=rect(page.locator('.toolbar-items'))
                ok = (
                   nav['x'] < 8 and abs(nav['x']+nav['width']-cap['x'])<=8 and
                   url['width'] > 180 and
                   url['x'] >= leftlast['x']+leftlast['width']-2 and
                   url['x']+url['width'] <= rightfirst['x']+2 and
                   rightlast['x']+rightlast['width'] < cap['x']+2 and
                   tabs['width'] > 0
                )
                print('open',viewport,ext,'nav=',nav,'url=',url,'caption=',cap,'ok=',ok)
                assert ok, f'failed viewport={viewport} ext={ext}'
                if viewport==1907 and ext==5:page.screenshot(path=str(Path(__file__).resolve().parent / 'minui-v16-layout-preview.png'))
                tested+=1
                page.close()
        for viewport in [1120,1527,1907]:
            page=browser.new_page(viewport={'width':viewport,'height':200},device_scale_factor=1)
            page.set_content(html(5,False))
            page.wait_for_timeout(100)
            nav=rect(page.locator('#nav-bar'))
            url=rect(page.locator('#urlbar-container'))
            tabs=rect(page.locator('.toolbar-items'))
            cap=rect(page.locator('.titlebar-buttonbox-container'))
            print('closed',viewport,'nav=',nav,'tabs=',tabs,'cap=',cap,'url=',url)
            assert tabs['width']>200 and nav['x']>=tabs['x']+tabs['width']-2 and url['width']<3
            tested+=1
            page.close()
        print('PASS:',tested,'scenarios')
    finally:
        browser.close()
