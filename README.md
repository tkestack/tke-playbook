# TKE Playbook 仓库贡献指南

[English Version](./README_en.md)

欢迎来到 TKE Playbook 仓库！本文档将指导您如何向此仓库贡献内容。

## 仓库简介

TKE Playbook 是一个收集和分享 TKE 相关最佳实践、操作手册和故障处理方案的仓库。我们鼓励社区成员贡献自己的经验和知识，帮助更多人更好地使用和管理 Kubernetes 集群。

## 快速开始

要向此仓库贡献内容，请按照以下步骤操作：

### 1. 克隆仓库

```bash
git clone https://github.com/tkestack/tke-playbook.git
```

### 2. 创建您的内容目录

```bash
mkdir your-directory-name
cd your-directory-name
```

请将 `your-directory-name` 替换为您想要创建的目录名称。

### 3. 创建 README.md 文件

在您的目录中创建一个 README.md 文件来描述您的内容：

```bash
touch README.md
```

然后编辑该文件以添加详细内容。

### 4. 创建 __meta__.txt 文件

每个贡献的目录必须包含一个名为 `__meta__.txt` 的元数据文件。该文件包含有关您贡献内容的重要信息。

创建 `__meta__.txt` 文件：

```bash
touch __meta__.txt
```

`__meta__.txt` 文件的格式如下：

```
title = ''
description = ''
class = ""
tag = [""]
draft = false

title_en = ''
description_en = ''
class_en = ""
tag_en = [""]
draft = false
```

各字段说明：

- `title`: 中文标题，简要描述您的内容
- `description`: 中文详细描述，详细介绍您的内容
- `class`: 内容分类（例如："TKE"）
- `tag`: 标签列表，用于分类和搜索
- `draft`: 是否为草稿（true/false）
- `title_en`: 英文标题
- `description_en`: 英文详细描述
- `class_en`: 英文内容分类
- `tag_en`: 英文标签列表
- `draft`: 是否为草稿（true/false）



### 5. 提交您的内容

准备好内容目录和 `__meta__.txt` 文件后，您可以通过以下方式提交：

1. 添加并提交您的更改：
   ```bash
   git add .
   git commit -m "Add your-directory-name playbook"
   ```

2. 推送您的更改：
   ```bash
   git push origin main
   ```

3. 或者，如果您没有直接提交权限，请创建 Pull Request：
   - Fork 此仓库
   - 将您的内容目录添加到仓库中
   - 提交 Pull Request

## 注意事项

- 请确保您的 `__meta__.txt` 文件遵循指定格式
- 保持内容的相关性和质量
- 在提交前检查拼写和语法错误
- 如果内容尚未完成，请将 `draft` 字段设置为 `true`
