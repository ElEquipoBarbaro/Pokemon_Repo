from fastapi import APIRouter, HTTPException, status, Body, Header
from config.database import playerColection, serialize_doc, serialize_list
from config.security import hash_password, verify_password
from datetime import datetime

router = APIRouter(prefix="/player", tags=["Player"])


# 🔐 FUNCIÓN DE AUTENTICACIÓN
def authenticate_user(username: str, password: str):
    player = playerColection.find_one({"usuario.nombre": username})

    if not player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Player no encontrado"
        )

    if not verify_password(password, player["usuario"]["pwd"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Contraseña incorrecta"
        )

    return player


# ✅ CREAR PLAYER (usuario único + hash)
@router.post("/", status_code=status.HTTP_201_CREATED)
def create_player(player: dict = Body(...)):
    username = player.get("usuario", {}).get("nombre")
    password = player.get("usuario", {}).get("pwd")

    if not username or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="usuario.nombre y usuario.pwd son requeridos"
        )

    if playerColection.find_one({"usuario.nombre": username}):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Usuario ya creado"
        )

    # 🔐 Hashear contraseña
    player["usuario"]["pwd"] = hash_password(password)
    player["created_at"] = datetime.utcnow()

    result = playerColection.insert_one(player)
    new_player = playerColection.find_one({"_id": result.inserted_id})

    return serialize_doc(new_player)


# ✅ OBTENER TODOS LOS PLAYERS (NO protegido)
@router.get("/", status_code=status.HTTP_200_OK)
def get_players():
    players = playerColection.find()
    return serialize_list(players)


# ✅ OBTENER PLAYER POR USUARIO.NOMBRE (PROTEGIDO)
@router.get("/by-username/{username}", status_code=status.HTTP_200_OK)
def get_player_by_username(
    username: str,
    x_password: str = Header(..., alias="X-Password")
):
    player = authenticate_user(username, x_password)
    return serialize_doc(player)


# ✅ ACTUALIZAR PLAYER POR USUARIO.NOMBRE (PROTEGIDO)
@router.put("/by-username/{username}", status_code=status.HTTP_200_OK)
def update_player_by_username(
    username: str,
    data: dict = Body(...),
    x_password: str = Header(..., alias="X-Password")
):
    authenticate_user(username, x_password)

    playerColection.update_one(
        {"usuario.nombre": username},
        {"$set": data}
    )

    updated_player = playerColection.find_one(
        {"usuario.nombre": username}
    )

    return serialize_doc(updated_player)


# ✅ ELIMINAR PLAYER POR USUARIO.NOMBRE (PROTEGIDO)
@router.delete(
    "/by-username/{username}",
    status_code=status.HTTP_204_NO_CONTENT
)
def delete_player_by_username(
    username: str,
    x_password: str = Header(..., alias="X-Password")
):
    authenticate_user(username, x_password)

    playerColection.delete_one(
        {"usuario.nombre": username}
    )

    return None
