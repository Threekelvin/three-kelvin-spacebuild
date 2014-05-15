<html>
	<head>
		<style type="text/css">
		body{ background-color:#37393D; }
		
		* {
			text-align:left;
			font-family:"Classic Robot";
			font-size:18px;
			color:#FFFFFF;
		}
		
		.lightleft {
			background-color:#646464;
			text-align:left;
			padding-left:5px
		}
		.lightright {
			background-color:#646464;
			text-align:right;
			padding-right:5px
		}
		.darkleft {
			background-color:#969696;
			text-align:left;
			padding-left:5px
		}
		.darkright {
			background-color:#969696;
			text-align:right;
			padding-right:5px
		}
		</style>
	</head>
	
	<?php
		$mysql_host = "localhost";
		$mysql_database = "threekelvin";
		$mysql_user = "gmod_public";
		
		$con = mysql_connect($mysql_host, $mysql_user);
		if (!$con){
			die('Could not connect: ' . mysql_error());
		}
		
		mysql_select_db($mysql_database, $con);
		
		$result = mysql_query("SELECT nick_name, team, score, playtime FROM server_player_record, player_stats WHERE server_player_record.steamid = player_stats.steamid ORDER BY score DESC, playtime DESC LIMIT 20");
		
		function colorNamr($name, $faction){
			if($faction == 1){
				echo '<span style="color:#F4EEF4;">' . $name;
			}
			elseif($faction == 2){
				echo '<span style="color:#FAAF32;">' . $name;
			}
			elseif($faction == 3){
				echo '<span style="color:#4B4BEB;">' . $name;
			}
            elseif($faction == 4){
                echo '<span style="color:#afeb4b;">' . $name;
            }
            elseif($faction == 5){
                echo '<span style="color:#c84b4b;">' . $name;
            }
		}
		
		function pad($num){
			if($num < 10){
				return 0 . $num;
			}
			else{
				return $num;
			}
		}
		
		function formatTime($time){
			$days = floor($time / 1440);
			$hours = floor(($time - ($days * 1440)) / 60);
			$mins = floor(($time - ($days * 1440) - ($hours * 60)));
			
			if($days > 0){
				echo $days . " days " . pad($hours) . " hrs " . pad($mins) . " mins";
			}
			elseif($hours > 0){
				echo $hours . " hrs " . pad($mins) . " mins";
			}
			else{
				echo $mins . " mins";	
			}
		}
		
		echo "<table width='100%'>";
		
		$inc = 0;
		
		while($row = mysql_fetch_array($result)){
			$inc += 1;
			if($inc % 2 == 1){
				if($inc == 1){
					echo "<tr> <td class='darkleft'>" . pad($inc) . " ] </td> <td class='darkleft'>";
				}
				else{
					echo "<tr> <td class='darkleft'>" . pad($inc) . "] </td> <td class='darkleft'>";
				}
				colorNamr($row['nick_name'], $row['team']);
				echo "</td> <td class='darkright'>" . number_format($row['score']) . "</td> <td class='darkright'>";
				formatTime($row['playtime']);
				echo "</td> </tr>";
			}
			else{
				echo "<tr> <td class='lightleft'>" . pad($inc) . "] </td> <td class='lightleft'>";
				colorNamr($row['nick_name'], $row['team']);
				echo "</td> <td class='lightright'>" . number_format($row['score']) . "</td> <td class='lightright'>";
				formatTime($row['playtime']);
				echo "</td> </tr>";
			}
		}
		echo "</table>";

		mysql_close($con);
	?>
</html>