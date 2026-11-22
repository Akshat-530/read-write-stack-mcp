# The shell-mcp-server 0.1.0 console script calls an async main() without
# awaiting it (upstream bug). This launcher awaits it properly.
import asyncio
from shell_mcp_server.server import main

asyncio.run(main())
