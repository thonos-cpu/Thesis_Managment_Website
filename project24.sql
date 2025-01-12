-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 12, 2025 at 01:39 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `project24`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_member_id` (IN `thesis_id_in` INT, IN `new_member_id` INT)   BEGIN
    DECLARE m1_id INT;
    
    -- Get the current value of member1_id
    SELECT member1_id INTO m1_id
    FROM thesis
    WHERE thesis_id = thesis_id_in;
    
    -- Check if member1_id is NULL
    IF m1_id IS NULL THEN
        -- Update member1_id if it is NULL
        UPDATE thesis
        SET member1_id = new_member_id
        WHERE thesis_id = thesis_id_in;
    ELSE
        -- Update member2_id if member1_id is NOT NULL
        UPDATE thesis
        SET member2_id = new_member_id
        WHERE thesis_id = thesis_id_in;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `anouncements`
--

CREATE TABLE `anouncements` (
  `title` text NOT NULL,
  `description` text NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `user` int(11) NOT NULL,
  `anc_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `anouncements`
--

INSERT INTO `anouncements` (`title`, `description`, `datetime`, `user`, `anc_id`) VALUES
('Announcement Test', 'anouncement test', '2025-01-11 12:00:00', 1, 1),
('New Thesis Announcement: Artificial Intelligence in Healthcare', 'This thesis explores the applications of artificial intelligence in modern healthcare systems, focusing on diagnosis and treatment automation.', '2023-08-29 13:28:48', 0, 9),
('Call for Applications: Research on Sustainable Energy Solutions', 'The research aims to find innovative solutions for sustainable energy production, with a focus on renewable resources and energy storage technologies.', '2024-03-29 13:28:48', 0, 10),
('PhD Opportunities in Quantum Computing at ABC University', 'This announcement invites applications for PhD candidates in Quantum Computing, offering funding and research opportunities at ABC University.', '2024-04-16 13:28:48', 0, 12),
('Thesis Proposal: Exploring the Future of Blockchain Technology', 'The proposal explores how blockchain technology could transform various sectors, from finance to supply chain management.', '2024-01-21 13:28:48', 0, 14),
('Open Call for Postgraduate Research in Environmental Sustainability', 'We are accepting applications for postgraduate research in environmental sustainability, with a focus on mitigating climate change.', '2024-11-11 13:28:48', 0, 15),
('New Thesis on Machine Learning Algorithms for Predictive Modeling', 'The thesis examines the development of machine learning algorithms for accurate predictive modeling, with applications in various industries.', '2023-02-16 13:28:48', 0, 16),
('Research Grants Available for Studies on Renewable Energy Sources', 'This is an open call for research grants aimed at promoting the development of renewable energy sources and technologies.', '2024-01-04 13:28:48', 0, 17),
('New Study: Impact of Urbanization on Local Ecosystems and Biodiversity', 'This new study explores how urbanization impacts local ecosystems and biodiversity, with a focus on sustainable city planning.', '2023-08-19 13:28:48', 0, 18),
('pop_up_test', 'sdc', '2025-01-11 13:50:05', 1, 19);

-- --------------------------------------------------------

--
-- Table structure for table `committee_invitations`
--

