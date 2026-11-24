(() => {
  "use strict";

  // La raíz se obtiene de este archivo para no depender de la página abierta.
  const raiz = new URL("../../", document.currentScript.src);
  const cuerpo = document.body;
  const contenido = document.querySelector("main#contenido");

  // Cada plantilla aporta una sola raíz. El selector esperado forma parte del contrato con shared/templates.
  async function cargarBloque(nombre, selector) {
    const respuesta = await fetch(new URL(`shared/templates/${nombre}.html`, raiz), {
      cache: "no-cache",
    });
    if (!respuesta.ok) {
      throw new Error(`No se pudo cargar ${nombre}.html (${respuesta.status}).`);
    }

    // El módulo de la página determina qué enlace se marca como activo en el menú.
    const html = (await respuesta.text())
      .replaceAll("{{raiz}}", raiz.href)
      .replace(/\{\{activo:([a-z0-9-]+)\}\}/g, (_, modulo) =>
        modulo === cuerpo.dataset.modulo
          ? ' class="actual" aria-current="location"'
          : "",
      );
    if (html.includes("{{")) {
      throw new Error(`Hay un marcador desconocido en ${nombre}.html.`);
    }

    const plantilla = document.createElement("template");
    plantilla.innerHTML = html;
    const elemento = plantilla.content.firstElementChild;
    if (plantilla.content.childElementCount !== 1 || !elemento.matches(selector)) {
      throw new Error(`La estructura de ${nombre}.html no es válida.`);
    }
    return elemento;
  }

  async function iniciar() {
    cuerpo.dataset.layoutEstado = "cargando";
    try {
      if (location.protocol === "file:") {
        throw new Error("Abre el proyecto con Go Live para cargar los bloques compartidos.");
      }
      if (!contenido) {
        throw new Error("La página debe contener un main con id contenido.");
      }

      if (cuerpo.dataset.layout === "acceso") {
        const lateral = await cargarBloque("acceso-lateral", "aside.identidad");
        contenido.before(lateral);
      } else if (cuerpo.dataset.layout === "gestion") {
        // Cargar todos los bloques antes de modificar la página evita un montaje parcial.
        const [sidebar, encabezado, pie] = await Promise.all([
          cargarBloque("sidebar", "aside.lateral"),
          cargarBloque("encabezado-gestion", "header.barra"),
          cargarBloque("pie-gestion", "footer.pie-interno"),
        ]);
        const marco = document.createElement("div");
        marco.className = "marco";
        const area = document.createElement("div");
        area.className = "area";
        marco.append(sidebar, area);
        contenido.replaceWith(marco);
        // Se mueve el main original para conservar su contenido y los destinos de enlaces internos.
        area.append(encabezado, contenido, pie);
      } else {
        throw new Error("La página debe indicar un layout de acceso o gestion.");
      }
      cuerpo.dataset.layoutEstado = "listo";
    } catch (error) {
      // Sitúa el aviso fuera del main para mantener disponible el contenido de la pantalla.
      cuerpo.dataset.layoutEstado = "error";
      cuerpo.classList.add("layout-error");
      const aviso = document.createElement("p");
      aviso.className = "error-layout";
      aviso.setAttribute("role", "alert");
      aviso.textContent = `No se pudo completar la página. ${error.message}`;
      cuerpo.prepend(aviso);
      console.error("Error al cargar los bloques compartidos:", error);
    }
  }

  iniciar();
})();
