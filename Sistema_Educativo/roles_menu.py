# roles_menu.py
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

def sp_insertar_rol(nombre: str, descripcion: str):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_INSERT_ROL(IN p_nombre_rol, IN p_descripcion)
        cur.callproc("SP_INSERT_ROL", [nombre, descripcion]) 
        cnx.commit()
        print(f"✅ Rol '{nombre}' insertado correctamente.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar_rol:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico_rol(id_rol: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_DELETE_LOGIC_ROL(IN p_id_rol)
        cur.callproc("SP_DELETE_LOGIC_ROL", [id_rol])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al Rol ID {id_rol}.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico_rol:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_roles_activos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ACTIVOS_ROLES()
        cur.callproc("SP_SELECT_ACTIVOS_ROLES")
        print("\n=== ROLES ACTIVOS ===")
        # Se recuperan los resultados devueltos por el SELECT dentro del SP
        for result in cur.stored_results():
            # Columnas: id_rol, nombre_rol, descripcion, created_at
            print("-" * 70)
            print(f"| {'ID':<3} | {'Nombre':<15} | {'Descripción':<30} | {'Creado':<19} |")
            print("-" * 70)
            for (id_, nombre, descripcion, created_at) in result.fetchall():
                print(f"| {id_:<3} | {nombre:<15} | {descripcion[:30]:<30} | {str(created_at):<19} |")
            print("-" * 70)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_roles_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_roles_todos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ALL_ROLES()
        cur.callproc("SP_SELECT_ALL_ROLES")
        print("\n=== ROLES (TODOS) ===")
        for result in cur.stored_results():
            # Columnas: id_rol, nombre_rol, descripcion, created_at, updated_at, deleted
            print("-" * 120)
            print(f"| {'ID':<3} | {'Nombre':<15} | {'Estado':<9} | {'Descripción':<30} | {'Creado':<19} | {'Actualizado':<19} |")
            print("-" * 120)
            for (id_, nombre, descripcion, created_at, updated_at, deleted) in result.fetchall():
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = str(updated_at) if updated_at is not None else "-"
                print(
                    f"| {id_:<3} | {nombre:<15} | {estado:<9} | {descripcion[:30]:<30} | "
                    f"{str(created_at):<19} | {ua:<19} |"
                )
            print("-" * 120)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_roles_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()


# ----------------- MENÚ PRINCIPAL -----------------

def menu_roles():
    while True:
        print("\n===== MENÚ ROLES (MySQL + SP) =====")
        print("1) Insertar Rol")
        print("2) Listar Roles ACTIVOS")
        print("3) Listar Roles (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre del Rol: ").strip()
            descripcion = input("Descripción: ").strip()
            if nombre and descripcion:
                sp_insertar_rol(nombre, descripcion)
            else:
                print("❌ Nombre y descripción no pueden estar vacíos.")
        
        elif opcion == "2":
            sp_listar_roles_activos()

        elif opcion == "3":
            sp_listar_roles_todos()

        elif opcion == "4":
            try:
                id_rol = int(input("ID de Rol a eliminar lógicamente: ").strip())
                sp_borrado_logico_rol(id_rol)
            except ValueError:
                print("❌ ID inválido.")

        elif opcion == "0":
            print("👋 Saliendo del menú de Roles...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu_roles()