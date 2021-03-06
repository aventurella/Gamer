require.paths.unshift("/usr/local/lib/node");

var couchdb     = require('./libs/node-couchdb/lib/couchdb'),
	environment = require('./system/environment'),
	client      = couchdb.createClient(environment.database.port, environment.database.host),
	db          = client.db(environment.database.catalog),
	sys         = require('sys'),
	fs          = require('fs'),
	spawn       = require('child_process').spawn,
	Game        = require('./data/game'),
	MySql       = require('mysql').Client;


var mysqlAdminUsername = null;
var mysqlAdminPassword = null;

var colors = {
	  reset: "\x1B[0m",

	  grey:    "\x1B[0;30m",
	  red:     "\x1B[0;31m",
	  green:   "\x1B[0;32m",
	  yellow:  "\x1B[0;33m",
	  blue:    "\x1B[0;34m",
	  magenta: "\x1B[0;35m",
	  cyan:    "\x1B[0;36m",
	  white:   "\x1B[0;37m",
	
	bold: {
	    grey:    "\x1B[1;30m",
	    red:     "\x1B[1;31m",
	    green:   "\x1B[1;32m",
	    yellow:  "\x1B[1;33m",
	    blue:    "\x1B[1;34m",
	    magenta: "\x1B[1;35m",
	    cyan:    "\x1B[1;36m",
	    white:   "\x1B[1;37m",
	  }
	}

var logging = {
	error: colors.red + "[Error]" + colors.reset + " ",
	success : colors.green + "[Success]" + colors.reset + " ",
	warn : colors.yellow + "[Warn]" + colors.reset + " ",
}

function prompt(question, callback)
{
	// https://github.com/jesusabdullah/node-prompt/blob/master/prompt.js
	// quiet mode is available there too.
	
	var p = process.openStdin();
	p.setEncoding('utf8');
	
	console.log(question);
	
	p.on('data', function(line) 
	{
		p.removeAllListeners('data');
		callback(line);
		
		if (p.listeners('data').length === 0) 
		{
			p.destroy();
		}
	});
}

function install()
{
	console.log(colors.magenta + 'Installing GamePop' + colors.reset);
	
	prompt("Install type: [games, full]", function(choice)
	{
		
		choice = choice.trim().toLowerCase();
		
		if(choice == 'games')
		{
			initializeGames(installComplete);
		}
		else if(choice == 'full')
		{
			prompt("Administrative MySQL Username:", function(username)
			{
				mysqlAdminUsername = username.trim();
		
				prompt("Administrative MySQL Password:", function(password)
				{
					mysqlAdminPassword = password.trim();
					setup();
				});
			})
		}
		else
		{
			console.log("Unknown Choice. Terminating");
			process.exit(0);
		}
	});
}

function setup()
{
	initializeCouchDB(function()
	{
		initializeMySQL(function()
		{
			initializeSystemUsers(function()
			{
				initializeGames(installComplete);
			});
		});
	});
}

function initializeCouchDB(next)
{
	console.log(colors.magenta + 'Initializing CouchDB');
	db.remove();
	db.create();
	
	var couchapp = spawn('couchapp', ['push', './couchapp', environment.database.catalog]);

	couchapp.on('exit', function (code) 
	{
		if (code !== 0) 
		{
			console.log(logging.error + 'couchapp push failed ' + code );
		}
		else
		{
			console.log(logging.success + 'couchapp push complete');
			next();
		}
	});
}

