# ==========================================
# gestor_roles.py
# Script para gestionar la tabla 'roles'.
# ==========================================

import mysql.connector
# Importa las funciones de conexión y ayuda desde el archivo db_config.py
from db_config import conectar, obtener_id

# =======================================================
# FUNCIONES PARA 'roles'
# =======================================================

def sp_insertar_rol(nombre: str, descripcion: str):
    """Llama a SP_INSERT_ROL(p_nombre_rol, p_descripcion)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_INSERT_ROL", [nombre, descripcion])
        cnx.commit()
        print(f"✅ Rol '{nombre}' insertado correctamente.")
        
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_rol: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_rol(id_rol: int):
    """Llama a SP_DELETE_LOGIC_ROL(p_id_rol)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_DELETE_LOGIC_ROL", [id_rol])
        cnx.commit()
        
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado al Rol ID {id_rol}.")
        else:
            print(f"⚠️ No se encontró el Rol ID {id_rol} (o ya estaba eliminado).")
            
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_rol: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_roles_activos():
    """Llama a SP_SELECT_ACTIVOS_ROLES()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ACTIVOS_ROLES")
        print("\n--- ROLES ACTIVOS ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron roles activos.")
                continue
                
            for (id_r, nombre, desc, creado) in rows:
                print(f"ID:{id_r:<3} | Nombre:{nombre:<20} | Desc:{desc:<30} | Creado:{creado}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_roles_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_roles_todos():
    """Llama a SP_SELECT_ALL_ROLES()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ALL_ROLES")
        print("\n--- TODOS LOS ROLES (INCLUYE ELIMINADOS) ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron roles.")
                continue

            for row in rows:
                estado = "ELIMINADO" if row[5] == 1 else "ACTIVO"
                print(f"ID:{row[0]:<3} | Nombre:{row[1]:<20} | Estado:{estado:<10} | Creado:{row[3]} | Actualizado:{row[4]}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_roles_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# =======================================================
# MENÚ PRINCIPAL DE ROLES
# =======================================================
def menu_roles():
    while True:
        print("\n===== GESTIÓN DE ROLES =====")
        print("1) Insertar Rol")
        print("2) Listar Roles Activos")
        print("3) Listar Todos los Roles")
        print("4) Eliminar Rol (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            nombre = input("Nombre del Rol: ").strip()
            desc = input("Descripción: ").strip()
            if nombre:
                sp_insertar_rol(nombre, desc)
            else:
                print("❌ El nombre es obligatorio.")
        elif opc == '2':
            sp_listar_roles_activos()
        elif opc == '3':
            sp_listar_roles_todos()
        elif opc == '4':
            id_rol = obtener_id("ID del Rol a eliminar: ")
            if id_rol:
                sp_eliminar_rol(id_rol)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Roles...")
            break
        else:
            print("❌ Opción no válida.")

# Punto de entrada del script
if __name__ == "__main__":
    menu_roles()