<?php
$steamid = (isset($_GET['steamid']) ? $_GET['steamid'] : null);
$regex = '/^STEAM_[0-5]:[01]:\d+$/';
if(!preg_match($regex, $steamid)) {
	echo 'Invalid Parameters';
	exit(1);
}

function getString( $steamid )
{
	$mysqli = new mysqli('localhost', 'gmod_dev', 'zKKZ8KSHCmx4Rzve', 'threekelvin');

	if ($mysqli->connect_error) {
		die('Connect Error (' . $mysqli->connect_errno . ') '
				. $mysqli->connect_error);
	}

	$query = "SELECT `captcha` FROM `terminal_setting` WHERE `steamid`='" . $steamid . "'";
	if ($result = $mysqli->query($query)) {
		$retstr = $result->fetch_object()->captcha;
		$result->close();
	}

	return $retstr;
}

$x_size = 200;
$y_size = 140;
$im = imagecreatetruecolor($x_size, $y_size);
$black = imagecolorallocate($im, 0, 0, 0);
$grey = imagecolorallocate($im, 127, 127, 127);
$white = imagecolorallocate($im, 255, 255, 255);

imagefilledrectangle($im, 0, 0, $x_size-1, $y_size-1, $white);

$font = '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf';
$fontsize = 40;
$angle = rand(-20, 20);
$captcha = getString($steamid);
$bbox = imagettfbbox($fontsize, $angle, $font, $captcha);
$bbox_width = $bbox[0] - $bbox[4];
$bbox_height = $bbox[1] - $bbox[5];

$x = $x_size/2 + $bbox_width/2;
$y = $y_size/2 + $bbox_height/2;

imagettftext($im, $fontsize, $angle, $x, $y, $black, $font, $captcha);

$hlines = 3;
$vlines = 5;
for ($i = 1; $i <= $hlines; $i++) {
	imageline($im, 0, rand(0, $y_size - 1), $x_size - 1, rand(0, $y_size - 1), $grey);
}
for ($i = 1; $i <= $vlines; $i++) {
	imageline($im, rand(0, $x_size - 1), 0, rand(0, $x_size - 1), $y_size - 1, $grey);
}

header('Content-Type: image/png');

imagepng($im);
imagedestroy($im);
?>