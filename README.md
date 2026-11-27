# Kleido Print

Design business cards and loyalty stamp cards from Claude, ChatGPT, Codex, Cursor, and other AI agents, then get them printed and shipped to you. You approve the design and pay on a Stripe checkout page.

This repository is the Kleido plugin. It contains the connection to Kleido's hosted MCP server and a skill that teaches the agent how to use it. The server itself runs at `https://www.kleidoprint.com/mcp` and isn't part of this repository.

## What's included

- **Kleido connector** (`https://www.kleidoprint.com/mcp`): tools to read print options and prices, start a design with Kleido's designer, edit your saved cards, create a print order, and check order status. You sign in with your Kleido account over OAuth; there are no API keys.
- **`business-cards` skill**: tells the agent how to use those tools in order. It asks whether you want Kleido's designer (1 credit per design) or a free design the agent writes itself, shows you a proof, and confirms the quantity, finish, and address before it creates a checkout link.

## Install

**Claude Code**

```sh
claude plugin install kleido-print --marketplace kleidoprint/kleido-plugin
```

Then run `/mcp`, choose `plugin:kleido-print:kleido`, and sign in.

**Antigravity**

```sh
agy plugin install https://github.com/kleidoprint/kleido-plugin
```

Use the full URL; `agy` doesn't accept `kleidoprint/kleido-plugin`. Then open `/plugin`, expand kleido-print under Installed, and choose Sign in. Sign in there before you use one-shot `agy -p` runs, which can't open the sign-in page.

**Claude (claude.ai, desktop, Cowork), ChatGPT, Codex, and Cursor**: install Kleido Print from the app's plugin directory once it's listed there. Until then, add the server by URL with OAuth; [kleidoprint.com/agents](https://www.kleidoprint.com/agents) has steps for each app.

**Any MCP client**: connect to `https://www.kleidoprint.com/mcp` (Streamable HTTP, OAuth).

If you already added the Kleido server by hand, remove that copy so the agent doesn't see the same tools twice.

## Try it

- "Design business cards for my bakery, ryeandco.com."
- "Change the title on my card to Head Baker." (paste your kleidoprint.com/c/ link)
- "What's the status of my latest Kleido order?"

## Payment

The agent never pays for you. `create_print_order` returns a Stripe checkout link that expires in 24 hours, and printing starts only after you pay on that page. US shipping is free; international shipping to supported countries is quoted at checkout. Kleido credits are spent only when you choose Kleido's designer, and they aren't sold through AI assistants.

## Data

The plugin sends Kleido what you ask it to print: card details such as names, titles, and contact information, the website you want a design based on, card HTML, and your shipping address. Kleido links them to your Kleido account through OAuth sign-in. The plugin has no other servers, scripts, or hooks, and it stores nothing on your computer. See Kleido's [privacy policy](https://www.kleidoprint.com/privacy) and [terms](https://www.kleidoprint.com/terms).

## Repository layout

One folder serves every client:

| File                                                | Used by                                                               |
| --------------------------------------------------- | --------------------------------------------------------------------- |
| `plugin.json`, `mcp.json`                           | [Agent Plugins](https://agent-plugins.org) clients and OpenAI (ChatGPT, Codex) |
| `.claude-plugin/plugin.json`, `.mcp.json`           | Claude (claude.ai, Cowork, Claude Code)                               |
| `.claude-plugin/marketplace.json`                   | Claude Code installs from this repository                             |
| `.cursor-plugin/plugin.json`                        | Cursor                                                                |
| `mcp_config.json`                                   | Antigravity, which doesn't read `mcp.json` yet                        |
| `server.json`                                       | The [MCP Registry](https://registry.modelcontextprotocol.io)          |
| `skills/business-cards/`                            | Every client (the [Agent Skills](https://agentskills.io) format)      |

Keep `version` the same in `plugin.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `server.json`, and raise it with every release. The `Check` workflow (`.github/workflows/check.yml`) checks this and validates the manifests on every push and pull request. It isn't a script in the repository because Claude's plugin directory only accepts scripts from Verified organizations. Pushing a matching tag such as `v1.0.0` publishes `server.json` to the MCP Registry as `io.github.kleidoprint/kleido`.

## Support

Setup help: [kleidoprint.com/agents](https://www.kleidoprint.com/agents). Questions: hello@kleidoprint.com. Bugs in the plugin: open an issue here.

## License

[MIT](LICENSE)
