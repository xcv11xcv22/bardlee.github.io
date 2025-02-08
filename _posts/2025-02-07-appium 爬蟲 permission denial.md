---
tags: [spider]
title: appium 爬蟲 permission denial

---

當你使用
```bash
adb shell dumpsys window | grep -E 'mCurrentFocus|mFocusedApp'
```
取得MainActivity,並放到capabilities
啟動失敗被告知權限不足時

因中途的CurrentFocus已發生改變，抓取到錯誤的數值

輸入
```bash
adb logcat -s actionmanager
```
再次開啟APP 這次就能抓取正確的activity





