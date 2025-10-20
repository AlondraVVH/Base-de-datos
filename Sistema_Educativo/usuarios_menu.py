# usuarios_menu.py
import mysql.connector

# ==========================================
# 🚨 MODIFICAR ESTA SECCIÓN CON TUS CREDENCIALES REALES
# ==========================================
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234", 
    "database": "sistemaeducativo" 
}
# ==========================================

def conectar():
    """Crea y devuelve una conexión a MySQL."""
    return mysql.connector.connect(**DB_CONFIG)

# ----------------- FUNCIONES DE OPERACIÓN -----------------

def sp_insertar_usuario(nombre_usuario: str, rut: str, nombre_completo: str, 
                        correo: str, contrasena_hash: str, id_rol: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [nombre_usuario, rut, nombre_completo, correo, contrasena_hash, id_rol]
        # Llama a SP_INSERT_USUARIO(...)
        cur.callproc("SP_INSERT_USUARIO", args) 
        cnx.commit()
        print(f"✅ Usuario '{nombre_usuario}' insertado correctamente (ID Rol: {id_rol}).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar_usuario:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico_usuario(id_usuario: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_DELETE_LOGIC_USUARIO(IN p_id_usuario)
        cur.callproc("SP_DELETE_LOGIC_USUARIO", [id_usuario])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al Usuario ID {id_usuario}.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico_usuario:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_usuarios_activos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ACTIVOS_USUARIOS()
        cur.callproc("SP_SELECT_ACTIVOS_USUARIOS")
        print("\n=== USUARIOS ACTIVOS ===")
        for result in cur.stored_results():
            # Columnas: id_usuario, nombre_usuario, nombre_completo, correo_electronico, id_rol
            print("-" * 110)
            print(f"| {'ID':<3} | {'Usuario':<15} | {'Nombre Completo':<30} | {'Correo':<30} | {'ID Rol':<6} |")
            print("-" * 110)
            for (id_, usuario, nombre_c, correo, id_rol) in result.fetchall():
                print(
                    f"| {id_:<3} | {usuario:<15} | {nombre_c:<30} | {correo:<30} | {id_rol:<6} |"
                )
            print("-" * 110)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_usuarios_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_usuarios_todos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ALL_USUARIOS()
        cur.callproc("SP_SELECT_ALL_USUARIOS")
        print("\n=== USUARIOS (TODOS) ===")
        for result in cur.stored_results():
            # Columnas: id_usuario, nombre_usuario, rut, nombre_completo, correo_electronico, hash_contrasena, id_rol, created_at, updated_at, deleted
            print("-" * 150)
            print(f"| {'ID':<3} | {'Usuario':<15} | {'Nombre':<20} | {'Correo':<30} | {'ID Rol':<6} | {'Estado':<9} | {'Actualizado':<19} |")
            print("-" * 150)
            for (id_, usuario, rut, nombre_c, correo, hash_c, id_rol, created_at, updated_at, deleted) in result.fetchall():
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = str(updated_at) if updated_at is not None else "-"
                print(
                    f"| {id_:<3} | {usuario:<15} | {nombre_c:<20} | {correo:<30} | "
                    f"{id_rol:<6} | {estado:<9} | {ua:<19} |"
                )
            print("-" * 150)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_usuarios_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()


# ----------------- MENÚ PRINCIPAL -----------------

def menu_usuarios():
    while True:
        print("\n===== MENÚ USUARIOS (MySQL + SP) =====")
        print("1) Insertar Usuario")
        print("2) Listar Usuarios ACTIVOS")
        print("3) Listar Usuarios (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            usuario = input("Nombre de usuario (único): ").strip()
            rut = input("RUT: ").strip()
            nombre = input("Nombre Completo: ").strip()
            correo = input("Correo Electrónico (único): ").strip()
            contrasena_hash = "PLACEHOLDER_HASH" # Usar un hash real en producción
            try:
                id_rol = int(input("ID de Rol (debe existir): ").strip())
                if usuario and rut and nombre and correo:
                    sp_insertar_usuario(usuario, rut, nombre, correo, contrasena_hash, id_rol)
                else:
                    print("❌ Campos principales no pueden estar vacíos.")
            except ValueError:
                print("❌ ID de Rol o valor inválido.")

        elif opcion == "2":
            sp_listar_usuarios_activos()

        elif opcion == "3":
            sp_listar_usuarios_todos()

        elif opcion == "4":
            try:
                id_user = int(input("ID de Usuario a eliminar lógicamente: ").strip())
                sp_borrado_logico_usuario(id_user)
            except ValueError:
                print("❌ ID inválido.")

        elif opcion == "0":
            print("👋 Saliendo del menú de Usuarios...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu_usuarios()