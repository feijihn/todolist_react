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

var DB_FILE = path.join(__dirname, 'tasks.json');
	

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
  fs.readFile(DB_FILE, function(err, data) {
    if (err) {
      console.error(err);
      process.exit(1);
    }
		method = req.body.method
    var tasks = JSON.parse(data);
		if(method == 'append'){
		 var newTask= {
				id: Date.now(),
				priority: req.body.priority,
				text: req.body.text,
			};
			tasks.push(newTask);
		}else if(method == 'delete'){
			var idToDelete;
			tasks.forEach(function(task, i, tasks){
				if(tasks[i].id == req.body.key){
					idToDelete = i;
				} 			
			});
			tasks.splice(idToDelete,1)
		}else if(method == 'edit'){
			var idToEdit;
			tasks.forEach(function(task, i, tasks){
				if(tasks[i].id == req.body.key) idToEdit = i;
			});
			tasks[idToEdit].text = req.body.text;
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
