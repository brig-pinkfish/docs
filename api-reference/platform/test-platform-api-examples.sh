#!/bin/bash
# Test script for Platform API documentation examples (docs/api-reference/platform/)
# Tests against dev20. Swap URLs for production.
# Requires: API_KEY, ORG_ID

# Don't use set -e - run all tests and report
API_URL="${API_URL:-https://app-api.dev20.pinkfish.dev}"
MCP_URL="${MCP_URL:-https://mcp.dev20.pinkfish.dev}"
PINKCONNECT_URL="${PINKCONNECT_URL:-https://proxy-stage.pinkfish.ai}"
API_KEY="${API_KEY:?Set API_KEY}"
ORG_ID="${ORG_ID:?Set ORG_ID}"

echo "=== Getting runtime token (from overview.mdx / authentication.mdx) ==="
PINKFISH_TOKEN=$(curl -s -X POST "${API_URL}/auth/token" \
  -H "X-Api-Key: ${API_KEY}" \
  -H "X-Selected-Org: ${ORG_ID}" \
  -H "Content-Type: application/json" | jq -r '.token')
if [ "$PINKFISH_TOKEN" = "null" ] || [ -z "$PINKFISH_TOKEN" ]; then
  echo "FAIL: Token exchange failed"; exit 1
fi
export PINKFISH_TOKEN
echo "OK"

run_test() {
  local name="$1"
  local result="$2"
  if echo "$result" | jq -e '.error' >/dev/null 2>/dev/null; then
    echo "FAIL: $name - $(echo "$result" | jq -r '.error.message')"
    return 1
  fi
  if echo "$result" | jq -e '.result' >/dev/null 2>/dev/null; then
    echo "OK: $name"
    return 0
  fi
  echo "FAIL: $name - no result"; return 1
}

echo ""
echo "=== 1. overview.mdx - Quick Start: Call web-search (search_googlesearch) ==="
R=$(curl -s -X POST "${MCP_URL}/web-search" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"search_googlesearch","arguments":{"query":"latest AI news"}},"id":1}')
run_test "overview Quick Start web-search" "$R"

echo ""
echo "=== 2. mcp-protocol.mdx - listServers ==="
R=$(curl -s -X POST "${MCP_URL}/mcp" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"listServers","arguments":{}},"id":1}')
run_test "mcp-protocol listServers" "$R"

echo ""
echo "=== 3. mcp-protocol.mdx - tools/list (gmail) ==="
R=$(curl -s -X POST "${MCP_URL}/gmail" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}')
run_test "mcp-protocol tools/list gmail" "$R"

echo ""
echo "=== 4. mcp-protocol.mdx - web-search search_googlesearch ==="
R=$(curl -s -X POST "${MCP_URL}/web-search" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"search_googlesearch","arguments":{"query":"latest AI news"}},"id":1}')
run_test "mcp-protocol web-search" "$R"

echo ""
echo "=== 5. discovery.mdx - capabilities_discover ==="
R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"capabilities_discover","arguments":{"request":"search my gmail for unread emails"}},"id":1}')
run_test "discovery capabilities_discover" "$R"

echo ""
echo "=== 6. discovery.mdx - capability_details ==="
R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"capability_details","arguments":{"items":["gmail_search_emails"]}},"id":1}')
run_test "discovery capability_details" "$R"

echo ""
echo "=== 7. connections.mdx - PinkConnect list user-connections ==="
R=$(curl -s -X GET "${PINKCONNECT_URL}/manage/user-connections" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json")
if echo "$R" | jq -e 'type == "array"' >/dev/null 2>/dev/null; then
  echo "OK: connections PinkConnect user-connections"
else
  echo "CHECK: connections PinkConnect (response: $(echo "$R" | head -c 100))"
fi

echo ""
echo "=== 8. connections.mdx - capabilities_discover (search my gmail) ==="
R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"capabilities_discover","arguments":{"request":"search my gmail"}},"id":1}')
run_test "connections capabilities_discover" "$R"

echo ""
echo "=== 9. code-execution.mdx - code-execution_execute ==="
R=$(curl -s -X POST "${MCP_URL}/restricted/code-execution" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"code-execution_execute","arguments":{"code":"const result = await callTool(\"/web-search\", \"search_googlesearch\", { query: \"Pinkfish AI\" });\nreturn result;"}},"id":1}')
run_test "code-execution" "$R"

echo ""
echo "=== 10. browser-automation.mdx - logins_list ==="
R=$(curl -s -X POST "${MCP_URL}/browser-automation" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"browser-automation_logins_list","arguments":{}},"id":1}')
run_test "browser-automation logins_list" "$R"

echo ""
echo "=== 11. browser-automation.mdx - operator_run (quick task) ==="
R=$(curl -s -X POST "${MCP_URL}/browser-automation" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "browser-automation_operator_run",
      "arguments": {
        "task": "Navigate to https://example.com and extract the page title",
        "cacheKey": "doc8x2k4",
        "model": "google/gemini-3-flash-preview",
        "agentMode": "hybrid",
        "maxSteps": 5,
        "blockAds": true,
        "solveCaptchas": false,
        "recordSession": true
      }
    },
    "id": 1
  }')
