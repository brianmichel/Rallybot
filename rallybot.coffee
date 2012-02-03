# Rally information for bugs, stories, and users
#
# rally me <defect id | task id | story id> - Lookup a task, story or defect from Rally
#
# ENV Variables Required:
# HUBOT_RALLY_USERNAME : username that hubot will use to login to Rally
# HUBOT_RALLY_PASSWORD : password that hubot will use to login to Rally
#
# Add to heroku:
# % heroku config:add HUBOT_RALLY_USERNAME="..."
# % heroku config:add HUBOT_RALLY_PASSWORD="..."
#

user = process.env.HUBOT_RALLY_USERNAME
pass = process.env.HUBOT_RALLY_PASSWORD
api_version = 1.29

String::startsWith = (string) ->
  this.indexOf(string) == 0

module.exports = (robot) ->
	robot.respond /(rally)( me)? (.*)/i, (msg) ->
		if user && pass
			if msg.match[3].startsWith("DE")
				bugRequest msg, msg.match[3], (string) ->
					msg.send string
			else if msg.match[3].startsWith("TA")
				taskRequest msg, msg.match[3], (string) ->
					msg.send string
			else if msg.match[3].startsWith("US")
				storyRequest msg, msg.match[3], (string) ->
					msg.send string
			else
				msg.send "Sorry, I can't play that tune."
		else
		  msg.send "You need to set HUBOT_RALLY_USERNAME & HUBOT_RALLY_PASSWORD before making requests!"

bugRequest = (msg, defectId, cb) ->
	query_string = '/defect.js?query=(FormattedId%20=%20'+defectId+')' + '&fetch=true'
	rallyRequest msg, query_string, (json) ->
		msg.send getLinkToItem json.QueryResult.Results[0], "defect"
		return_array = [
			"#{json.QueryResult.Results[0].FormattedID} - #{json.QueryResult.Results[0]._refObjectName}"
			"Owner - #{ if json.QueryResult.Results[0].Owner then json.QueryResult.Results[0].Owner._refObjectName else "No Owner" }"
			"Project - #{ if json.QueryResult.Results[0].Project then json.QueryResult.Results[0].Project._refObjectName else "No Project" }"
			"Severity - #{json.QueryResult.Results[0].Severity}"
			"State - #{json.QueryResult.Results[0].State}"
			"#{if json.QueryResult.Results[0].Description then json.QueryResult.Results[0].Description else "No Description"}"
			]
		cb return_array.join("\n") || "Aww snap, I couldn't find that bug!"

taskRequest = (msg, taskId, cb) ->
	query_string = '/task.js?query=(FormattedId%20=%20'+taskId+')' + '&fetch=true'
	rallyRequest msg, query_string, (json) ->
		msg.send getLinkToItem json.QueryResult.Results[0], "task"
		return_array = [
			"#{json.QueryResult.Results[0].FormattedID} - #{json.QueryResult.Results[0].Name}"
			"Owner - #{ if json.QueryResult.Results[0].Owner then json.QueryResult.Results[0].Owner._refObjectName else "No Owner" }"
			"Project - #{ if json.QueryResult.Results[0].Project then json.QueryResult.Results[0].Project._refObjectName else "No Project" }"
			"State - #{json.QueryResult.Results[0].State}"
			"Feature - #{if json.QueryResult.Results[0].WorkProduct ? json.QueryResult.Results[0].WorkProduct._refObjectName  else "Not associated with any feature"}"
			]
		cb return_array.join("\n") || "Aww snap, I couldn't find that task!"

storyRequest = (msg, storyId, cb) ->
	query_string = '/hierarchicalrequirement.js?query=(FormattedId%20=%20'+storyId+')' + '&fetch=true'
	rallyRequest msg, query_string, (json) ->
		msg.send getLinkToItem json.QueryResult.Results[0], "userstory"
		return_array = [
			"#{json.QueryResult.Results[0].FormattedID} - #{json.QueryResult.Results[0].Name}"
			"Owner - #{ if json.QueryResult.Results[0].Owner then json.QueryResult.Results[0].Owner._refObjectName else "No Owner" }"
			"Project - #{ if json.QueryResult.Results[0].Project then json.QueryResult.Results[0].Project._refObjectName else "No Project" }"
			"ScheduleState - #{json.QueryResult.Results[0].ScheduleState}"
			"#{if json.QueryResult.Results[0].Description then json.QueryResult.Results[0].Description else "No Description"}"
			]
		cb return_array.join("\n") || "Aww snap, I couldn't find that story!"

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

getLinkToItem = (object, type) ->
	project = object.Project
	if project
		objectId = object.ObjectID
		jsPos = project._ref.lastIndexOf ".js"
		lastSlashPos = project._ref.lastIndexOf "/"
		projectId = project._ref[(lastSlashPos+1)..(jsPos-1)]
		return "https://rally1.rallydev.com/slm/rally.sp#/#{projectId}/detail/#{type}/#{objectId}"
	else
		return null
		