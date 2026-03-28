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

## Issue #4: codex-as-mcp 共享工作目录导致分支污染

- **日期**: 2026-03-28
- **阶段**: Worker 并行分发
- **问题**: `spawn_agents_parallel` 的 3 个 Worker 共享同一个 `/home/fy274/projects/hot_repo` 目录。每个 Worker 执行 `git checkout feat/xxx` 时互相冲突，导致:
  - 所有 Worker 的代码变更泄漏到其他分支
  - feat/infra 包含了 scraper 和 notifier 的 commit
  - 分支不再代表独立的工作单元
- **根因**: `codex-as-mcp` 的 `spawn_agents_parallel` 在同一个 cwd 中并行执行，没有 git worktree 隔离。框架文档描述了 worktree 隔离但 MCP 桥接层不支持
- **影响**: 分支策略失效，无法做真正的并行隔离开发
- **修复建议**:
  1. 在 Worker spec 中要求 Worker 自己创建 worktree: `git worktree add ../hot_repo-scraper feat/scraper`
  2. 或在分发前由 Planner 预创建 worktrees，然后传入不同的 cwd
  3. 长期方案: 在 task-dispatcher skill 中内置 worktree 管理逻辑
  4. 对于 `codex-as-mcp`，可能需要支持 per-agent cwd 参数

## Issue #5: Worker 间接口不匹配（最常见的多 Agent 问题）

- **日期**: 2026-03-28
- **阶段**: Review
- **问题**: GPT-5.4 对抗式审查发现:
  - Worker 3 的 main.py 用 `_invoke_compatible()` 反射调用替代直接函数调用
  - main.py 传 `generated_at`(datetime) 但 scraper 期望 `date_str`(string)
  - notifier.dispatch 签名参数名与 main.py 传入的不匹配
  - config key 不一致: `to` vs `to_addrs`, `url` vs `bark_url`
- **根因**: Worker 3 不知道 Worker 1 和 Worker 2 的实际函数签名，Spec 中只描述了功能而非精确的函数签名和参数类型
- **影响**: 模块间接口不兼容，运行时会报错
- **修复建议**:
  1. 在 task-dispatcher skill 中增加"接口契约"部分，明确定义跨 Worker 的函数签名
  2. 对于有依赖关系的模块（如 main.py 依赖 scraper 和 notifier），应在独立模块完成后再分发
  3. 或者提供 .pyi stub 文件给依赖方 Worker
  4. Planner 承担集成责任：合并后修复接口问题

## 待记录

- [ ] Codex Worker MCP 调用的实际延迟和可靠性
- [x] Worker 之间的状态同步问题 → Issue #4
- [ ] 复杂任务的计划分解粒度
- [x] Review 迭代的实际轮次和效率 → 第一轮 Review 发现 4 个 Critical 问题
- [ ] token 消耗和成本
