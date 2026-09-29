import sys
sys.stdout.reconfigure(encoding='utf-8')
with open(r'F:\11\dddd\2\DYYY\DYYYSettingViewController.m', 'rb') as f:
    c = f.read()
old = b'itle:@\"  -\xe4\xba\x92\xe5\x85\xb3\xe6\x95\xb0\xe9\x87\x8f\" key:@\"DYYYCustomMutual\" type:DYYYSettingItemTypeTextField placeholder:@\"\xe5\xa1\xab\xe5\x86\x99\xe6\x95\xb0\xe5\xad\x97\"],'
new = old + b'\n                  [DYYYSettingItem itemWithTitle:@\"  -\xe4\xbf\xae\xe6\x94\xb9\xe6\x95\xb0\xe9\x87\x8f(\xe4\xbb\x85\xe8\x87\xaa\xe5\xb7\xb1)\" key:@\"DYYYModifyCountButton\" type:DYYYSettingItemTypeButton],'
if old in c:
    c = c.replace(old, new, 1)
    with open(r'F:\11\dddd\2\DYYY\DYYYSettingViewController.m', 'wb') as f:
        f.write(c)
    print('OK')
else:
    print('NOT FOUND')
