# instituciones_menu.py
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

def sp_insertar_institucion(nombre: str, direccion: str, telefono: str):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_INSERT_INSTITUCION(IN p_nombre, IN p_direccion, IN p_telefono)
        cur.callproc("SP_INSERT_INSTITUCION", [nombre, direccion, telefono]) 
        cnx.commit()
        print(f"✅ Institución '{nombre}' insertada correctamente.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar_institucion:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico_institucion(id_institucion: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_DELETE_LOGIC_INSTITUCION(IN p_id_institucion)
        cur.callproc("SP_DELETE_LOGIC_INSTITUCION", [id_institucion])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado a la Institución ID {id_institucion}.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico_institucion:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_instituciones_activos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ACTIVOS_INSTITUCIONES()
        cur.callproc("SP_SELECT_ACTIVOS_INSTITUCIONES")
        print("\n=== INSTITUCIONES ACTIVAS ===")
        for result in cur.stored_results():
            # Columnas: id_institucion, nombre, direccion, telefono
            print("-" * 100)
            print(f"| {'ID':<3} | {'Nombre':<30} | {'Dirección':<30} | {'Teléfono':<15} |")
            print("-" * 100)
            for (id_, nombre, direccion, telefono) in result.fetchall():
                print(
                    f"| {id_:<3} | {nombre:<30} | {direccion[:30]:<30} | {telefono:<15} |"
                )
            print("-" * 100)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_instituciones_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_instituciones_todos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ALL_INSTITUCIONES()
        cur.callproc("SP_SELECT_ALL_INSTITUCIONES")
        print("\n=== INSTITUCIONES (TODAS) ===")
        for result in cur.stored_results():
            # Columnas: id_institucion, nombre, direccion, telefono, created_at, updated_at, deleted
            print("-" * 150)
            print(f"| {'ID':<3} | {'Nombre':<30} | {'Estado':<9} | {'Dirección':<20} | {'Teléfono':<15} | {'Actualizado':<19} |")
            print("-" * 150)
            for (id_, nombre, direccion, telefono, created_at, updated_at, deleted) in result.fetchall():
                estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
                ua = str(updated_at) if updated_at is not None else "-"
                print(
                    f"| {id_:<3} | {nombre:<30} | {estado:<9} | {direccion[:20]:<20} | {telefono:<15} | {ua:<19} |"
                )
            print("-" * 150)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_instituciones_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()


# ----------------- MENÚ PRINCIPAL -----------------

def menu_instituciones():
    while True:
        print("\n===== MENÚ INSTITUCIONES (MySQL + SP) =====")
        print("1) Insertar Institución")
        print("2) Listar Instituciones ACTIVAS")
        print("3) Listar Instituciones (TODAS)")
        print("4) Borrado lógico por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre de la Institución: ").strip()
            direccion = input("Dirección: ").strip()
            telefono = input("Teléfono: ").strip()
            if nombre and direccion and telefono:
                sp_insertar_institucion(nombre, direccion, telefono)
            else:
                print("❌ Todos los campos son obligatorios.")
        
        elif opcion == "2":
            sp_listar_instituciones_activos()

        elif opcion == "3":
            sp_listar_instituciones_todos()

        elif opcion == "4":
            try:
                id_inst = int(input("ID de Institución a eliminar lógicamente: ").strip())
                sp_borrado_logico_institucion(id_inst)
            except ValueError:
                print("❌ ID inválido.")

        elif opcion == "0":
            print("👋 Saliendo del menú de Instituciones...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu_instituciones()