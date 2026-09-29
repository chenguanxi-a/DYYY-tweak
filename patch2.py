import sys
sys.stdout.reconfigure(encoding='utf-8')
with open(r'F:\11\dddd\2\DYYY\DYYYSettingViewController.m', 'rb') as f:
    c = f.read()
old = b'}\n      [tableView deselectRowAtIndexPath:indexPath animated:YES];'
new = b'''} else if ([item.key isEqualToString:@\ DYYYModifyCountButton\]) {
          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@\\\U4fee\\U6539\\U6570\\U91cf\ message:nil preferredStyle:UIAlertControllerStyleAlert];
          
          UITextField *followersField = [[UITextField alloc] init];
          followersField.placeholder = @\\\U65b0\\U7684\\U5168\\U90e8\\U7c89\\U4e1d\\U6570\;
          followersField.borderStyle = UITextBorderStyleRoundedRect;
          followersField.keyboardType = UIKeyboardTypeNumberPad;
          NSString *savedFollowers = [[NSUserDefaults standardUserDefaults] stringForKey:@\DYYYModifyCountFollowers\];
          if (savedFollowers.length > 0) followersField.text = savedFollowers;
          [alert.view addSubview:followersField];
          
          UITextField *likesField = [[UITextField alloc] init];
          likesField.placeholder = @\\\U65b0\\U7684\\U8d60\\U8d60\\U91cf\;
          likesField.borderStyle = UITextBorderStyleRoundedRect;
          likesField.keyboardType = UIKeyboardTypeNumberPad;
          NSString *savedLikes = [[NSUserDefaults standardUserDefaults] stringForKey:@\DYYYModifyCountLikes\];
          if (savedLikes.length > 0) likesField.text = savedLikes;
          [alert.view addSubview:likesField];
          
          [alert addAction:[UIAlertAction actionWithTitle:@\\\U53d6\\U6d88\ style:UIAlertActionStyleCancel handler:nil]];
          [alert addAction:[UIAlertAction actionWithTitle:@\\\U786e\\U5b9a\ style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
              [[NSUserDefaults standardUserDefaults] setObject:followersField.text forKey:@\DYYYModifyCountFollowers\];
              [[NSUserDefaults standardUserDefaults] setObject:likesField.text forKey:@\DYYYModifyCountLikes\];
              [[NSUserDefaults standardUserDefaults] synchronize];
              [[NSNotificationCenter defaultCenter] postNotificationName:@\DYYYSettingChanged\ object:nil userInfo:@{@\key\: @\DYYYModifyCountFollowers\, @\value\: followersField.text}];
              [self.tableView reloadData];
          }]];
          [self presentViewController:alert animated:YES completion:nil];
      }
      [tableView deselectRowAtIndexPath:indexPath animated:YES];'''
if old in c:
    c = c.replace(old, new, 1)
    with open(r'F:\11\dddd\2\DYYY\DYYYSettingViewController.m', 'wb') as f:
        f.write(c)
    print('OK')
else:
    print('NOT FOUND')
