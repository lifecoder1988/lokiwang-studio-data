---
title: ADR-0001：Repository conventions
status: accepted
date: 2026-07-08
owners:
  - lokiwang-studio-data
supersedes: []
superseded_by: []
tags: [conventions]
---

# ADR-0001：Repository conventions

## 背景

项目接入 AI Agent 协作，需要统一仓库元数据结构：AGENTS.md、领域文档、ADR、frontmatter 与校验规则。

## 决策

采用 Wing 约定：

- 根 `AGENTS.md` 只保留操作性规则与文档入口，不复制领域规则。
- 领域规则统一放在 `docs/domain/<domain>/`。
- 长期架构决策记录在 `docs/adr/`，四位递增编号，不复用编号。
- 受约束文档必须包含 frontmatter：title、status、owner、last_reviewed。
- 通过 `wing check` 在本地与 CI 校验元数据完整性。

## 不采用的方案

### 单一大 AGENTS.md

规则集中在单文件会不可维护，且 Agent 无法按目录感知局部规则。

## 后果

### 正向影响

- 规则只写一次，可被机器校验。

### 代价与限制

- 需要维护文档 frontmatter 与审核时间。

### 后续约束

- 新领域必须通过 `wing new-domain` 创建。

## 关联内容

- Domain docs: docs/domain/
- Related ADRs:
