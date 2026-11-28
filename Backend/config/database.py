"""
Módulo de conexión a la Base de Datos MariaDB/MySQL - Impresión 3D SENA
Utiliza PyMySQL con soporte para variables de entorno (.env),
cursores tipo diccionario y context manager para transacciones seguras.
"""

import os
import pymysql
from pymysql import OperationalError, ProgrammingError


try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", 3307)),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "impresion3d_db"),
    "charset": "utf8mb4",
    "autocommit": False,
    "cursorclass": pymysql.cursors.DictCursor
}


def get_connection():
    """
    Crea y retorna una nueva conexión a la base de datos.

    :return: Objeto de conexión de pymysql o None si falla.
    """
    try:
        conexion = pymysql.connect(**DB_CONFIG)
        return conexion
    except (OperationalError, ProgrammingError) as e:
        print(f"[Error de Conexión] No se pudo conectar a la base de datos '{DB_CONFIG['database']}': {e}")
        return None


class Database:
    """Clase administradora con soporte de Context Manager (with Database() as conn:)."""

    def __init__(self):
        self.config = DB_CONFIG

    def conectar(self):
        """Retorna una conexión activa."""
        return get_connection()

    def __enter__(self):
        self.conn = get_connection()
        if not self.conn or not self.conn.open:
            raise ConnectionError(f"No se pudo establecer conexión con la base de datos '{self.config['database']}'")
        return self.conn

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.conn and self.conn.open:
            if exc_type is not None:
                self.conn.rollback()
            else:
                self.conn.commit()
            self.conn.close()


if __name__ == "__main__":
    print("Probando conexión a la base de datos MariaDB/MySQL...")
    conn = get_connection()
    if conn and conn.open:
        db_info = conn.get_server_info()
        print(f"✅ ¡Conexión exitosa! Versión del servidor: {db_info}")
        cursor = conn.cursor()
        cursor.execute("SELECT DATABASE() AS bd_actual;")
        resultado = cursor.fetchone()
        print(f"Base de datos seleccionada: {resultado['bd_actual']}")
        cursor.close()
        conn.close()
    else:
        print("❌ Falló la conexión.")
        print("💡 Sugerencia: Si tu servidor tiene contraseña, cámbiala en DB_CONFIG o en un archivo .env (DB_PASSWORD=tu_clave).")
