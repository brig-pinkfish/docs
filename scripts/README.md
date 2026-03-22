# Documentation Scripts

## generate-application-mcp-docs.ts

Generates `.mdx` documentation pages for application (external) MCP servers by reading tool definitions directly from the platform repo.

**Quick run (single server, e.g. zoom):**
```bash
cd platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-application-mcp-docs.ts --server zoom
```
*(Run from docs repo root; platform must be at `../platform`)*

### When to run

- A new application MCP server is added to the platform
- An existing server's tools change (new tool, removed tool, parameter changes)
- The generator script changes in a way that affects generated page content or nav labels
- You want to regenerate all pages from scratch

### Prerequisites

- The `platform` repo must be cloned alongside this repo at `../platform`
- Node.js 20+ and `npx` must be available (`tsx` is used via npx)

### How to run

```bash
# From the platform MCP directory (required for TypeScript path resolution):
cd ../platform/servers/agentic/mcp

# Generate ALL production-enabled application server pages:
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts

# Generate a single server (useful for testing):
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts --server slack

# One parent page with child servers (merged page from mcp-server-definitions):
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts --server genesys
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts --server jira-cloud
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts --server workday

# Generate only servers with changes vs origin/main:
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts --changed

# Generate only servers with changes vs a specific git ref:
npx tsx /path/to/docs/scripts/generate-application-mcp-docs.ts --changed HEAD~3
```

Or as a one-liner from the docs repo root:

```bash
# All servers
(cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-application-mcp-docs.ts)

# Only changed servers
(cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-application-mcp-docs.ts --changed)
```

### What it does

1. Imports `AVAILABLE_SERVERS` from `platform/servers/agentic/mcp/src/servers/available-servers.ts`
2. Merges any `platform/.../external/<name>/` directory that has `tools.ts` and **tools** but is **missing** from `available-servers.ts` (registry drift on some branches). Directories that are only referenced via an import path (e.g. `microsoft-dynamics-crm` tools used by server name `dynamics-crm`) are **not** double-documented.
3. Filters to external servers where `productionEnabled !== false`
4. For each server, reads its tool definitions (Zod schemas) and generates:
   - A parameters table (excluding PCID, which is documented in the overview)
   - An expandable `inputSchema` JSON block
5. Writes `.mdx` files to `docs/api-reference/mcp-servers/application/`
6. Updates `docs.json` navigation with all generated pages
7. **Parent pages with child servers** (`../platform/mcp-server-definitions/`): For each registered family, writes one merged `.mdx` (child server table + per-child-server tool docs) and updates `docs.json`. Today: **`genesys`** (flat `genesys-*` dirs), **`jira-cloud`** (nested under `jira-cloud/`), **`workday`** (nested under `workday/`). Uses dynamic `import()` of each tool file (run from `platform/servers/agentic/mcp` as usual). If a family has no child servers, its `.mdx` is removed and the nav entry is dropped on a full regen. To add another family, extend `PARTITION_FAMILIES` in the script.

### Output format

Each page follows the lighter application server format:

- Frontmatter (title, description — also used for Mintlify meta; not repeated as a body paragraph)
- Lower-case `sidebarTitle` values that match the MCP server path shown in the customer-facing nav
- Server metadata line (path, type, PCID required)
- Tools overview table
- Per-tool sections with parameters table + expandable inputSchema
- No response fields table or curl examples (keeps pages focused)

### Adding a new server

When a new application server is added to the platform:

1. Add the server to `available-servers.ts` in the platform repo (as usual)
2. Add a human-readable description to the `DESCRIPTION_OVERRIDES` map in this script (optional but recommended — without one, the raw description from `available-servers.ts` is used)
3. Run the script: `(cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-application-mcp-docs.ts)`
4. Commit and push the generated files + updated `docs.json`

## generate-embedded-mcp-docs.ts

Generates `.mdx` documentation pages for embedded MCP servers by reading tool definitions directly from the platform repo.

**Quick run (single server, e.g. vault):**
```bash
cd platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-embedded-mcp-docs.ts --server vault
```
*(Run from docs repo root; platform must be at `../platform`)*

### When to run

- A new embedded MCP server is added to the platform
- An existing embedded server's tools change (new tool, removed tool, parameter changes)
- The generator script changes in a way that affects generated page content
- You want to regenerate all embedded pages from scratch

