# ==========================================
# gestor_inscripciones.py
# Script para gestionar la tabla 'inscripcion_cursos'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# --- FUNCIONES PARA 'inscripcion_cursos' ---

def sp_insertar_inscripcion(id_curso, id_est, id_prof, f_ins, id_estado):
    """Llama a SP_INSERT_INSCRIPCION"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        # Convertir 0 a None (NULL) si el usuario lo ingresa
        id_prof_real = id_prof if id_prof != 0 else None
        
        args = [id_curso, id_est, id_prof_real, f_ins, id_estado]
        cur.callproc("SP_INSERT_INSCRIPCION", args)
        cnx.commit()
        print(f"✅ Estudiante {id_est} inscrito en curso {id_curso} correctamente.")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_inscripcion: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_inscripcion(id_curso: int, id_estudiante: int):
    """Llama a SP_DELETE_LOGIC_INSCRIPCION"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_DELETE_LOGIC_INSCRIPCION", [id_curso, id_estudiante])
        cnx.commit()
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado a la inscripción (Curso: {id_curso}, Est: {id_estudiante}).")
        else:
            print(f"⚠️ No se encontró la inscripción (o ya estaba eliminada).")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_inscripcion: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_inscripciones_activas():
    """Llama a SP_SELECT_ACTIVOS_INSCRIPCIONES"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ACTIVOS_INSCRIPCIONES")
        print("\n--- INSCRIPCIONES ACTIVAS ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron inscripciones activas.")
                continue
            for (curso, est, estado, f_ins, calif) in rows:
                cal = calif if calif else "N/A"
                print(f"Curso:{curso:<25} | Estudiante:{est:<25} | Estado:{estado:<15} | Calif:{cal}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_inscripciones_activas: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_inscripciones_todas():
    """Llama a SP_SELECT_ALL_INSCRIPCIONES"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ALL_INSCRIPCIONES")
        print("\n--- TODAS LAS INSCRIPCIONES (INCLUYE ELIMINADAS) ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron inscripciones.")
                continue
            for row in rows:
                estado = "ELIMINADO" if row[10] == 1 else "ACTIVO"
                print(f"ID Curso:{row[0]:<4} | ID Est:{row[1]:<4} | ID Estado:{row[4]:<3} | Estado:{estado:<10}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_inscripciones_todas: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# --- MENÚ PRINCIPAL DE INSCRIPCIONES ---
def menu_inscripciones():
    while True:
        print("\n===== GESTIÓN DE INSCRIPCIONES A CURSOS =====")
        print("1) Inscribir Estudiante en Curso")
        print("2) Listar Inscripciones Activas")
        print("3) Listar Todas las Inscripciones")
        print("4) Eliminar Inscripción (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            print("--- Nueva Inscripción ---")
            id_curso = obtener_id("ID del Curso: ")
            id_est = obtener_id("ID del Estudiante (Usuario): ")
            id_prof = obtener_id("ID del Profesor (Usuario) (Opcional, 0 si no aplica): ")
            f_ins = input("Fecha Inscripción (YYYY-MM-DD): ").strip()
            id_estado = obtener_id("ID Estado (1=Inscrito, 2=En Progreso, 3=Finalizado): ")
            if not (id_curso and id_est and f_ins and id_estado):
                print("❌ IDs de Curso, Estudiante, Fecha y Estado son obligatorios.")
                continue
            sp_insertar_inscripcion(id_curso, id_est, id_prof, f_ins, id_estado)
        elif opc == '2':
            sp_listar_inscripciones_activas()
        elif opc == '3':
            sp_listar_inscripciones_todas()
        elif opc == '4':
            id_curso = obtener_id("ID del Curso de la inscripción a eliminar: ")
            id_est = obtener_id("ID del Estudiante de la inscripción a eliminar: ")
            if id_curso and id_est:
                sp_eliminar_inscripcion(id_curso, id_est)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Inscripciones...")
            break
        else:
            print("❌ Opción no válida.")

if __name__ == "__main__":
    menu_inscripciones()