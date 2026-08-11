# Instructor Setup

學生不需要自行上傳 `roadrecon.db`。講師把 snapshot 與 checksum 放進固定 tag 的 private GitHub Release，Codespace 第一次建立時會自動下載。

## Repository 權限

這個 repository 必須符合其中一種設定：

- Private organization repository，學生只有 read access。這是建議做法。
- Private personal repository，學生以 collaborator 身分加入。請注意 personal repository 的 collaborator 會取得 write access。
- Public repository，只有在 `roadrecon.db` 已確認可以公開時才使用。

## 第一次建立 Release

在存放正式 `roadrecon.db` 的目錄執行：

```bash
sha256sum roadrecon.db > roadrecon.db.sha256

gh release create course-assets \
  roadrecon.db \
  roadrecon.db.sha256 \
  --repo hackerpeanutjohn/EntraID_Training \
  --title "Course assets" \
  --notes "Private runtime assets for the Entra ID training Codespace."
```

macOS 若沒有 `sha256sum`，改用：

```bash
shasum -a 256 roadrecon.db > roadrecon.db.sha256
```

## 更新 Snapshot

更新時沿用同一個 Release tag，學生端不必換連結：

```bash
sha256sum roadrecon.db > roadrecon.db.sha256

gh release upload course-assets \
  roadrecon.db \
  roadrecon.db.sha256 \
  --repo hackerpeanutjohn/EntraID_Training \
  --clobber
```

## 課前驗證

1. 用測試學生帳號建立全新的 Codespace。
2. 確認建立過程出現 `ROADrecon snapshot downloaded and verified`。
3. 執行 `bash scripts/start-lab.sh`。
4. 確認 workstation 為 `healthy`。
5. 確認 Private Port `6080` 能開啟 Linux Desktop。
6. 確認 container 內的 `/course/roadrecon.db` 可讀。
