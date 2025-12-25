from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config.database import client

from routes import player

# Crear aplicación FastAPI
app = FastAPI(
    title="Farmacia API",
    description="Sistema de gestión para guardado PK con MongoDB",
    version="1.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios permitidos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(player.router)

# Rutas principales
@app.get("/")
def root():
    """Ruta raíz"""
    return {
        "message": "PK  API - Sistema de Guardado",
        "version": "1.0.0",
        "endpoints": {
            "docs": "/docs",
        }
    }

@app.get("/health")
def health_check():
    """Verificar estado de la API y la base de datos"""
    try:
        # Ping a MongoDB
        client.admin.command('ping')
        return {
            "status": "healthy",
            "database": "connected",
            "message": "API funcionando correctamente"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }

@app.on_event("startup")
async def startup_event():
    print("🚀 Iniciando Farmacia API...")
    print("📊 Conectando a MongoDB...")
    try:
        client.admin.command('ping')
        print("✅ Conexión exitosa a MongoDB")
    except Exception as e:
        print(f"❌ Error al conectar a MongoDB: {e}")
        
        
@app.on_event("shutdown")
async def shutdown_event():
    print("👋 Cerrando Farmacia API...")
    client.close()
    print("✅ Conexión a MongoDB cerrada")