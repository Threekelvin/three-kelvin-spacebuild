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

function getSteamID64($steamid) {
	$steamid = explode(':', $_GET['steamid']);
	$V = 0x0110000100000000;
	//$X = substr($steamid[0], 6, 1);
	$Y = $steamid[1];
	$Z = $steamid[2];
	return $V + $Y + 2*$Z;
}

$steamid = $_GET['steamid'];
$steamid64 = getSteamID64($steamid);

$url = 'http://steamcommunity.com/profiles/' . $steamid64 . '?xml=1';
$profile = simplexml_load_file( $url );
if($profile) {
	$avatarURL = $profile->avatarMedium;
}
else
{
	$avatarURL = 'avatars/default_avatar.jpg';
}
$img = 'avatars/' . $steamid64 . '.jpg';
file_put_contents($img, file_get_contents($avatarURL));
chmod($img, 0664);
?>