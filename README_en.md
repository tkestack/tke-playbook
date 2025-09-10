# TKE Playbook Repository Contribution Guide

[中文版本](./README.md)

Welcome to the TKE Playbook repository! This document will guide you on how to contribute content to this repository.

## Repository Introduction

TKE Playbook is a repository that collects and shares best practices, operation manuals, and troubleshooting solutions related to TKE. We encourage community members to contribute their own experiences and knowledge to help more people better use and manage Kubernetes clusters.

## Quick Start

To contribute content to this repository, please follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/tkestack/tke-playbook.git
```

### 2. Create Your Content Directory

```bash
mkdir your-directory-name
cd your-directory-name
```

Please replace `your-directory-name` with the directory name you want to create.

### 3. Create a README.md File

Create a README.md file in your directory to describe your content:

```bash
touch README.md
```

Then edit the file to add detailed content.

### 4. Create a __meta__.txt File

Each contributed directory must contain a metadata file named `__meta__.txt`. This file contains important information about your contributed content.

Create the `__meta__.txt` file:

```bash
touch __meta__.txt
```

The format of the `__meta__.txt` file is as follows:

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

Field descriptions:

- `title`: Chinese title, briefly describing your content
- `description`: Chinese detailed description, detailing your content
- `class`: Content category (e.g., "TKE")
- `tag`: Tag list for classification and searching
- `draft`: Whether it's a draft (true/false)
- `title_en`: English title
- `description_en`: English detailed description
- `class_en`: English content category
- `tag_en`: English tag list
- `draft`: Whether it's a draft (true/false)

### 5. Submit Your Content

After preparing your content directory and `__meta__.txt` file, you can submit through the following methods:

1. Add and commit your changes:
   ```bash
   git add .
   git commit -m "Add your-directory-name playbook"
   ```

2. Push your changes:
   ```bash
   git push origin main
   ```

3. Or, if you don't have direct commit permissions, create a Pull Request:
   - Fork this repository
   - Add your content directory to the repository
   - Submit a Pull Request

## Notes

- Please ensure your `__meta__.txt` file follows the specified format
- Maintain the relevance and quality of the content
- Check spelling and grammar errors before submitting
- If the content is not yet complete, set the `draft` field to `true`
