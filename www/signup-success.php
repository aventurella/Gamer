<?php
require 'application/system/GMREnvironment.php'; 
GMRPage::Controller('DefaultController.php');
?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>GamePop : Create an Account</title>
	<link rel="stylesheet" href="/resources/css/gamepod.css" type="text/css" media="screen" charset="utf-8">
	<link rel="stylesheet" href="/resources/css/facebox.css" type="text/css" media="screen" charset="utf-8">
	<script type="text/javascript" charset="utf-8" src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
	<script type="text/javascript" charset="utf-8" src="/resources/js/libs/jquery/facebox.js"></script>
	<script type="text/javascript" charset="utf-8" src="/resources/js/utils/GMRDateTime.js"></script>
	<script type="text/javascript" charset="utf-8" src="/resources/js/gameDetailController.js"></script>
	<script type="text/javascript" charset="utf-8">
		var page = { "server": <?php echo $page->formErrors()?> };
	</script>
</head>
<body>
	<div id="window" >
		<!-- content -->
		<div class="content">
			<div class="content-top">
				<div class="content-mid">
					<div id="gamepod-details">
						<div id="header">
							<h1 class="appname">GamePop</h1>
							<h2 class="appsub">Multiplatform Game Scheduling</h2>
						</div>
						<div id="body" class="signup-success">
							<h1>Thanks for signing up!</h1>
							<p>In order to complete the signup process you must verify your account.</p>
							<p>It should be painless, just check the email account you just gave us for a verification email.</p>
							<p>Visit the url in that email. That's all there is to it.</p>
							<p class="special">*If you don't see the email in your inbox, be sure you look in your spam folder.</p>
						</div>
					</div>
				</div>
				<!-- /content-mid -->
			</div>
		</div>
		<!-- /content -->
	</div>
	<div id="errors">
		<h2>Oops</h2>
		<div class="message">
		</div>
	</div>
</body>
</html>
