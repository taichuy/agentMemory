# agentMemory

`agentMemory` 是一个面向 AI 协同开发场景的通用记忆模板仓库。

它不是业务代码仓库，而是为项目开发过程提供一套可落地、可版本化的 `.memory/` 目录规范，用来统一管理用户偏好、项目阶段事实、工具踩坑记录、参考入口和待确认事项，让 Agent 在持续协作中可以稳定复用上下文，而不是每次都从零开始。

这个仓库默认只保留规则文件和模板文件，不附带任何具体项目示例，目的就是避免新项目初始化时把旧案例误当成通用记忆继续沿用。

## 适用场景

在项目开发过程中，团队通常需要一个专门的记忆管理目录，用来沉淀“代码之外、但又会持续影响决策”的信息。`agentMemory` 适合以下场景：

- 需要给 AI / Agent 提供稳定的长期上下文。
- 需要把聊天中的临时结论整理成可复用的项目资产。
- 需要把用户偏好、项目共识、工具故障经验和参考入口分开管理。
- 需要让记忆内容可以跟随仓库一起提交、审查、迁移和复用。

## 设计参考

本项目的设计思路参考了 Claude Code 的记忆系统，但把记忆从“会话内能力”进一步落到仓库中的 `.memory/` 目录里，使其成为可维护的工程结构。

核心目标有三点：

- 让记忆成为项目资产，而不是散落在上下文窗口中的隐性信息。
- 让 Agent 先读取摘要，再按需展开全文，降低检索噪声。
- 让不同类型的记忆有清晰边界，避免把所有信息混在一起。

## 使用
建议在根目录的：AGENTS.md，CLAUDE.md，GEMINI.md进行强制指向如：
```markdown
# ai必读
1.开始之前需要先阅读相关记忆，并且与用户沟通完决策性沟通时候应该主动维护记忆内容，对应记忆请先阅读：`.memory/AGENTS.md`

# 文件管理约定
1.如果对应子目录下有AGENTS.md，需要先介绍阅读再做处理
2.所有AGENTS.md，目标是提供短、硬、稳定的本地执行规则，尽可能精准，清晰，简短，最多不得超过200行。

```

## 目录结构

```text
.memory/
  AGENTS.md
  user-memory.md
  feedback-memory/
  project-memory/
  reference-memory/
  tool-memory/
  todolist/
```

各目录职责如下：

- `AGENTS.md`：记忆系统总规则，定义存储边界与检索顺序。
- `user-memory.md`：记录用户角色、技术背景、工作习惯、知识水平和沟通偏好。
- `feedback-memory/`：记录用户对协作方式和工程实践的纠正或确认。
- `project-memory/`：记录项目当前阶段事实、短期共识和决策背景。
- `reference-memory/`：只记录“去哪里看什么”的入口索引，不记录结论。
- `tool-memory/`：记录真实发生过的工具失败案例和已验证的解决办法。
- `todolist/`：记录 AI 自主推进过程中暂时需要用户确认的事项，处理后应删除，不做长期沉淀。

## 记忆存储规则

所有正式记忆文件都应优先使用 `YAML front matter` 作为摘要层，正文用于补充完整上下文。这样可以支持“先摘要检索，再按需展开”的工作流。

另外，这个模板仓库强调一条原则：能套模板就不要让大模型自己猜结构。每类记忆都应优先基于对应模板填写，再根据项目实际情况补充内容。

### 1. 用户记忆

用户记忆用于记录稳定信息，例如：

- 用户是谁。
- 用户的技术背景与熟悉语言。
- 用户的工作节奏和沟通偏好。
- 用户对输出风格、计划方式、实现方式的长期偏好。

这类记忆应该稳定、克制，不应写成用户画像或情绪日志。

### 2. 反馈记忆

反馈记忆用于记录用户已经明确给出的纠正或认可，要求一条记忆至少包含：

- 规则是什么。
- 为什么这样要求。
- 适用于什么场景。

反馈记忆应拆分为两类：

- `interaction/`：用户沟通、执行流程、记忆检索等交互类反馈。
- `repository/`：仓库结构、目录管理、脚本放置、版本控制等工程类反馈。

默认 `decision_policy` 为 `direct_reference`。

### 3. 项目记忆

项目记忆用于记录“当前正在发生的事情”，例如阶段目标、短期共识、当前约束、谁在做什么、为什么这样做。

项目记忆正文至少应回答：

- 谁在做什么？
- 为什么这样做？
- 为什么要做？
- 截止日期是什么？
- 决策背后的动机是什么？

这类记忆衰减较快，默认 `decision_policy` 为 `verify_before_decision`，表示在真正依赖它做判断前，应回到当前代码、文档或运行结果再次验证。

