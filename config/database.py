import os
from pymongo import MongoClient
from bson import ObjectId


# Variables de entorno
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb+srv://mathiuz2:jayGA2q5qdEKX8i@cluster0.bi4re.mongodb.net/")
DATABASE_NAME = os.getenv("DATABASE_NAME", "pkr")


# Cliente MongoDB
client = MongoClient(MONGODB_URL)
db = client[DATABASE_NAME]

playerColection = db.player

def serialize_doc(doc):
    """Convierte ObjectId a string para JSON"""
    if doc is None:
        return None
    if "_id" in doc and isinstance(doc["_id"], ObjectId):
        doc["_id"] = str(doc["_id"])
    return doc

def serialize_list(docs):
    """Serializa lista de documentos"""
    return [serialize_doc(doc) for doc in docs]