function initializeMySQL(next)
{
	console.log(colors.magenta + 'Initializing MySQL');
	
	var db      = new MySql();
	db.user     = mysqlAdminUsername;
	db.password = mysqlAdminPassword; //GalaxyFoundryqc0LTh7
	db.connect();
	
	console.log(colors.magenta + 'Creating Catalog ' + environment.mysql.catalog);
	
	db.query('CREATE DATABASE '+environment.mysql.catalog, function(err) 
	{
		if (err && err.number != MySQL.ERROR_DB_CREATE_EXISTS) 
		{
			console.log(logging.error + 'Unable to create MySQL Catalog ' + environment.mysql.catalog);
		}
		else
		{
			console.log(colors.magenta + 'Creating Database Tables');
			
			db.query('USE '+ environment.mysql.catalog);
			db.query('SET NAMES utf8;');
			//db.query('SET FOREIGN_KEY_CHECKS = 0;');
			db.query('DROP TABLE IF EXISTS `user`;');
			db.query('DROP TABLE IF EXISTS `user_alias`;');
			db.query('DROP TABLE IF EXISTS `user_verification`;');
			
			db.query('CREATE TABLE `user` ('+
				  '`id` int(11) unsigned NOT NULL AUTO_INCREMENT,'+
				  '`username` varchar(100) NOT NULL,'+
				  '`email` varchar(255) NOT NULL,'+
				  '`password` char(64) NOT NULL,'+
				  '`token` char(32) NOT NULL,'+
				  '`active` int(1) NOT NULL,'+
				  '`created_on` char(24) NOT NULL,'+
				  'PRIMARY KEY (`id`),'+
				  'UNIQUE KEY `email_index` (`email`),'+
				  'UNIQUE KEY `username_index` (`username`),'+
				  'UNIQUE KEY `email+username_index` (`username`,`email`)'+
				') ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;',
			function(err){
				if(!err) console.log(logging.success + "user table created");
			});
			
			db.query('CREATE TABLE `user_alias` ('+
			  '`id` int(11) unsigned NOT NULL AUTO_INCREMENT,'+
			  '`user_id` int(11) NOT NULL,'+
			  '`platform` varchar(24) NOT NULL,'+
			  '`alias` varchar(75) NOT NULL,'+
			  'PRIMARY KEY (`id`),'+
			  'UNIQUE KEY `alias_platform_index` (`platform`,`alias`),'+
			  'UNIQUE KEY `alias_index` (`user_id`,`platform`) USING BTREE'+
			') ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;',
			function(err){
				if(!err) console.log(logging.success + "user_alias table created");
			});
			
			db.query('CREATE TABLE `user_verification` ('+
			  '`id` int(11) unsigned NOT NULL AUTO_INCREMENT,'+
			  '`user_id` int(11) NOT NULL,'+
			  '`token` char(32) NOT NULL,'+
			  '`created_on` char(24) NOT NULL,'+
			  'PRIMARY KEY (`id`),'+
			  'UNIQUE KEY `token_index` (`token`),'+
			  'UNIQUE KEY `user_index` (`user_id`)'+
			') ENGINE=MyISAM DEFAULT CHARSET=latin1;',
			function(err){
				if(!err)
				{
					console.log(logging.success + "user_verification table created");
					console.log(logging.success + 'Database Tables Created Successfully');
					console.log(colors.magenta + "Creating database account");
					
					db.query("CREATE USER '" + environment.mysql.username + "'@'localhost' IDENTIFIED BY '" + environment.mysql.password + "';", function(err){
						if(!err)
						{
							console.log(logging.success + 'Database User \"' + environment.mysql.username + '\" Created Successfully');
							console.log(colors.magenta + 'Assigning Privileges to \"' + environment.mysql.username + '\"');
						
							db.query("GRANT USAGE ON *.* TO '" + environment.mysql.username + "'@'localhost' IDENTIFIED BY '" + environment.mysql.password + "' "+
							"WITH MAX_QUERIES_PER_HOUR 0 "+
							"MAX_UPDATES_PER_HOUR 0 "+
							"MAX_CONNECTIONS_PER_HOUR 0 "+
							"MAX_USER_CONNECTIONS 0;", function(err)
							{
								if(!err)
								{
									db.query("GRANT Create Temporary Tables, Trigger, References, Insert, Update, Create Routine, Alter, Create View, Event, Lock Tables, Drop, Execute, Grant Option, Alter Routine, Create, Delete, Index, Select, Show View ON `" + environment.mysql.catalog + "`.* TO `" + environment.mysql.username + "`@`localhost`;", function(err){
										if(!err)
										{
											console.log(logging.success + 'Database Privileges Assigned to User \"' + environment.mysql.username + '\" Successfully');
											console.log(logging.success + 'MySQL Initialization complete');
											next();
										}
										else
										{
											console.log(logging.error + 'Database Privileges Assigned to User \"' + environment.mysql.username + '\" Failed');
										}
									});
								}
								else
								{
									console.log(logging.error + 'Unable to assign initial privileges to database user \"' + environment.mysql.username + '\"');
									console.log(err)
								}
							});
						}
						else
						{
							console.log(logging.error + 'Unable to Create Database User \"' + environment.mysql.username + '\"');
						}
					});
				}
			});
		}
	});
}

