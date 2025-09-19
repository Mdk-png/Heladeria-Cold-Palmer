-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-09-2025 a las 17:15:48
-- Versión del servidor: 10.4.22-MariaDB
-- Versión de PHP: 8.1.2

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
  `metodo_pago` varchar(50) DEFAULT NULL,
  `gusto1` int(11) DEFAULT NULL,
  `gusto2` int(11) DEFAULT NULL,
  `gusto3` int(11) DEFAULT NULL,
  `gusto4` int(11) DEFAULT NULL,
  `id_envase` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_faltante`
--

CREATE TABLE `producto_faltante` (
  `id_gusto` int(11) NOT NULL,
  `id_envase` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recibo`
--

CREATE TABLE `recibo` (
  `id_recibo` int(11) NOT NULL,
  `id_comanda` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stock_envases`
--

CREATE TABLE `stock_envases` (
  `id_envase` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `stock_gustos`
--

CREATE TABLE `stock_gustos` (
  `id_gusto` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
  ADD KEY `id_envase` (`id_envase`);

--
-- Indices de la tabla `producto_faltante`
--
ALTER TABLE `producto_faltante`
  ADD PRIMARY KEY (`id_gusto`,`id_envase`),
  ADD KEY `id_envase` (`id_envase`);

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
  ADD CONSTRAINT `comanda_ibfk_5` FOREIGN KEY (`id_envase`) REFERENCES `stock_envases` (`id_envase`);

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
