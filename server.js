/**
 * This file provided by Facebook is for non-commercial testing and evaluation
 * purposes only. Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

var fs = require('fs');
var path = require('path');
var express = require('express');
var bodyParser = require('body-parser');
var app = express();

var DB_FILE = path.join(__dirname, '/data/tasks.json');

var findById = function(array, id, callback){
	array.some(function(element, i, array){
		if(element.id == id) callback(i);  
		return element.id == id;
	});
}

app.set('port', (process.env.PORT || 3000));

app.use('/', express.static(path.join(__dirname, 'public')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.get('/api/tasks', function(req, res) {
	fs.readFile(DB_FILE, function(err, data) {
		if (err) {
			console.error(err);
			process.exit(1);
		}
		res.setHeader('Cache-Control', 'no-cache');
		res.json(JSON.parse(data));
	});
});

app.post('/api/tasks', function(req, res) {
	console.log('post event!')
	fs.readFile(DB_FILE, function(err, data) { //if post req got to /api/tasks/ read DB_FILE
		if (err) {
			console.error(err);
			process.exit(1);
		}
		var tasks = JSON.parse(data); //parse DB_FILE from json
		method = req.body.method //get the post method of the req
		switch(method){		//switch for methods. 'append' appends a new task, 'delete' deletes the task with specified id, 'edit' changes the specified id task text,																																																														'move' moves task up or down in task list.
			case 'append':
				var newTask= {
					id: Date.now().toString(),
					status: req.body.status,
					text: req.body.text,
				};
				tasks.push(newTask);
				break;
			case 'delete':
				findById(tasks, req.body.key, function(idToDelete){
					tasks.splice(idToDelete, 1);
				});
				break;
			case 'edit':
				findById(tasks, req.body.key, function(idToEdit){
					tasks[idToEdit].text = req.body.text;
				});
				break;
			case 'move':
				findById(tasks, req.body.key, function (idToMove) {
					var temp = tasks[idToMove]
					if(req.body.dir == 1){
						if(tasks[idToMove-1] != undefined){
							console.log('moving task[' + idToMove + '] up');
							tasks[idToMove] = tasks[idToMove-1];
							tasks[idToMove-1] = temp;
						}
					}else{
						if(tasks[idToMove+1] != undefined){
							console.log('moving task[' + idToMove + '] down');
							tasks[idToMove] = tasks[idToMove+1];
							tasks[idToMove+1] = temp;
						}
					}	
					return 1;
				});
				break;
		}
		fs.writeFile(DB_FILE, JSON.stringify(tasks, null, 4), function(err) {
			if (err) {
				console.error(err);
				process.exit(1);
			}
			res.setHeader('Cache-Control', 'no-cache');
			res.json(tasks);
		});
	});
});


app.listen(app.get('port'), function() {
	console.log('Server started: http://localhost:' + app.get('port') + '/');
});
