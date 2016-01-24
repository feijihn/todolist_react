var React = require('react');
var ajax = require('ajax');
var $ = require('jquery');
var ReactDOM = require('react-dom');
var {render} = require('react-dom');
var Paper = require('material-ui/lib/paper');
var Colors = require('material-ui/lib/styles/colors');
var AppBar = require('material-ui/lib/app-bar');
var TextField = require('material-ui/lib/text-field');
var RaisedButton = require('material-ui/lib/raised-button');
var FlatButton = require('material-ui/lib/flat-button');
var IconButton = require('material-ui/lib/icon-button');
var MenuItem = require('material-ui/lib/menus/menu-item');
var Divider = require('material-ui/lib/divider');
var IconMenu = require('material-ui/lib/menus/icon-menu');
var DropDownMenu = require('material-ui/lib/DropDownMenu');

var circleButtonStyle = {
	height: 50,
	width: 50,
	backgroundColor: Colors.cyan100,
	textAlign: 'center',
	display: 'inline-block',
	opacity: 0.6,
};

var circleButtonStyleHover = {
	height: 50,
	width: 50,
	backgroundColor: Colors.cyan100,
	textAlign: 'center',
	display: 'inline-block',
	opacity: 1,
};

var appBarsStyle = {
	backgroundColor: Colors.blueGrey600,
};

