# Model Selection Guide

Complete guide to selecting the right AI model for OpenCode agents, with rationale for each agent's model assignment.

**Last Updated:** 2026-02-04

---

## Table of Contents

- [Model Tiers Overview](#model-tiers-overview)
- [Selection Criteria](#selection-criteria)
- [Agent Model Assignments](#agent-model-assignments)
- [Decision Framework](#decision-framework)
- [Cost vs Quality Trade-offs](#cost-vs-quality-trade-offs)
- [Future Model Options](#future-model-options)

---

## Model Tiers Overview

### Claude Haiku 4.5 - Fast & Efficient ⚡

**Characteristics:**
- **Speed**: Fastest response times (⚡⚡⚡)
- **Cost**: Most economical ($)
- **Quality**: High quality for well-defined tasks (⭐⭐⭐)
- **Best For**: Deterministic workflows, simple transformations, fast iterations

**Use Cases:**
- Git operations and workflow automation
- Format conversion and text transformation
- Linear API integration (CRUD operations)
- Simple configuration tasks
- Quick lookups and queries

**Current Agents (4):**
- `git-flow-manager` - Deterministic Git Flow workflows
- `linearapp` - Linear.app issue tracking integration  
- `markdown-formatter` - Markdown syntax formatting
- `discord-golang-haiku45` - Straightforward Discord bot patterns

**Cost Profile:**
- Input: ~$0.25 per million tokens
- Output: ~$1.25 per million tokens
- **Best value** for high-frequency, simple tasks

---

### Claude Sonnet 4.5 - Balanced Intelligence ⚖️

**Characteristics:**
- **Speed**: Moderate response times (⚡⚡)
- **Cost**: Mid-tier pricing ($$)
- **Quality**: Excellent for most tasks (⭐⭐⭐⭐)
- **Best For**: Code review, analysis, balanced complexity

**Use Cases:**
- Code review and architecture analysis
- Prompt engineering and optimization
- Meta-tasks (creating agents/commands)
- Security analysis and compliance
- TypeScript backend (balanced stack)

**Current Agents (9):**
- `agent-creation` - Creating new agents (meta-reasoning)
- `architecture-review` - Architectural analysis
- `code-review` - Code quality review
- `command-creation` - Workflow design
- `error-detective` - Log analysis
- `hytale-modding` - Game mod development
- `prompt-engineering` - Prompt optimization
- `security-engineer` - Security analysis
- `typescript-backend` - TypeScript APIs

**Cost Profile:**
- Input: ~$3 per million tokens
- Output: ~$15 per million tokens
- **Best balance** of quality and cost

---

### Claude Opus 4.5 - Maximum Intelligence 🧠

**Characteristics:**
- **Speed**: Slower, more thoughtful (⚡)
- **Cost**: Premium pricing ($$$)
- **Quality**: Exceptional reasoning (⭐⭐⭐⭐⭐)
- **Best For**: Complex architecture, multi-system orchestration, deep analysis

**Use Cases:**
- Complex Spring Boot microservices
- Advanced Go patterns and concurrency
- Multi-stack full-stack applications
- Infrastructure as Code (IaC) design
- Game systems design (economy, progression)
- ML pipeline architecture

**Current Agents (12):**
- `devops-infrastructure` - K8s, Terraform, ArgoCD orchestration
- `golang-backend-api` - Advanced Go patterns
- `golang-tui-bubbletea` - Complex TUI architecture
- `java-kotlin-backend` - Spring microservices
- `mcp-server` - MCP integration patterns
- `mlops-engineer` - ML infrastructure
- `nextjs-fullstack` - Modern Next.js App Router
- `nixos` - NixOS declarative systems
- `react-typescript` - Advanced React patterns
- `rpg-mmo-systems-designer` - Complex game systems
- `sveltekit-frontend` - Svelte 5 reactivity
- `sveltekit-fullstack` - Full-stack SvelteKit

**Cost Profile:**
- Input: ~$15 per million tokens
- Output: ~$75 per million tokens
- **Premium tier** for complex reasoning

---

### OpenAI GPT-5.2 - Alternative Premium 🔄

**Characteristics:**
- **Speed**: Comparable to Opus (⚡)
- **Cost**: Premium pricing ($$$)
- **Quality**: Excellent, different strengths (⭐⭐⭐⭐⭐)
- **Best For**: Alternative perspective, certain language specializations

**Use Cases:**
- Fallback for Opus-tier agents
- Alternative for Java/Kotlin (strong Java performance)
- Multi-provider redundancy

**Current Usage:**
- Fallback model for `java-kotlin-backend`
- Not primary model for any agent (by design)

**Cost Profile:**
- Comparable to Opus tier
- Provider diversity benefit

---

## Selection Criteria

### 1. Task Complexity

**Low Complexity** → Haiku
- Well-defined, deterministic operations
- Simple transformations with clear rules
- CRUD operations with established patterns
- Format conversions

**Medium Complexity** → Sonnet
- Code analysis requiring pattern recognition
- Architectural decisions with trade-offs
- Security analysis with context awareness
- Balanced technical + reasoning tasks

**High Complexity** → Opus
- Multi-system orchestration
- Complex state management
- Advanced architectural patterns
- Deep reasoning about trade-offs

### 2. Reasoning Requirements

**Minimal Reasoning** → Haiku
- Follow documented procedures
- Execute known workflows
- Apply formatting rules

**Moderate Reasoning** → Sonnet
- Analyze code quality
- Identify security issues
- Balance competing concerns
- Create structured workflows

**Deep Reasoning** → Opus
- Design system architecture
- Optimize complex systems
- Model game economies
- Plan infrastructure changes

### 3. Code Generation Scope

**Simple Code** → Haiku
- Configuration files
- Simple scripts
- Template-based generation

**Moderate Code** → Sonnet
- TypeScript services
- React components
- Test suites
- API endpoints

**Complex Code** → Opus
- Microservice architectures
- Concurrent systems (Go)
- Full-stack applications
- Infrastructure as Code

### 4. Domain Expertise Depth

**Narrow Domain** → Haiku
- Specific tool operation (Git, Linear)
- Single-purpose formatters
- Well-bounded integrations

**Broad Domain** → Sonnet
- Language + framework knowledge
- Cross-cutting concerns
- Meta-level operations

**Deep Expertise** → Opus
- Multiple frameworks + patterns
- System design principles
- Performance optimization
- Complex domain modeling

---

## Agent Model Assignments

### Why Each Agent Uses Its Model

#### Haiku Agents (Fast Operations)

**git-flow-manager** - Haiku 4.5
- **Rationale**: Git Flow is deterministic with well-defined rules
- **Complexity**: Low - follows established branching patterns
- **Speed Benefit**: Fast branch creation, merging validation
- **Cost Efficiency**: High-frequency operation, predictable outcomes

**linearapp** - Haiku 4.5
- **Rationale**: Linear API is CRUD-focused with clear patterns
- **Complexity**: Low - issue tracking operations
- **Speed Benefit**: Quick issue creation, updates, queries
- **Cost Efficiency**: Frequent small operations

**markdown-formatter** - Haiku 4.5
- **Rationale**: Markdown formatting has clear syntax rules
- **Complexity**: Low - text transformation with defined spec
- **Speed Benefit**: Fast formatting feedback
- **Cost Efficiency**: Simple transformations

**discord-golang-haiku45** - Haiku 4.5
- **Rationale**: Discord bots follow established patterns
- **Complexity**: Medium-low - mostly CRUD + event handling
- **Speed Benefit**: Quick bot command generation
- **Note**: Could upgrade to Sonnet for more complex bot logic

---

#### Sonnet Agents (Balanced Tasks)

**agent-creation** - Sonnet 4.5
- **Rationale**: Meta-task requiring structure + creativity
- **Complexity**: Medium - needs to understand agent architecture
- **Reasoning**: Moderate - balancing agent scope and capabilities
- **Quality**: High accuracy important for system consistency

**code-review** - Sonnet 4.5
- **Rationale**: Pattern recognition + established best practices
- **Complexity**: Medium - analyzing code against standards
- **Reasoning**: Moderate - identifying issues and suggesting fixes
- **Quality**: Good balance of thoroughness and speed

**architecture-review** - Sonnet 4.5
- **Rationale**: Architectural patterns + best practices knowledge
- **Complexity**: Medium-high - system design evaluation
- **Reasoning**: Moderate-deep - trade-off analysis
- **Quality**: Strong architectural knowledge without Opus cost

**security-engineer** - Sonnet 4.5
- **Rationale**: Security patterns + compliance frameworks
- **Complexity**: Medium-high - security analysis
- **Reasoning**: Moderate-deep - threat modeling
- **Quality**: Critical accuracy, but established patterns

**typescript-backend** - Sonnet 4.5
- **Rationale**: TypeScript is well-documented, clear patterns
- **Complexity**: Medium - backend APIs with established frameworks
- **Reasoning**: Moderate - framework selection, pattern application
- **Cost Balance**: Good quality without premium cost

---

#### Opus Agents (Complex Reasoning)

**java-kotlin-backend** - Opus 4.5
- **Rationale**: Spring ecosystem is vast and complex
- **Complexity**: High - microservices, transaction management, JPA
- **Reasoning**: Deep - architectural decisions, performance optimization
- **Fallbacks**: GPT-5.2 (strong Java), Sonnet (budget mode)
- **Justification**: Enterprise applications justify premium model

**golang-backend-api** - Opus 4.5
- **Rationale**: Go concurrency and advanced patterns require deep understanding
- **Complexity**: High - goroutines, channels, context management
- **Reasoning**: Deep - performance optimization, concurrent design
- **Justification**: Go's simplicity hides complex concurrency considerations

**devops-infrastructure** - Opus 4.5
- **Rationale**: Multi-system orchestration (K8s, Terraform, ArgoCD)
- **Complexity**: Very high - distributed systems, IaC, GitOps
- **Reasoning**: Deep - infrastructure design, security, scaling
- **Justification**: Infrastructure mistakes are expensive

**nextjs-fullstack** - Opus 4.5
- **Rationale**: Next.js 16+ App Router is cutting-edge
- **Complexity**: High - React Server Components, caching strategies
- **Reasoning**: Deep - performance optimization, SSR vs CSR decisions
- **Justification**: Modern full-stack patterns require latest knowledge

**mlops-engineer** - Opus 4.5
- **Rationale**: ML pipelines require specialized knowledge
- **Complexity**: High - model training, deployment, monitoring
- **Reasoning**: Deep - system architecture, resource optimization
- **Justification**: ML infrastructure has unique challenges

**rpg-mmo-systems-designer** - Opus 4.5
- **Rationale**: Game economy is highly complex
- **Complexity**: Very high - balancing systems, player psychology
- **Reasoning**: Deep - mathematical modeling, player retention
- **Justification**: Game economy mistakes kill games

---

## Decision Framework

### For New Agents

```
START
  ↓
Does the task follow well-defined rules with little ambiguity?
  ├─ YES → Haiku ⚡
  └─ NO → Continue
         ↓
Does it require analyzing patterns but not deep architectural reasoning?
  ├─ YES → Sonnet ⚖️
  └─ NO → Continue
         ↓
Does it involve complex systems, multi-framework knowledge, or deep optimization?
  ├─ YES → Opus 🧠
  └─ UNSURE → Start with Sonnet, upgrade if needed
```

### Upgrade Triggers

**Haiku → Sonnet:**
- Agent struggles with context-dependent decisions
- Requires pattern recognition beyond simple rules
- Needs to balance competing concerns

**Sonnet → Opus:**
- Agent produces suboptimal architectural decisions
- Complex system interactions cause issues
- Performance optimization becomes critical
- Multi-framework orchestration required

### Downgrade Triggers

**Opus → Sonnet:**
- Task becomes well-understood with clear patterns
- Cost outweighs quality benefit
- Faster iterations more valuable than deep reasoning

**Sonnet → Haiku:**
- Task becomes purely procedural
- Speed becomes critical factor
- High-frequency operations with predictable outcomes

---

## Cost vs Quality Trade-offs

### Cost Examples (per 1M tokens)

| Model | Input | Output | Total (10K in + 2K out) |
|-------|-------|--------|-------------------------|
| Haiku | $0.25 | $1.25 | $2.75 |
| Sonnet | $3.00 | $15.00 | $30.60 |
| Opus | $15.00 | $75.00 | $165.00 |

### Quality Considerations

**When to Accept Lower Quality:**
- Non-critical formatting tasks
- Well-documented operations
- Tasks with validation steps
- High-frequency, low-risk operations

**When Quality is Critical:**
- Security analysis
- Infrastructure design
- Production database migrations
- Game economy balancing
- User-facing features

### Cost Optimization Strategies

1. **Use Appropriate Tier**
   - Don't use Opus for simple tasks
   - Don't use Haiku for complex architecture

2. **Optimize Prompts**
   - Clearer prompts = better results at lower tiers
   - Include examples in agent definitions

3. **Leverage Fallbacks**
   - Primary model for normal operations
   - Fallback to budget model when appropriate
   - Premium model for complex edge cases

4. **Monitor Usage**
   - Track which agents are used most
   - Identify opportunities for tier changes
   - Measure quality vs cost trade-offs

---

## Future Model Options

### Potential Additions

**Claude Haiku 5.x** (when available)
- May upgrade current Haiku agents
- Could replace some Sonnet agents

**OpenAI GPT-6.x**
- Alternative to Opus for some agents
- Potential different strengths

**Google Gemini Pro**
- Multi-modal capabilities
- Alternative provider diversity

**Anthropic Sonnet 5.x**
- May enable Opus → Sonnet downgrades
- Better cost/quality ratio

### Model Selection Evolution

```
2026 Current State:
├── Haiku 4.5 (4 agents)
├── Sonnet 4.5 (9 agents)
├── Opus 4.5 (12 agents)
└── GPT-5.2 (fallback)

2026+ Future State:
├── Haiku 5.x (5-6 agents)
├── Sonnet 5.x (12-15 agents)
├── Opus 5.x (8-10 agents)
└── Multi-provider fallbacks
```

### Continuous Improvement

- **Quarterly Review**: Reassess model assignments
- **Performance Tracking**: Monitor agent quality metrics
- **Cost Analysis**: Identify optimization opportunities
- **Model Upgrades**: Test new models as they release

---

## Best Practices

### For Agent Creators

1. **Start Conservative**: Begin with Sonnet, upgrade if needed
2. **Justify Premium**: Document why Opus is necessary
3. **Add Fallbacks**: Always include 1-2 fallback models
4. **Document Complexity**: Explain complexity level in metadata
5. **Test Tiers**: Try lower tier before committing to higher

### For System Maintainers

1. **Monitor Costs**: Track spend per agent
2. **Quality Metrics**: Measure agent effectiveness
3. **User Feedback**: Gather data on agent performance
4. **Regular Review**: Quarterly model assignment review
5. **Stay Updated**: Test new models as they release

### For Users

1. **Use Specific Agents**: Don't use Opus agent for simple tasks
2. **Understand Tier**: Know what you're paying for
3. **Provide Feedback**: Report quality issues
4. **Suggest Improvements**: If agent seems over/under-powered

---

## Conclusion

Model selection is a **continuous optimization** process balancing:
- **Quality**: Getting the right answer
- **Cost**: Spending efficiently
- **Speed**: Getting answers quickly

The current distribution (4 Haiku, 9 Sonnet, 12 Opus) reflects the **complexity distribution** of the agent ecosystem, with most agents requiring moderate (Sonnet) to high (Opus) intelligence for their domain expertise.

As models improve, we expect to see a **shift toward lower tiers** while maintaining quality, reducing overall cost without sacrificing capability.

---

**For Questions or Suggestions:**
- Open a Linear issue in the OpenCode Components team
- Tag with `model-selection` label
- Include specific agent name and rationale
