/* 31-01-2023 */

CREATE TABLE `vehicles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'all,city_wise',
  `size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city_ids` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacity` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `orders` ADD `vehicle_id` bigint unsigned DEFAULT NULL AFTER `total_parcel`, ADD `vehicle_data` json DEFAULT NULL AFTER `vehicle_id`; 

ALTER TABLE `app_settings` ADD `is_vehicle_in_order` TINYINT NULL DEFAULT '0' AFTER `currency_position`;

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (NULL, '2023_01_30_121805_create_vehicles_table', '7'), (NULL, '2023_01_30_131633_add_is_vehicle_in_order_in_app_settings_table', '7'), (NULL, '2023_01_30_132224_add_vehicle_data_in_orders_table', '7');

/* noting to import */