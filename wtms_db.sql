-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 20, 2025 at 05:17 PM
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
-- Database: `wtms_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_submissions`
--

CREATE TABLE `tbl_submissions` (
  `id` int(11) NOT NULL,
  `work_id` int(11) NOT NULL,
  `worker_id` int(11) NOT NULL,
  `submission_text` text NOT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_submissions`
--

INSERT INTO `tbl_submissions` (`id`, `work_id`, `worker_id`, `submission_text`, `submitted_at`) VALUES
(2, 1, 1, 'Test', '2025-06-20 14:44:54'),
(4, 6, 1, 'Done', '2025-06-20 19:52:36'),
(5, 2, 2, 'Done after due date was given', '2025-06-20 21:19:09'),
(6, 7, 2, 'Done on 20th June 2025 (overdue)', '2025-06-20 22:33:20');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `worker_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text NOT NULL,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`worker_id`, `full_name`, `email`, `password`, `phone`, `address`, `image`) VALUES
(1, 'Najihah Husain', 'najihah@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0133537889', 'Ipoh', 'assets/images/profiles/1.png'),
(2, 'Amira', 'meerakawaii@gmail.com', '6367c48dd193d56ea7b0baad25b19455e529f5ee', '0134980308', 'Ipoh Perak', 'assets/images/profiles/2.png');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_works`
--

CREATE TABLE `tbl_works` (
  `work_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `date_assigned` date NOT NULL,
  `due_date` date NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_works`
--

INSERT INTO `tbl_works` (`work_id`, `title`, `description`, `assigned_to`, `date_assigned`, `due_date`, `status`) VALUES
(1, 'Prepare Material A', 'Prepare raw material A for assembly.', 1, '2025-05-25', '2025-05-28', 'success'),
(2, 'Inspect Machine X', 'Conduct inspection for machine X.', 2, '2025-05-25', '2025-05-29', 'success'),
(3, 'Clean Area B', 'Deep clean work area B before audit.', 3, '2025-05-25', '2025-05-30', 'pending'),
(4, 'Test Circuit Board', 'Perform unit test for circuit batch 4.', 4, '2025-05-25', '2025-05-28', 'pending'),
(5, 'Document Process', 'Write SOP for packaging unit.', 5, '2025-05-25', '2025-05-29', 'pending'),
(6, 'Paint Booth Check', 'Routine check on painting booth.', 1, '2025-05-25', '2025-05-30', 'success'),
(7, 'Label Inventory', 'Label all boxes in section C.', 2, '2025-05-25', '2025-05-28', 'success'),
(8, 'Update Database', 'Update inventory in MySQL system.', 3, '2025-05-25', '2025-05-29', 'pending'),
(9, 'Maintain Equipment', 'Oil and tune cutting machine.', 4, '2025-05-25', '2025-05-30', 'pending'),
(10, 'Prepare Report', 'Prepare monthly performance report.', 5, '2025-05-25', '2025-05-30', 'pending');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_submissions`
--
ALTER TABLE `tbl_submissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`worker_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `tbl_works`
--
ALTER TABLE `tbl_works`
  ADD PRIMARY KEY (`work_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_submissions`
--
ALTER TABLE `tbl_submissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `worker_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tbl_works`
--
ALTER TABLE `tbl_works`
  MODIFY `work_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
