# Multi-Agent 开发流程 Skills 生态分析

> 调研日期: 2026-03-28
> 目的: 评估可加速 Claude Planner + Multi-GPT Worker Pool 架构的 skills 生态

## 一、开发流程全景与 Skills 覆盖度

```
需求明确 → 开发计划 → 工作分发 → 并行实现 → 测试验证 → Code Review → 合并/迭代
   ▲          ▲          ▲          ▲          ▲          ▲          ▲
  弱覆盖     中等覆盖    弱覆盖     强覆盖     中等覆盖    强覆盖     弱覆盖
```

**结论: 生态对"实现"和"审查"阶段覆盖较好，但在需求定义、工作编排和合并流程上存在明显空白。**

---

## 二、按开发阶段分析推荐 Skills

### Phase 1: 需求明确与规格定义

| Skill | 来源 | 功能 | 推荐度 | 备注 |
|-------|------|------|--------|------|
| **planning-with-files** | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | Manus 式持久化 Markdown 规划，将工作记忆从上下文窗口移到磁盘 | ★★★★ | 已在 external-skill-review.md 中评估为 fork-first |
| **prd-taskmaster** | [anombyte93/prd-taskmaster](https://github.com/anombyte93/prd-taskmaster) | AI 驱动的 PRD 生成，与 taskmaster 集成 | ★★★ | 需评估安全性 |
| **superpowers** | [obra/superpowers](https://github.com/obra/superpowers) | Socratic brainstorming，TDD 强制执行，4 阶段调试 | ★★★★ | 已在 external-skill-review.md 中评估为 fork-first |

**现状**: 没有一个 skill 能完整覆盖"从模糊需求到结构化 spec"的流程。planning-with-files 最接近但仍偏向实现层面。

**建议**: 自建一个 `requirement-spec` skill，流程:
1. 用户描述需求 → 生成结构化 spec（目标、约束、验收标准）
2. 用户确认 spec → 自动创建 task_plan.md
3. 输出可供 Worker 直接消费的任务 spec 文件

---

### Phase 2: 开发计划与任务分解

| Skill | 来源 | 功能 | 推荐度 | 备注 |
|-------|------|------|--------|------|
| **create-plan** | [openai/skills](https://github.com/openai/skills) (experimental) | 生成 6-12 个原子级 action items，含依赖关系和验证策略 | ★★★★ | Codex 实验性 skill，值得试用 |
| **Architecture Decision Records** | [mcpmarket.com](https://mcpmarket.com/tools/skills/architecture-decision-records-adrs-3) | 结构化决策文档：context、alternatives、pros/cons | ★★★ | 适合记录架构决策 |
| Claude Code Plan Mode | 内置 | Shift+Tab×2 进入只读规划模式 | ★★★★★ | 已内置，无需安装 |

**现状**: create-plan 能生成不错的计划，但缺少"根据计划自动分配到 N 个 Worker"的能力。

**建议**: 自建一个 `task-dispatcher` skill，流程:
1. 读取 task_plan.md → 解析出独立可并行的任务
2. 根据任务复杂度建议 Worker 数量和配置
3. 为每个 Worker 生成独立的 spec 文件
4. 输出 MCP 调用命令

---

### Phase 3: 多代理编排与工作分发

| Skill/工具 | 来源 | 功能 | 推荐度 | 备注 |
|------------|------|------|--------|------|
| **ccswarm** | [nwiizo/ccswarm](https://github.com/nwiizo/ccswarm) | Claude Code 多代理编排，git worktree 隔离 | ★★★★ | 值得研究其模式 |
| **parallel-worktrees** | [spillwavesolutions/parallel-worktrees](https://github.com/spillwavesolutions/parallel-worktrees) | Git worktree 并行管理 | ★★★ | 纯 worktree 管理 |
| **subtask-orchestrator** | [mcpmarket.com](https://mcpmarket.com/tools/skills/subtask-orchestrator) | CLI 驱动的子任务分发到并行 subagent | ★★★★ | 接近我们的需求 |
| **Agent Teams** | Claude Code 实验性功能 | 多会话协同，共享任务列表 | ★★★ | 需要 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS |
| **codex-as-mcp** | [kky42/codex-as-mcp](https://github.com/kky42/codex-as-mcp) | Codex CLI 转 MCP server | ★★★★★ | 我们架构的核心桥接 |
| `/batch` | Claude Code 内置 | 将大规模变更分解为并行单元 | ★★★★ | 内置，但面向 Claude subagent 而非 Codex |

**现状**: 这是整个生态最薄弱的环节。没有一个 skill 能做到:
```
读取计划 → 自动判断并行度 → 分发给 Codex Worker → 监控进度 → 汇总结果
```

**核心问题**: codex-as-mcp 提供了桥接，但缺少上层编排逻辑。

**建议**: 这是 multi-agent-dev-framework 最需要补强的地方。可能需要:
1. 一个 `orchestrator` skill，管理 Worker 生命周期
2. 或者利用 Claude Code 的原生 subagent + MCP scoping 来实现

---

### Phase 4: 并行实现

| Skill | 来源 | 功能 | 推荐度 | 备注 |
|-------|------|------|--------|------|
| **superpowers TDD** | [obra/superpowers](https://github.com/obra/superpowers) | 强制 red-green-refactor 工作流 | ★★★★ | Worker 级别的质量保证 |
| **Codex subagent configs** | 我们的 .codex/agents/*.toml | implementer/analyzer/tester 分工 | ★★★★★ | 已内置 |
| **repo-working-memory** | 我们的 .codex/skills/ | 持久化上下文追踪 | ★★★★★ | 已内置 |

**现状**: 实现阶段覆盖最好。Worker 有明确的 agent 配置、沙箱隔离、worktree 隔离。

---

### Phase 5: 测试验证

| Skill | 来源 | 功能 | 推荐度 | 备注 |
|-------|------|------|--------|------|
| **Unit Test Writer** | [lobehub.com](https://lobehub.com/skills) | 生成 pytest/Jest/JUnit 单元测试 | ★★★ | 质量取决于 prompt |
| **testing-workflow** | [fastmcp.me](https://fastmcp.me/Skills/Details/473/testing-workflow) | 测试生成、mocking、stubs，覆盖单元/集成/性能 | ★★★★ | 较全面 |
| **我们的 tester subagent** | .codex/agents/tester.toml | gpt-5.4-mini 编写和运行测试 | ★★★★ | 已内置 |
| **Playwright MCP** | 官方 MCP | 浏览器控制，E2E 测试 | ★★★ | 需要 UI 测试时使用 |

**现状**: 单元测试生成有多个 skill 可用，但缺少:
- 集成测试编排（多组件协同测试）
- 测试覆盖率追踪（跨 agent 会话）
- 测试环境自动搭建

**建议**: 利用现有 tester subagent + testing-workflow skill 组合使用。

---

### Phase 6: Code Review

| Skill | 来源 | 功能 | 推荐度 | 备注 |
|-------|------|------|--------|------|
| **Claude Code Review** | 官方（2026-03-09 发布） | 多代理并行审查 diff，内联评论，严重度分级 | ★★★★★ | 最强大，但需要 Teams/Enterprise |
| **/review** | Claude Code 内置 | 生成并行审查代理分析代码变更 | ★★★★★ | 免费可用 |
| **/simplify** | Claude Code 内置 | 三个并行审查代理从不同角度分析 | ★★★★ | 补充 /review 使用 |
| **codex-code-review** | [smithery.ai](https://smithery.ai/skills) | 基于 Codex SDK 的只读 PR 分析 | ★★★ | 适合 Codex 侧审查 |
| **diffity** | [kamranahmedse/diffity](https://github.com/kamranahmedse/diffity) | GitHub 风格 diff 可视化 | ★★★ | 辅助工具 |

**现状**: **覆盖最好的阶段**。内置 /review + /simplify 已经很强大。

---

### Phase 7: 合并与迭代

| Skill | 来源 | 功能 | 推荐度 | 备注 |
|-------|------|------|--------|------|
| **merge-conflict-resolution** | [lobehub.com](https://lobehub.com/skills) | 自动分析冲突双方意图，智能解决 | ★★★ | 需评估实际效果 |
| **/commit** | Claude Code 内置 | 自动生成 commit message | ★★★★ | 已内置 |
| **GitHub MCP Server** | [github/github-mcp-server](https://github.com/github/github-mcp-server) | 管理 Issues/PRs/Workflows | ★★★★★ | 官方，强烈推荐 |

**现状**: 缺少自动化的"Review 发现问题 → 自动分发修改任务 → 重新测试 → 重新审查"循环。

---

## 三、生态空白分析

### 当前最大的 3 个空白

| 空白 | 描述 | 影响 | 可能的解决方案 |
|------|------|------|---------------|
| **编排层缺失** | 没有 skill 能自动将计划分解为 Worker 任务并分发 | 每次都需要人工拆分任务和编写 MCP 调用 | 自建 orchestrator skill |
| **Review→Fix 循环未自动化** | Review 发现问题后，没有自动重新分发修改任务 | 人工中转降低效率 | 在 orchestrator 中加入迭代逻辑 |
| **跨 Agent 状态同步** | Worker 之间、Worker 与 Planner 之间缺乏实时状态同步 | 无法动态调整并行策略 | 利用 repo-local files 或 MCP memory |

### 次要空白

- 测试覆盖率无法跨 agent 会话追踪
- 没有统一的多代理工作仪表板
- Agent Teams 仍为实验性功能
- token 成本归因（哪个 agent 用了多少）无法追踪

---

## 四、推荐的 Skills 安装优先级

### 第一优先级（立即安装/评估）

1. **GitHub MCP Server** — PR/Issue 管理自动化
   ```bash
   claude mcp add github -- npx -y @modelcontextprotocol/server-github
   ```

2. **create-plan** (openai/skills) — 结构化开发计划生成
   ```bash
   # 安装到 .codex/skills/
   ```

3. **testing-workflow** — 测试生成和验证
   ```bash
   # 从 fastmcp.me 安装
   ```

### 第二优先级（评估后决定）

4. **ccswarm 模式研究** — 学习其多代理编排方式
5. **subtask-orchestrator** — 子任务分发模式
6. **planning-with-files** (fork 版) — 持久化规划

### 第三优先级（自建）

7. **requirement-spec skill** — 需求 → 结构化 spec
8. **task-dispatcher skill** — 计划 → Worker 分发
9. **review-loop skill** — Review → Fix → Re-review 自动循环

---

## 五、对 multi-agent-dev-framework 的改进建议

基于此次调研，框架应考虑增加:

1. **开发流程 skills 套件**:
   ```
   .codex/skills/
   ├── repo-working-memory/     # 已有 ✓
   ├── requirement-spec/        # 新增: 需求规格化
   ├── task-dispatcher/         # 新增: 任务分发到 Worker
   └── review-loop/             # 新增: Review 迭代循环
   ```

2. **Claude Code 侧 skills**:
   ```
   .claude/skills/
   ├── plan-and-dispatch/       # 新增: 规划后自动分发
   └── review-and-merge/        # 新增: 审查后合并流程
   ```

3. **MCP 服务器集成建议**:
   - GitHub MCP（PR/Issue 管理）
   - codex-as-mcp（已有 ✓）

4. **文档补充**:
   - 开发流程最佳实践指南
   - 实战案例（hot-repo 作为第一个案例）
   - 常见问题和 Bug 记录

---

## 六、参考来源

### Skills 市场
- [SkillsMP](https://skillsmp.com/) — 66,500+ skills
- [Smithery.ai](https://smithery.ai/skills) — 15,000+ community skills
- [FastMCP](https://fastmcp.me/skills) — Claude Code skills 浏览器
- [LobeHub](https://lobehub.com/skills) — Agent Skills marketplace
- [MCPMarket](https://mcpmarket.com/) — MCP tools & skills

### 社区合集
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
- [awesome-codex-skills](https://github.com/ComposioHQ/awesome-codex-skills)
- [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit)
- [claude-skills (192+)](https://github.com/alirezarezvani/claude-skills)

### 官方文档
- [Codex CLI Skills](https://developers.openai.com/codex/skills)
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Claude Code Review](https://code.claude.com/docs/en/code-review)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [MCP Registry](https://registry.modelcontextprotocol.io/)