### Prerequisites

- The `platform` repo must be cloned alongside this repo at `../platform`
- Node.js 20+ and `npx` must be available (`tsx` is used via npx)

### How to run

```bash
# From the platform MCP directory (required for TypeScript path resolution):
cd ../platform/servers/agentic/mcp

# Generate ALL embedded server pages:
npx tsx /path/to/docs/scripts/generate-embedded-mcp-docs.ts

# Generate a single server (useful for testing):
npx tsx /path/to/docs/scripts/generate-embedded-mcp-docs.ts --server vault

# Generate only servers with changes vs origin/main:
npx tsx /path/to/docs/scripts/generate-embedded-mcp-docs.ts --changed

# Generate only servers with changes vs a specific git ref:
npx tsx /path/to/docs/scripts/generate-embedded-mcp-docs.ts --changed HEAD~3
```

Or as a one-liner from the docs repo root:

```bash
# All servers
(cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-embedded-mcp-docs.ts)

# Only changed servers
(cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-embedded-mcp-docs.ts --changed)
```

### What it does

1. Imports `AVAILABLE_SERVERS` from `platform/servers/agentic/mcp/src/servers/available-servers.ts`
2. Filters to embedded servers that are available to users or agents, excluding deprecated/internal servers (`llm`, `perplexity`, `ocr`, `pinkfish-utilities`)
3. For each server, reads its tool definitions (Zod schemas) and generates:
   - A parameters table (excluding PCID)
   - An expandable `inputSchema` JSON block
4. Writes `.mdx` files to `docs/api-reference/mcp-servers/embedded/`
5. Updates `docs.json` navigation with all generated pages
6. Preserves manually-maintained pages (`overview.mdx`, `artifact-tools.mdx`)

### Output format

Each page follows the embedded server format:

- Frontmatter (title, description)
- Server metadata line (path, type: Embedded, PCID required: No)
- Tools overview table
- Per-tool sections with parameters table + expandable inputSchema

### Server name mapping

Some embedded servers have different directory names vs doc slugs:

| Server name (registry) | Code directory | Doc slug |
| --- | --- | --- |
| `embedded-anthropic` | `anthropic/` | `embedded-anthropic` |
| `embedded-openai` | `openai/` | `embedded-openai` |
| `embedded-gemini` | `gemini/` | `embedded-gemini` |
| `embedded-groq` | `groq/` | `embedded-groq` |
| `embedded-perplexity` | `perplexity-embedded/` | `embedded-perplexity` |
| `datastore-structured` | `datastore/` | `datastore-structured` |
| `web-search` | `search/` | `web-search` |
| `code-execution` | `code-execution/` (sandbox group) | `code-execution` |

### Files modified

- `api-reference/mcp-servers/embedded/*.mdx` — one per server (auto-generated, do not edit manually)
- `docs.json` — Embedded MCP Servers navigation group updated
- `api-reference/mcp-servers/embedded/overview.mdx` — NOT touched (manually maintained)
- `api-reference/mcp-servers/embedded/artifact-tools.mdx` — NOT touched (manually maintained)

## count-mcp-tools.ts

Counts the current MCP Farm tool total from source definitions in the `platform` repo.

**Quick run:**
```bash
cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/count-mcp-tools.ts
```

### What it counts

- Classic MCP tools from `AVAILABLE_SERVERS` (embedded + external)
- Generated dynamic MCP tools from `platform/mcp-server-definitions/**/tools/*.ts`

Use this before updating customer-facing copy such as the Platform API overview or agent prompt so the published number stays fresh.

### Updating the overview page

The overview page at `api-reference/mcp-servers/application/overview.mdx` is **manually maintained** and is NOT updated by this script. When adding a new application server, you must manually add a row for it in the appropriate category table on the overview page.

### Description overrides

The script has a `DESCRIPTION_OVERRIDES` map that provides better descriptions than the terse ones in `available-servers.ts` (e.g. "Slack API" becomes "Channels, messages, reactions, users, and workspace management"). If a server isn't in the map, the raw description from `available-servers.ts` is used as-is.

### Files modified

- `api-reference/mcp-servers/application/*.mdx` — one per server (auto-generated, do not edit manually)
- `docs.json` — Application MCP Servers navigation group updated
- `api-reference/mcp-servers/application/overview.mdx` — NOT touched (manually maintained)
