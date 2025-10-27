# ==========================================
# gestor_contenidos.py
# Script para gestionar la tabla 'contenidos'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# --- FUNCIONES PARA 'contenidos' ---

def sp_insertar_contenido(id_curso, titulo, desc, id_tipo):
    """Llama a SP_INSERT_CONTENIDO"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        args = [id_curso, titulo, desc, id_tipo]
        cur.callproc("SP_INSERT_CONTENIDO", args)
        cnx.commit()
        print(f"✅ Contenido '{titulo}' insertado correctamente.")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_contenido: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_contenido(id_contenido: int):
    """Llama a SP_DELETE_LOGIC_CONTENIDO"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_DELETE_LOGIC_CONTENIDO", [id_contenido])
        cnx.commit()
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado al Contenido ID {id_contenido}.")
        else:
            print(f"⚠️ No se encontró el Contenido ID {id_contenido} (o ya estaba eliminado).")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_contenido: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_contenidos_activos():
    """Llama a SP_SELECT_ACTIVOS_CONTENIDOS"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ACTIVOS_CONTENIDOS")
        print("\n--- CONTENIDOS ACTIVOS ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron contenidos activos.")
                continue
            for (id_c, curso, titulo, tipo) in rows:
                tipo_str = tipo if tipo else "N/A"
                print(f"ID:{id_c:<4} | Curso:{curso:<25} | Titulo:{titulo:<30} | Tipo:{tipo_str}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_contenidos_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_contenidos_todos():
    """Llama a SP_SELECT_ALL_CONTENIDOS"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ALL_CONTENIDOS")
        print("\n--- TODOS LOS CONTENIDOS (INCLUYE ELIMINADOS) ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron contenidos.")
                continue
            for row in rows:
                estado = "ELIMINADO" if row[11] == 1 else "ACTIVO"
                print(f"ID:{row[0]:<4} | ID Curso:{row[1]:<4} | Titulo:{row[2]:<30} | Estado:{estado:<10}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_contenidos_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# --- MENÚ PRINCIPAL DE CONTENIDOS ---
def menu_contenidos():
    while True:
        print("\n===== GESTIÓN DE CONTENIDOS =====")
        print("1) Insertar Contenido")
        print("2) Listar Contenidos Activos")
        print("3) Listar Todos los Contenidos")
        print("4) Eliminar Contenido (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            print("--- Nuevo Contenido ---")
            id_curso = obtener_id("ID del Curso al que pertenece: ")
            titulo = input("Título del contenido: ").strip()
            desc = input("Descripción: ").strip()
            id_tipo = obtener_id("ID Tipo Contenido (1=Video, 2=Doc, 3=Quiz, 4=Actividad): ")
            if not (id_curso and titulo and id_tipo):
                print("❌ ID de Curso, Título y ID de Tipo son obligatorios.")
                continue
            sp_insertar_contenido(id_curso, titulo, desc, id_tipo)
        elif opc == '2':
            sp_listar_contenidos_activos()
        elif opc == '3':
            sp_listar_contenidos_todos()
        elif opc == '4':
            id_cont = obtener_id("ID del Contenido a eliminar: ")
            if id_cont:
                sp_eliminar_contenido(id_cont)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Contenidos...")
            break
        else:
            print("❌ Opción no válida.")

if __name__ == "__main__":
    menu_contenidos()