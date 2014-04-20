<?php
if (getenv('SERVER_ADDR') !== getenv('REMOTE_ADDR')) {
	http_response_code(403);
	exit;
}

$steamid = (isset($_GET['steamid']) ? $_GET['steamid'] : null);
$regex = '/^STEAM_[0-5]:[01]:\d+$/';
if(!preg_match($regex, $steamid)) {
	http_response_code(400);
	exit;
}

$steamid = explode(':', $_GET['steamid']);
$Z = $steamid[2];
$V = 76561197960265728;
$Y = $steamid[1];
$steamid64 = 2*$Z + $V + $Y;

$url = 'http://steamcommunity.com/profiles/' . $steamid64 . '?xml=1';
$profile = simplexml_load_file( $url );
$avatar = $profile->avatarMedium;
echo $avatar;
header('Location: ' . $avatar);
?>
