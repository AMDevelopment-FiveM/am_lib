CREATE TABLE IF NOT EXISTS `am_vrp_characters` (
  `account_identifier` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `slot` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`account_identifier`, `user_id`),
  UNIQUE KEY `am_vrp_account_slot` (`account_identifier`, `slot`),
  KEY `am_vrp_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
