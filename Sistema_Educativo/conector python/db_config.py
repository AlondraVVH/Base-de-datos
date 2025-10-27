# ==========================================
# db_config.py
#
# Archivo de configuración central.
# Contiene los datos de conexión y la función
# para conectarse a la BD 'sistemaeducativo'.
# ==========================================

import mysql.connector
from mysql.connector import errorcode

# ---------- CONFIGURACIÓN DE CONEXIÓN ----------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "sistemaeducativo"
}

# ---------- FUNCIÓN DE CONEXIÓN ----------
def conectar():
    """
    Crea y devuelve una conexión a MySQL usando DB_CONFIG.
    Maneja errores comunes de conexión.
    """
    try:
        cnx = mysql.connector.connect(**DB_CONFIG)
        return cnx
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("❌ Error: Usuario o contraseña incorrectos.")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print(f"❌ Error: La base de datos '{DB_CONFIG['database']}' no existe.")
        else:
            print(f"❌ Error de conexión: {err}")
        return None

# ---------- FUNCIÓN AUXILIAR ----------
def obtener_id(mensaje="ID: "):
    """
    Solicita un ID numérico al usuario y maneja errores.
    """
    try:
        id_val = int(input(mensaje).strip())
        if id_val <= 0:
            print("❌ ID inválido. Debe ser un número positivo.")
            return None
        return id_val
    except ValueError:
        print("❌ ID inválido. Debe ser un número.")
        return None