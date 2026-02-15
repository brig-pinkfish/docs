# MCP Server Documentation Plan

## Objective

Create documentation pages for all MCP servers, organized into two sections:

- **`embedded/`** — Built-in platform servers (no external connection required)
- **`application/`** — External integration proxy servers (PCID required)

Each embedded server gets its own page following the standard format. Application servers are documented via a single index page with runtime discovery instructions.

## Folder Structure

```
api-reference/mcp-servers/
├── PLANNING.md
├── embedded/
│   ├── agent-management.mdx       ✅
│   ├── browser-automation.mdx     ✅
│   ├── code-execution.mdx         ✅
│   ├── pinkfish-sidekick.mdx      ✅
│   ├── datastore-structured.mdx   (pending)
│   ├── datastore-unstructured.mdx (pending)
│   ├── filestorage.mdx            (pending)
│   ├── ...
│   └── email.mdx                  (pending)
└── application/
    └── overview.mdx               ✅
```

## Standard Format (per embedded page)

```
---
title: "server-name"
description: "One-line description"
---

**Server path:** `/server-name` | **Type:** Embedded | **PCID required:** No

## Tools
| Tool | Description |
| --- | --- |
| [tool_name](#tool_name) | Brief description |

---

## tool_name

Description.

**Parameters:**
| Parameter | Type | Required | Description |

**Response fields:**
| Field | Type | Description |

<Expandable title="inputSchema">
```json
{ ... }
```
</Expandable>

**Example:** (curl)
**Response:** (JSON)
```

## Completed

### Embedded Servers (4 servers, 37 tools)

| Server | File | Tools |
| --- | --- | --- |
| agent-management | `embedded/agent-management.mdx` | 9 |
| code-execution | `embedded/code-execution.mdx` | 1 |
| browser-automation | `embedded/browser-automation.mdx` | 5 |
| pinkfish-sidekick | `embedded/pinkfish-sidekick.mdx` | 22 |

### Application Servers

| Server | File | Notes |
| --- | --- | --- |
| All (107 servers) | `application/overview.mdx` | Index page with runtime discovery pattern |

## Remaining Embedded Servers (23 servers, ~110 tools)

### Priority 1 — Core data & storage (referenced heavily in guides)

| Server | Path | Tools | Notes |
| --- | --- | --- | --- |
| datastore-structured | `/datastore-structured` | 20 | Tables with schemas. Largest embedded server. |
| datastore-unstructured | `/datastore-unstructured` | 14 | Flexible key-value JSON storage. |
| filestorage | `/filestorage` | 10 | File upload, download, share links. |
| knowledge-base | `/knowledge-base` | 7 | RAG search, semantic Q&A, file upload. |
| vault | `/vault` | 7 | Encrypted secrets storage. |

### Priority 2 — Search, scraping, and web tools

| Server | Path | Tools | Notes |
| --- | --- | --- | --- |
| web-search | `/web-search` | 12 | Google, YouTube, Amazon, shopping, flights, hotels, news, academic, restaurants, events. |
| web-scraping | `/web-scraping` | 4 | Firecrawl-based scrape, crawl, map, RSS. |
| weather | `/weather` | 2 | Current conditions and forecasts. |
| http-utils | `/http-utils` | 1 | Raw HTTP requests to public APIs. |

### Priority 3 — AI model servers

| Server | Path | Tools | Notes |
| --- | --- | --- | --- |
| embedded-anthropic | `/embedded-anthropic` | 1 | Claude models. |
| embedded-openai | `/embedded-openai` | 1 | GPT models. |
| embedded-gemini | `/embedded-gemini` | 1 | Gemini models. |
| embedded-groq | `/embedded-groq` | 1 | Groq models. |
| embedded-perplexity | `/embedded-perplexity` | 1 | Perplexity web research. |

### Priority 4 — Media & document processing

| Server | Path | Tools | Notes |
| --- | --- | --- | --- |
| docprocess | `/docprocess` | 17 | PDF, Word, CSV, OCR, template fill, format conversion. Large server. |
| image-processing | `/image-processing` | 3 | AI generate, edit, background removal. |
| video-processing | `/video-processing` | 3 | VEO generation, poll, audio extraction. |
| audio-processing | `/audio-processing` | 2 | Text-to-speech, transcription. |
| ocr | `/ocr` | 1 | Standalone OCR (also available in docprocess). |

### Priority 5 — Deployment & utilities

| Server | Path | Tools | Notes |
| --- | --- | --- | --- |
| web-application | `/web-application` | 1 | Deploy HTML to shareable URL. |
| charting | `/charting` | 1 | Chart.js to shareable URL. |
| 3d-application | `/3d-application` | 1 | 3D model viewer (GLB/GLTF). |
| email | `/email` | 1 | Send emails with attachments. |

### Excluded

| Server | Path | Tools | Reason |
| --- | --- | --- | --- |
| llm | `/llm` | 3 | **Deprecated.** Replaced by embedded-anthropic, embedded-openai, embedded-gemini. |
| perplexity | `/perplexity` | 3 | **Deprecated.** Replaced by embedded-perplexity. |
| pinkfish-utilities | `/pinkfish-utilities` | 3 | **Internal-only.** Analytics and guardian sessions. Not user-facing. |
| firecrawl | not registered | 5 | **Not registered.** Not in available-servers. Internal use only. |

## Execution Plan

### Phase 1 — Embedded servers (23 pages)
Work through Priority 1–5 above. Each page requires:
1. Read the `tools.ts` file for the server
2. Extract all paramsSchema, outputSchema, descriptions
3. Write the page following the standard format
4. Add link from any platform guide page that references the server

### Phase 2 — Navigation
Once all pages are ready, add "MCP Servers" group to `docs.json` with two sub-groups:
- **Embedded Servers** — all embedded spec pages
- **Application Servers** — the overview/index page

## Total Documentation Scope

| Category | Servers | Tools (approx) | Pages |
| --- | --- | --- | --- |
| Embedded (completed) | 4 | 37 | 4 |
| Embedded (remaining) | 23 | ~110 | 23 |
| Application (index) | 107 | varies | 1 |
| **Total** | **134** | **~147+ embedded** | **28** |

---

## Checklist

### Completed

- [x] agent-management (9 tools)
- [x] code-execution (1 tool)
- [x] browser-automation (5 tools)
- [x] pinkfish-sidekick (22 tools)
- [x] application-servers index page (107 servers)

### Priority 1 — Core data & storage

- [ ] datastore-structured (20 tools)
- [ ] datastore-unstructured (14 tools)
- [ ] filestorage (10 tools)
- [ ] knowledge-base (7 tools)
- [ ] vault (7 tools)

### Priority 2 — Search, scraping, and web

- [ ] web-search (12 tools)
- [ ] web-scraping (4 tools)
- [ ] weather (2 tools)
- [ ] http-utils (1 tool)

### Priority 3 — AI model servers

- [ ] embedded-anthropic (1 tool)
- [ ] embedded-openai (1 tool)
- [ ] embedded-gemini (1 tool)
- [ ] embedded-groq (1 tool)
- [ ] embedded-perplexity (1 tool)

### Priority 4 — Media & document processing

- [ ] docprocess (17 tools)
- [ ] image-processing (3 tools)
- [ ] video-processing (3 tools)
- [ ] audio-processing (2 tools)
- [ ] ocr (1 tool)

### Priority 5 — Deployment & utilities

- [ ] web-application (1 tool)
- [ ] charting (1 tool)
- [ ] 3d-application (1 tool)
- [ ] email (1 tool)

### Other

- [ ] Add "MCP Servers" group to docs.json navigation
