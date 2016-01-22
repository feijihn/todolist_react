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
	componentDidMount: function() { //update data with this.props.updateInterval interval
		this.loadTasksFromServer();
	},
	handleDelete: function(key){
		/*$.ajax({
      url: this.props.url,
      dataType: 'json',
      data: {"id" : 11453464243666},
      type: 'DELETE',
      success: function (data) {
      }.bind(this), 
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
      });	*/
			/*this.loadTasksFromServer();*/
			console.log('handleDelete called!')
		},
	handleAdd: function(){
		$.ajax({																																	
			url: this.props.url,
			dataType: 'json',
			type: 'POST',
			data: {"id" : Date.now(), "priority": 1, "text": "newtask"},
			success: function(data) {
				this.setState({data: data});
			}.bind(this),
			error: function(xhr, status, err) {
				console.error(this.props.url, status, err.toString());
			}.bind(this)
		});
		this.loadTasksFromServer();
	},
	render: function() { //after server implemented, "this.props.data" should be replaced with "this.state.data"
		return (
			<Paper className="paperE" zDepth={5}>
			  	<AppBar
			 		title="Just To-Do. No shit"
			 		iconClassNameRight="muidocs-icon-navigation-expand-more"/>
				<TaskList data={this.state.data} onDelete={this.handleDelete} onEdit={this.handleEdit}/>
				<AddNewTask onAdd={this.handleAdd} />
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
	passDelete: function(){
		this.props.onDelete
	},
	render: function() {
  	  var taskNodes = this.props.data.map(function(task) {
    	  return (
        	<TaskElement key={task.id} priority={task.priority} text={task.text} onEdit={this.props.onEdit} onDelete={this.passDelete}/>
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
		    priority : 0
	    }
	},
	componentDidMount: function() {
		this.setState({
			text: this.props.text,
			id: this.props.id,
			priority: this.props.priority
		});
	},
  render: function() {
    return (
      <div className="taskElement">
       	<i className="material-icons" onClick={this.props.onEdit}>mode_edit</i>
       	<i className="material-icons" onClick={this.props.onDelete}>delete</i>
       	<p>{this.props.priority}.{this.state.text}</p>
      </div>
		   );
	}
});

var AddNewTask = React.createClass({
    render: function() {
        return (
            <div className="addNewTask">
            	<i className="material-icons" onClick={this.props.onAdd}>add</i>
            </div>
        );
    }
});

ReactDOM.render(
	<TaskBox url='/api/comments' updateInterval={10000}/>,
	document.getElementById('content')
);
