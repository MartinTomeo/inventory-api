<?php

define('JWT_ALG', 'HS512');

$jwtKey = getenv('JWT_KEY');

if (!$jwtKey) {
    throw new RuntimeException('JWT_KEY is not configured');
}

define('JWT_KEY', $jwtKey);

define('JWT_EXP', 20);
define('REFRESH_TOKEN_EXP', 7 * 24 * 60 * 60);
define('REFRESH_COOKIE_NAME', 'refresh_token');
define('REFRESH_COOKIE_SECURE', true);