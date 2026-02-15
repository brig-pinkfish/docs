# Documentation Scripts

## generate-application-mcp-docs.ts

Generates `.mdx` documentation pages for application (external) MCP servers by reading tool definitions directly from the platform repo.

### When to run

- A new application MCP server is added to the platform
- An existing server's tools change (new tool, removed tool, parameter changes)
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
```

Or as a one-liner from the docs repo root:

```bash
(cd ../platform/servers/agentic/mcp && npx tsx ../../../../docs/scripts/generate-application-mcp-docs.ts)
```

### What it does

1. Imports `AVAILABLE_SERVERS` from `platform/servers/agentic/mcp/src/servers/available-servers.ts`
2. Filters to external servers where `productionEnabled !== false`
3. For each server, reads its tool definitions (Zod schemas) and generates:
   - A parameters table (excluding PCID, which is documented in the overview)
   - An expandable `inputSchema` JSON block
4. Writes `.mdx` files to `docs/api-reference/mcp-servers/application/`
5. Updates `docs.json` navigation with all generated pages

### Output format

Each page follows the lighter application server format:

- Frontmatter (title, description)
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

### Description overrides

The script has a `DESCRIPTION_OVERRIDES` map that provides better descriptions than the terse ones in `available-servers.ts` (e.g. "Slack API" becomes "Channels, messages, reactions, users, and workspace management"). If a server isn't in the map, the raw description from `available-servers.ts` is used as-is.

### Files modified

- `api-reference/mcp-servers/application/*.mdx` — one per server (auto-generated, do not edit manually)
- `docs.json` — Application MCP Servers navigation group updated
- `api-reference/mcp-servers/application/overview.mdx` — NOT touched (manually maintained)
