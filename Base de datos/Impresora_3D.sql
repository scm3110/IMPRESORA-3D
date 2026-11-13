-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema impresion3d_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema impresion3d_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `impresion3d_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `impresion3d_db` ;

-- -----------------------------------------------------
-- Table `impresion3d_db`.`colores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`colores` (
  `id_color` INT NOT NULL,
  `nombre_color` VARCHAR(50) NOT NULL,
  `estado` ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
  PRIMARY KEY (`id_color`),
  UNIQUE INDEX `nombre_color_UNIQUE` (`nombre_color` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`laboratorio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`laboratorio` (
  `id_laboratorio` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(150) NOT NULL,
  `pais` VARCHAR(80) NOT NULL,
  `ciudad` VARCHAR(80) NOT NULL,
  `moneda` CHAR(3) NOT NULL,
  PRIMARY KEY (`id_laboratorio`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`equipos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`equipos` (
  `id_equipo` INT UNSIGNED NOT NULL,
  `numero_serie` VARCHAR(100) NULL,
  `marca` VARCHAR(100) NOT NULL COMMENT '[MR] RF-3.6: Marca del equipo.',
  `modelo` VARCHAR(150) NOT NULL COMMENT '[MR] RF-3.6: Modelo del equipo.',
  `tecnologia` ENUM('FDM', 'SLA', 'SLS', 'DLP', 'Otro') NOT NULL DEFAULT 'FDM' COMMENT '[MR] RF-3.6: Tipo de tecnologia.',
  `consumo_kw` DECIMAL(6,3) UNSIGNED NOT NULL COMMENT '[MR] RF-3.8: Consumo electrico en kW. Individual por equipo.',
  `estado` ENUM('disponible', 'en_impresion', 'mantenimiento', 'fuera_de_servicio') NOT NULL DEFAULT 'disponible' COMMENT '[MR] RF-3.7: Estado operativo.',
  `fecha_adquisicion` DATE NULL DEFAULT NULL COMMENT '[MR] RI-3.6: Fecha de adquisicion.',
  `id_laboratorio` INT NOT NULL,
  PRIMARY KEY (`id_equipo`),
  INDEX `idx_eq_estado` (`estado` ASC) VISIBLE,
  INDEX `fk_equipos_laboratorio1_idx` (`id_laboratorio` ASC) VISIBLE,
  UNIQUE INDEX `numero_serie_UNIQUE` (`numero_serie` ASC) VISIBLE,
  CONSTRAINT `fk_equipos_laboratorio1`
    FOREIGN KEY (`id_laboratorio`)
    REFERENCES `impresion3d_db`.`laboratorio` (`id_laboratorio`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Impresoras 3D del laboratorio. [MP] Gestion de Equipos. [MR] RF-3.6-RF-3.8.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`tipos_filamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`tipos_filamento` (
  `id_tipo_filamento` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `codigo` VARCHAR(10) NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `estado` ENUM('activo', 'inactivo') NOT NULL,
  PRIMARY KEY (`id_tipo_filamento`),
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE,
  UNIQUE INDEX `codigo_UNIQUE` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`roles` (
  `id_rol` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre_rol` VARCHAR(80) NOT NULL COMMENT '[MR] RN-2.0: Nombre unico del rol.',
  `descripcion` TEXT NULL DEFAULT NULL COMMENT 'Descripcion de responsabilidades del rol.',
  `estado` ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo' COMMENT '[MR] RF-2.3: Estado del rol.',
  PRIMARY KEY (`id_rol`),
  UNIQUE INDEX `uq_nombre_rol` (`nombre_rol` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Roles del sistema. [MR] RF-2.0.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`usuarios` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombres` VARCHAR(100) NOT NULL COMMENT '[MR] RI-1.0: Nombres del usuario.',
  `apellidos` VARCHAR(100) NOT NULL COMMENT '[MR] RI-1.0: Apellidos del usuario.',
  `numero_documento` VARCHAR(20) NOT NULL COMMENT '[MR] RI-1.0: Numero de documento. Unico.',
  `correo` VARCHAR(120) NOT NULL COMMENT '[MR] RF-1.0: Correo institucional SENA. Unico.',
  `telefono` VARCHAR(20) NULL DEFAULT NULL COMMENT '[MR] RI-1.0: Telefono de contacto.',
  `password_hash` VARCHAR(255) NOT NULL COMMENT '[MR] RF-1.4: Hash bcrypt de contrasena.',
  `estado` ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo' COMMENT '[MR] RF-1.3: Estado del usuario.',
  `cambiar_clave` TINYINT NULL DEFAULT 1,
  `id_rol` INT UNSIGNED NOT NULL,
  `id_laboratorio` INT NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `uq_correo` (`correo` ASC) VISIBLE,
  UNIQUE INDEX `uq_numero_documento` (`numero_documento` ASC) VISIBLE,
  INDEX `idx_us_estado` (`estado` ASC) VISIBLE,
  INDEX `fk_usuarios_roles1_idx` (`id_rol` ASC) VISIBLE,
  INDEX `fk_usuarios_laboratorio1_idx` (`id_laboratorio` ASC) VISIBLE,
  CONSTRAINT `fk_usuarios_laboratorio1`
    FOREIGN KEY (`id_laboratorio`)
    REFERENCES `impresion3d_db`.`laboratorio` (`id_laboratorio`),
  CONSTRAINT `fk_usuarios_roles1`
    FOREIGN KEY (`id_rol`)
    REFERENCES `impresion3d_db`.`roles` (`id_rol`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Usuarios del sistema. [FC] Administracion de Usuarios. [MR] RF-1.0-RF-1.5.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`inventario` (
  `id_inventario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `marca` VARCHAR(80) NULL DEFAULT NULL COMMENT 'Marca del filamento.',
  `presentacion` VARCHAR(30) NOT NULL DEFAULT '1kg' COMMENT '[MR] RF-4.0: Presentacion (500g, 1kg, etc.).',
  `stock_actual_g` DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT '0.00' COMMENT '[MR] RF-4.1: Stock actual en gramos.',
  `stock_minimo_g` DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT '0.00' COMMENT '[MR] RF-4.5: Umbral minimo (dispara alerta).',
  `stock_maximo_g` DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT '0.00' COMMENT '[MR] RI-4.0: Stock maximo de referencia.',
  `estado` ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo' COMMENT 'Solo activos usables en produccion.',
  `fecha_registro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` DATETIME NOT NULL,
  `usuario_registro` INT UNSIGNED NOT NULL,
  `id_color` INT NOT NULL,
  `id_laboratorio` INT NOT NULL,
  `id_tipo_filamento` INT NOT NULL,
  PRIMARY KEY (`id_inventario`),
  INDEX `idx_mat_estado` (`estado` ASC) VISIBLE,
  INDEX `fk_materiales_colores1_idx` (`id_color` ASC) VISIBLE,
  INDEX `fk_materiales_laboratorio1_idx` (`id_laboratorio` ASC) VISIBLE,
  INDEX `fk_materiales_tipos_filamento1_idx` (`id_tipo_filamento` ASC) VISIBLE,
  INDEX `fk_inventario_usuarios1_idx` (`usuario_registro` ASC) VISIBLE,
  CONSTRAINT `fk_materiales_colores1`
    FOREIGN KEY (`id_color`)
    REFERENCES `impresion3d_db`.`colores` (`id_color`),
  CONSTRAINT `fk_materiales_laboratorio1`
    FOREIGN KEY (`id_laboratorio`)
    REFERENCES `impresion3d_db`.`laboratorio` (`id_laboratorio`),
  CONSTRAINT `fk_materiales_tipos_filamento1`
    FOREIGN KEY (`id_tipo_filamento`)
    REFERENCES `impresion3d_db`.`tipos_filamento` (`id_tipo_filamento`),
  CONSTRAINT `fk_inventario_usuarios1`
    FOREIGN KEY (`usuario_registro`)
    REFERENCES `impresion3d_db`.`usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Inventario de filamentos y materiales. [FC] Gestion de Inventario. [MR] RF-4.0-RF-4.6.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`trabajos_impresion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`trabajos_impresion` (
  `id_trabajo` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_cotizacion_origen` INT UNSIGNED NULL,
  `id_equipo` INT UNSIGNED NOT NULL COMMENT '[MR] RF-3.7: Impresora asignada.',
  `id_material` INT UNSIGNED NOT NULL COMMENT '[MR] RI-5.0: Material utilizado.',
  `id_usuario_responsable` INT UNSIGNED NOT NULL COMMENT '[MR] RI-5.0: Responsable del trabajo.',
  `tipo` ENUM('cotizacion', 'trabajo') NOT NULL DEFAULT 'trabajo',
  `nombre_pieza` VARCHAR(150) NOT NULL COMMENT '[MR] RF-5.0: Nombre de la pieza a imprimir.',
  `fecha_creacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `tiempo_estimado_h` DECIMAL(8,2) NOT NULL DEFAULT '0.00' COMMENT '[MR] RI-5.0: Horas estimadas.',
  `gramos_estimados` DECIMAL(8,2) NOT NULL DEFAULT '0.00' COMMENT '[MR] RI-5.0: Gramos estimados.',
  `estado` VARCHAR(20) NOT NULL COMMENT '[MR] RF-5.0: Estado. Inicial: pendiente (RN-5.0).',
  `tiempo_real_h` DECIMAL(8,2) NULL DEFAULT NULL COMMENT '[MR] RF-5.2: Horas reales. Registrar tambien si cancelado con merma.',
  `gramos_reales` DECIMAL(8,2) NULL DEFAULT NULL COMMENT '[MR] RF-5.2: Gramos reales. Registrar tambien si cancelado con merma.',
  `fecha_fin` DATETIME NULL DEFAULT NULL COMMENT '[MR] RI-5.2: Cierre del trabajo.',
  `motivo_cancelacion` TEXT NULL DEFAULT NULL COMMENT '[MR] RF-5.3: Requerido cuando estado=cancelado.',
  `archivo_nombre` VARCHAR(150) NULL,
  `archivo_formato` VARCHAR(10) NULL,
  `archivo_fecha_lectura` DATETIME NULL,
  PRIMARY KEY (`id_trabajo`),
  INDEX `idx_tj_equipo` (`id_equipo` ASC) VISIBLE,
  INDEX `idx_tj_material` (`id_material` ASC) VISIBLE,
  INDEX `idx_tj_responsable` (`id_usuario_responsable` ASC) VISIBLE,
  INDEX `idx_tj_estado` (`estado` ASC) VISIBLE,
  INDEX `fk_trabajos_impresion_trabajos_impresion1_idx` (`id_cotizacion_origen` ASC) VISIBLE,
  CONSTRAINT `fk_tj_equipo`
    FOREIGN KEY (`id_equipo`)
    REFERENCES `impresion3d_db`.`equipos` (`id_equipo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tj_material`
    FOREIGN KEY (`id_material`)
    REFERENCES `impresion3d_db`.`inventario` (`id_inventario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_tj_responsable`
    FOREIGN KEY (`id_usuario_responsable`)
    REFERENCES `impresion3d_db`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_trabajos_impresion_trabajos_impresion1`
    FOREIGN KEY (`id_cotizacion_origen`)
    REFERENCES `impresion3d_db`.`trabajos_impresion` (`id_trabajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Trabajos de impresion 3D. [FC] Gestion de Produccion. [MR] RF-5.0-RF-5.4.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`costeos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`costeos` (
  `id_costeo` INT NOT NULL AUTO_INCREMENT,
  `tipo_costeo` ENUM('estimado', 'real') NOT NULL DEFAULT 'real',
  `costo_material` DECIMAL(14,4) NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-6.0: gramos_reales * precio_gramo_usado.',
  `costo_energia` DECIMAL(14,4) NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-6.1: tiempo_real_h * consumo_kw_usado * costo_kwh_usado.',
  `costo_tiempo` DECIMAL(14,4) NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-6.2: tiempo_real_h * costo_hora_usado.',
  `margen_aplicado` DECIMAL(5,2) NOT NULL DEFAULT '0.00' COMMENT '[MR] RF-6.3: Margen aplicado (%).',
  `precio_final` DECIMAL(14,4) NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-6.3: subtotal * (1 + margen/100).',
  `precio_gramo_usado` DECIMAL(12,4) NOT NULL DEFAULT '0.0000' COMMENT '[R-05] Snapshot precio filamento/g al calcular.',
  `consumo_kw_usado` DECIMAL(8,4) NOT NULL DEFAULT '0.0000' COMMENT '[R-05] Snapshot consumo kW del equipo al calcular.',
  `costo_kwh_usado` DECIMAL(12,4) NOT NULL DEFAULT '0.0000' COMMENT '[R-05] Snapshot costo kWh al calcular.',
  `costo_hora_usado` DECIMAL(12,4) NOT NULL DEFAULT '0.0000' COMMENT '[R-05] Snapshot costo hora al calcular.',
  `fecha_calculo` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '[MR] RI-6.0: Fecha del calculo.',
  `id_trabajo` INT NOT NULL,
  PRIMARY KEY (`id_costeo`),
  UNIQUE INDEX `uq_costeo_trabajo` (`id_trabajo` ASC) VISIBLE,
  INDEX `idx_co_fecha` (`fecha_calculo` ASC) VISIBLE,
  INDEX `fk_costeos_trabajos_impresion1_idx` (`id_trabajo` ASC) VISIBLE,
  CONSTRAINT `fk_costeos_trabajos_impresion1`
    FOREIGN KEY (`id_trabajo`)
    REFERENCES `impresion3d_db`.`trabajos_impresion` (`id_trabajo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Costeos (1:1 con trabajos). [FC] Costeo Produccion. [MR] RF-6.0-RF-6.5.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`parametros_sistema`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`parametros_sistema` (
  `id_parametro` TINYINT UNSIGNED NOT NULL,
  `precio_filamento_gramo` DECIMAL(12,4) UNSIGNED NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-3.0: Precio filamento por gramo ($/g).',
  `costo_kwh` DECIMAL(12,4) NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-3.1: Costo energia electrica por kWh.',
  `costo_hora_impresion` DECIMAL(12,4) NOT NULL DEFAULT '0.0000' COMMENT '[MR] RF-3.2: Costo global por hora de impresion.',
  `margen_ganancia` DECIMAL(5,2) NOT NULL DEFAULT '0.00' COMMENT '[MR] RF-3.3: Margen de ganancia (%). Rango: 0-100.',
  `fecha_actualizacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '[MR] RI-3.0: Ultima actualizacion.',
  `id_laboratorio` INT NOT NULL,
  PRIMARY KEY (`id_parametro`),
  UNIQUE INDEX `id_laboratorio_UNIQUE` (`id_laboratorio` ASC) VISIBLE,
  INDEX `fk_parametros_sistema_laboratorio1_idx` (`id_laboratorio` ASC) VISIBLE,
  CONSTRAINT `fk_parametros_sistema_laboratorio1`
    FOREIGN KEY (`id_laboratorio`)
    REFERENCES `impresion3d_db`.`laboratorio` (`id_laboratorio`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`historico_parametros`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`historico_parametros` (
  `id_historico` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL COMMENT '[MR] RN-3.5: Usuario que realizo el cambio.',
  `campo_modificado` VARCHAR(80) NOT NULL COMMENT '[MR] RI-3.5: Campo modificado (ej: costo_kwh).',
  `valor_anterior` DECIMAL(12,4) NOT NULL COMMENT '[MR] RN-3.5: Valor antes del cambio.',
  `valor_nuevo` DECIMAL(12,4) NOT NULL COMMENT '[MR] RN-3.5: Valor despues del cambio.',
  `fecha_cambio` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '[MR] RN-3.5: Fecha del cambio.',
  `observacion` TEXT NULL DEFAULT NULL COMMENT 'Contexto del cambio.',
  `id_parametro` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_historico`),
  INDEX `idx_hp_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `idx_hp_fecha` (`fecha_cambio` ASC) VISIBLE,
  INDEX `fk_historico_parametros_parametros_sistema1_idx` (`id_parametro` ASC) VISIBLE,
  CONSTRAINT `fk_historico_parametros_parametros_sistema1`
    FOREIGN KEY (`id_parametro`)
    REFERENCES `impresion3d_db`.`parametros_sistema` (`id_parametro`),
  CONSTRAINT `fk_hp_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `impresion3d_db`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Historial de cambios en parametros. [MR] RF-3.5.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`tipo_movimiento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`tipo_movimiento` (
  `id_tipo_movimiento` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `codigo` VARCHAR(10) NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id_tipo_movimiento`),
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE,
  UNIQUE INDEX `codigo_UNIQUE` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`movimientos_inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`movimientos_inventario` (
  `id_movimiento` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_material` INT UNSIGNED NOT NULL COMMENT 'Material afectado.',
  `id_trabajo` INT UNSIGNED NULL DEFAULT NULL COMMENT 'Trabajo que genero el movimiento. NULL = entrada manual.',
  `id_usuario` INT UNSIGNED NOT NULL COMMENT 'Usuario que registro el movimiento.',
  `cantidad_g` DECIMAL(10,2) NOT NULL COMMENT 'Cantidad en gramos. Siempre positivo.',
  `stock_anterior_g` DECIMAL(10,2) NOT NULL COMMENT 'Stock antes del movimiento.',
  `stock_posterior_g` DECIMAL(10,2) NOT NULL COMMENT 'Stock despues del movimiento.',
  `motivo` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Descripcion del motivo.',
  `fecha_movimiento` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_tipo_movimiento` INT NOT NULL,
  PRIMARY KEY (`id_movimiento`),
  INDEX `idx_mv_material` (`id_material` ASC) VISIBLE,
  INDEX `idx_mv_trabajo` (`id_trabajo` ASC) VISIBLE,
  INDEX `idx_mv_usuario` (`id_usuario` ASC) VISIBLE,
  INDEX `idx_mv_fecha` (`fecha_movimiento` ASC) VISIBLE,
  INDEX `fk_movimientos_inventario_tipo_movimiento1_idx` (`id_tipo_movimiento` ASC) VISIBLE,
  CONSTRAINT `fk_movimientos_inventario_tipo_movimiento1`
    FOREIGN KEY (`id_tipo_movimiento`)
    REFERENCES `impresion3d_db`.`tipo_movimiento` (`id_tipo_movimiento`),
  CONSTRAINT `fk_mv_material`
    FOREIGN KEY (`id_material`)
    REFERENCES `impresion3d_db`.`inventario` (`id_inventario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_mv_trabajo`
    FOREIGN KEY (`id_trabajo`)
    REFERENCES `impresion3d_db`.`trabajos_impresion` (`id_trabajo`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_mv_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `impresion3d_db`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Movimientos de inventario. [MR] RF-4.3, RF-4.4.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`permisos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`permisos` (
  `id_permiso` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `modulo` ENUM('usuarios', 'configuracion_roles_permisos', 'control_parametros', 'laboratorios', 'equipos', 'inventario_materiales', 'produccion_impresion', 'costeo_produccion', 'estadisticas_uso', 'dashboard', 'generacion_reportes') NOT NULL COMMENT '[MP] Modulo del sistema al que aplica el permiso.',
  `accion` ENUM('ver', 'crear', 'editar', 'cambiar_estado') NOT NULL COMMENT '[MR] RN-2.0: Accion controlada.',
  `descripcion` VARCHAR(255) NULL DEFAULT NULL COMMENT 'Descripcion legible del permiso.',
  PRIMARY KEY (`id_permiso`),
  UNIQUE INDEX `uq_modulo_accion` (`modulo` ASC, `accion` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 29
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci
COMMENT = 'Catalogo de permisos por modulo y accion. [MR] RN-2.0.';


-- -----------------------------------------------------
-- Table `impresion3d_db`.`permisos_roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`permisos_roles` (
  `id_permiso` INT UNSIGNED NOT NULL,
  `id_rol` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_permiso`, `id_rol`),
  INDEX `fk_permisos_has_roles_roles1_idx` (`id_rol` ASC) VISIBLE,
  INDEX `fk_permisos_has_roles_permisos1_idx` (`id_permiso` ASC) VISIBLE,
  CONSTRAINT `fk_permisos_has_roles_permisos1`
    FOREIGN KEY (`id_permiso`)
    REFERENCES `impresion3d_db`.`permisos` (`id_permiso`),
  CONSTRAINT `fk_permisos_has_roles_roles1`
    FOREIGN KEY (`id_rol`)
    REFERENCES `impresion3d_db`.`roles` (`id_rol`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`token_recuperacion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`token_recuperacion` (
  `id_token_recuperacion` INT NOT NULL AUTO_INCREMENT,
  `token_recuperacion` CHAR(6) NOT NULL COMMENT 'Código OTP de 6 dígitos para recuperación',
  `fecha_creacion` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_expiracion` DATETIME NOT NULL,
  `estado_uso` TINYINT NULL DEFAULT 0,
  `id_usuario` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_token_recuperacion`, `id_usuario`),
  UNIQUE INDEX `token_recuperacion_UNIQUE` (`token_recuperacion` ASC) VISIBLE,
  INDEX `fk_token_recuperacion_usuarios1_idx` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_token_recuperacion_usuarios1`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `impresion3d_db`.`usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `impresion3d_db`.`historial_estados_equipos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `impresion3d_db`.`historial_estados_equipos` (
  `id_historial_estados` INT NOT NULL,
  `estado_anterior` ENUM('disponible', 'en_impresion', 'mantenimiento', 'fuera_de_servicio') NULL,
  `estado_nuevo` ENUM('disponible', 'en_impresion', 'mantenimiento', 'fuera_de_servicio') NULL,
  `fecha_cambio` DATETIME NULL,
  `observaciones` VARCHAR(500) NULL,
  `id_equipo` INT UNSIGNED NOT NULL,
  `id_usuario` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_historial_estados`),
  INDEX `fk_historial_estados_equipos_equipos1_idx` (`id_equipo` ASC) VISIBLE,
  INDEX `fk_historial_estados_equipos_usuarios1_idx` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_historial_estados_equipos_equipos1`
    FOREIGN KEY (`id_equipo`)
    REFERENCES `impresion3d_db`.`equipos` (`id_equipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_historial_estados_equipos_usuarios1`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `impresion3d_db`.`usuarios` (`id_usuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
