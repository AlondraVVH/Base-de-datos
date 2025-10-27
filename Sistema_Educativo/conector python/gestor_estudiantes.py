# ==========================================
# gestor_estudiantes.py
# Script para gestionar la tabla 'estudiantes'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# --- FUNCIONES PARA 'estudiantes' ---

def sp_insertar_estudiante(id_usuario, id_institucion, fecha_nac, fecha_reg):
    """Llama a SP_INSERT_ESTUDIANTE"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        args = [id_usuario, id_institucion, fecha_nac, fecha_reg]
        cur.callproc("SP_INSERT_ESTUDIANTE", args)
        cnx.commit()
        print(f"✅ Estudiante (ID Usuario: {id_usuario}) insertado correctamente.")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_estudiante: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_estudiante(id_usuario: int):
    """Llama a SP_DELETE_LOGIC_ESTUDIANTE"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_DELETE_LOGIC_ESTUDIANTE", [id_usuario])
        cnx.commit()
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado al Estudiante (ID Usuario: {id_usuario}).")
        else:
            print(f"⚠️ No se encontró el Estudiante ID {id_usuario} (o ya estaba eliminado).")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_estudiante: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_estudiantes_activos():
    """Llama a SP_SELECT_ACTIVOS_ESTUDIANTES"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ACTIVOS_ESTUDIANTES")
        print("\n--- ESTUDIANTES ACTIVOS ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron estudiantes activos.")
                continue
            for (id_u, nombre, institucion, f_nac, f_reg) in rows:
                inst = institucion if institucion else "N/A"
                print(f"ID:{id_u:<3} | Nombre:{nombre:<25} | Institución:{inst:<20} | Nacimiento:{f_nac} | Registro:{f_reg}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_estudiantes_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_estudiantes_todos():
    """Llama a SP_SELECT_ALL_ESTUDIANTES"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ALL_ESTUDIANTES")
        print("\n--- TODOS LOS ESTUDIANTES (INCLUYE ELIMINADOS) ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron estudiantes.")
                continue
            for row in rows:
                estado = "ELIMINADO" if row[7] == 1 else "ACTIVO"
                print(f"ID Usuario:{row[0]:<3} | Institución ID:{row[1]:<4} | Nacimiento:{row[2]} | Estado:{estado:<10}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_estudiantes_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# --- MENÚ PRINCIPAL DE ESTUDIANTES ---
def menu_estudiantes():
    while True:
        print("\n===== GESTIÓN DE ESTUDIANTES =====")
        print("(Nota: Debe existir un 'Usuario' con rol 'Estudiante' primero)")
        print("1) Insertar Estudiante (Asignar datos a Usuario existente)")
        print("2) Listar Estudiantes Activos")
        print("3) Listar Todos los Estudiantes")
        print("4) Eliminar Estudiante (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            print("--- Nuevo Estudiante ---")
            id_usuario = obtener_id("ID del Usuario (debe ser rol Estudiante): ")
            id_inst = obtener_id("ID de la Institución: ")
            f_nac = input("Fecha Nacimiento (YYYY-MM-DD): ").strip()
            f_reg = input("Fecha Registro (YYYY-MM-DD): ").strip()
            if not (id_usuario and id_inst and f_nac and f_reg):
                print("❌ Datos inválidos.")
                continue
            sp_insertar_estudiante(id_usuario, id_inst, f_nac, f_reg)
        elif opc == '2':
            sp_listar_estudiantes_activos()
        elif opc == '3':
            sp_listar_estudiantes_todos()
        elif opc == '4':
            id_user = obtener_id("ID del Usuario-Estudiante a eliminar: ")
            if id_user:
                sp_eliminar_estudiante(id_user)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Estudiantes...")
            break
        else:
            print("❌ Opción no válida.")

if __name__ == "__main__":
    menu_estudiantes()