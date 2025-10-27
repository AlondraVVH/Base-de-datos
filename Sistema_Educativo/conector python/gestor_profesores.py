# ==========================================
# gestor_profesores.py
# Script para gestionar la tabla 'profesores'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# --- FUNCIONES PARA 'profesores' ---

def sp_insertar_profesor(id_usuario, id_institucion, materia, edad):
    """Llama a SP_INSERT_PROFESOR"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        args = [id_usuario, id_institucion, materia, edad]
        cur.callproc("SP_INSERT_PROFESOR", args)
        cnx.commit()
        print(f"✅ Profesor (ID Usuario: {id_usuario}) insertado correctamente.")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_profesor: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_profesor(id_usuario: int):
    """Llama a SP_DELETE_LOGIC_PROFESOR"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_DELETE_LOGIC_PROFESOR", [id_usuario])
        cnx.commit()
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado al Profesor (ID Usuario: {id_usuario}).")
        else:
            print(f"⚠️ No se encontró el Profesor ID {id_usuario} (o ya estaba eliminado).")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_profesor: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_profesores_activos():
    """Llama a SP_SELECT_ACTIVOS_PROFESORES"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ACTIVOS_PROFESORES")
        print("\n--- PROFESORES ACTIVOS ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron profesores activos.")
                continue
            for (id_u, nombre, institucion, materia, edad) in rows:
                inst = institucion if institucion else "N/A"
                print(f"ID:{id_u:<3} | Nombre:{nombre:<25} | Institución:{inst:<20} | Materia:{materia:<20} | Edad:{edad}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_profesores_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_profesores_todos():
    """Llama a SP_SELECT_ALL_PROFESORES"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        cur.callproc("SP_SELECT_ALL_PROFESORES")
        print("\n--- TODOS LOS PROFESORES (INCLUYE ELIMINADOS) ---")
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron profesores.")
                continue
            for row in rows:
                estado = "ELIMINADO" if row[7] == 1 else "ACTIVO"
                print(f"ID Usuario:{row[0]:<3} | Institución ID:{row[1]:<4} | Materia:{row[2]:<20} | Estado:{estado:<10}")
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_profesores_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# --- MENÚ PRINCIPAL DE PROFESORES ---
def menu_profesores():
    while True:
        print("\n===== GESTIÓN DE PROFESORES =====")
        print("(Nota: Debe existir un 'Usuario' con rol 'Profesor' primero)")
        print("1) Insertar Profesor (Asignar datos a Usuario existente)")
        print("2) Listar Profesores Activos")
        print("3) Listar Todos los Profesores")
        print("4) Eliminar Profesor (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            print("--- Nuevo Profesor ---")
            id_usuario = obtener_id("ID del Usuario (debe ser rol Profesor): ")
            id_inst = obtener_id("ID de la Institución: ")
            materia = input("Materia que imparte: ").strip()
            edad = obtener_id("Edad: ")
            if not (id_usuario and id_inst and materia and edad):
                print("❌ Datos inválidos.")
                continue
            sp_insertar_profesor(id_usuario, id_inst, materia, edad)
        elif opc == '2':
            sp_listar_profesores_activos()
        elif opc == '3':
            sp_listar_profesores_todos()
        elif opc == '4':
            id_user = obtener_id("ID del Usuario-Profesor a eliminar: ")
            if id_user:
                sp_eliminar_profesor(id_user)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Profesores...")
            break
        else:
            print("❌ Opción no válida.")

if __name__ == "__main__":
    menu_profesores()