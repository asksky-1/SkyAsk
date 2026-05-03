#!/bin/bash
# 更新博客主页的最新文章列表
# 自动提取最新 5 篇日记和 5 篇随笔

POSTS_DIR="/root/.openclaw/workspace/github-skyask/_posts"
INDEX_FILE="/root/.openclaw/workspace/github-skyask/index.md"

# 获取最新 5 篇日记
echo "获取最新日记..."
DIARY_FILES=$(ls -t "$POSTS_DIR"/*-diary.md 2>/dev/null | head -5)

# 获取最新 5 篇随笔（非日记）
echo "获取最新随笔..."
ESSAY_FILES=$(ls -t "$POSTS_DIR"/*.md 2>/dev/null | grep -v diary | head -5)

# 生成日记列表
DIARY_LIST=""
for file in $DIARY_FILES; do
    filename=$(basename "$file")
    # 提取日期：2026-04-20-diary.md -> 2026-04-20
    date=$(echo "$filename" | sed 's/-diary.md$//')
    # 生成链接
    year=$(echo "$date" | cut -d'-' -f1)
    month=$(echo "$date" | cut -d'-' -f2)
    day=$(echo "$date" | cut -d'-' -f3)
    DIARY_LIST="${DIARY_LIST}- [${date} 日记](./${year}/${month}/${day}/diary.html) - ${date}\n"
done

# 生成随笔列表
ESSAY_LIST=""
for file in $ESSAY_FILES; do
    filename=$(basename "$file")
    # 提取日期和标题：2026-03-03-welcome.md -> 2026-03-03, welcome
    date=$(echo "$filename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
    title=$(echo "$filename" | sed 's/^[0-9-]*-//' | sed 's/.md$//' | sed 's/-/ /g')
    # 生成链接
    year=$(echo "$date" | cut -d'-' -f1)
    month=$(echo "$date" | cut -d'-' -f2)
    day=$(echo "$date" | cut -d'-' -f3)
    # 从文件提取标题
    post_title=$(grep "^title:" "$file" | head -1 | sed 's/^title: *//' | sed 's/^"\(.*\)"$/\1/')
    if [ -z "$post_title" ]; then
        post_title="$title"
    fi
    ESSAY_LIST="${ESSAY_LIST}- [${post_title}](./${year}/${month}/${day}/${filename%.md}.html) - ${date}\n"
done

# 更新 index.md
cat > "$INDEX_FILE" << EOF
# SkyAsk 🌟

技术博客 - 分享思考与见解

---

## 关于博主

一名技术研发从业者，专注前沿科技领域。

---

## 最新文章

### 日记

$(echo -e "$DIARY_LIST")
### 随笔

$(echo -e "$ESSAY_LIST")
---

*Powered by GitHub Pages*
EOF

echo "✅ 主页已更新！"
echo "最新日记：$(echo "$DIARY_FILES" | wc -w) 篇"
echo "最新随笔：$(echo "$ESSAY_FILES" | wc -w) 篇"
