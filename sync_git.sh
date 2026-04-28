#!/bin/bash

# --- 配置区域 ---
UPSTREAM_URL="https://github.com/NVlabs/FoundationStereo.git"
UPSTREAM_NAME="upstream"
# 获取当前分支名称
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "🚀 开始同步当前分支: $CURRENT_BRANCH"

# 1. 检查是否存在 upstream 远程仓库，不存在则添加
if ! git remote | grep -q "$UPSTREAM_NAME"; then
    echo "💡 未发现 upstream，正在添加官方仓库..."
    git remote add $UPSTREAM_NAME $UPSTREAM_URL
fi

# 2. 获取官方最新代码
echo "📥 正在从官方 (upstream) 拉取更新..."
git fetch $UPSTREAM_NAME

# 3. 使用 rebase 合并官方更新
# 注意：rebase 会把你的本地提交“挪到”官方最新提交之后，保持线性历史
echo "🔄 正在执行 rebase $UPSTREAM_NAME/master..."
if git rebase $UPSTREAM_NAME/master; then
    echo "✅ Rebase 成功！"
else
    echo "❌ Rebase 出现冲突，请手动解决后执行 git rebase --continue"
    exit 1
fi

# 4. 推送到你自己的 origin 仓库
# 注意：由于使用了 rebase，如果你的 origin 之前有旧提交，可能需要 --force
echo "📤 正在推送到个人仓库 (origin)..."
git push origin $CURRENT_BRANCH --force

echo "🎉 同步完成！你的 Fork 现在与官方保持一致了。"