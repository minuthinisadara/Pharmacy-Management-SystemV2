-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 06, 2026 at 04:28 PM
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
-- Database: `pharmacy_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `description`) VALUES
(1, 'Tablets', 'Oral solid medicines in tablet form'),
(2, 'Capsules', 'Medicines supplied in capsule form'),
(3, 'Syrups', 'Liquid oral medicines'),
(4, 'First Aid', 'First aid and wound care products'),
(5, 'Vitamins', 'Vitamin and nutritional supplements'),
(6, 'Creams', 'Topical creams and ointments');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `customer_id` int(11) NOT NULL,
  `customer_name` varchar(150) NOT NULL,
  `phone_number` varchar(30) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`customer_id`, `customer_name`, `phone_number`, `address`) VALUES
(1, 'Kamal Perera', '0771234567', 'Galle, Sri Lanka'),
(2, 'Nadeesha Silva', '0712345678', 'Matara, Sri Lanka'),
(3, 'Tharindu Fernando', '0753456789', 'Hikkaduwa, Sri Lanka'),
(4, 'Sanduni Jayawardena', '0764567890', 'Unawatuna, Sri Lanka'),
(5, 'Ruwan Bandara', '0785678901', 'Ambalangoda, Sri Lanka'),
(6, 'Dilani Perera', '0706789012', 'Weligama, Sri Lanka');

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `invoice_id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment_method` enum('Cash','Card') NOT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `invoices`
--

INSERT INTO `invoices` (`invoice_id`, `customer_id`, `user_id`, `total_amount`, `payment_method`, `transaction_date`) VALUES
(1, 1, 2, 58.00, 'Cash', '2026-10-01 16:15:00'),
(2, 2, 2, 350.00, 'Card', '2026-10-01 17:30:00'),
(3, 3, 3, 80.00, 'Cash', '2026-10-02 18:20:00'),
(4, 4, 2, 540.00, 'Card', '2026-10-03 21:10:00'),
(5, 5, 3, 150.00, 'Cash', '2026-10-04 23:45:00'),
(6, 6, 2, 45.00, 'Cash', '2026-10-05 16:50:00'),
(7, NULL, 1, 90.00, 'Cash', '2026-10-06 12:38:35'),
(8, 1, 1, 10.00, 'Cash', '2026-10-06 13:39:13');

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

CREATE TABLE `invoice_items` (
  `item_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity_sold` int(11) NOT NULL,
  `unit_price_at_sale` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `invoice_items`
--

INSERT INTO `invoice_items` (`item_id`, `invoice_id`, `product_id`, `quantity_sold`, `unit_price_at_sale`, `subtotal`) VALUES
(1, 1, 1, 6, 5.00, 30.00),
(2, 1, 3, 2, 8.00, 16.00),
(3, 1, 6, 1, 12.00, 12.00),
(4, 2, 5, 1, 350.00, 350.00),
(5, 3, 1, 4, 5.00, 20.00),
(6, 3, 7, 4, 10.00, 40.00),
(7, 3, 9, 1, 20.00, 20.00),
(8, 4, 2, 2, 18.00, 36.00),
(9, 4, 4, 2, 12.00, 24.00),
(10, 4, 8, 1, 280.00, 280.00),
(11, 4, 12, 1, 200.00, 200.00),
(12, 5, 10, 1, 150.00, 150.00),
(13, 6, 6, 3, 15.00, 45.00),
(14, 7, 2, 5, 18.00, 90.00),
(15, 8, 1, 2, 5.00, 10.00);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `product_code` varchar(50) NOT NULL,
  `product_name` varchar(150) NOT NULL,
  `category_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `reorder_level` int(11) NOT NULL DEFAULT 10,
  `expiry_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `product_code`, `product_name`, `category_id`, `supplier_id`, `unit_price`, `cost_price`, `stock_quantity`, `reorder_level`, `expiry_date`) VALUES
(1, 'MED001', 'Paracetamol 500mg', 1, 1, 5.00, 3.00, 248, 50, '2028-06-30'),
(2, 'MED002', 'Amoxicillin 500mg', 2, 2, 18.00, 12.00, 3, 30, '2027-11-30'),
(3, 'MED003', 'Cetirizine 10mg', 1, 1, 8.00, 5.00, 180, 40, '2028-03-31'),
(4, 'MED004', 'Omeprazole 20mg', 2, 3, 12.00, 8.00, 20, 30, '2027-09-30'),
(5, 'MED005', 'Cough Syrup 100mll', 3, 2, 350.00, 250.00, 45, 10, '2027-08-31'),
(6, 'MED006', 'Vitamin C 500mg', 5, 4, 15.00, 10.00, 200, 40, '2028-01-31'),
(7, 'MED007', 'Ibuprofen 400mg', 1, 3, 10.00, 6.50, 100, 25, '2027-12-31'),
(8, 'MED008', 'Antiseptic Cream 20g', 6, 5, 280.00, 190.00, 10, 15, '2028-05-31'),
(9, 'MED009', 'ORS Sachet', 1, 4, 40.00, 25.00, 90, 20, '2027-10-31'),
(10, 'MED010', 'Bandage Roll', 4, 5, 150.00, 100.00, 35, 10, '2029-01-31'),
(11, 'MED011', 'Multivitamin Tablets', 5, 4, 25.00, 17.00, 140, 30, '2028-04-30'),
(12, 'MED012', 'Antifungal Cream 15g', 6, 2, 320.00, 220.00, 55, 15, '2027-07-31');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`) VALUES
(1, 'Admin'),
(2, 'cashier');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `supplier_id` int(11) NOT NULL,
  `company_name` varchar(150) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `phone_number` varchar(30) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`supplier_id`, `company_name`, `contact_person`, `phone_number`, `email`) VALUES
(1, 'Ceylon Pharma Distributors', 'Nuwan Silva', '0112345678', 'sales@ceylonpharma.lk'),
(2, 'HealthCare Pharmaceuticals', 'Tharindu Perera', '0112456789', 'info@healthcarepharma.lk'),
(3, 'Lanka Medical Supplies', 'Amal Fernando', '0112567890', 'sales@lankamedical.lk'),
(4, 'MediLife Distributors', 'Sahan Jayasinghe', '0112678901', 'orders@medilife.lk'),
(5, 'ABC Pharmaceutical Suppliers', 'Ruwan Kumar', '0112789012', 'info@abcpharma.lk');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `role_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `full_name`, `role_id`) VALUES
(1, 'admin', 'admin123', 'System Administrator', 1),
(2, 'cashier1', 'cashier123', 'Nimali Perera', 2),
(3, 'cashier2', 'cashier234', 'Kasun Fernando', 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `category_name` (`category_name`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customer_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`invoice_id`),
  ADD KEY `fk_invoices_customer` (`customer_id`),
  ADD KEY `fk_invoices_user` (`user_id`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `fk_invoice_items_invoice` (`invoice_id`),
  ADD KEY `fk_invoice_items_product` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD UNIQUE KEY `product_code` (`product_code`),
  ADD KEY `fk_products_category` (`category_id`),
  ADD KEY `fk_products_supplier` (`supplier_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `role_name` (`role_name`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`supplier_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `fk_users_role` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `invoice_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `invoice_items`
--
ALTER TABLE `invoice_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `supplier_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `fk_invoices_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_invoices_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- Constraints for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD CONSTRAINT `fk_invoice_items_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_invoice_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
