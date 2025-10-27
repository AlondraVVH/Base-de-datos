# ==========================================
# gestor_usuarios.py
# Script para gestionar la tabla 'usuarios'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# =======================================================
# FUNCIONES PARA 'usuarios'
# =======================================================

def sp_insertar_usuario(nombre_usuario, rut, nombre_completo, correo, hash_pass, id_rol):
    """Llama a SP_INSERT_USUARIO(...) con 6 parámetros"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        args = [nombre_usuario, rut, nombre_completo, correo, hash_pass, id_rol]
        cur.callproc("SP_INSERT_USUARIO", args)
        cnx.commit()
        print(f"✅ Usuario '{nombre_completo}' insertado correctamente.")
        
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_usuario: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_usuario(id_usuario: int):
    """Llama a SP_DELETE_LOGIC_USUARIO(p_id_usuario)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_DELETE_LOGIC_USUARIO", [id_usuario])
        cnx.commit()
        
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado al Usuario ID {id_usuario}.")
        else:
            print(f"⚠️ No se encontró el Usuario ID {id_usuario} (o ya estaba eliminado).")
            
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_usuario: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_usuarios_activos():
    """Llama a SP_SELECT_ACTIVOS_USUARIOS()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ACTIVOS_USUARIOS")
        print("\n--- USUARIOS ACTIVOS ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron usuarios activos.")
                continue

            for (id_u, user, nombre, correo, id_r) in rows:
                print(f"ID:{id_u:<3} | Usuario:{user:<15} | Nombre:{nombre:<25} | Correo:{correo:<25} | ID_Rol:{id_r}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_usuarios_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_usuarios_todos():
    """Llama a SP_SELECT_ALL_USUARIOS()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ALL_USUARIOS")
        print("\n--- TODOS LOS USUARIOS (INCLUYE ELIMINADOS) ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron usuarios.")
                continue
                
            for row in rows:
                estado = "ELIMINADO" if row[13] == 1 else "ACTIVO"
                print(f"ID:{row[0]:<3} | Usuario:{row[1]:<15} | Nombre:{row[3]:<25} | Estado:{estado:<10} | ID_Rol:{row[6]}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_usuarios_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# =======================================================
# MENÚ PRINCIPAL DE USUARIOS
# =======================================================
def menu_usuarios():
    while True:
        print("\n===== GESTIÓN DE USUARIOS =====")
        print("1) Insertar Usuario")
        print("2) Listar Usuarios Activos")
        print("3) Listar Todos los Usuarios")
        print("4) Eliminar Usuario (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            print("--- Nuevo Usuario ---")
            nombre_usuario = input("Nombre de usuario (login): ").strip()
            rut = input("RUT (ej: 12345678-9): ").strip()
            nombre_completo = input("Nombre Completo: ").strip()
            correo = input("Correo: ").strip()
            hash_pass = input("Contraseña (se guardará como texto plano): ").strip()
            id_rol = obtener_id("ID del Rol (1=Admin, 2=Profesor, 3=Estudiante): ")
            
            if not (nombre_usuario and rut and nombre_completo and correo and hash_pass and id_rol):
                print("❌ Todos los campos son obligatorios.")
                continue
            sp_insertar_usuario(nombre_usuario, rut, nombre_completo, correo, hash_pass, id_rol)
            
        elif opc == '2':
            sp_listar_usuarios_activos()
        elif opc == '3':
            sp_listar_usuarios_todos()
        elif opc == '4':
            id_user = obtener_id("ID del Usuario a eliminar: ")
            if id_user:
                sp_eliminar_usuario(id_user)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Usuarios...")
            break
        else:
            print("❌ Opción no válida.")

# Punto de entrada del script
if __name__ == "__main__":
    menu_usuarios()