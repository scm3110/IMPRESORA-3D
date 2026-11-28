"""
Punto de entrada de la API REST – Impresión 3D SENA.
Ejecutar:  python app.py
La API queda disponible en http://localhost:5000
"""

from flask import Flask, jsonify, render_template
from routes.laboratorio_routes import laboratorio_bp


def crear_app():
    """Fábrica de la aplicación Flask."""
    app = Flask(__name__)
    app.config["JSON_SORT_KEYS"] = False

    # Registrar blueprints (rutas)
    app.register_blueprint(laboratorio_bp)

    # Interfaz web del CRUD
    @app.route("/")
    def index():
        return render_template("laboratorios.html")

    # Ruta informativa de la API
    @app.route("/api")
    def api_info():
        return jsonify({
            "proyecto": "Impresión 3D SENA – API REST",
            "version": "1.0.0",
            "endpoints": {
                "laboratorios": {
                    "listar":    "GET    /api/laboratorios",
                    "consultar": "GET    /api/laboratorios/<id>",
                    "crear":     "POST   /api/laboratorios",
                    "editar":    "PUT    /api/laboratorios/<id>",
                    "eliminar":  "DELETE /api/laboratorios/<id>",
                }
            }
        })

    return app


if __name__ == "__main__":
    app = crear_app()
    print("=" * 55)
    print("  🖨️  API Impresión 3D SENA – Módulo Laboratorios")
    print("  📍 http://localhost:5000")
    print("  📋 Endpoints en http://localhost:5000/")
    print("=" * 55)
    app.run(debug=True, port=5000)
