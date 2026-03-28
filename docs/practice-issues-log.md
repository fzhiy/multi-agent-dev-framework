# Multi-Agent Dev Framework 实践问题记录

> 目的: 记录使用本框架进行实际开发时遇到的问题、Bug 和经验教训
> 实践项目: hot-repo (GitHub Trending Top 10 每日推送)

## Issue #1: Claude 越过架构直接实现

- **日期**: 2026-03-28
- **阶段**: 初次使用
- **问题**: 让 Claude "使用多智能体架构开发"时，Claude 没有调用 codex-sub MCP 分发 Worker，而是自己完成了全部规划、实现、测试、提交、推送
- **根因**: 框架文档没有明确定义 Claude 作为 Planner 时的约束规则。Claude 默认"高效完成任务"而非"遵循架构"
- **影响**: 完全绕过了 Worker Pool，等于没有使用框架
- **修复建议**:
  1. 在 CLAUDE.md 中添加明确的行为约束: "当使用多智能体架构时，实现代码必须通过 MCP 分发给 Codex Worker"
  2. 添加 Planner 角色的 skill，强制执行规划→分发→审查流程
  3. 在 README 中增加 "Planner 行为规范" 章节

## Issue #2: 未经审查直接推送到 GitHub

- **日期**: 2026-03-28
- **阶段**: 初次使用
- **问题**: Claude 在完成代码后直接执行 `gh repo create --push` 推送到公开仓库，没有经过 Review 环节
- **根因**: 框架的 Review Loop 是文档描述的设计模式，没有在 Claude 的行为约束中强制执行
- **影响**: 未审查的代码被公开
- **修复建议**:
  1. 在 CLAUDE.md 中添加: "禁止在未经用户明确批准的情况下执行 git push 或创建 PR"
  2. 在框架中增加 pre-push hook 或 skill 来强制审查

## Issue #3: 未使用 feature branch

- **日期**: 2026-03-28
- **阶段**: 初次使用
- **问题**: 所有代码直接提交到 main 分支，没有使用 feature branch
- **根因**: 框架文档描述了 Worker 在独立 worktree 中工作，但没有定义分支策略
- **影响**: 无法进行 PR 审查，无法回滚单个功能
- **修复建议**:
  1. 定义默认分支策略: `feat/<task-slug>` → PR → Review → Merge to main
  2. 在 Worker 配置中默认创建 feature branch

## 待记录

- [ ] Codex Worker MCP 调用的实际延迟和可靠性
- [ ] Worker 之间的状态同步问题
- [ ] 复杂任务的计划分解粒度
- [ ] Review 迭代的实际轮次和效率
- [ ] token 消耗和成本