function initializeSystemUsers(next)
{
	console.log(colors.magenta + 'Initializing MySQL System Users');
	
	var db = new MySql({host:environment.mysql.host,
		            port:environment.mysql.port,
		            user:environment.mysql.username,
		            password:environment.mysql.password,
		            database:environment.mysql.catalog});

	db.connect();
	db.query("BEGIN;", function(err){
		if(!err)
		{
			db.query("INSERT INTO `user` VALUES ('1', 'system', 'system@gamepopapp.com', '', 'a35dec05633be98c00ebc27a46f54365', '1', '2010-12-06T05:16:05+0000'), ('2', 'anonymous', 'anonymous@gamepopapp.com', '', '', '1', '2010-12-06T05:16:05+0000');", function(err){
				if(!err)
				{
					db.query("COMMIT;", function(err){
						if(!err)
						{
							console.log(logging.success + 'GamePop System Users Created Successfully');
							next();
						}
					})
				}
				else
				{
					console.log(logging.error + 'Unable to create GamePop system users');
					console.log(err);
				}
			});
		}
	});
}

function initializeGames(next)
{
	console.log(colors.magenta + 'Initializing Default Games' + colors.reset);
	
	var games             = null;
	var count             = 0;
	
	fs.readFile('./games.json', 'utf8', function (err, data) 
	{
		var crypto = require('crypto');
		
		
		if (err) throw err;
		games = JSON.parse(data);
		
		for(var index in games)
		{
			var g = games[index];
			
			// test if this game already exists:
			db.getDoc(encodeURIComponent(g._id), function(error, target)
			{
				var game = g;
				return function(error, target)
				{
					var gameObject = null;
					var dirty      = false;
					
					// this is an existing game, update it.
					// this does not take into account arrays
					// so things will always get updated.
					// we could solve this by first alphabetizing the array
					// then hasing it and comparing the hashes. Of course,
					// this will only work on arrays of strings.
					
					if(error == null)
					{
						gameObject = target;
						
						for(var key in game)
						{
							if(typeof gameObject[key] != "undefined")
							{
								if(key == "modes" || key == "platforms")
								{
									
									var existing   = crypto.createHash('md5');
									var candidates = crypto.createHash('md5');
									
									existing.update(gameObject[key].sort().join("").toLowerCase());
									candidates.update(game[key].sort().join("").toLowerCase());
									
									if(existing.digest('hex') != candidates.digest('hex'))
									{
										gameObject[key] = game[key];
										dirty = true;
									}
								}
								else
								{
									if(gameObject[key] != game[key])
									{
										gameObject[key] = game[key];
										dirty = true;
									}
								}
							}
							else
							{
								gameObject[key] = game[key];
								dirty = true;
							}
						}
					}
					else
					{
						gameObject = new Game();
						dirty = true;
					
						for(var key in game)
							gameObject[key] = game[key];
					}
				
					if(dirty)
					{
						db.saveDoc(gameObject, function(error, data)
						{
							if(error == null)
							{
								console.log(logging.success +"Initialized Game: " + game.label);
							}
							else
							{
								console.log(logging.error +"Failed to Initialize Game: " + game.label);
								console.log(error);
							}

							count = count + 1;
							if(next && count == games.length) next();
						});
					}
					else
					{
						console.log(logging.warn +"No Change: " + game.label);
					}
				}
			}());
		}
	});
}

function installComplete()
{
	console.log("\n" + colors.bold.green + 'GamePop Install Complete!' + colors.reset + "\n");
	process.exit(0);
	return;
	
}

install();