TEXT=$(echo "$R" | jq -r '.result.content[0].text // .result.structuredContent // empty')
if [ -n "$TEXT" ]; then
  SESSION_ID=$(echo "$TEXT" | jq -r '.sessionId // empty')
  if [ -n "$SESSION_ID" ]; then
    echo "OK: browser-automation operator_run (sessionId: $SESSION_ID)"
    echo "  Polling for completion..."
    for i in 1 2 3 4 5 6 7 8 9 10; do
      sleep 5
      R2=$(curl -s -X POST "${MCP_URL}/browser-automation" \
        -H "Authorization: Bearer $PINKFISH_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"browser-automation_operator_run_continue\",\"arguments\":{\"sessionId\":\"$SESSION_ID\"}},\"id\":1}")
      STATUS=$(echo "$R2" | jq -r '.result.content[0].text' 2>/dev/null | jq -r '.status // empty' 2>/dev/null)
      [ -z "$STATUS" ] && STATUS=$(echo "$R2" | jq -r '.result.structuredContent.status // empty')
      echo "  Attempt $i: status=$STATUS"
      [ "$STATUS" = "completed" ] || [ "$STATUS" = "failed" ] && break
    done
  else
    echo "FAIL: browser-automation operator_run - no sessionId"
  fi
else
  echo "FAIL: browser-automation operator_run - $(echo "$R" | jq -c '.')"
fi

echo ""
echo "=== 12. browser-automation.mdx - playwright_run (from docs) ==="
R=$(curl -s -X POST "${MCP_URL}/browser-automation" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "browser-automation_playwright_run",
      "arguments": {
        "code": "await page.goto(\"https://news.ycombinator.com\");\nconst stories = await page.$$eval(\".titleline > a\", links => links.slice(0, 10).map((a, i) => ({ rank: i + 1, title: a.textContent, url: a.href })));\nreturn { writeToCollection: true, fileName: \"stories.json\", fileContent: JSON.stringify(stories, null, 2) };",
        "buildId": "doc-playwright-001"
      }
    },
    "id": 1
  }')
TEXT=$(echo "$R" | jq -r '.result.content[0].text // .result.structuredContent // empty')
if [ -n "$TEXT" ]; then
  SESSION_ID=$(echo "$TEXT" | jq -r '.sessionId // empty')
  if [ -n "$SESSION_ID" ]; then
    echo "OK: playwright_run (sessionId: $SESSION_ID)"
    echo "  Polling for completion..."
    for i in 1 2 3 4 5 6 7 8 9 10; do
      sleep 5
      R2=$(curl -s -X POST "${MCP_URL}/browser-automation" \
        -H "Authorization: Bearer $PINKFISH_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"browser-automation_playwright_run_continue\",\"arguments\":{\"sessionId\":\"$SESSION_ID\"}},\"id\":1}")
      STATUS=$(echo "$R2" | jq -r '.result.content[0].text' 2>/dev/null | jq -r '.status // empty' 2>/dev/null)
      [ -z "$STATUS" ] && STATUS=$(echo "$R2" | jq -r '.result.structuredContent.status // empty')
      echo "  Attempt $i: status=$STATUS"
      [ "$STATUS" = "completed" ] || [ "$STATUS" = "failed" ] && break
    done
  else
    echo "FAIL: playwright_run - no sessionId"
  fi
else
  echo "FAIL: playwright_run - $(echo "$R" | jq -c '.')"
fi

echo ""
echo "=== 13. workflows.mdx - Full lifecycle: create, update, run, results ==="
echo "  Step 1: workflow_create"
R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"workflow_create","arguments":{"name":"Doc Test Workflow","description":"Test from platform API docs"}},"id":1}')
AUTO_ID=$(echo "$R" | jq -r '.result.content[0].text' 2>/dev/null | jq -r '.id // empty' 2>/dev/null)
[ -z "$AUTO_ID" ] && AUTO_ID=$(echo "$R" | jq -r '.result.structuredContent.id // empty')
if [ -z "$AUTO_ID" ]; then
  echo "FAIL: workflow_create - $(echo "$R" | jq -c '.')"
else
  echo "  OK: workflow_create (automationId: $AUTO_ID)"
  echo "  Step 2: workflow_update (with full workflow code from docs)"
  WORKFLOW_CODE='//---REQUIRED HEADER - DO NOT MODIFY---
import { pf } from "./pf-bootstrap.mjs";
//---END REQUIRED HEADER---

const WORKFLOW_RESOURCES = {};

