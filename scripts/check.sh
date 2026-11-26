#!/bin/sh
# Validates every manifest in this plugin. Run from the repository root.
# Needs: python3, uvx (https://docs.astral.sh/uv/), and npx (Node.js).
set -eu

CLAUDE_CODE_VERSION=2.1.332
CHECK_JSONSCHEMA_VERSION=0.39.0
AGENT_PLUGINS_SCHEMAS=https://agent-plugins.org/schemas/1.0.0
MCP_REGISTRY_SCHEMA=https://static.modelcontextprotocol.io/schemas/2025-12-11/server.schema.json

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

jsonschema() {
  uvx "check-jsonschema==$CHECK_JSONSCHEMA_VERSION" "$@"
}

echo "== versions and names match"
python3 - <<'PY'
import json, sys

files = ["plugin.json", ".claude-plugin/plugin.json", ".cursor-plugin/plugin.json", "server.json"]
versions = {f: json.load(open(f))["version"] for f in files}
names = {f: json.load(open(f))["name"] for f in files[:3]}
problems = []
if len(set(versions.values())) != 1:
    problems.append(f"versions differ: {versions}")
if len(set(names.values())) != 1:
    problems.append(f"plugin names differ: {names}")
market = json.load(open(".claude-plugin/marketplace.json"))
if market["plugins"][0]["name"] != names["plugin.json"]:
    problems.append("marketplace entry name differs from the plugin name")
urls = {
    "mcp.json": [s["url"] for s in json.load(open("mcp.json"))["mcpServers"].values()],
    ".mcp.json": [s["url"] for s in json.load(open(".mcp.json"))["mcpServers"].values()],
    "server.json": [r["url"] for r in json.load(open("server.json"))["remotes"]],
}
if len({tuple(u) for u in urls.values()}) != 1:
    problems.append(f"MCP server URLs differ: {urls}")
if problems:
    sys.exit("\n".join(problems))
print(f"ok: {names['plugin.json']} {versions['plugin.json']}")
PY

echo "== Agent Plugins manifest"
jsonschema --schemafile "$AGENT_PLUGINS_SCHEMAS/plugin.schema.json" plugin.json

# OpenAI documents its OAuth settings as an `extensions` object on each server
# entry, which the Agent Plugins 1.0.0 schema doesn't allow yet. Check
# everything else against the schema.
echo "== Agent Plugins MCP config (without the com.openai server extension)"
python3 - "$tmp/mcp.json" <<'PY'
import json, sys
config = json.load(open("mcp.json"))
for server in config["mcpServers"].values():
    server.pop("extensions", None)
json.dump(config, open(sys.argv[1], "w"))
PY
jsonschema --schemafile "$AGENT_PLUGINS_SCHEMAS/mcp.schema.json" "$tmp/mcp.json"

echo "== MCP Registry server.json"
jsonschema --schemafile "$MCP_REGISTRY_SCHEMA" server.json

echo "== Agent Skills frontmatter"
python3 - <<'PY'
import pathlib, re, sys
problems = []
for skill in sorted(pathlib.Path("skills").glob("*/SKILL.md")):
    text = skill.read_text()
    match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not match:
        problems.append(f"{skill}: no frontmatter")
        continue
    fields = dict(line.split(": ", 1) for line in match.group(1).splitlines() if ": " in line)
    if fields.get("name") != skill.parent.name:
        problems.append(f"{skill}: name must be {skill.parent.name!r}")
    if not 1 <= len(fields.get("description", "")) <= 1024:
        problems.append(f"{skill}: description must be 1-1024 characters")
if problems:
    sys.exit("\n".join(problems))
print("ok")
PY

echo "== Claude plugin and marketplace"
npx --yes "@anthropic-ai/claude-code@$CLAUDE_CODE_VERSION" plugin validate --strict .

echo "All checks passed."
