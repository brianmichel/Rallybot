# Rally information for bugs, stories, and users
#
# ENV Variables Required:
# HUBOT_RALLY_USERNAME : username that hubot will use to login to Rally
# HUBOT_RALLY_PASSWORD : password that hubot will use to login to Rally
#
# Add to heroku:
# % heroku config:add HUBOT_RALLY_USERNAME="..."
# % heroku config:add HUBOT_RALLY_PASSWORD="..."
#
# rally me <defect id | task id>
#

user = process.env.HUBOT_RALLY_USERNAME
pass = process.env.HUBOT_RALLY_PASSWORD
api_version = 1.29

String::startsWith = (string) ->
  this.indexOf(string) == 0

module.exports = (robot) ->
	robot.hear /(rally)( me)? (.*)/i, (msg) ->
		if user && pass
			if msg.match[3].startsWith("DE")
				bugRequest msg, msg.match[3], (string) ->
					msg.send string
			else if msg.match[3].startsWith("TA")
				taskRequest msg, msg.match[3], (string) ->
					msg.send string
			else
				msg.send "Sorry, I can't play that tune."
		else
		  msg.send "You need to set HUBOT_RALLY_USERNAME & HUBOT_RALLY_PASSWORD before making requests!"

bugRequest = (msg, defectId, cb) ->
	query_string = '/defect.js?query=(FormattedId%20=%20'+defectId+')' + '&fetch=true'
	rallyRequest msg, query_string, (json) ->
		console.log(json)
		return_string = "Owner: " + json.QueryResult.Results[0].Owner._refObjectName + "\n" + "Desc: " + json.QueryResult.Results[0].Description;
		cb return_string || "Aww snap, I couldn't find that bug!" 

taskRequest = (msg, taskId, cb) ->
	query_string = '/task.js?query=(FormattedId%20=%20'+taskId+')' + '&fetch=true'
	rallyRequest msg, query_string, (json) ->
		return_string = "Owner: " + json.QueryResult.Results[0].Owner._refObjectName + "\n" + "Desc: " + json.QueryResult.Results[0].Name;
		cb return_string || "Aww snap, I couldn't find that task!"

rallyRequest = (msg, query, cb) ->
	rally_url = 'https://rally1.rallydev.com/slm/webservice/' + api_version + query
	basicAuthRequest msg, rally_url, (json) ->
		cb json

basicAuthRequest = (msg, url, cb) ->
	auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');
	msg.http(url)
		.headers(Authorization: auth, Accept: 'application/json')
		.get() (err, res, body) ->
			json_body = JSON.parse(body)
			cb json_body