var TaskBox = React.createClass({
	getInitialState: function() { //initialize data
		return {data: []};
	},
	loadTasksFromServer: function() {
		$.ajax({
			url: this.props.url,
			dataType: 'json',
			cache: false,
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});	
	},
	componentDidMount: function() { 
		this.loadTasksFromServer();
		setInterval(this.loadTasksFromServer, 5000)
	},
	handleDelete: function(key){
		$.ajax({
			url: this.props.url,
			dataType: 'json',
			type: 'POST',
			data: {"method": "delete", "key": key},
			success: function (data) {
				this.setState({
					data:data
				})
			}.bind(this), 
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
	},
	handleAdd: function(){
		$.ajax({																																	
			url: this.props.url, 
			dataType: 'json',
			type: 'POST',
			data: {"method": "append", "status": "1", "text": "New task"},
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
	},
	handleEdit: function(key, newText, newStatus){
		$.ajax({																																	
			url: this.props.url, 
			dataType: 'json',
			type: 'POST',
			data: {"method": "edit", "key": key, "text": newText, "status": newStatus},
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
	},
	handleMove: function(key, direction){
		$.ajax({																																	
			url: this.props.url, 
			dataType: 'json',
			type: 'POST',
			data: {"method": "move", "key": key, "dir": direction},
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
	},
	render: function() { 
		return (
			<Paper className="paperE" zDepth={5}>
			<AppBar 
			showMenuIconButton={false}
			title="Just To-Do. No shit"
			style={appBarsStyle}
			/>
			<TaskList data={this.state.data} onDelete={this.handleDelete} onEdit={this.handleEdit} onMove={this.handleMove}/>
			<AddNewTask onAdd={this.handleAdd}/>
			</Paper>
		);
	}
});

var TaskList = React.createClass({
	getInitialState: function(){
		return {
			data: []
		}
	},
	componentDidMount: function(){
		this.setState({
			data: this.props.data
		}) ;	
	},
	render: function() {
		var taskNodes = this.props.data.map(function(task) {
			return (
				<TaskElement key={task.id} id={task.id} status={task.status} text={task.text} editing={task.editing} onEdit={this.props.onEdit} onDelete={this.props.onDelete} onMove={this.props.onMove}/>
			);
		}, this);
		return (
			<div className="taskList">
			{taskNodes}
			</div>
		);
	}
});

var TaskElement = React.createClass({
	getInitialState: function() {
		return {
			text : "",
			id : 0,
			status: '1', 
			editing: false,
			showIcons: false
		}
	},
	updateStatus: function(newStatus) {
		switch(newStatus){
			case "1":
				this.setState({
					style: {
						backgroundColor: Colors.brown100
					},
					status: newStatus
				})
				break;
			case "2":
				this.setState({
					style: {
						backgroundColor: Colors.indigo100
					},
					status: newStatus			
				})
				break;

			case "3":
				this.setState({
					style: {
						backgroundColor: Colors.deepPurple100
					},
					status: newStatus	
				})
				break;
		};
	},
	componentDidMount: function() {
		this.setState({
			text: this.props.text,
			id: this.props.id,
			editing: this.props.editing
		});
		this.updateStatus(this.props.status)
	},
	deleteTask: function() {
		this.props.onDelete(this.state.id);
	},
	toEditMode: function() {
		this.setState({
			editing: true
		});
	},
	editTask: function() {
		this.setState({
			editing: false,
		});
		this.props.onEdit(this.state.id, this.state.text, this.state.status);
	},
	textChange: function(e) {
		this.setState({
			text: e.target.value
		})
	},
	moveTask: function(direction){
		this.props.onMove(this.state.id, direction) //1 means move UP and 0 means move DOWN
	},
	handleMouseEnter: function() {
		this.setState({
			showIcons: true
		});
	},
	handleMouseLeave: function() {
		this.setState({
			showIcons: false
		});
	},
	render: function() {
		if(!this.state.editing){
			return (
				<div className="taskElement" style={this.state.style}
				onMouseEnter={this.handleMouseEnter}
				onMouseLeave={this.handleMouseLeave}>
					<div className="textArea" style={this.state.showIcons ? {opacity: 1} : null}>
						<h4 onDoubleClick={this.toEditMode}>{this.state.text}</h4>
					</div>
					{this.state.showIcons ? 
					<div className="iconsArea">					
						<i className="material-icons" onClick={this.moveTask.bind(this, 1)}>keyboard_arrow_up</i>
						<i className="material-icons" onClick={this.moveTask.bind(this, 0)}>keyboard_arrow_down</i>
						<i className="material-icons" onClick={this.deleteTask}>delete</i>
						<i className="material-icons" onClick={this.toEditMode}>mode_edit</i>
					</div> 
					: null }
				</div>		   
			);
		}else{
		return (
			<div className="taskElement" style={this.state.style}>
				<TextField 
				onChange={this.textChange}
				defaultValue={this.state.text}
				underlineStyle={{borderColor:Colors.blueGrey300}}
				underlineFocusStyle={{borderColor:Colors.blueGrey600}} 
				multiLine={true}
				fullWidth={true}
				onEnterKeyDown={this.editTask}
				/>
				<br/>
				<br/>
				<RaisedButton label="brown" backgroundColor={Colors.brown100} onClick={this.updateStatus.bind(this, "1")}/>
				<RaisedButton label="blue" backgroundColor={Colors.indigo100} onClick={this.updateStatus.bind(this, "2")}/>
				<RaisedButton label="purple" backgroundColor={Colors.deepPurple100} onClick={this.updateStatus.bind(this, "3")}/>
				<RaisedButton label="Done" backgroundColor={Colors.blueGrey600} primary={true} onClick={this.editTask}/>
				</div>
			);
			}
		}
	});

	var AddNewTask = React.createClass({
		getInitialState: function() {
			return {currentButtonStyle:circleButtonStyle};
		},
		handleMouseEnter: function() {
			this.setState({
				currentButtonStyle:circleButtonStyleHover
			});
		},
		handleMouseLeave: function() {
			this.setState({
				currentButtonStyle:circleButtonStyle
			});
		},
		render: function() {
			var currentButtonStyle = this.state.currentButtonStyle;
			return (
				<div className="addNewTask" style={appBarsStyle}>
				<Paper style={currentButtonStyle} zDepth={3} className="circleButtonStyle" circle={true} 
				onClick={this.props.onAdd}
				onMouseEnter={this.handleMouseEnter}
				onMouseLeave={this.handleMouseLeave}>

				<i className="material-icons" >add</i>
				</Paper>
				</div>
			);
		}
	});

	ReactDOM.render(
		<TaskBox url='/api/tasks' fs={require('fs')}/>,
			document.getElementById('content')
	);
