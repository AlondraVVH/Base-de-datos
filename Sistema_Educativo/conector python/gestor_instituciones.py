# ==========================================
# gestor_instituciones.py
# Script para gestionar la tabla 'instituciones'.
# ==========================================

import mysql.connector
from db_config import conectar, obtener_id

# =======================================================
# FUNCIONES PARA 'instituciones'
# =======================================================

def sp_insertar_institucion(nombre: str, direccion: str, telefono: str):
    """Llama a SP_INSERT_INSTITUCION(p_nombre, p_direccion, p_telefono)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_INSERT_INSTITUCION", [nombre, direccion, telefono])
        cnx.commit()
        print(f"✅ Institución '{nombre}' insertada correctamente.")
        
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_insertar_institucion: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_eliminar_institucion(id_inst: int):
    """Llama a SP_DELETE_LOGIC_INSTITUCION(p_id_institucion)"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_DELETE_LOGIC_INSTITUCION", [id_inst])
        cnx.commit()
        
        if cur.rowcount > 0:
            print(f"✅ Borrado lógico aplicado a la Institución ID {id_inst}.")
        else:
            print(f"⚠️ No se encontró la Institución ID {id_inst} (o ya estaba eliminada).")
            
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_eliminar_institucion: {e}")
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_instituciones_activos():
    """Llama a SP_SELECT_ACTIVOS_INSTITUCIONES()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ACTIVOS_INSTITUCIONES")
        print("\n--- INSTITUCIONES ACTIVAS ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron instituciones activas.")
                continue
                
            for (id_i, nombre, direc, tel) in rows:
                print(f"ID:{id_i:<3} | Nombre:{nombre:<25} | Dirección:{direc:<30} | Teléfono:{tel}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_instituciones_activos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_instituciones_todos():
    """Llama a SP_SELECT_ALL_INSTITUCIONES()"""
    cnx = cur = None
    try:
        cnx = conectar()
        if cnx is None: return
        cur = cnx.cursor()
        
        cur.callproc("SP_SELECT_ALL_INSTITUCIONES")
        print("\n--- TODAS LAS INSTITUCIONES (INCLUYE ELIMINADAS) ---")
        
        for result in cur.stored_results():
            rows = result.fetchall()
            if not rows:
                print("No se encontraron instituciones.")
                continue

            for row in rows:
                estado = "ELIMINADO" if row[8] == 1 else "ACTIVO"
                print(f"ID:{row[0]:<3} | Nombre:{row[1]:<25} | Estado:{estado:<10} | Creado:{row[4]}")
                
    except mysql.connector.Error as e:
        print(f"❌ Error en sp_listar_instituciones_todos: {e}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# =======================================================
# MENÚ PRINCIPAL DE INSTITUCIONES
# =======================================================
def menu_instituciones():
    while True:
        print("\n===== GESTIÓN DE INSTITUCIONES =====")
        print("1) Insertar Institución")
        print("2) Listar Instituciones Activas")
        print("3) Listar Todas las Instituciones")
        print("4) Eliminar Institución (Lógica)")
        print("0) Salir")
        opc = input("Opción: ").strip()
        
        if opc == '1':
            nombre = input("Nombre de la Institución: ").strip()
            direccion = input("Dirección: ").strip()
            telefono = input("Teléfono: ").strip()
            if nombre:
                sp_insertar_institucion(nombre, direccion, telefono)
            else:
                print("❌ El nombre es obligatorio.")
        elif opc == '2':
            sp_listar_instituciones_activos()
        elif opc == '3':
            sp_listar_instituciones_todos()
        elif opc == '4':
            id_inst = obtener_id("ID de la Institución a eliminar: ")
            if id_inst:
                sp_eliminar_institucion(id_inst)
        elif opc == '0':
            print("👋 Saliendo de Gestión de Instituciones...")
            break
        else:
            print("❌ Opción no válida.")

# Punto de entrada del script
if __name__ == "__main__":
    menu_instituciones()