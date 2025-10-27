# ==========================================
# gestor_cursos.py
# Script para gestionar la tabla 'cursos_capacitacion'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# =======================================================
# FUNCIONES PARA 'cursos_capacitacion'
# =======================================================

def sp_insertar_curso(nombre: str, descripcion: str):
    """Llama a SP_INSERT_CURSO(p_nombre_curso, p_descripcion)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_INSERT_CURSO", [nombre, descripcion])
        cnx.commit()
        print(f"✅ Curso '{nombre}' insertado correctamente.")
        
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_curso: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_curso(id_curso: int):
    """Llama a SP_DELETE_LOGIC_CURSO(p_id_curso)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_DELETE_LOGIC_CURSO", [id_curso])
        cnx.commit()
        
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado al Curso ID {id_curso}.")
        else:
            print(f"⚠️ No se encontró el Curso ID {id_curso} (o ya estaba eliminado).")
            
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_curso: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_cursos_activos():
    """Llama a SP_SELECT_ACTIVOS_CURSOS()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ACTIVOS_CURSOS")
        print("\n--- CURSOS ACTIVOS ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron cursos activos.")
                continue

            for (id_c, nombre, desc, act) in rows:
                estado = "ACTIVO" if act == 1 else "INACTIVO"
                print(f"ID:{id_c:<3} | Nombre:{nombre:<30} | Desc:{desc:<30} | Estado:{estado}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_cursos_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_cursos_todos():
    """Llama a SP_SELECT_ALL_CURSOS()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ALL_CURSOS")
        print("\n--- TODOS LOS CURSOS (INCLUYE ELIMINADOS) ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron cursos.")
                continue

            for row in rows:
                estado = "ELIMINADO" if row[7] == 1 else "ACTIVO"
                print(f"ID:{row[0]:<3} | Nombre:{row[1]:<30} | Estado:{estado:<10} | Creado:{row[4]}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_cursos_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# =======================================================
# MENÚ PRINCIPAL DE CURSOS
# =======================================================
def menu_cursos():
    while True:
        print("\n===== GESTIÓN DE CURSOS =====")
        print("1) Insertar Curso")
        print("2) Listar Cursos Activos")
        print("3) Listar Todos los Cursos")
        print("4) Eliminar Curso (Lógico)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            nombre = input("Nombre del Curso: ").strip()
            desc = input("Descripción: ").strip()
            if nombre:
                sp_insertar_curso(nombre, desc)
            else:
                print("❌ El nombre es obligatorio.")
        elif opc == '2':
            sp_listar_cursos_activos()
        elif opc == '3':
            sp_listar_cursos_todos()
        elif opc == '4':
            id_curso = obtener_id("ID del Curso a eliminar: ")
            if id_curso:
                sp_eliminar_curso(id_curso)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Cursos...")
            break
        else:
            print("❌ Opción no válida.")

# Punto de entrada del script
if __name__ == "__main__":
    menu_cursos()