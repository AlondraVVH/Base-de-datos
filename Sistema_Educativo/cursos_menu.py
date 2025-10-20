# cursos_menu.py
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

def sp_insertar_curso(nombre: str, descripcion: str):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_INSERT_CURSO(IN p_nombre_curso, IN p_descripcion)
        cur.callproc("SP_INSERT_CURSO", [nombre, descripcion]) 
        cnx.commit()
        print(f"✅ Curso '{nombre}' insertado correctamente.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar_curso:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico_curso(id_curso: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_DELETE_LOGIC_CURSO(IN p_id_curso)
        cur.callproc("SP_DELETE_LOGIC_CURSO", [id_curso])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al Curso ID {id_curso}.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico_curso:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_cursos_activos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ACTIVOS_CURSOS()
        cur.callproc("SP_SELECT_ACTIVOS_CURSOS")
        print("\n=== CURSOS ACTIVOS ===")
        for result in cur.stored_results():
            # Columnas: id_curso, nombre_curso, descripcion, activo
            print("-" * 110)
            print(f"| {'ID':<3} | {'Nombre':<35} | {'Estado':<9} | {'Descripción':<30} |")
            print("-" * 110)
            for (id_, nombre, descripcion, activo) in result.fetchall():
                estado = "ACTIVO" if activo == 1 else "INACTIVO"
                print(f"| {id_:<3} | {nombre:<35} | {estado:<9} | {descripcion[:30]:<30} |")
            print("-" * 110)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_cursos_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_cursos_todos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        # Llama a SP_SELECT_ALL_CURSOS()
        cur.callproc("SP_SELECT_ALL_CURSOS")
        print("\n=== CURSOS (TODOS) ===")
        for result in cur.stored_results():
            # Columnas: id_curso, nombre_curso, descripcion, activo, created_at, updated_at, deleted
            print("-" * 160)
            print(f"| {'ID':<3} | {'Nombre':<35} | {'Funcional':<10} | {'Lógico':<9} | {'Creado':<19} | {'Actualizado':<19} |")
            print("-" * 160)
            for (id_, nombre, descripcion, activo, created_at, updated_at, deleted) in result.fetchall():
                estado_logico = "ACTIVO" if deleted == 0 else "ELIMINADO"
                estado_funcional = "ACTIVO" if activo == 1 else "INACTIVO"
                ua = str(updated_at) if updated_at is not None else "-"
                print(
                    f"| {id_:<3} | {nombre:<35} | {estado_funcional:<10} | {estado_logico:<9} | "
                    f"{str(created_at):<19} | {ua:<19} |"
                )
            print("-" * 160)
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_cursos_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()


# ----------------- MENÚ PRINCIPAL -----------------

def menu_cursos():
    while True:
        print("\n===== MENÚ CURSOS (MySQL + SP) =====")
        print("1) Insertar Curso")
        print("2) Listar Cursos ACTIVOS")
        print("3) Listar Cursos (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre del Curso: ").strip()
            descripcion = input("Descripción: ").strip()
            if nombre and descripcion:
                sp_insertar_curso(nombre, descripcion)
            else:
                print("❌ Nombre y descripción no pueden estar vacíos.")
        
        elif opcion == "2":
            sp_listar_cursos_activos()

        elif opcion == "3":
            sp_listar_cursos_todos()

        elif opcion == "4":
            try:
                id_curso = int(input("ID de Curso a eliminar lógicamente: ").strip())
                sp_borrado_logico_curso(id_curso)
            except ValueError:
                print("❌ ID inválido.")

        elif opcion == "0":
            print("👋 Saliendo del menú de Cursos...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu_cursos()