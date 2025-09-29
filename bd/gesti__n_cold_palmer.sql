-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 29-09-2025 a las 15:30:07
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gestión_cold_palmer`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comanda`
--

CREATE TABLE `comanda` (
  `id_comanda` int(11) NOT NULL,
  `fecha_pedido` date NOT NULL,
  `gusto1` int(11) DEFAULT NULL,
  `gusto2` int(11) DEFAULT NULL,
  `gusto3` int(11) DEFAULT NULL,
  `gusto4` int(11) DEFAULT NULL,
  `id_envase` int(11) DEFAULT NULL,
  `id_metodo_pago` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `comanda`
--

INSERT INTO `comanda` (`id_comanda`, `fecha_pedido`, `gusto1`, `gusto2`, `gusto3`, `gusto4`, `id_envase`, `id_metodo_pago`) VALUES
(1, '2025-09-01', 1, 2, NULL, NULL, 1, 1),
(2, '2025-09-02', 3, 4, 5, NULL, 2, 2),
(3, '2025-09-03', 6, NULL, NULL, NULL, 4, 3),
(4, '2025-09-04', 2, 7, 1, NULL, 7, 4),
(5, '2025-09-05', 8, 9, 10, NULL, 8, 5),
(6, '2025-09-06', 5, NULL, NULL, NULL, 3, 6),
(7, '2025-09-07', 4, 2, 6, NULL, 9, 7),
(8, '2025-09-08', 1, 3, NULL, NULL, 10, 8),
(9, '2025-09-09', 7, 8, 5, 9, 6, 9),
(10, '2025-09-10', 10, NULL, NULL, NULL, 5, 10);

--
-- Disparadores `comanda`
--
DELIMITER $$
CREATE TRIGGER `check_envase_disponible` BEFORE INSERT ON `comanda` FOR EACH ROW BEGIN
    DECLARE cant INT;

    IF NEW.id_envase IS NOT NULL THEN
        SELECT cantidad INTO cant FROM stock_envases WHERE id_envase = NEW.id_envase;
        IF cant = 0 THEN
            INSERT INTO producto_faltante (id_gusto, id_envase) VALUES (NULL, NEW.id_envase);
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Envase no disponible, comanda cancelada';
        END IF;
    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_gustos_disponibles` BEFORE INSERT ON `comanda` FOR EACH ROW BEGIN
    DECLARE cant INT;

    -- GUSTO 1
    IF NEW.gusto1 IS NOT NULL THEN
        SELECT cantidad INTO cant FROM stock_gustos WHERE id_gusto = NEW.gusto1;
        IF cant = 0 THEN
            INSERT INTO producto_faltante (id_gusto, id_envase) VALUES (NEW.gusto1, NULL);
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Gusto 1 no disponible, comanda cancelada';
        END IF;
    END IF;

    -- GUSTO 2
    IF NEW.gusto2 IS NOT NULL THEN
        SELECT cantidad INTO cant FROM stock_gustos WHERE id_gusto = NEW.gusto2;
        IF cant = 0 THEN
            INSERT INTO producto_faltante (id_gusto, id_envase) VALUES (NEW.gusto2, NULL);
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Gusto 2 no disponible, comanda cancelada';
        END IF;
    END IF;

    -- GUSTO 3
    IF NEW.gusto3 IS NOT NULL THEN
        SELECT cantidad INTO cant FROM stock_gustos WHERE id_gusto = NEW.gusto3;
        IF cant = 0 THEN
            INSERT INTO producto_faltante (id_gusto, id_envase) VALUES (NEW.gusto3, NULL);
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Gusto 3 no disponible, comanda cancelada';
        END IF;
    END IF;

    -- GUSTO 4
    IF NEW.gusto4 IS NOT NULL THEN
        SELECT cantidad INTO cant FROM stock_gustos WHERE id_gusto = NEW.gusto4;
        IF cant = 0 THEN
            INSERT INTO producto_faltante (id_gusto, id_envase) VALUES (NEW.gusto4, NULL);
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Gusto 4 no disponible, comanda cancelada';
        END IF;
    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `restar_stock_comanda` AFTER INSERT ON `comanda` FOR EACH ROW BEGIN
    -- Restar stock del envase
    IF NEW.id_envase IS NOT NULL THEN
        UPDATE stock_envases
        SET cantidad = cantidad - 1
        WHERE id_envase = NEW.id_envase;
    END IF;

    -- Restar stock de gustos
    IF NEW.gusto1 IS NOT NULL THEN
        UPDATE stock_gustos
        SET cantidad = cantidad - 1
        WHERE id_gusto = NEW.gusto1;
    END IF;

    IF NEW.gusto2 IS NOT NULL THEN
        UPDATE stock_gustos
        SET cantidad = cantidad - 1
        WHERE id_gusto = NEW.gusto2;
    END IF;

    IF NEW.gusto3 IS NOT NULL THEN
        UPDATE stock_gustos
        SET cantidad = cantidad - 1
        WHERE id_gusto = NEW.gusto3;
    END IF;

    IF NEW.gusto4 IS NOT NULL THEN
        UPDATE stock_gustos
        SET cantidad = cantidad - 1
        WHERE id_gusto = NEW.gusto4;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `metodo_pago`
--

CREATE TABLE `metodo_pago` (
  `id_metodo_pago` int(11) NOT NULL,
  `nombre_metodo_pago` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `metodo_pago`
--

INSERT INTO `metodo_pago` (`id_metodo_pago`, `nombre_metodo_pago`) VALUES
(1, 'Efectivo'),
(2, 'Tarjeta'),
(3, 'MercadoPago'),
(4, 'Transferencia'),
(5, 'Débito'),
(6, 'Crédito'),
(7, 'Cheque'),
(8, 'Vale'),
(9, 'Criptomoneda'),
(10, 'QR');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_faltante`
--

CREATE TABLE `producto_faltante` (
  `id_gusto` int(11) DEFAULT NULL,
  `id_envase` int(11) DEFAULT NULL,
  `id_faltante` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_faltante`
--

INSERT INTO `producto_faltante` (`id_gusto`, `id_envase`, `id_faltante`) VALUES
(1, NULL, 1),
(3, NULL, 2),
(7, NULL, 3),
(5, NULL, 4),
(9, NULL, 5),
(NULL, 2, 6),
(NULL, 6, 7),
(NULL, 8, 8),
(NULL, 10, 9),
(NULL, 4, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recibo`
--

CREATE TABLE `recibo` (
  `id_recibo` int(11) NOT NULL,
  `id_comanda` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `recibo`
--

INSERT INTO `recibo` (`id_recibo`, `id_comanda`, `precio`) VALUES
(1, 1, 1000.00),
(2, 2, 1800.00),
(3, 3, 800.00),
(4, 4, 2500.00),
(5, 5, 4200.00),
(6, 6, 1200.00),
(7, 7, 3500.00),
(8, 8, 2000.00),
(9, 9, 5000.00),
(10, 10, 1500.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stock_envases`
--

CREATE TABLE `stock_envases` (
  `id_envase` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `stock_envases`
--

INSERT INTO `stock_envases` (`id_envase`, `nombre`, `precio`, `cantidad`) VALUES
(1, 'Vaso Chico', 500.00, 49),
(2, 'Vaso Mediano', 800.00, 39),
(3, 'Vaso Grande', 1200.00, 34),
(4, 'Cucurucho Simple', 300.00, 59),
(5, 'Cucurucho Doble', 450.00, 54),
(6, 'Cucurucho Bañado', 600.00, 24),
(7, 'Pote 1/4 Kg', 1500.00, 19),
(8, 'Pote 1/2 Kg', 2800.00, 17),
(9, 'Pote 1 Kg', 5000.00, 11),
(10, 'Copa Especial', 2000.00, 14);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stock_gustos`
--

CREATE TABLE `stock_gustos` (
  `id_gusto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `stock_gustos`
--

INSERT INTO `stock_gustos` (`id_gusto`, `nombre`, `cantidad`) VALUES
(1, 'Chocolate', 22),
(2, 'Vainilla', 27),
(3, 'Frutilla', 18),
(4, 'Dulce de Leche', 13),
(5, 'Menta Granizada', 15),
(6, 'Cookies & Cream', 20),
(7, 'Banana Split', 8),
(8, 'Limón', 10),
(9, 'Crema Americana', 26),
(10, 'Tramontana', 12);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `comanda`
--
ALTER TABLE `comanda`
  ADD PRIMARY KEY (`id_comanda`),
  ADD KEY `gusto1` (`gusto1`),
  ADD KEY `gusto2` (`gusto2`),
  ADD KEY `gusto3` (`gusto3`),
  ADD KEY `gusto4` (`gusto4`),
  ADD KEY `id_envase` (`id_envase`),
  ADD KEY `fk_comanda_metodo_pago` (`id_metodo_pago`);

--
-- Indices de la tabla `metodo_pago`
--
ALTER TABLE `metodo_pago`
  ADD PRIMARY KEY (`id_metodo_pago`);

--
-- Indices de la tabla `producto_faltante`
--
ALTER TABLE `producto_faltante`
  ADD PRIMARY KEY (`id_faltante`),
  ADD KEY `producto_faltante_ibfk_1` (`id_gusto`),
  ADD KEY `producto_faltante_ibfk_2` (`id_envase`);

--
-- Indices de la tabla `recibo`
--
ALTER TABLE `recibo`
  ADD PRIMARY KEY (`id_recibo`),
  ADD KEY `id_comanda` (`id_comanda`);

--
-- Indices de la tabla `stock_envases`
--
ALTER TABLE `stock_envases`
  ADD PRIMARY KEY (`id_envase`);

--
-- Indices de la tabla `stock_gustos`
--
ALTER TABLE `stock_gustos`
  ADD PRIMARY KEY (`id_gusto`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `producto_faltante`
--
ALTER TABLE `producto_faltante`
  MODIFY `id_faltante` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `comanda`
--
ALTER TABLE `comanda`
  ADD CONSTRAINT `comanda_ibfk_1` FOREIGN KEY (`gusto1`) REFERENCES `stock_gustos` (`id_gusto`),
  ADD CONSTRAINT `comanda_ibfk_2` FOREIGN KEY (`gusto2`) REFERENCES `stock_gustos` (`id_gusto`),
  ADD CONSTRAINT `comanda_ibfk_3` FOREIGN KEY (`gusto3`) REFERENCES `stock_gustos` (`id_gusto`),
  ADD CONSTRAINT `comanda_ibfk_4` FOREIGN KEY (`gusto4`) REFERENCES `stock_gustos` (`id_gusto`),
  ADD CONSTRAINT `comanda_ibfk_5` FOREIGN KEY (`id_envase`) REFERENCES `stock_envases` (`id_envase`),
  ADD CONSTRAINT `fk_comanda_metodo_pago` FOREIGN KEY (`id_metodo_pago`) REFERENCES `metodo_pago` (`id_metodo_pago`);

--
-- Filtros para la tabla `producto_faltante`
--
ALTER TABLE `producto_faltante`
  ADD CONSTRAINT `producto_faltante_ibfk_1` FOREIGN KEY (`id_gusto`) REFERENCES `stock_gustos` (`id_gusto`),
  ADD CONSTRAINT `producto_faltante_ibfk_2` FOREIGN KEY (`id_envase`) REFERENCES `stock_envases` (`id_envase`);

--
-- Filtros para la tabla `recibo`
--
ALTER TABLE `recibo`
  ADD CONSTRAINT `recibo_ibfk_1` FOREIGN KEY (`id_comanda`) REFERENCES `comanda` (`id_comanda`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