const WORKFLOW_NODES = [
  { id: "trigger_1", name: "Start", type: "trigger", triggerType: "manual" },
  { id: "node_search_news", name: "Search News", type: "mcp-tool", serverName: "web-search", toolName: "search_googlesearch", parameters: { query: "latest AI news 2026" }, inputSchema: { query: { type: "string", source: "literal", value: "latest AI news 2026" } } },
  { id: "node_summarize", name: "Summarize Results", type: "mcp-tool", serverName: "embedded-groq", toolName: "embedded-groq_generate", parameters: { prompt: "@node_search_news", systemPrompt: "Summarize these search results into 5 bullet points." }, inputSchema: { prompt: { type: "string", source: "node", value: "@node_search_news" }, systemPrompt: { type: "string", source: "literal", value: "Summarize these search results into 5 bullet points." } } }
];

const WORKFLOW_EDGES = [
  { source: "trigger_1", target: "node_search_news" },
  { source: "node_search_news", target: "node_summarize" }
];

async function node_search_news(params) {
  pf.log.info("Searching for AI news...");
  const result = await pf.mcp.callTool("web-search", "search_googlesearch", { query: params.query });
  await pf.files.writeFile("node_search_news_output.json", result);
  pf.log.success("Search complete");
  return result;
}

async function node_summarize(params) {
  pf.log.info("Summarizing results...");
  const result = await pf.mcp.callTool("embedded-groq", "embedded-groq_generate", { prompt: JSON.stringify(params.prompt), systemPrompt: params.systemPrompt });
  await pf.files.writeFile("node_summarize_output.json", result);
  pf.log.success("Summary generated");
  return result;
}

global.node_search_news = node_search_news;
global.node_summarize = node_summarize;

//---REQUIRED FOOTER - DO NOT MODIFY---
await pf.run(WORKFLOW_NODES, WORKFLOW_EDGES);
//---END REQUIRED FOOTER---'
  R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
    -H "Authorization: Bearer $PINKFISH_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"workflow_update\",\"arguments\":{\"automationId\":\"$AUTO_ID\",\"name\":\"Doc Test Workflow\",\"changeDescription\":\"Add search and summarize nodes\",\"code\":$(echo "$WORKFLOW_CODE" | jq -Rs .)}},\"id\":1}")
  if echo "$R" | jq -e '.error' >/dev/null 2>/dev/null; then
    echo "  FAIL: workflow_update - $(echo "$R" | jq -r '.error.message')"
  else
    echo "  OK: workflow_update"
    echo "  Step 3: workflow_run"
    R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
      -H "Authorization: Bearer $PINKFISH_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"workflow_run\",\"arguments\":{\"automationId\":\"$AUTO_ID\"}},\"id\":1}")
    RUN_ID=$(echo "$R" | jq -r '.result.content[0].text' 2>/dev/null | jq -r '.runId // .id // empty' 2>/dev/null)
    [ -z "$RUN_ID" ] && RUN_ID=$(echo "$R" | jq -r '.result.structuredContent.runId // .result.structuredContent.id // empty')
    if echo "$R" | jq -e '.error' >/dev/null 2>/dev/null; then
      echo "  FAIL: workflow_run - $(echo "$R" | jq -r '.error.message')"
    else
      echo "  OK: workflow_run (runId: ${RUN_ID:-success})"
      echo "  Step 4: workflow_results (verify output)"
      sleep 10
      R=$(curl -s -X POST "${MCP_URL}/pinkfish-sidekick" \
        -H "Authorization: Bearer $PINKFISH_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"workflow_results\",\"arguments\":{\"automationId\":\"$AUTO_ID\",\"operation\":\"read\",\"filename\":\"node_summarize_output.json\"}},\"id\":1}")
      if echo "$R" | jq -e '.error' >/dev/null 2>/dev/null; then
        echo "  CHECK: workflow_results - $(echo "$R" | jq -r '.error.message') (file may have different name)"
      elif echo "$R" | jq -e '.result' >/dev/null 2>/dev/null; then
        echo "  OK: workflow_results - run produced output"
      else
        echo "  CHECK: workflow_results - $(echo "$R" | jq -c '.')"
      fi
    fi
  fi
fi

echo ""
echo "=== 14. mcp-protocol.mdx / connections.mdx - gmail_search_emails (real PCID) ==="
GMAIL_PCID=$(curl -s -X GET "${PINKCONNECT_URL}/manage/user-connections?statuses=connected" \
  -H "Authorization: Bearer $PINKFISH_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.[] | select(.service_key == "gmail") | .id' | head -1)
if [ -n "$GMAIL_PCID" ] && [ "$GMAIL_PCID" != "null" ]; then
  R=$(curl -s -X POST "${MCP_URL}/gmail" \
    -H "Authorization: Bearer $PINKFISH_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"gmail_search_emails\",\"arguments\":{\"PCID\":\"$GMAIL_PCID\",\"query\":\"is:unread\"}},\"id\":1}")
  run_test "gmail_search_emails" "$R"
else
  echo "SKIP: gmail_search_emails - no Gmail connection found (connect Gmail in Integrations to test)"
fi

echo ""
echo "=== Done: Platform API docs examples tested ==="
