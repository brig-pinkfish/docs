#!/usr/bin/env npx tsx
/**
 * Count MCP tools exposed by the Pinkfish MCP Farm.
 *
 * Usage (run from platform/servers/agentic/mcp/ for TypeScript path resolution):
 *   cd ../platform/servers/agentic/mcp
 *   npx tsx /path/to/docs/scripts/count-mcp-tools.ts
 */

import * as fs from 'node:fs'
import * as path from 'node:path'
import { fileURLToPath } from 'node:url'

import { AVAILABLE_SERVERS } from '@servers/available-servers.js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const DOCS_ROOT = path.resolve(__dirname, '..')
const PLATFORM_ROOT = path.resolve(DOCS_ROOT, '../platform')
const MCP_SERVER_DEFINITIONS_DIR = path.join(
  PLATFORM_ROOT,
  'mcp-server-definitions'
)

type ClassicBreakdown = {
  embeddedServerCount: number
  embeddedToolCount: number
  externalServerCount: number
  externalToolCount: number
}

const walkDynamicToolFiles = (dir: string): string[] => {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name)

    if (entry.isDirectory()) {
      return walkDynamicToolFiles(fullPath)
    }

    if (
      entry.isFile() &&
      fullPath.includes(`${path.sep}tools${path.sep}`) &&
      fullPath.endsWith('.ts')
    ) {
      return [fullPath]
    }

    return []
  })
}

const getClassicBreakdown = (): ClassicBreakdown => {
  return AVAILABLE_SERVERS.reduce<ClassicBreakdown>(
    (acc, server) => {
      const toolCount = server.tools?.length ?? 0

      if (server.embedded) {
        acc.embeddedServerCount += 1
        acc.embeddedToolCount += toolCount
        return acc
      }

      acc.externalServerCount += 1
      acc.externalToolCount += toolCount
      return acc
    },
    {
      embeddedServerCount: 0,
      embeddedToolCount: 0,
      externalServerCount: 0,
      externalToolCount: 0
    }
  )
}

const classic = getClassicBreakdown()
const dynamicToolCount = walkDynamicToolFiles(MCP_SERVER_DEFINITIONS_DIR).length
const classicToolCount = classic.embeddedToolCount + classic.externalToolCount
const totalToolCount = classicToolCount + dynamicToolCount

const formatNumber = (value: number) => value.toLocaleString('en-US')

console.log('Pinkfish MCP Farm tool count')
console.log(`- Embedded servers: ${classic.embeddedServerCount}`)
console.log(`- Embedded tools: ${formatNumber(classic.embeddedToolCount)}`)
console.log(`- External servers: ${classic.externalServerCount}`)
console.log(`- External tools: ${formatNumber(classic.externalToolCount)}`)
console.log(`- Dynamic tools: ${formatNumber(dynamicToolCount)}`)
console.log(`- Total tools: ${formatNumber(totalToolCount)}`)
