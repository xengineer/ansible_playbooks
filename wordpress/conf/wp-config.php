<?php
define('DB_NAME', 'mywp_db');
define('DB_USER', 'wp-user');
define('DB_PASSWORD', '');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'xrS0|~E/9$3>)g1aN}Z^LHzs3;`gu|I*309Nbdj&w$$3[/7]/%|Q@VwCK+4j+G,]');
define('SECURE_AUTH_KEY',  'T3-!c7U_zx0sV-0OMM1uUAPMNsTGFu?7u> <JAPZ)|+4!<d/O=vwrqImqKn*|{F6');
define('LOGGED_IN_KEY',    'MP2}[;N2QsR~~x-Gz<NDw]p.Kew&GW|-Z:jiI^?AHM+9![{&:i|FII<p1o4Y$}p@');
define('NONCE_KEY',        'XMnVgR8rf8No-qs&%/Y.mR4K+2-]/UfI T.kd@B-=}~=!,@{.!y8:7Zu,!@AwI<I');
define('AUTH_SALT',        '@t?6-CX,~Rmt}op_q6(k#|aFDU^}-.E~~_!.furA F[aWGJrs-VKnbmY+i#CVs%8');
define('SECURE_AUTH_SALT', '?Z+qzR:N7[|+C/ M~Y83`ONAb{LGAzb/?@7tb@h-@.-kMzf(AbI=D~*`2Y>-*QR~');
define('LOGGED_IN_SALT',   '&yKToiE]J9!m{6|0p_lCWky=Eb*o.G|-4,pAD;+Vw)Q]~Z;Q_d}BJ$pRAOgESR,p');
define('NONCE_SALT',       'FJ8(?y0-|O`b( V8bsM^k-3Z-G-ys0}e yF%g8ic#xCb]:Ei*{t0ZzDtMoH>a 7L');

$table_prefix  = 'mywp_';
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