### 4. 引用记忆

引用记忆只负责建立入口索引，例如：

- 某个外部源码仓库在哪里。
- 某个 API 文档地址在哪里。
- 某个脚本入口在什么位置。

它不直接存放结论，默认 `decision_policy` 为 `index_only`。

### 5. 工具记忆

工具记忆只记录项目环境中真实发生过的工具问题，以及已经验证过的解决办法。边界要严格：

- 只记录真实失败过的问题。
- 只记录已验证可复用的解法。
- 不写通用工具教程。
- 不写尚未发生的风险猜测。
- 同一工具、同一问题、同一处理办法再次出现时，直接追加到原文件。

默认 `decision_policy` 为 `reference_on_failure`。

### 6. 不应存入记忆的内容

以下内容原则上不应写入 `.memory/`：

- 可以直接从当前代码中读出的结构、路径和实现细节。
- `git` 历史中已经存在的版本信息。
- 不能复用的一次性调试流水账。
- 配置文件里已经明确定义的内容。
- 与记忆系统无关的运行摘要、草稿和临时杂项。

## 记忆检索规则

本模板建议 Agent 按以下顺序检索记忆：

1. 固定先读 `.memory/AGENTS.md`。
2. 固定再读 `.memory/user-memory.md`。
3. 对 `feedback-memory`、`project-memory`、`reference-memory`、`tool-memory`，第一轮只读取每个文件前 30 行的 `YAML front matter`。
4. 单轮最多扫描 200 个记忆文件。
5. 单轮只展开与当前任务最相关的最多 5 条有效记忆全文。
6. 有效记忆选择原则是宁缺毋滥，只选真正相关的，不为了凑数量而展开。
7. 是否直接采用某条记忆，不只看时间，还要结合记忆类型、`decision_policy` 和当前任务相关性一起判断。
8. `project-memory` 如果已经超过两天，只有在它仍然影响当前决策时，才回到当前代码、当前文档或当前运行结果做验证。
9. `reference-memory` 只作为索引入口，不直接作为最终结论来源。
10. `tool-memory` 只在当前任务需要用到对应工具，或者该工具刚刚失败时再参与检索。

## 为什么要用这种结构

这套结构的重点，不是“把更多内容存起来”，而是“把真正有复用价值的内容存对地方”。

这样做的收益包括：

- 减少 Agent 每轮都重新理解项目背景的成本。
- 让长期偏好和短期事实分离，降低信息污染。
- 让工具经验沉淀成可复用知识，而不是停留在一次性对话里。
- 让记忆内容可以像代码一样被维护、被审查、被继承。

## 推荐用法

如果你准备把这个仓库作为新项目模板使用，推荐流程如下：

1. 保留根目录下的 `.memory/` 结构作为记忆系统入口。
2. 根据项目实际情况初始化 `user-memory.md` 和各类模板文件。
3. 在每次项目协作中，把真正可复用的信息按类型写回对应目录。
4. 让 Agent 在每次进入任务前，先按检索规则读取 `.memory`，再开始实现或决策。

当前仓库中已经为各类记忆准备了明确模板：

- `user-memory.md`：用户记忆模板。
- `feedback-memory/template.md`、`interaction/template.md`、`repository/template.md`：反馈记忆模板。
- `project-memory/template.md`：项目记忆模板。
- `reference-memory/template.md`、`source-reference.md`、`api-reference.md`、`script-reference.md`：引用记忆模板。
- `tool-memory/template.md`：工具记忆模板。
- `todolist/template.md`：待确认事项模板。

从这个角度看，`agentMemory` 本质上是一个“面向 AI 协作开发的记忆管理模板仓库”。

## 鸣谢

Thanks,
LINUX DO Moderators

感谢 [Linux.do](https://linux.do/) 社区支持。特别感谢L社区各位佬们分享学习经验和笔记，受益匪浅

---

## License

This project is licensed under [Apache-2.0](LICENSE).

---

## Contributors

<p align="center">
  <a href="https://github.com/taichuy/agentMemory/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=taichuy/agentMemory&max=50" alt="Contributors" />
  </a>
</p>

## Star History

<p align="center">
  <a href="https://www.star-history.com/#iOfficeAI/aionui&Date" target="_blank">
    <img src="https://api.star-history.com/svg?repos=taichuy/agentMemory&type=Date" alt="Star History" width="600">
  </a>
</p>

<div align="center">

**If you like it, give us a star**

[Report Bug](https://github.com/taichuy/agentMemory/issues) · [Request Feature](https://github.com/taichuy/agentMemory/issues)

</div>