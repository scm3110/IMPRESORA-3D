"""
Rutas (endpoints) CRUD para el módulo Laboratorios.
Blueprint de Flask que se registra en app.py.
"""

from flask import Blueprint, request, jsonify
import pymysql

from config.database import Database
from models.laboratorio import Laboratorio

laboratorio_bp = Blueprint("laboratorios", __name__, url_prefix="/api/laboratorios")


# ── POST  /api/laboratorios  ─  Crear laboratorio ───────
@laboratorio_bp.route("", methods=["POST"])
def crear():
    datos = request.get_json(silent=True)
    if not datos:
        return jsonify({"error": "El cuerpo de la petición debe ser JSON."}), 400

    # Validar campos requeridos
    requeridos = ["nombre", "pais", "ciudad", "moneda"]
    faltantes = [c for c in requeridos if not datos.get(c)]
    if faltantes:
        return jsonify({"error": f"Campos requeridos faltantes: {', '.join(faltantes)}"}), 400

    # Validar longitud de moneda (CHAR 3)
    if len(datos["moneda"]) != 3:
        return jsonify({"error": "El campo 'moneda' debe tener exactamente 3 caracteres (ej: COP, USD)."}), 400

    try:
        with Database() as conn:
            resultado = Laboratorio.crear(conn, datos)
            return jsonify(resultado), 201
    except pymysql.Error as e:
        return jsonify({"error": f"Error de base de datos: {e}"}), 500


# ── GET  /api/laboratorios  ─  Listar todos ─────────────
@laboratorio_bp.route("", methods=["GET"])
def listar():
    try:
        with Database() as conn:
            laboratorios = Laboratorio.listar(conn)
            return jsonify(laboratorios), 200
    except pymysql.Error as e:
        return jsonify({"error": f"Error de base de datos: {e}"}), 500


# ── GET  /api/laboratorios/<id>  ─  Consultar uno ───────
@laboratorio_bp.route("/<int:id_laboratorio>", methods=["GET"])
def obtener(id_laboratorio):
    try:
        with Database() as conn:
            lab = Laboratorio.obtener_por_id(conn, id_laboratorio)
            if not lab:
                return jsonify({"error": "Laboratorio no encontrado."}), 404
            return jsonify(lab), 200
    except pymysql.Error as e:
        return jsonify({"error": f"Error de base de datos: {e}"}), 500


# ── PUT  /api/laboratorios/<id>  ─  Editar ──────────────
@laboratorio_bp.route("/<int:id_laboratorio>", methods=["PUT"])
def actualizar(id_laboratorio):
    datos = request.get_json(silent=True)
    if not datos:
        return jsonify({"error": "El cuerpo de la petición debe ser JSON."}), 400

    # Validar moneda si se envía
    if "moneda" in datos and len(datos["moneda"]) != 3:
        return jsonify({"error": "El campo 'moneda' debe tener exactamente 3 caracteres."}), 400

    try:
        with Database() as conn:
            # Verificar que existe
            existente = Laboratorio.obtener_por_id(conn, id_laboratorio)
            if not existente:
                return jsonify({"error": "Laboratorio no encontrado."}), 404

            resultado = Laboratorio.actualizar(conn, id_laboratorio, datos)
            if not resultado:
                return jsonify({"error": "No se proporcionaron campos válidos para actualizar."}), 400
            return jsonify(resultado), 200
    except pymysql.Error as e:
        return jsonify({"error": f"Error de base de datos: {e}"}), 500


# ── DELETE  /api/laboratorios/<id>  ─  Eliminar ─────────
@laboratorio_bp.route("/<int:id_laboratorio>", methods=["DELETE"])
def eliminar(id_laboratorio):
    try:
        with Database() as conn:
            # Verificar que existe
            existente = Laboratorio.obtener_por_id(conn, id_laboratorio)
            if not existente:
                return jsonify({"error": "Laboratorio no encontrado."}), 404

            resultado = Laboratorio.eliminar(conn, id_laboratorio)
            return jsonify(resultado), 200
    except pymysql.Error as e:
        # FK constraint: tiene equipos/usuarios/parámetros asociados
        if e.args[0] == 1451:
            return jsonify({
                "error": "No se puede eliminar: el laboratorio tiene equipos, usuarios o parámetros asociados."
            }), 409
        return jsonify({"error": f"Error de base de datos: {e}"}), 500