CREATE TABLE `committee_invitations` (
  `inv_id` int(4) NOT NULL,
  `thesis_id` int(4) NOT NULL,
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  `professor_id` int(4) NOT NULL,
  `approved` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `committee_invitations`
--

INSERT INTO `committee_invitations` (`inv_id`, `thesis_id`, `time`, `professor_id`, `approved`) VALUES
(64, 68, '2025-01-11 14:14:43', 0, 1);

--
-- Triggers `committee_invitations`
--
DELIMITER $$
CREATE TRIGGER `committee_invitations_delete_trigger` AFTER DELETE ON `committee_invitations` FOR EACH ROW BEGIN
    INSERT INTO committee_log (inv_id, datetime, action, old_value, new_value, field_of_change, comments)
    VALUES (OLD.inv_id, NOW(), 'delete', CONCAT('inv_id: ', OLD.inv_id), NULL, 'ALL', NULL);

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `committee_invitations_insert_trigger` AFTER INSERT ON `committee_invitations` FOR EACH ROW BEGIN
    INSERT INTO committee_log (inv_id, datetime, action, old_value, new_value, field_of_change, comments)
    VALUES (NEW.inv_id, NOW(), 'insert', NULL, CONCAT('inv_id: ', NEW.inv_id), 'ALL', NULL);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `committee_invitations_update_trigger` AFTER UPDATE ON `committee_invitations` FOR EACH ROW BEGIN
    IF (OLD.approved IS NULL AND NEW.approved IS NOT NULL) OR 
       (OLD.approved IS NOT NULL AND NEW.approved IS NULL) OR 
       (OLD.approved IS NOT NULL AND NEW.approved IS NOT NULL AND OLD.approved <> NEW.approved) THEN
        INSERT INTO committee_log (inv_id, datetime, action, old_value, new_value, field_of_change, comments)
        VALUES (NEW.inv_id, NOW(), 'update', OLD.approved, NEW.approved, 'approved', NULL);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `inv_block` BEFORE INSERT ON `committee_invitations` FOR EACH ROW IF EXISTS (
        SELECT 1
        FROM thesis
        WHERE thesis_id = NEW.thesis_id
        AND state != 'pending'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'NEW INVITATIONS CAN BE CREATED ONLY FOR PENDING THESIS FOR THIS USER.';
    END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `committee_log`
--

CREATE TABLE `committee_log` (
  `log_id` int(10) NOT NULL,
  `inv_id` int(4) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `action` enum('insert','update','delete','') NOT NULL,
  `old_value` varchar(300) DEFAULT NULL,
  `new_value` varchar(300) DEFAULT NULL,
  `field_of_change` enum('inv_id','thesis_id','professor_id','approved') NOT NULL,
  `comments` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `committee_log`
--

INSERT INTO `committee_log` (`log_id`, `inv_id`, `datetime`, `action`, `old_value`, `new_value`, `field_of_change`, `comments`) VALUES
(1, 0, '2024-11-27 19:42:06', 'insert', NULL, 'inv_id: 0', '', NULL),
(2, 0, '2024-11-27 19:42:27', 'update', '0', '1', 'approved', NULL),
(3, 0, '2024-11-27 19:43:00', 'delete', 'inv_id: 0', NULL, '', NULL),
(4, 0, '2024-12-24 17:20:15', 'insert', NULL, 'inv_id: 0', '', NULL),
(5, 2, '2024-12-24 17:21:01', 'insert', NULL, 'inv_id: 2', '', NULL),
(6, 3, '2024-12-24 17:21:01', 'insert', NULL, 'inv_id: 3', '', NULL),
(9, 8, '2024-12-24 17:21:46', 'insert', NULL, 'inv_id: 8', '', NULL),
(10, 9, '2024-12-24 17:21:46', 'insert', NULL, 'inv_id: 9', '', NULL),
(11, 1, '2024-12-24 17:26:26', 'delete', 'inv_id: 1', NULL, '', NULL),
(12, 3, '2024-12-24 17:26:27', 'delete', 'inv_id: 3', NULL, '', NULL),
(13, 9, '2024-12-24 17:26:27', 'delete', 'inv_id: 9', NULL, '', NULL),
(14, 2, '2024-12-24 17:26:28', 'delete', 'inv_id: 2', NULL, '', NULL),
(15, 8, '2024-12-24 17:26:28', 'delete', 'inv_id: 8', NULL, '', NULL),
(16, 10, '2024-12-24 17:28:53', 'insert', NULL, 'inv_id: 10', '', NULL),
(17, 11, '2024-12-24 17:28:53', 'insert', NULL, 'inv_id: 11', '', NULL),
(18, 12, '2024-12-24 17:29:03', 'insert', NULL, 'inv_id: 12', '', NULL),
(19, 13, '2024-12-24 17:29:03', 'insert', NULL, 'inv_id: 13', '', NULL),
(20, 24, '2024-12-24 17:29:57', 'insert', NULL, 'inv_id: 24', '', NULL),
(21, 25, '2024-12-24 17:29:57', 'insert', NULL, 'inv_id: 25', '', NULL),
(24, 25, '2024-12-25 18:49:22', 'delete', 'inv_id: 25', NULL, '', NULL),
(25, 24, '2024-12-25 18:49:22', 'delete', 'inv_id: 24', NULL, '', NULL),
(26, 13, '2024-12-25 18:50:54', 'delete', 'inv_id: 13', NULL, '', NULL),
(27, 11, '2024-12-25 18:50:57', 'delete', 'inv_id: 11', NULL, '', NULL),
(28, 12, '2024-12-25 18:50:57', 'delete', 'inv_id: 12', NULL, '', NULL),
(29, 30, '2024-12-25 19:06:22', 'insert', NULL, 'inv_id: 30', '', NULL),
(30, 31, '2024-12-25 19:06:22', 'insert', NULL, 'inv_id: 31', '', NULL),
(31, 10, '2024-12-26 11:55:10', 'delete', 'inv_id: 10', NULL, '', NULL),
(32, 30, '2024-12-26 11:55:10', 'delete', 'inv_id: 30', NULL, '', NULL),
(33, 31, '2024-12-26 11:55:10', 'delete', 'inv_id: 31', NULL, '', NULL),
(34, 32, '2024-12-28 13:14:54', 'insert', NULL, 'inv_id: 32', '', NULL),
(35, 33, '2024-12-28 14:48:33', 'insert', NULL, 'inv_id: 33', '', NULL),
(36, 32, '2024-12-28 14:48:57', 'delete', 'inv_id: 32', NULL, '', NULL),
(37, 33, '2024-12-28 14:49:04', 'delete', 'inv_id: 33', NULL, '', NULL),
(38, 34, '2024-12-28 14:49:20', 'insert', NULL, 'inv_id: 34', '', NULL),
(39, 35, '2024-12-28 15:28:39', 'insert', NULL, 'inv_id: 35', '', NULL),
(40, 35, '2024-12-28 15:30:22', 'update', '1', '0', 'approved', NULL),
(41, 35, '2024-12-28 15:32:37', 'update', '0', NULL, 'approved', NULL),
(42, 35, '2024-12-28 15:32:41', 'update', NULL, '1', 'approved', NULL),
(43, 35, '2024-12-28 16:35:54', 'delete', 'inv_id: 35', NULL, '', NULL),
(44, 36, '2024-12-28 17:12:42', 'insert', NULL, 'inv_id: 36', '', NULL),
(45, 36, '2024-12-29 11:43:22', 'update', NULL, '1', 'approved', NULL),
(46, 36, '2024-12-29 11:43:27', 'update', '1', NULL, 'approved', NULL),
(47, 36, '2024-12-29 11:44:24', 'update', NULL, '1', 'approved', NULL),
(48, 36, '2024-12-29 11:48:43', 'delete', 'inv_id: 36', NULL, '', NULL),
(49, 37, '2024-12-29 11:49:31', 'insert', NULL, 'inv_id: 37', '', NULL),
(50, 37, '2024-12-29 11:49:57', 'update', NULL, '1', 'approved', NULL),
(51, 37, '2024-12-29 11:50:16', 'update', '1', NULL, 'approved', NULL),
(52, 37, '2024-12-29 12:08:33', 'delete', 'inv_id: 37', NULL, '', NULL),
(53, 38, '2024-12-29 12:15:52', 'insert', NULL, 'inv_id: 38', '', NULL),
(54, 38, '2024-12-29 12:25:24', 'update', NULL, '0', 'approved', NULL),
(56, 45, '2024-12-29 12:28:49', 'insert', NULL, 'inv_id: 45', '', NULL),
(57, 46, '2024-12-29 12:28:49', 'insert', NULL, 'inv_id: 46', '', NULL),
(58, 45, '2024-12-29 13:06:12', 'delete', 'inv_id: 45', NULL, '', NULL),
(59, 46, '2024-12-29 13:06:12', 'delete', 'inv_id: 46', NULL, '', NULL),
(60, 38, '2024-12-29 15:39:16', 'delete', 'inv_id: 38', NULL, '', NULL),
(62, 50, '2025-01-01 17:33:21', 'insert', NULL, 'inv_id: 50', '', NULL),
(63, 51, '2025-01-01 17:33:21', 'insert', NULL, 'inv_id: 51', '', NULL),
(64, 50, '2025-01-01 19:38:43', 'update', NULL, '0', 'approved', NULL),
(65, 51, '2025-01-01 19:38:55', 'update', NULL, '1', 'approved', NULL),
(66, 50, '2025-01-02 14:26:55', 'delete', 'inv_id: 50', NULL, '', NULL),
(67, 52, '2025-01-02 19:34:22', 'insert', NULL, 'inv_id: 52', '', NULL),
(68, 52, '2025-01-02 19:37:07', 'update', NULL, '0', 'approved', NULL),
(69, 52, '2025-01-02 19:49:41', 'delete', 'inv_id: 52', NULL, '', NULL),
(70, 53, '2025-01-02 19:50:51', 'insert', NULL, 'inv_id: 53', '', NULL),
(71, 53, '2025-01-02 19:50:59', 'update', NULL, '0', 'approved', NULL),
(72, 53, '2025-01-02 19:52:02', 'update', '0', NULL, 'approved', NULL),
(73, 53, '2025-01-02 19:52:32', 'update', NULL, '0', 'approved', NULL),
(74, 53, '2025-01-02 19:54:53', 'delete', 'inv_id: 53', NULL, '', NULL),
(75, 62, '2025-01-02 20:01:58', 'insert', NULL, 'inv_id: 62', '', NULL),
(76, 62, '2025-01-02 20:02:59', 'update', NULL, '0', 'approved', NULL),
(77, 62, '2025-01-02 20:19:57', 'delete', 'inv_id: 62', NULL, '', NULL),
(78, 63, '2025-01-03 14:49:35', 'insert', NULL, 'inv_id: 63', '', NULL),
(79, 63, '2025-01-03 14:49:51', 'update', NULL, '0', 'approved', NULL),
(80, 63, '2025-01-03 14:51:50', 'delete', 'inv_id: 63', NULL, '', NULL),
(81, 64, '2025-01-11 14:14:43', 'insert', NULL, 'inv_id: 64', '', NULL),
(82, 64, '2025-01-11 14:15:42', 'update', NULL, '0', 'approved', NULL),
(83, 64, '2025-01-11 14:15:53', 'update', '0', NULL, 'approved', NULL),
(84, 64, '2025-01-11 14:16:17', 'update', NULL, '1', 'approved', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `examination`
--

CREATE TABLE `examination` (
  `thesis_id` int(4) NOT NULL,
  `datetime` datetime NOT NULL,
  `place` varchar(100) NOT NULL,
  `mode` enum('online','in_person','','') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `examination`
--
DELIMITER $$
CREATE TRIGGER `reviewing_date` BEFORE INSERT ON `examination` FOR EACH ROW IF EXISTS( (SELECT * FROM thesis WHERE thesis_id = new.thesis_id AND state != 'reviewing')) THEN 
SIGNAL SQLSTATE '45000' 
SET MESSAGE_TEXT = 'EXAMINATION CANT BE ORGANISED BECAUSE THESIS WILL NOT BE REVIEWED';
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `professor`
--

CREATE TABLE `professor` (
  `professor_id` int(4) NOT NULL,
  `name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `topic` varchar(50) NOT NULL,
  `landline` varchar(20) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `department` varchar(50) NOT NULL,
  `university` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `professor`
--

INSERT INTO `professor` (`professor_id`, `name`, `surname`, `email`, `topic`, `landline`, `mobile`, `department`, `university`, `password`) VALUES
(0, 'Dimitrios', 'Tasis', 'dtassis@uoi.gr', 'Organic Chemistry', '2610123465', '6912345687', 'Chemistry', 'Ioannina', 'dtassis@uoi.gr'),
(1, 'Athanasios', 'Tasis', 'tasisinfo@gmail.com', 'Computer Science', '2610437281', '6947291783', 'Computer Science', 'University of Patras', 'thanos123'),
(2, 'Nikow', 'www', 'jnjnj', 'jnj', 'jnjnj', 'jnjn', 'jnjnj', 'jnjn', 'err'),
(3, 'Vagellis', 'Erft', 'njnjk', 'kjbnjkb ', 'kn jnk b', 'jkb k', 'jhbkjh', 'b khjb k', ''),
(7, 'Vasilis', 'Foukaras', 'vasfou@ceid.upatras.gr', 'Integrated Systems', '2610885511', '6988812345', 'CEID', 'University of Patras', 'vasfou@ceid.upatras.gr'),
(8, 'Basilis', 'Karras', 'karras@nterti.com', 'Artificial Intelligence', '23', '545', 'CEID', 'University of Patras', 'karras@nterti.com'),
(9, 'Eleni', 'Voyiatzaki', 'eleni@ceid.gr', 'WEB', '34', '245', 'CEID', 'University of Patras', 'eleni@ceid.gr'),
(10, 'Andrew', 'Hozier Byrne', 'hozier@ceid.upatras.gr', 'Artificial Intelligence', '2610170390', '6917031990', 'CEID', 'University of Patras', 'hozier@ceid.upatras.gr'),
(11, 'Nikos', 'Korobos', 'nikos.korobos12@gmail.com', 'Data Engineering', '2610324365', '6978530352', 'IT', 'University of Patras', 'nikos.korobos12@gmail.com'),
(12, 'Kostas', 'Karanikolos', 'kostkaranik@gmail.com', 'informatics', '2610324242', '6934539920', 'CEID', 'University of Patras', 'kostkaranik@gmail.com'),
(13, 'Mpampis', 'Sougias', 'mpampis123@gmail.com', 'Arxeologia', '2610945934', '6947845334', 'Arxeologias', 'UOI', 'mpampis123@gmail.com'),
(14, 'Daskalos', 'Makaveli', 'makavelibet@gmail.com', 'Business', '2310231023', '6929349285', 'Economics', 'UOA', 'makavelibet@gmail.com'),
(15, 'Maria', 'Palami', 'palam@upatras.gr', 'SQL injections', '1234567890', '6988223322', 'Engineering', 'University of SKG', 'palam@upatras.gr'),
(16, 'Meni', 'Talaiporimeni', 'meniT@upatras.gr', 't', '2610333999', '6999990999', 'CEID', 'UoP', 'meniT@upatras.gr'),
(17, 'Tzouli', 'Alexandratou', 'tzouli.ax@upatras.gr', 'Big Data', '2264587412', '6996116921', 'CEID', 'University of Patras', 'tzouli.ax@upatras.gr'),
(18, 'Karikhs', 'Raftel', 'karikhs@yahoo.gr', 'Pharmaceutical Drugs', '69', '6945258923', 'Chemistry', 'University of Streets', 'karikhs@yahoo.gr'),
(19, 'Vlasis', 'Restas', 'toxrusoftiari@funerals.gr', 'Nekro8aftiki', '78696910', '69696964', 'Nekro8aftikis', 'University Of Ohio', 'toxrusoftiari@funerals.gr'),
(20, 'Fat ', 'Banker', 'fatbanker@kapitalas.gr', 'kippah', '6942014121', '6969784205', 'Froutemporiki', 'University of Israel', 'fatbanker@kapitalas.gr'),
(21, 'Hamze', 'Mohamed', 'info@hamzat.gr', 'Logistics', '1245789513', '1456983270', 'Social Rehabitation', 'University of UAE', 'info@hamzat.gr'),
(22, 'Stefania', 'Nikolaou', 'snikolaou@upatras.gr', 'Information Theory', '2106723456', '6942323452', 'ECE', 'University of Patras', 'snikolaou@upatras.gr'),
(23, 'Petros', 'Danezis', 'pdanezis@upatras.gr', 'Telecommunication Electronics', '2610908888', '6971142424', 'ECE', 'University of Patras	', 'pdanezis@upatras.gr'),
(24, 'Papadopoulos ', 'Eustathios', 'eustratiospap@gmail.com', 'Physics', '210-1234567', '690-1234567', 'Physics', 'National and Kapodistrian University of Athens', 'eustratiospap@gmail.com'),
(25, 'Konstantinou', 'Maria', 'mariakon@gmail.com', 'Statistics and Probability', '2310-7654321', '694-7654321', 'Mathematics', 'Aristotle University of Thessaloniki', 'mariakon@gmail.com'),
(26, 'Jim', 'Nikolaou', 'jimnik@gmail.com', 'Artificial Intelligence', '2610-9876543', '697-9876543', 'Computer Science', 'University of Patras', 'jimnik@gmail.com'),
(27, 'Sophia', 'Michailidi', 'sophiamich@gmail.com', 'Economic Theory', '2310-5432109', '698-5432109', 'Economics', 'Athens University of Economics and Business', 'sophiamich@gmail.com'),
(28, 'Michael ', 'Papadreou', 'michaelpap@gmail.com', 'Renewable Energy Systems', '2610-4455667', '697-4455667', 'Electrical Engineering', 'University of Ioannina', 'michaelpap@gmail.com'),
(29, 'Elon', 'Musk', 'elonmusk@gmail.com', 'Electric Vehicles', '1-888-518-3752', 'Null', 'Department of Physics', 'University of Pennsylvania, Philadelphia', 'elonmusk@gmail.com'),
(30, 'Kostas', 'Kalantas', 'abcdef@example.com', 'AI', '2610121212', '6912121212', 'department', 'University', 'abcdef@example.com'),
(32, 'Giorgis', 'Fousekis', 'abcdefg@example.com', 'topic', 'land', 'mob', 'dep', 'university', 'abcdefg@example.com'),
(33, 'Nikos', 'Koukos', 'exxample@example.com', 'top', 'la', 'mo', 'de', 'university', 'exxample@example.com'),
(34, 'patrick', 'xrusopsaros', 'patric@xrusopsaros.com', 'thalasioi ipopotamoi', '2610567917', '6952852742', 'Solomos', 'Nemo', 'patric@xrusopsaros.com'),
(35, 'Paraskevas', 'koutsikos', 'paraskevas@kobres.ath', 'Provata', '2298042035', '6969696969', 'Ktinotrofia', 'University of Methana', 'paraskevas@kobres.ath'),
(37, 'Sotiris', 'Panaikas', 'spana@hotmail.com', 'Bet Predictions', '1235654899', '2310521010', 'opap', 'London', 'spana@hotmail.com'),
(38, 'Anitta', 'Wynn', 'anittamaxwynn@cashmoney.com', 'Probability', '2610486396', '698888884', 'Computer Engineering', 'University of Beegwean', 'anittamaxwynn@cashmoney.com');

-- --------------------------------------------------------

--
-- Table structure for table `secretary`
--

CREATE TABLE `secretary` (
  `id` int(4) NOT NULL,
  `name` varchar(50) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `landline` varchar(20) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `department` varchar(100) NOT NULL,
  `university` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `secretary`
--

INSERT INTO `secretary` (`id`, `name`, `surname`, `password`, `email`, `landline`, `mobile`, `department`, `university`) VALUES
(1, 'John', 'Doe', 'password123', 'john.doe@example.com', '2101234567', '6901234567', 'Computer Science', 'Athens University'),
(2, 'Jane', 'Smith', 'securePass99', 'jane.smith@example.com', '2109876543', '6909876543', 'Mathematics', 'Thessaloniki University'),
(3, 'Alice', 'Brown', 'alicePass01', 'alice.brown@example.com', '2101112233', '6901112233', 'Physics', 'Crete University'),
(4, 'Bob', 'Williams', 'bobTheGreat', 'bob.williams@example.com', '2103334455', '6903334455', 'Biology', 'Ioannina University'),
(5, 'Eve', 'Taylor', 'eveSecure00', 'eve.taylor@example.com', '2105556677', '6905556677', 'Chemistry', 'Patras University'),
(6, 'Charlie', 'Davis', 'charliePass2021', 'charlie.davis@example.com', '2109998887', '6909998887', 'Engineering', 'Volos University'),
(7, 'Sophia', 'Wilson', 'sophia987', 'sophia.wilson@example.com', '2104445566', '6904445566', 'Medicine', 'Larissa University'),
(8, 'Lucas', 'Moore', 'lucasStrong88', 'lucas.moore@example.com', '2107778899', '6907778899', 'Philosophy', 'Kavala University'),
(9, 'Mia', 'Taylor', 'miaSecret12', 'mia.taylor@example.com', '2102223344', '6902223344', 'Law', 'Athens University'),
(10, 'Ethan', 'Anderson', 'ethanPass45', 'ethan.anderson@example.com', '2106667788', '6906667788', 'Economics', 'Thessaloniki University');

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `student_id` int(4) UNSIGNED NOT NULL,
  `student_AM` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `street` varchar(100) NOT NULL,
  `number` int(5) UNSIGNED NOT NULL,
  `city` varchar(20) NOT NULL,
  `postcode` varchar(20) NOT NULL,
  `father_name` varchar(100) NOT NULL,
  `landline` varchar(20) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`student_id`, `student_AM`, `name`, `surname`, `street`, `number`, `city`, `postcode`, `father_name`, `landline`, `mobile`, `email`, `password`) VALUES
(3, 0, 'Giota', 'Nikolina', '', 0, '', '', '', '', '', 'giota@gmail.com', ''),
(1, 12345, 'Kostas', 'Theodosopoulos', 'Mantzarou', 16, '26442', '26442', 'Nikos', '1234567890', '1234567891', 'ss', 'root'),
(2, 14522, 'Thanaros', 'Tasaros', 'yo yo122', 2, 'patra', '26442', 'JIm', '261012345677', '6954781325', 'tasisinfo2@gmail.com', 'dsdd'),
(4, 242111, 'Georgios', 'Tasis', '', 0, '', '', '', '26104372812', '691558121354', 'wef@yahoo.com', 'ee21'),
(18, 10433999, 'Makis', 'Makopoulos', 'test street', 45, 'test city', '39955', 'Orestis', '2610333000', '6939096979', '104333999@students.upatras.gr', '104333999@students.upatras.gr'),
(19, 10434000, 'John', 'Lennon', 'Ermou', 18, 'Athens', '10431', 'George', '2610123456', '6970001112', 'st10434000@upnet.gr', 'st10434000@upnet.gr'),
(21, 10434002, 'test', 'name', 'str', 1, 'patra', '26222', 'father', '2610123456', '6912345678', 'st10434002@upnet.gr', 'st10434002@upnet.gr'),
(22, 10434003, 'Robert', 'Smith', 'Fascination', 17, 'London', '1989', 'Alex', '2610251989', '6902051989', 'st10434003@upnet.gr', 'st10434003@upnet.gr'),
(23, 10434004, 'Rex', 'Tyrannosaurus', 'Cretaceous', 2, 'Laramidia', '54321', 'Daspletosaurus', '2610432121', '6911231234', 'st10434004@upnet.gr', 'st10434004@upnet.gr'),
(24, 10434005, 'Paul', 'Mescal ', 'Smith Str.', 33, 'New York ', '59', 'Paul', '-', '-', 'st10434005@upnet.gr', 'st10434005@upnet.gr'),
(28, 10434009, 'Stevie', 'Nicks', 'Magic Str. ', 8, 'New Orleans', '35', 'Jess ', '56', '67', 'st10434009@upnet.gr', 'st10434009@upnet.gr'),
(29, 10434010, 'Margaret', 'Qualley', 'Substance Str.', 25, 'Los Angeles ', '7', 'Paul', '67', '90', 'st10434010@upnet.gr', 'st10434010@upnet.gr'),
(31, 10434012, 'Florence ', 'Pugh', 'Midsommar Str. l', 1, 'Away', '24', '-', '5', '2', 'st10434012@upnet.gr', 'st10434012@upnet.gr'),
(32, 10434013, 'PJ ', 'Harvey', 'Lonely Str.', 27, 'Bridport', '-7', 'Ray', '56', '43', 'st10434013@upnet.gr', 'st10434013@upnet.gr'),
(33, 10434014, 'Penélope', 'Cruz', 'Almadovar', 55, 'Madrid', '23', 'Eduardo ', '5', '4', 'st10434014@upnet.gr', 'st10434014@upnet.gr'),
(34, 10434015, 'Emma', 'Stone', 'Poor Str.', 3, 'Paris ', '34', 'none', '2333333', '4455555', 'st10434015@upnet.gr', 'st10434015@upnet.gr'),
(35, 10434016, 'Jenny', 'Vanou', 'Mpouat Str.', 23, 'Athens', '10', 'Basil', '09', '45', 'st10434016@upnet.gr', 'st10434016@upnet.gr'),
(36, 10434017, 'Salma ', 'Hayek', 'Desperado Str. ', 24, 'Madrid ', '656', 'Sami', '344', '221', 'st10434017@upnet.gr', 'st10434017@upnet.gr'),
(37, 10434018, 'Julie ', 'Delpy', 'Before Str.', 36, 'Paris', '567', 'Kieślowski', '1223', '3455', 'st10434018@upnet.gr', 'st10434018@upnet.gr'),
(39, 10434020, 'Eleutheria ', 'Arvanitaki', 'Entexno Str. ', 2, 'Athens', '345', 'Kosmos', '657', '345', 'st10434020@upnet.gr', 'st10434020@upnet.gr'),
(40, 10434021, 'Marina', 'Spanou', 'Pagkrati Str.', 25, 'Athens', '2456', 'Gates', '897', '354', 'st10434021@upnet.gr', 'st10434021@upnet.gr'),
(41, 10434022, 'Rena', 'Koumioti', 'Mpouat Str.', 24, 'Athens', '5749', 'Ellhniko', '23557', '32453', 'st10434022@upnet.gr', 'st10434022@upnet.gr'),
(42, 10434023, 'Charlotte', 'Aitchison', 'Boiler Room St', 365, 'New York', '360', 'Jon', '2610365365', '693653365', 'st10434023@upnet.gr', 'st10434023@upnet.gr'),
(43, 10434024, 'Rhaenyra', 'Targaryen', 'Dragon St', 2021, 'Kings Landing', '2021', 'Viserys', '2610101010', '6910101010', 'st10434024@upnet.gr', 'st10434024@upnet.gr'),
(44, 10434025, 'Ben', 'Dover', 'Colon Str.', 124, 'NY', '11045', 'Carlos', '2584694587', '5841852384', 'st10434025@upnet.gr', 'st10434025@upnet.gr'),
(45, 10434026, 'Marios', 'Papadakis', 'Korinthou', 266, 'Patras', '26223', 'Ioannis', '+302105562567', '+306975562567', 'st10434026@upnet.gr', 'st10434026@upnet.gr'),
(46, 10434027, 'Nicholas ', 'Hoult', 'Nosferatu Str.', 34, 'London', '567', 'Roger', '436', '46478', 'st10434027@upnet.gr', 'st10434027@upnet.gr'),
(47, 10434028, 'Joo Hyuk', 'Nam', 'Kanakari', 135, 'Patra', '26440', 'Baek Yi Jin', '2610443568', '6978756432', 'st10434028@upnet.gr', 'st10434028@upnet.gr'),
(48, 10434029, 'Nikos', 'Peletie', 'Kolokotroni', 6, 'Athens', '34754', 'George', '2104593844', '6987655433', 'st10434029@upnet.gr', 'st10434029@upnet.gr'),
(49, 10434030, 'Nikos', 'Koukos', 'Triton', 12, 'Salamina', '12216', 'Giannis', '210553985', '6946901012', 'st10434030@upnet.gr', 'st10434030@upnet.gr'),
(50, 10434031, 'Maria', 'Fouseki', 'Jason ', 33, 'London', '44391', 'Tasos', '2109993719', '6923144642', 'st10434031@upnet.gr', 'st10434031@upnet.gr'),
(51, 10434032, 'Nikos ', 'Korobos', 'Masalias', 4, 'Sparti', '32095', 'Giannis', '2279036758', '6948308576', 'st10434032@upnet.gr', 'st10434032@upnet.gr'),
(52, 10434033, 'Maria', 'Togia', 'Athinon', 4, 'Athens', '28482', 'Petros', '2100393022', '6953782102', 'st10434033@upnet.gr', 'st10434033@upnet.gr'),
(53, 10434034, 'Giorgos', 'Menegakis', 'korinthou', 56, 'patras', '56892', 'nikos', '2610485796', '6934527125', 'st10434034@upnet.gr', 'st10434034@upnet.gr'),
(54, 10434035, 'Trakis', 'Giannakopoulos', 'Othonos kai Amalias ', 100, 'Patras', '26500', 'None', '2610381393', '6028371830', 'st10434035@upnet.gr', 'st10434035@upnet.gr'),
(55, 10434036, 'Chris', 'Kouvadis', 'vanizelou', 36, 'Patras', '26500', 'Pfloutsou', '2610995999', '6947937524', 'st10434036@upnet.gr', 'st10434036@upnet.gr'),
(56, 10434037, 'pafloutsou', 'kaskarai', 'kolokotroni', 12, 'Patras', '26500', 'mauragkas', '2610978423', '6935729345', 'st10434037@upnet.gr', 'st10434037@upnet.gr'),
(58, 10434039, 'Tome', 'of Madness', 'Panepisthmiou', 69, 'Patras', '26441', 'Prafit', '2610654321', '6969966996', 'st10434039@upnet.gr', 'st10434039@upnet.gr'),
(59, 10434040, 'fort', 'nite', 'karaiskakis', 69, 'tilted tower', '4747', 'epic games', '2610747474', '6988112233', 'st10434040@upnet.gr', 'st10434040@upnet.gr'),
(60, 10434041, 'Zeus', 'Ikosaleptos', 'Novi', 25, 'Athens', '20033', 'Kleft', '2109090901', '6900008005', 'st10434041@upnet.gr', 'st10434041@upnet.gr'),
(61, 10434042, 'AG', 'Cook', 'Britpop', 7, 'London', '2021', 'PC Music', '2121212121', '1212121212', 'st10434042@upnet.gr', 'st10434042@upnet.gr'),
(62, 10434043, 'Maria', 'Mahmood', 'Mouratidi', 4, 'New York', '25486', 'Paparizou', '2108452666', '6980081351', 'st10434043@upnet.gr', 'st10434043@upnet.gr'),
(63, 10434044, 'Kostas', 'Poupis', 'Ag Kiriakis', 11, 'Papaou', '50501', 'Aelakis', '222609123', '698452154', 'st10434044@upnet.gr', 'st10434044@upnet.gr'),
(64, 10434045, 'Hugh', 'Jass', 'Wall Street', 69, 'Jerusalem', '478', 'Mike Oxlong', '69696969', '696969420', 'st10434045@upnet.gr', 'st10434045@upnet.gr'),
(65, 10434046, 'Xontro ', 'Pigouinaki', 'Krasopotirou', 69, 'Colarato', '14121', 'Adolf Heisenberg', '6913124205', '4747859625', 'st10434046@upnet.gr', 'st10434046@upnet.gr'),
(66, 10434047, 'Μaria', 'Nikolaou', 'Achilleos', 21, 'Athens', '10437', 'Dimitris', '2109278907', '6945533213', 'st10434047@upnet.gr', 'st10434047@upnet.gr'),
(67, 10434048, 'Eleni', 'Fotiou', 'Adrianou ', 65, 'Athens', '10556', 'Nikos', '2108745645', '6978989000', 'st10434048@upnet.gr', 'st10434048@upnet.gr'),
(68, 10434049, 'Xara', 'Fanouriou', 'Chaonias ', 54, 'Athens', '10441', 'Petros', '2108724324', '6945622222', 'st10434049@upnet.gr', 'st10434049@upnet.gr'),
(69, 10434050, 'Nikos', 'Panagiotou', 'Chomatianou', 32, 'Athens', '10439', 'Giorgos', '2107655555', '6941133333', 'st10434050@upnet.gr', 'st10434050@upnet.gr'),
(70, 10434051, 'Petros', 'Daidalos', 'Dafnidos', 4, 'Athens', '11364', 'Pavlos', '2108534566', '6976644333', 'st10434051@upnet.gr', 'st10434051@upnet.gr'),
(71, 10434052, 'Giannis', 'Ioannou', 'Danais', 9, 'Athens', '11631', 'Kostas', '2107644999', '6976565655', 'st10434052@upnet.gr', 'st10434052@upnet.gr'),
(72, 10434053, 'Tsili', 'Doghouse', 'novi lane', 33, 'Patras', '26478', 'Stoiximan', '2610420420', '6999999999', 'st10434053@upnet.gr', 'st10434053@upnet.gr'),
(73, 10434054, 'Marialena', 'Antoniou', 'Ermou', 24, 'Athens', '10563', 'Nikolaos', '210-5678901', '693-5678901', 'st10434054@upnet.gr', 'st10434054@upnet.gr'),
(74, 10434055, 'Ioannis', 'Panagiotou', 'Kyprou', 42, 'Patra', '26441', 'Kwstas', '2610-123456', '698-1234567', 'st10434055@upnet.gr', 'st10434055@upnet.gr'),
(75, 10434056, 'George', 'Karamalis', 'Kolokotroni', 10, 'Larissa', '41222', 'Petros', '2410-456790', '697-4567891', 'st10434056@upnet.gr', 'st10434056@upnet.gr'),
(76, 10434057, 'Kyriakos', 'Papapetrou', 'Zakunthou', 36, 'Volos', '10654', 'Apostolos', '210-6789012', '695-6789012', 'st10434057@upnet.gr', 'st10434057@upnet.gr'),
(77, 10434058, 'Maria', 'Kp', 'pelopidas ', 52, 'patra', '28746', 'george', '2610555555', '6932323232', 'st10434058@upnet.gr', 'st10434058@upnet.gr'),
(78, 10434059, 'Nikos', 'papadopoulos', 'anapafseos', 34, 'patra', '26503', 'takis', '2691045092', '69090909', 'st10434059@upnet.gr', 'st10434059@upnet.gr'),
(79, 10434060, 'Giannis ', 'Molotof', 'Ermou', 34, 'Patras', '29438', 'Giorgos', '2610254390', '6943126767', 'st10434060@upnet.gr', 'st10434060@upnet.gr'),
(80, 10434061, 'Sagdy', 'Znuts', 'Grove', 12, 'San Andreas', '123456', 'NULL', '123456789', '123456789', 'st10434061@upnet.gr', 'st10434061@upnet.gr'),
(81, 10434062, 'Mary', 'Poppins', 'Niktolouloudias ', 123, 'Chalkida', '23456', 'George', '2613456089', '6980987654', 'st10434062@upnet.gr', 'st10434062@upnet.gr'),
(82, 10434063, 'Tinker', 'Bell', 'Vatomourias', 55, 'Pano Raxoula', '2345', 'Mixail', '2456034567', '6987543343', 'st10434063@upnet.gr', 'st10434063@upnet.gr'),
(83, 10434064, 'Lilly', 'Bloom', 'Patnanasis', 45, 'Patra', '26440', 'Menelaos', '2610435988', '6987555433', 'st10434064@upnet.gr', 'st10434064@upnet.gr'),
(84, 10434065, 'GIORGOS', 'MASOURAS', 'AGIOU IOANNNI RENTI', 7, 'PEIRAIAS', '47200', 'PETROS', '694837204', '210583603', 'st10434065@upnet.gr', 'st10434065@upnet.gr'),
(85, 10434066, 'KENDRICK', 'NUNN', 'OAKA', 25, 'ATHENS', '666', 'GIANNAKOPOULOS', '6982736199', '6906443321', 'st10434066@upnet.gr', 'st10434066@upnet.gr'),
(86, 10434067, 'Depeche', 'Mode', 'Enjoy The Silence', 1990, 'London', '1990', 'Dave', '1234567890', '1234567770', 'st10434067@upnet.gr', 'st10434067@upnet.gr'),
(87, 10434068, 'name', 'surname', 'your', 69, 'mom', '15584', 'father', '222', '2223', 'st10434068@upnet.gr', 'st10434068@upnet.gr'),
(88, 10434069, 'Nikos', 'Kosmopoulos', 'Araksou', 12, 'Giotopoli', '69420', 'Greg', '210 9241993', '6978722312', 'st10434069@upnet.gr', 'st10434069@upnet.gr'),
(89, 10434070, 'Aris', 'Poupis', 'Mpofa', 10, 'Kolonia', '12345', 'Mpamias', '2105858858', '6935358553', 'st10434070@upnet.gr', 'st10434070@upnet.gr'),
(90, 10434071, 'gerry', 'banana', 'lootlake', 12, 'tilted', '26500', 'johnesy', '6947830287', '2610987632', 'st10434071@upnet.gr', 'st10434071@upnet.gr'),
(91, 10434072, 'grekotsi', 'parthenios', 'kokmotou', 69, 'thessaloniki', '20972', 'mourlo', '6947910234', '2610810763', 'st10434072@upnet.gr', 'st10434072@upnet.gr'),
(92, 10434073, 'Mochi', 'Mon', 'Novi', 55, 'Maxxwin', '99999', 'Drake', '2610550406', '6967486832', 'st10434073@upnet.gr', 'st10434073@upnet.gr'),
(93, 10434074, 'Nikolaos', 'Serraios', 'Papaflessa', 12, 'Patra', '26222', 'Georgios', '2610456632', '6975849305', 'st10434074@upnet.gr', 'st10434074@upnet.gr');

-- --------------------------------------------------------

--
-- Table structure for table `thesis`
--

CREATE TABLE `thesis` (
  `thesis_id` int(4) NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` varchar(300) NOT NULL,
  `presentation_path` varchar(100) NOT NULL,
  `prof_path` varchar(250) DEFAULT NULL,
  `state` enum('pending','active','reviewing','completed','cancelled') NOT NULL DEFAULT 'pending',
  `professor_id` int(4) NOT NULL,
  `student_id` int(4) UNSIGNED DEFAULT NULL,
  `grade1` decimal(4,2) DEFAULT NULL,
  `grade2` decimal(4,2) DEFAULT NULL,
  `grade3` decimal(4,2) DEFAULT NULL,
  `grade` decimal(4,2) DEFAULT NULL,
  `links` varchar(300) DEFAULT NULL,
  `member1_id` int(4) DEFAULT NULL,
  `member2_id` int(4) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `ap` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `thesis`
--

INSERT INTO `thesis` (`thesis_id`, `title`, `description`, `presentation_path`, `prof_path`, `state`, `professor_id`, `student_id`, `grade1`, `grade2`, `grade3`, `grade`, `links`, `member1_id`, `member2_id`, `text`, `ap`) VALUES
(33, 'test_insert', 'yo', '../uploads/thesis_pdf_33.pdf', NULL, 'reviewing', 17, 2, 40.00, NULL, NULL, NULL, NULL, 2, 3, NULL, 1575),
(55, 'Diplomatiki test', 'o foititis kanei auto k auto', '', NULL, 'reviewing', 17, 3, 20.00, NULL, NULL, NULL, NULL, 2, 3, NULL, 528),
(68, 'Undergraduate Student at UPatrtas', 'No description testttt.', 'uploads/thesis_pdf_68.pdf', '../uploads/thesis_pdf_68.pdf', 'cancelled', 17, 90, 80.00, NULL, NULL, NULL, 'dc', 0, NULL, NULL, 15152),
(70, 'AI Ethics ETC1', 'no disc123', '', NULL, 'reviewing', 10, 39, 90.00, NULL, NULL, NULL, NULL, 17, NULL, 'te', NULL),
(71, 'test 2nisis23', '2nisis desc', '', NULL, 'cancelled', 17, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(72, 'test jan 12', 'test jan12', '', '', 'pending', 17, NULL, 90.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

--
-- Triggers `thesis`
--
DELIMITER $$
CREATE TRIGGER `active_auto` BEFORE UPDATE ON `thesis` FOR EACH ROW IF (NEW.member1_id IS NOT NULL AND NEW.member2_id IS NOT NULL AND OLD.state = 'pending') THEN
        SET NEW.state = 'active';
END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `active_trigger` BEFORE UPDATE ON `thesis` FOR EACH ROW BEGIN
    IF (NEW.state <> 'reviewing') AND (COALESCE(OLD.grade, -1) <> COALESCE(NEW.grade, -1)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot change grade until your thesis is under review.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_ttle_dsc` BEFORE UPDATE ON `thesis` FOR EACH ROW IF (NEW.state <> 'pending') AND ((OLD.title <> NEW.title) OR (OLD.description <> NEW.description)) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot update title and description unless state is pending';
END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `cancel_inv` AFTER UPDATE ON `thesis` FOR EACH ROW IF (NEW.student_id IS NULL) THEN
DELETE FROM committee_invitations
WHERE thesis_id = NEW.thesis_id;
END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dont_delete_if_pending` BEFORE DELETE ON `thesis` FOR EACH ROW BEGIN
    -- Declare variables for storing the active state timestamp
    DECLARE active_date DATETIME;

    -- Get the most recent timestamp when the state was set to 'active'
    SELECT t.datetime
    INTO active_date
    FROM thesis_log t
    WHERE t.thesis_id = OLD.thesis_id
      AND t.field_of_change = 'state'
      AND t.new_value = 'active'
    ORDER BY t.datetime DESC
    LIMIT 1;

    -- Check the conditions for deletion
    IF OLD.state = 'active' AND TIMESTAMPDIFF(YEAR, active_date, NOW()) < 2 AND (@bypass_trigger IS NULL OR @bypass_trigger = 0) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete the thesis: Less than 2 years have passed since it became active';
    ELSEIF OLD.state <> 'pending' AND (active_date IS NULL OR TIMESTAMPDIFF(YEAR, active_date, NOW()) < 2) AND (@bypass_trigger IS NULL OR @bypass_trigger = 0) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete the thesis unless the state is pending or 2 years have passed since it became active';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `grade_avg` BEFORE INSERT ON `thesis` FOR EACH ROW SET NEW.grade = (NEW.grade1 + NEW.grade2 + NEW.grade3) / 3
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `grade_avg_update` BEFORE UPDATE ON `thesis` FOR EACH ROW SET NEW.grade = (NEW.grade1 + NEW.grade2 + NEW.grade3) / 3
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `mem1_not_mem2` BEFORE UPDATE ON `thesis` FOR EACH ROW IF (NEW.member1_ID = NEW.member2_ID) THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'MEMBER 1 HAS TO BE DIFFRENT THAN MEMBER2';

END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `stdntChange_while_active` BEFORE UPDATE ON `thesis` FOR EACH ROW IF OLD.state <> 'pending' && (OLD.student_id <> NEW.student_id OR NEW.student_id IS NULL ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot change student while thesis is active'; END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `thesis_delete_trigger` AFTER DELETE ON `thesis` FOR EACH ROW INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
    VALUES (OLD.thesis_id, NOW(), 'delete', CONCAT('Title: ', OLD.title), NULL, 'ALL')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `thesis_insert_trigger` AFTER INSERT ON `thesis` FOR EACH ROW BEGIN
    INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
    VALUES (NEW.thesis_id, NOW(), 'insert', NULL, CONCAT('Title: ', NEW.title), 'ALL');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `thesis_update_trigger` AFTER UPDATE ON `thesis` FOR EACH ROW BEGIN
    -- Check for title change
    IF COALESCE(OLD.title, '') <> COALESCE(NEW.title, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.title, NEW.title, 'title');
    END IF;

    -- Check for description change
    IF COALESCE(OLD.description, '') <> COALESCE(NEW.description, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.description, NEW.description, 'description');
    END IF;

    -- Check for presentation_path change
    IF COALESCE(OLD.presentation_path, '') <> COALESCE(NEW.presentation_path, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.presentation_path, NEW.presentation_path, 'presentation_path');
    END IF;

    -- Check for state change
    IF COALESCE(OLD.state, '') <> COALESCE(NEW.state, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.state, NEW.state, 'state');
    END IF;

    -- Check for professor_id change
    IF COALESCE(OLD.professor_id, '') <> COALESCE(NEW.professor_id, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.professor_id, NEW.professor_id, 'professor_id');
    END IF;

    -- Check for student_id change
    IF COALESCE(OLD.student_id, '') <> COALESCE(NEW.student_id, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.student_id, NEW.student_id, 'student_id');
    END IF;

    -- Check for grade1 change
    IF COALESCE(OLD.grade1, '') <> COALESCE(NEW.grade1, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.grade1, NEW.grade1, 'grade1');
    END IF;

    -- Check for grade2 change
    IF COALESCE(OLD.grade2, '') <> COALESCE(NEW.grade2, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.grade2, NEW.grade2, 'grade2');
    END IF;

    -- Check for grade3 change
    IF COALESCE(OLD.grade3, '') <> COALESCE(NEW.grade3, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.grade3, NEW.grade3, 'grade3');
    END IF;

    -- Check for grade change
    IF COALESCE(OLD.grade, '') <> COALESCE(NEW.grade, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.grade, NEW.grade, 'grade');
    END IF;

    -- Check for links change
    IF COALESCE(OLD.links, '') <> COALESCE(NEW.links, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.links, NEW.links, 'links');
    END IF;

    -- Check for member1_id change
    IF COALESCE(OLD.member1_id, '') <> COALESCE(NEW.member1_id, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.member1_id, NEW.member1_id, 'member1_id');
    END IF;

    -- Check for member2_id change
    IF COALESCE(OLD.member2_id, '') <> COALESCE(NEW.member2_id, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.member2_id, NEW.member2_id, 'member2_id');
    END IF;

    -- Check for text change
    IF COALESCE(OLD.text, '') <> COALESCE(NEW.text, '') THEN
        INSERT INTO thesis_log (thesis_id, datetime, action, old_value, new_value, field_of_change)
        VALUES (NEW.thesis_id, NOW(), 'update', OLD.text, NEW.text, 'text');
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `thesis_log`
--

CREATE TABLE `thesis_log` (
  `log_id` int(10) NOT NULL,
  `thesis_id` int(4) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `action` enum('insert','update','delete','') NOT NULL,
  `old_value` varchar(300) DEFAULT NULL,
  `new_value` varchar(300) DEFAULT NULL,
  `field_of_change` enum('title','description','presentation_path','state','student_id','grade1','grade2','grade','links','member1_id','member2_id','text','ALL','') NOT NULL,
  `comments` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `thesis_log`
--

INSERT INTO `thesis_log` (`log_id`, `thesis_id`, `datetime`, `action`, `old_value`, `new_value`, `field_of_change`, `comments`) VALUES
(1, 1, '2024-11-27 19:26:48', 'insert', NULL, 'Title: Test_thesis', 'ALL', NULL),
(2, 1, '2024-11-27 19:27:29', 'update', 'testing/........', 'testing/........f', 'description', NULL),
(5, 1, '2024-11-27 19:31:27', 'delete', 'Title: Test_thesis', NULL, 'ALL', NULL),
(6, 1, '2024-11-27 19:40:04', 'insert', NULL, 'Title: Test_thesis', 'ALL', NULL),
(7, 0, '2024-11-27 19:40:04', 'insert', NULL, 'Title: ', 'ALL', NULL),
(8, 0, '2024-11-27 19:40:15', 'delete', 'Title: ', NULL, 'ALL', NULL),
(9, 1, '2024-12-05 11:47:18', 'update', 'WW', '', 'presentation_path', NULL),
(10, 1, '2024-12-05 11:47:47', 'update', '', 'uploads/thesis_pdf_1.pdf', 'presentation_path', NULL),
(11, 0, '2024-12-05 13:41:58', 'insert', NULL, 'Title: idk', 'ALL', NULL),
(12, 0, '2024-12-05 13:45:20', 'delete', 'Title: idk', NULL, 'ALL', NULL),
(13, 1, '2024-12-05 13:45:20', 'delete', 'Title: Test_thesis', NULL, 'ALL', NULL),
(14, 1, '2024-12-05 13:45:42', 'insert', NULL, 'Title: ccsv', 'ALL', NULL),
(15, 2, '2024-12-05 13:45:57', 'insert', NULL, 'Title: Test_thesis', 'ALL', NULL),
(16, 3, '2024-12-05 13:46:15', 'insert', NULL, 'Title: qw211', 'ALL', NULL),
(17, 1, '2024-12-05 13:46:26', 'update', '', 'uploads/thesis_pdf_1.pdf', 'presentation_path', NULL),
(18, 2, '2024-12-05 13:46:50', 'update', '', 'uploads/thesis_pdf_2.pdf', 'presentation_path', NULL),
(19, 3, '2024-12-05 13:47:00', 'update', '', 'uploads/thesis_pdf_3.pdf', 'presentation_path', NULL),
(20, 2, '2024-12-09 13:12:22', 'update', 'uploads/thesis_pdf_2.pdf', '', 'presentation_path', NULL),
(21, 3, '2024-12-09 13:12:22', 'update', 'uploads/thesis_pdf_3.pdf', '', 'presentation_path', NULL),
(22, 1, '2024-12-09 13:13:53', 'update', 'uploads/thesis_pdf_1.pdf', '', 'presentation_path', NULL),
(23, 1, '2024-12-09 13:13:56', 'update', '', 'uploads/thesis_pdf_1.pdf', 'presentation_path', NULL),
(24, 2, '2024-12-09 13:14:59', 'update', '', 'uploads/thesis_pdf_2.pdf', 'presentation_path', NULL),
(25, 1, '2024-12-15 13:03:13', 'update', 'ccsv', 'ccs', 'title', NULL),
(26, 1, '2024-12-15 13:21:31', 'update', 'pending', '', 'state', NULL),
(27, 1, '2024-12-15 13:21:39', 'update', '', 'pending', 'state', NULL),
(28, 3, '2024-12-15 13:33:19', 'update', '', 'uploads/thesis_3.pdf', 'presentation_path', NULL),
(29, 1, '2024-12-15 16:43:54', 'update', '1', '2', 'student_id', NULL),
(30, 2, '2024-12-15 16:48:18', 'update', 'Test_thesis', 'Test_thesis123', 'title', NULL),
(31, 1, '2024-12-15 16:52:25', 'update', '2', '1', 'student_id', NULL),
(32, 1, '2024-12-15 16:55:04', 'delete', 'Title: ccs', NULL, 'ALL', NULL),
(33, 18, '2024-12-15 16:56:52', 'insert', NULL, 'Title: sdfv', 'ALL', NULL),
(34, 2, '2024-12-15 17:05:17', 'update', 'pending', 'active', 'state', NULL),
(35, 2, '2024-12-15 17:38:23', 'update', 'active', 'pending', 'state', NULL),
(36, 18, '2024-12-15 18:14:50', 'update', '', 'uploads/thesis_18.pdf', 'presentation_path', NULL),
(37, 1, '2024-12-15 18:22:24', 'update', 'uploads/thesis_18.pdf', 'uploads/thesis_1.pdf', 'presentation_path', NULL),
(38, 27, '2024-12-16 14:09:24', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(39, 28, '2024-12-16 14:10:04', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(40, 29, '2024-12-16 14:10:19', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(41, 27, '2024-12-16 14:10:34', 'update', '', 'uploads/thesis_pdf_27.pdf', 'presentation_path', NULL),
(42, 2, '2024-12-16 14:17:50', 'update', 'qwd', 'qwd1', 'description', NULL),
(43, 27, '2024-12-16 15:04:02', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(44, 28, '2024-12-16 15:04:02', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(45, 29, '2024-12-16 15:04:02', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(46, 1, '2024-12-16 15:12:45', 'update', 'sdfv', 'sd', 'title', NULL),
(47, 30, '2024-12-16 15:38:43', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(48, 30, '2024-12-16 15:41:03', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(49, 31, '2024-12-16 15:42:06', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(50, 1, '2024-12-18 12:06:19', 'update', 'sd', 'Psyxologia Sta paidia', 'title', NULL),
(51, 1, '2024-12-18 12:06:52', 'update', 'uploads/thesis_1.pdf', 'uploads/thesis_pdf_1.pdf', 'presentation_path', NULL),
(52, 32, '2024-12-18 12:07:13', 'insert', NULL, 'Title: Test_thesis', 'ALL', NULL),
(53, 1, '2024-12-18 12:09:57', 'update', 'pending', 'active', 'state', NULL),
(54, 1, '2024-12-18 12:38:52', 'update', '6.50', '6.67', 'grade', NULL),
(55, 2, '2024-12-18 12:40:49', 'update', 'qwd1', 'cwaenl ewl hciuewh wiec iulewh crui hc4ui qu iclhl3 f', 'description', NULL),
(56, 2, '2024-12-18 12:40:54', 'update', 'cwaenl ewl hciuewh wiec iulewh crui hc4ui qu iclhl3 f', 'yooo\'', 'description', NULL),
(57, 1, '2024-12-19 11:18:01', 'delete', 'Title: Psyxologia Sta paidia', NULL, 'ALL', NULL),
(58, 2, '2024-12-19 11:21:05', 'update', 'pending', 'active', 'state', NULL),
(59, 3, '2024-12-19 11:35:00', 'update', 'qwdqwdqw', 'qwdqwdqw111', 'description', NULL),
(60, 3, '2024-12-19 11:35:05', 'update', 'qwdqwdqw111', 'qwdqwdqw111sc', 'description', NULL),
(61, 3, '2024-12-19 12:33:39', 'delete', 'Title: qw211', NULL, 'ALL', NULL),
(62, 31, '2024-12-19 12:35:42', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(63, 33, '2024-12-19 12:36:01', 'insert', NULL, 'Title: test_insert', 'ALL', NULL),
(64, 34, '2024-12-19 12:37:40', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(65, 36, '2024-12-19 12:38:07', 'insert', NULL, 'Title: nigger', 'ALL', NULL),
(66, 36, '2024-12-19 12:38:11', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(67, 2, '2024-12-19 13:34:01', 'update', 'active', 'pending', 'state', NULL),
(68, 52, '2024-12-19 13:42:52', 'insert', NULL, 'Title: Undergraduate Student at UPatrtas', 'ALL', NULL),
(69, 52, '2024-12-19 13:43:34', 'update', 'Undergraduate Student at UPatrtas', 'Undergraduate Student at UPatrtasxd', 'title', NULL),
(70, 52, '2024-12-19 13:44:17', 'delete', 'Title: Undergraduate Student at UPatrtasxd', NULL, 'ALL', NULL),
(71, 53, '2024-12-20 12:50:49', 'insert', NULL, 'Title: Undergraduate Student at UPatrtas', 'ALL', NULL),
(72, 2, '2024-12-20 12:55:04', 'update', '2', '3', 'student_id', NULL),
(73, 2, '2024-12-20 12:55:06', 'update', '3', '2', 'student_id', NULL),
(74, 2, '2024-12-20 12:55:07', 'update', '2', '4', 'student_id', NULL),
(75, 2, '2024-12-20 12:55:10', 'update', '4', '3', 'student_id', NULL),
(76, 2, '2024-12-20 13:01:29', 'update', '3', '2', 'student_id', NULL),
(77, 2, '2024-12-20 13:04:04', 'update', '2', '3', 'student_id', NULL),
(78, 2, '2024-12-20 13:04:06', 'update', '3', '2', 'student_id', NULL),
(79, 2, '2024-12-20 13:05:34', 'update', '2', '3', 'student_id', NULL),
(80, 2, '2024-12-20 13:07:06', 'update', '3', '2', 'student_id', NULL),
(81, 53, '2024-12-20 13:11:02', 'delete', 'Title: Undergraduate Student at UPatrtas', NULL, 'ALL', NULL),
(82, 54, '2024-12-20 13:11:06', 'insert', NULL, 'Title: sax', 'ALL', NULL),
(83, 2, '2024-12-20 13:18:35', 'update', '2', '3', 'student_id', NULL),
(84, 2, '2024-12-20 13:24:22', 'update', '3', '2', 'student_id', NULL),
(85, 2, '2024-12-24 16:09:10', 'update', '2', '3', 'student_id', NULL),
(86, 2, '2024-12-24 16:09:13', 'update', '3', '2', 'student_id', NULL),
(87, 2, '2024-12-24 16:15:03', 'update', '2', '3', 'student_id', NULL),
(88, 2, '2024-12-24 16:19:13', 'update', '3', '2', 'student_id', NULL),
(89, 2, '2024-12-24 16:19:29', 'update', '2', '3', 'student_id', NULL),
(90, 54, '2024-12-24 16:19:43', 'delete', 'Title: sax', NULL, 'ALL', NULL),
(91, 2, '2024-12-24 16:24:14', 'update', '3', '2', 'student_id', NULL),
(92, 2, '2024-12-24 17:26:36', 'update', '2', '1', 'student_id', NULL),
(93, 2, '2024-12-24 17:26:55', 'update', '1', '2', 'student_id', NULL),
(94, 32, '2024-12-24 17:27:33', 'update', '', 'uploads/thesis_pdf_32.pdf', 'presentation_path', NULL),
(95, 34, '2024-12-24 17:27:47', 'delete', 'Title: nigger', NULL, 'ALL', NULL),
(96, 55, '2024-12-24 17:28:03', 'insert', NULL, 'Title: Diplomatiki test', 'ALL', NULL),
(97, 33, '2024-12-25 16:15:41', 'update', '2', '3', 'member1_id', NULL),
(98, 33, '2024-12-25 18:16:53', 'update', '2', '3', 'member2_id', NULL),
(99, 33, '2024-12-25 18:33:07', 'update', 'pending', 'active', 'state', NULL),
(100, 33, '2024-12-25 18:39:27', 'update', 'active', 'pending', 'state', NULL),
(101, 2, '2024-12-25 18:49:22', 'update', 'pending', 'active', 'state', NULL),
(102, 2, '2024-12-25 18:49:22', 'update', '1', '2', 'member2_id', NULL),
(103, 33, '2024-12-25 18:50:57', 'update', 'pending', 'active', 'state', NULL),
(104, 33, '2024-12-25 18:50:57', 'update', '3', '2', 'member2_id', NULL),
(105, 33, '2024-12-25 18:54:12', 'update', 'active', 'pending', 'state', NULL),
(106, 33, '2024-12-25 18:55:04', 'update', 'pending', 'active', 'state', NULL),
(107, 2, '2024-12-26 11:45:13', 'update', 'active', 'pending', 'state', NULL),
(108, 33, '2024-12-26 11:45:13', 'update', 'active', 'pending', 'state', NULL),
(109, 55, '2021-12-26 11:47:59', 'update', 'pending', 'active', 'state', NULL),
(110, 55, '2024-12-26 11:48:54', 'update', 'active', 'pending', 'state', NULL),
(111, 55, '2024-12-26 11:54:41', 'update', 'pending', 'active', 'state', NULL),
(112, 55, '2024-12-26 11:54:48', 'update', '1', '3', 'member2_id', NULL),
(113, 55, '2024-12-28 13:52:06', 'update', 'active', 'completed', 'state', NULL),
(114, 33, '2024-12-28 14:01:39', 'update', 'pending', 'active', 'state', NULL),
(115, 33, '2024-12-28 14:02:08', 'update', 'active', 'completed', 'state', NULL),
(116, 2, '2024-12-28 14:45:42', 'update', 'yooo\'', 'yooo\'q', 'description', NULL),
(117, 32, '2024-12-28 14:45:49', 'update', 'test', 'test1', 'description', NULL),
(118, 32, '2024-12-28 14:50:26', 'delete', 'Title: Test_thesis', NULL, 'ALL', NULL),
(119, 59, '2024-12-28 14:50:44', 'insert', NULL, 'Title: pop_up_test', 'ALL', NULL),
(120, 2, '2024-12-28 14:54:30', 'update', 'yooo\'q', 'yooo\'q1', 'description', NULL),
(121, 2, '2024-12-28 14:54:43', 'update', 'yooo\'q1', 'yooo\'q', 'description', NULL),
(122, 2, '2024-12-28 14:54:51', 'update', 'Test_thesis123', 'Test_thesis12', 'title', NULL),
(123, 2, '2024-12-28 16:26:45', 'update', 'Test_thesis12', 'Test_thesis123', 'title', NULL),
(124, 2, '2024-12-28 16:27:00', 'update', 'Test_thesis123', 'Test_thesis12', 'title', NULL),
(125, 33, '2024-12-29 11:47:56', 'update', '7.00', '8.00', 'grade1', NULL),
(126, 33, '2024-12-29 11:47:56', 'update', '3.00', '3.33', 'grade', NULL),
(127, 33, '2024-12-29 11:48:06', 'update', '8.00', '9.00', 'grade1', NULL),
(128, 33, '2024-12-29 11:48:06', 'update', '3.33', '3.67', 'grade', NULL),
(129, 2, '2024-12-29 11:48:17', 'update', 'Test_thesis12', 'Test_thesis123', 'title', NULL),
(130, 2, '2024-12-29 11:48:21', 'update', 'Test_thesis123', 'Test_thesis', 'title', NULL),
(131, 59, '2024-12-29 11:49:57', 'update', 'pending', 'active', 'state', NULL),
(132, 59, '2024-12-29 11:50:52', 'update', 'active', 'pending', 'state', NULL),
(133, 60, '2024-12-29 11:52:09', 'insert', NULL, 'Title: stavros test', 'ALL', NULL),
(134, 60, '2024-12-29 11:52:15', 'update', 'stavros test', 'stavros test123', 'title', NULL),
(135, 33, '2024-12-29 11:53:04', 'update', '9.00', '10.00', 'grade1', NULL),
(136, 33, '2024-12-29 11:53:04', 'update', '3.67', '4.00', 'grade', NULL),
(137, 33, '2024-12-29 11:53:12', 'update', '10.00', '5.00', 'grade1', NULL),
(138, 33, '2024-12-29 11:53:12', 'update', '4.00', '2.33', 'grade', NULL),
(139, 33, '2024-12-29 11:54:07', 'update', '', 'uploads/thesis_pdf_33.pdf', 'presentation_path', NULL),
(140, 59, '2024-12-29 12:03:10', 'update', '', 'uploads/thesis_pdf_59.pdf', 'presentation_path', NULL),
(141, 60, '2024-12-29 12:15:41', 'delete', 'Title: stavros test123', NULL, 'ALL', NULL),
(142, 2, '2024-12-29 15:39:33', 'update', 'yooo\'q', 'yooo', 'description', NULL),
(143, 59, '2024-12-29 16:00:23', 'update', 'sdcs', 'sdcssdcsdcsdcsd', 'text', NULL),
(144, 59, '2024-12-29 16:25:41', 'update', 'sdcssdcsdcsdcsd', 'test notes oyoooo\r\n', 'text', NULL),
(145, 33, '2024-12-29 16:25:47', 'update', '5.00', '12.00', 'grade1', NULL),
(146, 33, '2024-12-29 16:25:47', 'update', '2.33', '4.67', 'grade', NULL),
(147, 33, '2024-12-29 16:25:50', 'update', '12.00', '99.99', 'grade1', NULL),
(148, 33, '2024-12-29 16:25:50', 'update', '4.67', '34.00', 'grade', NULL),
(149, 55, '2021-12-29 17:10:42', 'update', 'completed', 'active', 'state', NULL),
(150, 59, '2024-12-29 17:13:14', 'delete', 'Title: pop_up_test', NULL, 'ALL', NULL),
(151, 61, '2024-12-29 17:52:44', 'insert', NULL, 'Title: pop_up_test', 'ALL', NULL),
(152, 2, '2024-12-29 18:30:16', 'update', 'pending', 'reviewing', 'state', NULL),
(153, 55, '2024-12-31 16:52:31', 'update', 'active', 'reviewing', 'state', NULL),
(154, 55, '2024-12-31 16:53:48', 'update', 'reviewing', 'active', 'state', NULL),
(155, 2, '2024-12-31 16:56:44', 'update', 'reviewing', 'pending', 'state', NULL),
(156, 61, '2024-12-31 16:57:03', 'update', '34', '28', 'student_id', NULL),
(157, 61, '2024-12-31 16:57:04', 'update', '28', '41', 'student_id', NULL),
(158, 55, '2024-12-31 16:57:41', 'update', 'active', 'reviewing', 'state', NULL),
(159, 2, '2025-01-01 16:51:32', 'update', '2', '17', '', NULL),
(160, 33, '2025-01-01 16:51:32', 'update', '2', '17', '', NULL),
(161, 55, '2025-01-01 16:51:32', 'update', '2', '17', '', NULL),
(162, 61, '2025-01-01 16:51:32', 'update', '2', '17', '', NULL),
(163, 61, '2025-01-01 17:05:18', 'delete', 'Title: pop_up_test', NULL, 'ALL', NULL),
(164, 62, '2025-01-01 17:06:52', 'insert', NULL, 'Title: Undergraduate Student at UPatrtas', 'ALL', NULL),
(165, 55, '2025-01-01 17:10:03', 'update', '7.00', '5.00', 'grade1', NULL),
(166, 55, '2025-01-01 17:10:03', 'update', '5.67', '5.00', 'grade', NULL),
(167, 55, '2025-01-01 17:10:07', 'update', '5.00', '51.00', 'grade1', NULL),
(168, 55, '2025-01-01 17:10:07', 'update', '5.00', '20.33', 'grade', NULL),
(169, 2, '2025-01-01 17:10:18', 'update', '13.00', '6.00', 'grade1', NULL),
(170, 2, '2025-01-01 17:10:21', 'update', '6.00', '12.00', 'grade1', NULL),
(171, 2, '2025-01-01 17:24:34', 'update', '5.00', '7.00', 'grade1', NULL),
(172, 2, '2025-01-01 17:24:38', 'update', '7.00', '9.00', 'grade1', NULL),
(173, 55, '2025-01-01 17:25:15', 'update', '51.00', '6.00', 'grade1', NULL),
(174, 55, '2025-01-01 17:25:15', 'update', '20.33', '5.33', 'grade', NULL),
(175, 2, '2025-01-01 17:25:20', 'update', '9.00', '90.00', 'grade1', NULL),
(176, 62, '2025-01-01 19:46:48', 'delete', 'Title: Undergraduate Student at UPatrtas', NULL, 'ALL', NULL),
(177, 63, '2025-01-01 19:47:57', 'insert', NULL, 'Title: Test_thesis', 'ALL', NULL),
(178, 63, '2025-01-01 19:48:06', 'delete', 'Title: Test_thesis', NULL, 'ALL', NULL),
(179, 64, '2025-01-01 19:49:38', 'insert', NULL, 'Title: asc', 'ALL', NULL),
(180, 64, '2025-01-01 19:49:41', 'delete', 'Title: asc', NULL, 'ALL', NULL),
(181, 65, '2025-01-01 19:49:49', 'insert', NULL, 'Title: asc', 'ALL', NULL),
(182, 65, '2025-01-01 19:49:56', 'delete', 'Title: asc', NULL, 'ALL', NULL),
(183, 66, '2025-01-01 19:55:17', 'insert', NULL, 'Title: asc', 'ALL', NULL),
(184, 66, '2025-01-01 19:55:23', 'delete', 'Title: asc', NULL, 'ALL', NULL),
(185, 67, '2025-01-01 19:55:58', 'insert', NULL, 'Title: adc', 'ALL', NULL),
(186, 67, '2025-01-01 19:56:02', 'delete', 'Title: adc', NULL, 'ALL', NULL),
(187, 68, '2025-01-01 19:59:23', 'insert', NULL, 'Title: Undergraduate Student at UPatrtas', 'ALL', NULL),
(188, 55, '2025-01-02 14:28:18', 'update', 'reviewing', 'active', 'state', NULL),
(189, 2, '2025-01-02 14:30:35', 'update', 'Test_thesis', 'Test_thesis1', 'title', NULL),
(190, 33, '2025-01-02 19:31:23', 'update', 'uploads/thesis_pdf_33.pdf', '../uploads/thesis_pdf_33.pdf', 'presentation_path', NULL),
(191, 33, '2025-01-02 19:31:23', 'update', 'completed', 'active', 'state', NULL),
(192, 2, '2025-01-02 19:31:32', 'update', 'uploads/thesis_pdf_2.pdf', '../uploads/thesis_pdf_2.pdf', 'presentation_path', NULL),
(193, 2, '2025-01-02 19:33:21', 'update', 'vjghvjgv', 'vjghvjgvadscs', 'text', NULL),
(194, 33, '2025-01-02 19:47:06', 'update', 'active', 'reviewing', 'state', NULL),
(195, 33, '2025-01-02 19:48:11', 'update', 'reviewing', 'active', 'state', NULL),
(196, 33, '2025-01-02 19:49:05', 'update', 'active', 'reviewing', 'state', NULL),
(197, 2, '2025-01-02 19:49:22', 'update', 'Test_thesis1', 'Test_thesis', 'title', NULL),
(198, 2, '2025-01-02 20:20:52', 'update', 'pending', 'active', 'state', NULL),
(199, 69, '2025-01-02 20:30:33', 'insert', NULL, 'Title: testinggg', 'ALL', NULL),
(200, 69, '2025-01-02 20:30:43', 'delete', 'Title: testinggg', NULL, 'ALL', NULL),
(201, 70, '2025-01-03 10:26:06', 'insert', NULL, 'Title: AI Ethics ETC', 'ALL', NULL),
(202, 70, '2025-01-03 10:30:55', 'update', 'No description.', 'No description.bawlchkjbedckwb cwhkeq vlce vhkjeb vjklerdwb qvcjkwbn v.ajklncv fedsjk.qbv kjaefdb vjnkhedfs b.avc.jnkhdrsfb vckjhbn cfvkjedwsrbn .qacfvakerdjnq;kjer4 n', 'description', NULL),
(203, 70, '2025-01-03 10:31:09', 'update', 'No description.bawlchkjbedckwb cwhkeq vlce vhkjeb vjklerdwb qvcjkwbn v.ajklncv fedsjk.qbv kjaefdb vjnkhedfs b.avc.jnkhdrsfb vckjhbn cfvkjedwsrbn .qacfvakerdjnq;kjer4 n', 'no disc', 'description', NULL),
(204, 68, '2025-01-03 11:11:43', 'update', 'nigger_descrrrrrrrrrr', '', 'description', NULL),
(205, 68, '2025-01-03 11:12:40', 'update', '', 'dsc', 'description', NULL),
(206, 68, '2025-01-03 11:12:54', 'update', 'dsc', 'No description testttt.', 'description', NULL),
(207, 70, '2025-01-03 11:27:09', 'update', 'AI Ethics ETC', 'AI Ethics ETC1', 'title', NULL),
(208, 2, '2025-01-03 14:45:35', 'update', 'vjghvjgvadscs', 'vjghvjgvadscsevs', 'text', NULL),
(209, 2, '2025-01-03 14:45:43', 'update', 'vjghvjgvadscsevs', 'test 1', 'text', NULL),
(210, 71, '2025-01-03 14:47:13', 'insert', NULL, 'Title: test 2nisis', 'ALL', NULL),
(211, 71, '2025-01-03 14:47:28', 'update', 'test 2nisis', 'test 2nisis23', 'title', NULL),
(212, 68, '2025-01-10 16:33:36', 'update', 'pending', 'active', 'state', NULL),
(213, 68, '2025-01-10 16:34:07', 'update', 'active', 'reviewing', 'state', NULL),
(214, 68, '2025-01-10 16:51:33', 'update', 'reviewing', 'pending', 'state', NULL),
(215, 68, '2025-01-10 16:51:45', 'update', '', '../uploads/thesis_pdf_68.pdf', 'presentation_path', NULL),
(216, 68, '2025-01-10 16:56:54', 'update', '../uploads/thesis_pdf_68.pdf', '', 'presentation_path', NULL),
(217, 68, '2025-01-10 17:17:38', 'update', 'pending', 'reviewing', 'state', NULL),
(218, 68, '2025-01-10 17:17:46', 'update', '', 'uploads/Notes.pdf', 'presentation_path', NULL),
(219, 68, '2025-01-10 17:18:18', 'update', 'uploads/Notes.pdf', 'uploads/ceidnotes_2002-2016.pdf', 'presentation_path', NULL),
(220, 68, '2025-01-10 17:19:08', 'update', 'uploads/ceidnotes_2002-2016.pdf', 'uploads/thesis_pdf_68.pdf', 'presentation_path', NULL),
(221, 2, '2025-01-10 18:07:49', 'delete', 'Title: Test_thesis', NULL, 'ALL', NULL),
(222, 68, '2025-01-10 19:00:38', 'update', 'reviewing', 'cancelled', 'state', NULL),
(223, 68, '2025-01-10 19:03:14', 'update', 'cancelled', 'active', 'state', NULL),
(224, 55, '2025-01-10 19:03:22', 'update', 'active', 'cancelled', 'state', NULL),
(225, 55, '2025-01-10 19:03:59', 'update', 'cancelled', 'active', 'state', NULL),
(226, 33, '2025-01-10 19:04:06', 'update', 'reviewing', 'cancelled', 'state', NULL),
(227, 55, '2025-01-10 19:04:32', 'update', 'active', 'cancelled', 'state', NULL),
(228, 55, '2025-01-10 19:05:20', 'update', 'cancelled', 'active', 'state', NULL),
(231, 55, '2025-01-10 19:06:23', 'update', 'active', 'cancelled', 'state', NULL),
(233, 68, '2025-01-10 19:10:02', 'update', 'active', 'cancelled', 'state', NULL),
(234, 33, '2025-01-10 19:10:27', 'update', 'cancelled', 'active', 'state', NULL),
(235, 55, '2025-01-10 19:10:27', 'update', 'cancelled', 'reviewing', 'state', NULL),
(236, 68, '2025-01-10 19:10:27', 'update', 'cancelled', 'active', 'state', NULL),
(237, 68, '2025-01-10 19:11:33', 'update', 'active', 'completed', 'state', NULL),
(238, 71, '2025-01-10 19:14:21', 'update', 'pending', 'cancelled', 'state', NULL),
(239, 70, '2025-01-11 12:11:13', 'update', 'no disc', 'no disc123', 'description', NULL),
(240, 70, '2025-01-01 12:41:26', 'update', 'pending', 'active', 'state', NULL),
(241, 33, '2025-01-11 14:07:26', 'update', 'active', 'reviewing', 'state', NULL),
(242, 68, '2025-01-11 14:13:18', 'update', 'completed', 'pending', 'state', NULL),
(243, 68, '2025-01-11 14:17:15', 'update', 'pending', 'cancelled', 'state', NULL),
(244, 68, '2025-01-11 14:26:47', 'update', '10.00', '0.00', 'grade1', NULL),
(245, 70, '2025-01-12 10:39:15', 'update', 'active', 'reviewing', 'state', NULL),
(246, 72, '2025-01-12 10:39:37', 'insert', NULL, 'Title: test jan 12', 'ALL', NULL),
(247, 70, '2025-01-12 10:46:21', 'update', NULL, '90.00', 'grade1', NULL),
(248, 72, '2025-01-12 10:58:19', 'update', '21', NULL, 'student_id', NULL),
(249, 33, '2025-01-12 10:58:25', 'update', '50.00', '40.00', 'grade1', NULL),
(250, 68, '2025-01-12 10:58:29', 'update', '0.00', '50.00', 'grade1', NULL),
(251, 68, '2025-01-12 11:00:48', 'update', '50.00', '90.00', 'grade1', NULL),
(252, 72, '2025-01-12 11:01:03', 'update', '30.00', '90.00', 'grade1', NULL),
(253, 68, '2025-01-12 11:06:08', 'update', '90.00', '80.00', 'grade1', NULL),
(254, 68, '2025-01-12 11:07:55', 'update', '80.00', '99.99', 'grade1', NULL),
(255, 68, '2025-01-12 11:08:00', 'update', '99.99', '80.00', 'grade1', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `anouncements`
--
ALTER TABLE `anouncements`
  ADD PRIMARY KEY (`anc_id`),
  ADD KEY `anc_id` (`anc_id`);

--
-- Indexes for table `committee_invitations`
--
ALTER TABLE `committee_invitations`
  ADD PRIMARY KEY (`inv_id`),
  ADD UNIQUE KEY `thesis_professor` (`thesis_id`,`professor_id`),
  ADD KEY `professor_id_to_professor` (`professor_id`);

--
-- Indexes for table `committee_log`
--
ALTER TABLE `committee_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `inv_id_to_invitations` (`inv_id`);

--
-- Indexes for table `examination`
--
ALTER TABLE `examination`
  ADD PRIMARY KEY (`thesis_id`);

--
-- Indexes for table `professor`
--
ALTER TABLE `professor`
  ADD PRIMARY KEY (`professor_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `mobile` (`mobile`);

--
-- Indexes for table `secretary`
--
ALTER TABLE `secretary`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `mobile` (`mobile`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`student_AM`),
  ADD UNIQUE KEY `student_id` (`student_id`),
  ADD UNIQUE KEY `mobile` (`mobile`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `thesis`
--
ALTER TABLE `thesis`
  ADD PRIMARY KEY (`thesis_id`),
  ADD UNIQUE KEY `professor_id` (`professor_id`,`student_id`),
  ADD KEY `member1_to_professor` (`member1_id`),
  ADD KEY `member2_to_professor` (`member2_id`),
  ADD KEY `thesis_to_student` (`student_id`),
  ADD KEY `thesis_id` (`thesis_id`);

--
-- Indexes for table `thesis_log`
--
ALTER TABLE `thesis_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `thesis_log_to_thesis` (`thesis_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `anouncements`
--
ALTER TABLE `anouncements`
  MODIFY `anc_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `committee_invitations`
--
ALTER TABLE `committee_invitations`
  MODIFY `inv_id` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `committee_log`
--
ALTER TABLE `committee_log`
  MODIFY `log_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `student`
--
ALTER TABLE `student`
  MODIFY `student_id` int(4) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `thesis`
--
ALTER TABLE `thesis`
  MODIFY `thesis_id` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT for table `thesis_log`
--
ALTER TABLE `thesis_log`
  MODIFY `log_id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=256;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `committee_invitations`
--
ALTER TABLE `committee_invitations`
  ADD CONSTRAINT `professor_id_to_professor` FOREIGN KEY (`professor_id`) REFERENCES `professor` (`professor_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `thesis_id_to_thesis` FOREIGN KEY (`thesis_id`) REFERENCES `thesis` (`thesis_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `examination`
--
ALTER TABLE `examination`
  ADD CONSTRAINT `thesis_id_to_thesis1` FOREIGN KEY (`thesis_id`) REFERENCES `thesis` (`thesis_id`);

--
-- Constraints for table `thesis`
--
ALTER TABLE `thesis`
  ADD CONSTRAINT `member1_to_professor` FOREIGN KEY (`member1_id`) REFERENCES `professor` (`professor_id`),
  ADD CONSTRAINT `member2_to_professor` FOREIGN KEY (`member2_id`) REFERENCES `professor` (`professor_id`),
  ADD CONSTRAINT `professor_AM_to_professor` FOREIGN KEY (`professor_id`) REFERENCES `professor` (`professor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `thesis_to_student` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE SET NULL ON UPDATE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
