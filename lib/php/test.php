<?php
session_start();
require 'GMRClient.php';
$aventurella = new GMRClient('a35dec05633be98c00ebc27a46f54365', 'aventurella');
$bpuglisi    = new GMRClient('a35dec05633be98c00ebc27a46f54365', 'bpuglisi');
$client      = new GMRClient('a35dec05633be98c00ebc27a46f54365');
?>

<h2>Create New Match, Owned By: <span style="color:#00cc00">aventurella</span></h2>
<pre>
<?php 

$date = new DateTime('now');
$players = array('psyduck', 'robofish'); // robofish is an invalid username, just testing to make sure it is not included.
$created_match_id =  $aventurella->matchCreate($date, 'halo-reach', GMRPlatform::kXbox360, 'private', 4, $players, 'extra information - optional');
echo $created_match_id;
?>
</pre>

<hr>

<h2><span style="color:#00cc00">bpuglisi</span> Join Match <?php echo $created_match_id ?></h2>
<pre>
<?php
	$result =  $bpuglisi->matchJoin(GMRPlatform::kXbox360, 'halo-reach', $created_match_id);
	echo $result ? 'Success' : 'Failed';
?>
</pre>

<hr>

<h2><span style="color:#00cc00">bpuglisi</span> Leave Match <?php echo $created_match_id ?></h2>
<pre>
<?php
	$result =  $bpuglisi->matchLeave(GMRPlatform::kXbox360, 'halo-reach', $created_match_id);
	echo $result ? 'Success' : 'Failed';
?>
</pre>

<hr>

<h2><span style="color:#00cc00">aventurella</span> Leave Match <?php echo $created_match_id ?> (should remove the match all together)</h2>
<pre>
<?php
	$result =  $aventurella->matchLeave(GMRPlatform::kXbox360, 'halo-reach', $created_match_id);
	echo $result ? 'Success' : 'Failed';
?>
</pre>

<hr>

<h2>Schedules Matched for bpuglisi</h2>
<pre>
	<?php print_r($bpuglisi->matchesForUser()); ?>
</pre>

<hr>
<h2>Search For Game "red" Within Platform Xbox 360</h2>
<pre>
	
	<?php print_r($client->searchPlatformForGames(GMRPlatform::kXbox360, "red"));?>
</pre>

<hr>

<h2>Games for XBox 360 <span style="color:#00cc00">Page 1</span></h2>

<pre>
	<?php print_r($client->gamesForPlatform(GMRPlatform::kXbox360));?>
</pre>
<hr>

<h2>Games for XBox 360 <span style="color:#00cc00">Page 2</span></h2>

<pre>
	<?php print_r($client->gamesForPlatform(GMRPlatform::kXbox360, "game/halo-reach"));?>
</pre>

<hr>

<h2>Scheduled Matches for XBox 360 Starting in the <span style="color:#00cc00">next 15 minutes</span></h2>
<pre>
	<?php print_r($client->scheduledMatchesForPlatformAndTimeframe(GMRPlatform::kXbox360, "15min"));?>
</pre>

<hr>

<h2>Scheduled Matches for PS3 Starting in the <span style="color:#00cc00">next hour</span></h2>
<pre>
	<?php print_r($client->scheduledMatchesForPlatformAndTimeframe(GMRPlatform::kPlaystation3, "hour"));?>
</pre>

<hr>

<h2>Scheduled Matches for Halo Reach on the XBox 360 Starting in the <span style="color:#00cc00">next 30 minutes</span></h2>
<pre>
	<?php print_r($client->scheduledMatchesForPlatformAndGameAndTimeframe(GMRPlatform::kXbox360, "halo-reach", "30min"));?>
</pre>

