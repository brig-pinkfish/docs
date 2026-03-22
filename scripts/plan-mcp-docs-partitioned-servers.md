# Plan: Document partitioned MCP servers (Genesys-style)

This document describes how to extend `generate-application-mcp-docs.ts` so Mintlify can document **partitioned / codegen’d** MCP servers that live under `platform/mcp-server-definitions/`, in addition to today’s **classic application** servers under `platform/servers/agentic/mcp/src/servers/external/*/tools.ts`.

> **Naming:** Product and APIs are **Genesys** (Genesys Cloud). “Genesis” sometimes appears informally; all paths and types in platform use `genesys`.

---

## 1. Two shapes today

| Aspect | Classic application server (e.g. Adobe Sign) | Partitioned / OpenAPI-generated (e.g. Genesys) |
|--------|-----------------------------------------------|------------------------------------------------|
| **Location** | `servers/agentic/mcp/src/servers/external/<name>/` | `mcp-server-definitions/<partition-id>/` |
| **Tools** | Single `tools.ts` exporting `TOOLS: ServerTool[]` with **Zod** `paramsSchema` | Many `tools/<slug>.ts` files; each exports a **default** `McpToolDefinition` with **JSON Schema** `inputSchema` |
| **Server metadata** | `available-servers.ts` entry | Per-partition `server.ts` exporting `McpServerDefinition` (id, name, description, `serviceKey`, `productionEnabled`, optional `isParent` / `parentMcpId`) |
| **Registry** | `AVAILABLE_SERVERS` | Not necessarily listed in `available-servers.ts`; loaded as **dynamic** definitions at runtime |

The current doc generator only implements the **classic** path. Genesys-style servers are **not missing capability**; they are a **different artifact layout** the script does not scan.

---

## 2. Goals

1. **Detect** partitioned server families without hard-coding “Genesys” only (reusable for future OpenAPI partitions that share a `serviceKey` or parent id).
2. **Generate accurate tool docs** (parameters table + expandable schema) aligned with existing application pages.
3. **Navigation:** support the agreed UX — e.g. **one** `docs.json` entry (e.g. `genesys`) whose page is a **landing doc** listing siblings and in-page sections (or anchors) per partition, **or** nested nav — product decision; the script should support at least **one slug + merged MDX**.
4. **Respect `productionEnabled`** consistently with classic servers (e.g. skip or include based on the same rules used for public docs).

---

## 3. Recognition strategy (“what counts as a sibling?”)

Pick one primary rule (and optional fallbacks):

**Option A — Shared `serviceKey` (recommended)**  
- Parse each `mcp-server-definitions/*/server.ts` (or use a small Node script / tsx import).
- Group directories where `McpServerDefinition.serviceKey` is equal (e.g. all `serviceKey: 'genesys'`).
- **Family id** for docs slug: use `serviceKey` (`genesys`) or explicit `parentMcpId` when present.

**Option B — `parentMcpId` / `isParent`**  
- When platform adds a real parent row (`isParent: true`, id `genesys`) and children set `parentMcpId: 'genesys'`, group by that.
- Matches backend hierarchy; best long-term if parents exist in definitions.

**Option C — Naming convention**  
- e.g. directories matching `genesys-*`. Fragile; use only as fallback.

**Exclusions:** Skip `embedded` servers if any appear under `mcp-server-definitions`; skip entries that are clearly not application-facing if needed.

---

## 4. Extracting tool metadata without running handlers

`McpToolDefinition` includes a **`handler`** function. Blind `import()` of every tool file from the docs repo may pull in **heavy platform dependencies** or fail in isolation.

**Preferred approaches (in order):**

1. **Manifest file generated in platform** (CI or `openapi-to-mcp` step): e.g. `mcp-server-definitions/_manifest/genesys.docs.json` listing partitions and, per tool, `{ name, description, inputSchema }`. The docs script reads JSON only — fastest and most reliable.

2. **AST or regex extraction** in the docs script: read each `tools/*.ts` file as text; parse the exported object literal for `name`, `description`, `inputSchema` (strip `handler`). Works if codegen keeps a stable shape; brittle if formatting changes.

3. **tsx dynamic import** from `platform/mcp-server-definitions/...` with mocks for `handler` / executor — only if path aliases and deps are verified when run from `servers/agentic/mcp` (same cwd as today’s script).

Recommendation: **(1) manifest** for maintainability; **(2)** as interim if manifest is not yet built.

---

