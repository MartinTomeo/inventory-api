<?php

define('JWT_ALG', 'HS512');
$key = getenv('JWT_KEY');

if ($key === false || $key === '') {
    throw new RuntimeException('JWT_KEY is not configured');
}

define('JWT_KEY', $key);
define('JWT_EXP', 3600);