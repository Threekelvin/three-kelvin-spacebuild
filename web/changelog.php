<?php
function getAvatarUri($name) {
	$name = strtolower($name);
	
	if ($name == "randomic") {
		$id = "STEAM_0:0:4832636";
	}
	elseif ($name == "ghost400") {
		$id = "STEAM_0:1:21860684";
	}
	elseif ($name == "techbot") {
		$id = "STEAM_0:1:18717664";
	}
	
	$steamid = explode(':', $id);
	$V = 0x0110000100000000;
	//$X = substr($steamid[0], 6, 1);
	$Y = $steamid[1];
	$Z = $steamid[2];
	$steamid64 = $V + $Y + 2*$Z;
	$uri = 'avatars/' . $steamid64 . '.jpg';
	if(!file_exists($uri)) {
		http_get('http://resource.threekelv.in/avatar.php?steamid=' . $id);
	}
	return $uri;
}

$top = "<html><head><style type='text/css'> html, body { background:#979797; } .entry { background:#c9c9c9; border-radius:5px; margin:5px; padding:5px; overflow:hidden; min-height:64px; font-family:Tahoma,Arial,sans-serif; } .avatar { float:right; } img { margin:0; } ul { margin:0; } </style><title>Changelog</title><meta http-equiv='Content-Type' content='text/html;charset=utf-8' /></head><body>";
$middle = "";
$bottom = "</body></html>";

$delim = '@@@@@@@@@@';
$lines = explode( PHP_EOL, shell_exec("git log --pretty=tformat:'%cd%n%cN%n%B" . $delim . "' -20 --no-merges --date=short") );
$commits = [];
for($i = 0; $i < count($lines)-1; $i++) {
	$date = trim($lines[$i]);
	if(!array_key_exists($date, $commits)) { $commits[$date] = []; }
	$i++;
	$user = trim($lines[$i]);
	if(!array_key_exists($user, $commits[$date])) { $commits[$date][$user] = []; }
	$i++;
	// Commit messages
	while($lines[$i] != $delim) {
		array_push($commits[$date][$user], trim($lines[$i]));
		$i++;
	}
}

foreach($commits as $date => $users) {
	$middle = $middle . "<div class='entry'><b>" . $date . "</b><br>";
	foreach($users as $user => $messages) {
		$middle = $middle . "<u>" . $user . "</u><div class='avatar'><img src='" . getAvatarUri($user) . "' width='64' height='64'/></div><br><ul>";
		foreach($messages as $message) {
			$middle = $middle . "<li>" . $message . "</li>";
		}
		$middle = $middle . "</ul>";
	}
	$middle = $middle . "</div>";
}

$data = $top . $middle . $bottom;
echo $data;
?>