## 5. MDX generation from JSON Schema

Today’s script converts **Zod** → parameter tables and a synthetic `inputSchema` JSON block.

For partitioned tools, **`inputSchema` is already JSON Schema**. Add a parallel path:

- **Parameters table:** iterate `inputSchema.properties`; mark required via `inputSchema.required`; map JSON Schema types to display strings (reuse or simplify vs full Zod walk).
- **Expandable block:** pretty-print existing `inputSchema` (optionally omit or shorten `outputSchema` for parity with application pages).
- **PCID:** keep same convention as classic docs (document in overview; optional omit from table if desired).

**Per-partition sections on the merged page:**

- `## <partition-id>` or human title from `server.ts` `description` first line.
- **Server path:** `/<partition-id>` (actual MCP route — confirm with platform routing).
- Tools overview table + `---` + per-tool sections (same visual language as Adobe Sign screenshot).

---

## 6. `docs.json` updates

- **Single landing page:** append one path, e.g. `api-reference/mcp-servers/application/genesys`, and **do not** add eight separate partition slugs (per product choice).
- **`updateDocsJson`:** extend to merge **partitioned** slugs without wiping classic pages — today’s logic replaces the whole Application group when doing full regen; partitioned entries need a **stable merge** rule (e.g. known family slugs, or scan output dir).

---

## 7. CLI / README

Extend `docs/scripts/README.md`:

- New flags, e.g. `--partitioned-only`, `--family genesys`, or always run partitioned scan when `mcp-server-definitions` present.
- Clarify **prerequisite:** platform checkout on branch with definitions; if using manifest, path to manifest.

---

## 8. Implementation phases

| Phase | Work |
|-------|------|
| **1** | Add **family grouping** helper: discover `mcp-server-definitions/*/server.ts`, parse `serviceKey` / `parentMcpId`, return groups. |
| **2** | Add **JSON Schema → MDX** helpers (table + expandable). |
| **3** | Add **tool listing** via manifest **or** text extraction; validate on Genesys partitions. |
| **4** | Emit **`genesys.mdx`** (or generic `<serviceKey>.mdx`) under `api-reference/mcp-servers/application/`. |
| **5** | Update **`updateDocsJson`** to insert the new page once; document manual **overview.mdx** row. |
| **6** | Optional: platform PR to emit **docs manifest** on `openapi-to-mcp` run to simplify Phase 3. |

---

## 9. Open questions for product / platform

1. Should **non-production** partitions (`productionEnabled: false`) appear in **public** docs?
2. Confirm **canonical URL path** for each partition (`/genesys-conversations` vs nested).
3. Single **landing** slug only vs **nested** sidebar under “Genesys”.
4. Whether to add an explicit **`genesys` parent** `server.ts` with `isParent: true` in platform for parity with Workday-style hierarchy.

---

## 10. Files likely touched

| Repo | File |
|------|------|
| docs | `scripts/generate-application-mcp-docs.ts` |
| docs | `scripts/README.md` |
| docs | `docs.json` (generated / committed) |
| docs | `api-reference/mcp-servers/application/overview.mdx` (manual) |
| platform (optional) | `tools/openapi-to-mcp` or CI to write `mcp-server-definitions/**/docs-manifest.json` |

---

## 11. Current implementation vs future work

### What shipped (today)

`generate-application-mcp-docs.ts` uses a **`PARTITION_FAMILIES` registry**: each entry defines `docSlug`, PinkConnect service line, intro copy, **`gitDiffPathPrefix`**, and **discovery**:

- **`flat-prefix`** — e.g. top-level `genesys-*` (same as the original Genesys-only behavior).
- **`nested`** — e.g. `jira-cloud/<partition>/`, `workday/<partition>/`.

Registered families today: **`genesys`**, **`jira-cloud`**, **`workday`**. Each gets one merged Mintlify page and one `docs.json` slug. **`--changed`** treats any diff under a family’s `gitDiffPathPrefix` as a reason to regenerate that family.

### Future work

1. **Auto-discovery** from **`serviceKey` / `parentMcpId`** (§3) instead of manually appending to `PARTITION_FAMILIES` when new products ship.
2. Optional: **platform manifest** (§4.1) so the docs script does not rely on dynamic `import()` of every tool file.
3. **`productionEnabled`**: today partitioned docs include all partitions that load tools; align filtering with public-docs policy if needed (§9).

---

*This plan is descriptive only; implementation can follow the autodev process when prioritized.*
