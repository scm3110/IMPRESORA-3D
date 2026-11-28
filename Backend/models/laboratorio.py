"""
Modelo de datos para la tabla `laboratorio`.
Operaciones CRUD contra la base de datos MariaDB/MySQL existente.
"""

import pymysql


class Laboratorio:
    """Acceso a datos de la tabla laboratorio (CRUD completo)."""

    # ── CREAR ────────────────────────────────────────────
    @staticmethod
    def crear(conn, datos):
        """
        Inserta un nuevo laboratorio.

        :param conn: Conexión activa de pymysql.
        :param datos: dict con claves nombre, pais, ciudad, moneda.
        :return: dict con id y mensaje, o None si falla.
        """
        sql = """
            INSERT INTO laboratorio (nombre, pais, ciudad, moneda)
            VALUES (%(nombre)s, %(pais)s, %(ciudad)s, %(moneda)s)
        """
        try:
            cursor = conn.cursor()
            cursor.execute(sql, datos)
            conn.commit()
            nuevo_id = cursor.lastrowid
            cursor.close()
            return {"id_laboratorio": nuevo_id, "mensaje": "Laboratorio creado exitosamente."}
        except pymysql.Error as e:
            conn.rollback()
            raise e

    # ── LISTAR TODOS ─────────────────────────────────────
    @staticmethod
    def listar(conn):
        """
        Retorna todos los laboratorios ordenados por id.

        :param conn: Conexión activa.
        :return: Lista de diccionarios.
        """
        sql = "SELECT * FROM laboratorio ORDER BY id_laboratorio"
        try:
            cursor = conn.cursor()
            cursor.execute(sql)
            resultados = cursor.fetchall()
            cursor.close()
            return resultados
        except pymysql.Error as e:
            raise e

    # ── OBTENER UNO POR ID ───────────────────────────────
    @staticmethod
    def obtener_por_id(conn, id_laboratorio):
        """
        Busca un laboratorio por su id.

        :param conn: Conexión activa.
        :param id_laboratorio: int.
        :return: dict o None si no existe.
        """
        sql = "SELECT * FROM laboratorio WHERE id_laboratorio = %s"
        try:
            cursor = conn.cursor()
            cursor.execute(sql, (id_laboratorio,))
            resultado = cursor.fetchone()
            cursor.close()
            return resultado
        except pymysql.Error as e:
            raise e

    # ── ACTUALIZAR ───────────────────────────────────────
    @staticmethod
    def actualizar(conn, id_laboratorio, datos):
        """
        Actualiza un laboratorio existente.

        :param conn: Conexión activa.
        :param id_laboratorio: int.
        :param datos: dict con los campos a actualizar (nombre, pais, ciudad, moneda).
        :return: dict con mensaje, o None si no se encontró.
        """
        # Construir SET dinámico solo con los campos proporcionados
        campos_permitidos = {"nombre", "pais", "ciudad", "moneda"}
        campos = {k: v for k, v in datos.items() if k in campos_permitidos}

        if not campos:
            return None

        set_clause = ", ".join(f"{campo} = %({campo})s" for campo in campos)
        sql = f"UPDATE laboratorio SET {set_clause} WHERE id_laboratorio = %(id_laboratorio)s"
        campos["id_laboratorio"] = id_laboratorio

        try:
            cursor = conn.cursor()
            cursor.execute(sql, campos)
            conn.commit()
            filas = cursor.rowcount
            cursor.close()
            if filas == 0:
                return None
            return {"mensaje": "Laboratorio actualizado exitosamente."}
        except pymysql.Error as e:
            conn.rollback()
            raise e

    # ── ELIMINAR ─────────────────────────────────────────
    @staticmethod
    def eliminar(conn, id_laboratorio):
        """
        Elimina un laboratorio por su id.
        Falla si tiene equipos, usuarios o parámetros asociados (FK).

        :param conn: Conexión activa.
        :param id_laboratorio: int.
        :return: dict con mensaje, o None si no se encontró.
        """
        sql = "DELETE FROM laboratorio WHERE id_laboratorio = %s"
        try:
            cursor = conn.cursor()
            cursor.execute(sql, (id_laboratorio,))
            conn.commit()
            filas = cursor.rowcount
            cursor.close()
            if filas == 0:
                return None
            return {"mensaje": "Laboratorio eliminado exitosamente."}
        except pymysql.Error as e:
            conn.rollback()
            raise e
