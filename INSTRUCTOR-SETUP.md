# Instructor Setup

學生不需要自行上傳 `roadrecon.db`。講師先用 `age` 加密 snapshot，再把密文與 checksum 放進固定 tag 的 GitHub Release。Repository 在上課期間轉成 Public，也不會直接公開資料庫內容。

> 密碼只在現場公布。不要寫進 repository、Release 說明、Notion、投影片或聊天紀錄。

## 準備加密檔案

電腦需先安裝 [`age`](https://github.com/FiloSottile/age)。在本 repository 執行：

```bash
bash scripts/encrypt-roadrecon-asset.sh \
  /path/to/roadrecon.db \
  release-assets
```

依照畫面提示輸入同一組課程密碼。完成後會產生：

- `release-assets/roadrecon.db.age`
- `release-assets/roadrecon.db.age.sha256`
- `release-assets/roadrecon.db.sha256`

原始的 `roadrecon.db` 不會被複製到輸出目錄。

## 第一次建立 Release

```bash
gh release create course-assets \
  release-assets/roadrecon.db.age \
  release-assets/roadrecon.db.age.sha256 \
  release-assets/roadrecon.db.sha256 \
  --repo hackerpeanutjohn/EntraID_Training \
  --title "Course assets" \
  --notes "Encrypted runtime assets for the Entra ID training Codespace."
```

## 更新 Snapshot

重新執行加密 script 後，沿用同一個 Release tag：

```bash
gh release upload course-assets \
  release-assets/roadrecon.db.age \
  release-assets/roadrecon.db.age.sha256 \
  release-assets/roadrecon.db.sha256 \
  --repo hackerpeanutjohn/EntraID_Training \
  --clobber
```

每一梯建議更換密碼並重新加密。學生拿到密碼後，本來就能取得明文資料庫；加密的用途是避免 repository 暫時公開時，未參與課程的人直接下載使用。

## 課前驗證

1. 用測試學生帳號建立全新的 Codespace。
2. 確認建立過程出現 `Encrypted ROADrecon asset downloaded and verified`。
3. 執行 `bash scripts/start-lab.sh`，確認 Terminal 會要求輸入密碼。
4. 輸入本梯密碼，確認 checksum 與 SQLite 格式驗證通過。
5. 確認 workstation 為 `healthy`。
6. 確認 Private Port `6080` 能開啟 Linux Desktop。
7. 確認 container 內的 `/course/roadrecon.db` 可讀。
