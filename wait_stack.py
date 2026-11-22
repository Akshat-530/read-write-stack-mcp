import socket, time, os
ports = [4040, 4041, 4042, 4043]
for p in ports:
    for _ in range(120):
        try:
            socket.create_connection(('127.0.0.1', p), 2).close(); break
        except Exception:
            time.sleep(2)
os.execvp('node', ['node', '/app/mcp_http_bridge.js', '4034', 'node', '/app/web_stack_mcp.js'])
