import React from 'react';
import ajax from 'ajax';
import $ from 'jquery';
import ReactDOM from 'react-dom';
import {render} from 'react-dom';
import Paper from 'material-ui/lib/paper';
import Colors from 'material-ui/lib/styles/colors';
import FontIcon from 'material-ui/lib/font-icon';
import AppBar from 'material-ui/lib/app-bar';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';
import TextField from 'material-ui/lib/text-field';
import FlatButton from 'material-ui/lib/flat-button';

var circleButtonStyle = {
  height: 50,
  width: 50,
  backgroundColor: Colors.cyan100,
  textAlign: 'center',
  display: 'inline-block',
  opacity: 0.6,
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
			data: {"method": "append", "priority": 1, "text": "Empty task."},
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
	},
	handleEdit: function(key, newText){
		$.ajax({																																	
			url: this.props.url, 
			dataType: 'json',
			type: 'POST',
			data: {"method": "edit", "key": key, "text": newText},
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
	},
	render: function() { //after server implemented, "this.props.data" should be replaced with "this.state.data"
		return (
			<Paper className="paperE" zDepth={5}>
			  	<AppBar
			 		title="Just To-Do. No shit"
			 		iconClassNameRight="muidocs-icovigation-expand-more"/>
				<TaskList data={this.state.data} onDelete={this.handleDelete} onEdit={this.handleEdit}/>
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
        	<TaskElement key={task.id} id={task.id} priority={task.priority} text={task.text} onEdit={this.props.onEdit} onDelete={this.props.onDelete}/>
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
		    priority : 0,
				editing: false
	    }
	},
	componentDidMount: function() {
		this.setState({
			text: this.props.text,
			id: this.props.id,
			priority: this.props.priority
		});
	},
	Delete: function() {
		this.props.onDelete(this.state.id);
	},
	toEditMode: function() {
		this.setState({
			editing: true
		})
	},
	Edit: function(e) {
		this.props.onEdit(this.state.id, e.target.value)
		this.setState({
			editing: false,
			text: e.target.value
		})
			},
  render: function() {
		if(!this.state.editing){
			return (
			  <div className="taskElement">
					<i className="material-icons">keyboard_arrow_up</i>
			   	<i className="material-icons" onClick={this.toEditMode}>mode_edit</i>
			   	<i className="material-icons" onClick={this.Delete}>delete</i>
			   	<h3>{this.state.text}</h3>
			  </div>
		   );
		}else{
			return (
				<div className="taskElement">
			   <TextField onEnterKeyDown={this.Edit} />
			  </div>
			);
		}
	}
});

var AddNewTask = React.createClass({
    render: function() {
        return (
            <div className="addNewTask">
            <Paper style={circleButtonStyle} zDepth={3} className="circleButtonStyle" circle={true} onClick={this.props.onAdd}>
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
