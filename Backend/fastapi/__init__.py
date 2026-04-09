import uvicorn
from Backend.config import Telegram
from Backend.fastapi.main import app

Port = Telegram.PORT
config = uvicorn.Config(
    app=app, 
    host='0.0.0.0', 
    port=Port,
    ssl_keyfile="/app/ts.key",
    ssl_certfile="/app/ts.crt"
)
server = uvicorn.Server(config)
