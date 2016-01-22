import React from 'react';
import {render} from 'react-dom';
import Paper from 'material-ui/lib/paper';
import Colors from 'material-ui/lib/styles/colors';
import FontIcon from 'material-ui/lib/font-icon';
import AppBar from 'material-ui/lib/app-bar';
import Toolbar from 'material-ui/lib/toolbar/toolbar';
import ToolbarTitle from 'material-ui/lib/toolbar/toolbar-title';

var data = [
  {id: 1, priority: 1, text: "Prepare for math exam"},
  {id: 2, priority: 2, text: "Finish T0D0-list"},
  {id: 3, priority: 3, text: "Take a ride to Kyl-Dysh"}
];

var TaskBox = React.createClass({
	getInitialState: function() { //data will be taken from the server
		return {data: []};
	},

	componentDidMount: function() { //some server shit should be done here

	},

	render: function() { //after server implemented, "this.props.data" should be replaced with "this.state.data"
		return (
			<Paper className="paperE" zDepth={5}>
			  	<AppBar
			 		title="Just To-Do. No shit"
			 		iconClassNameRight="muidocs-icon-navigation-expand-more"/>
				<TaskList data={this.props.data} />
				<AddNewTask />
			</Paper>
		);
	}
});

var TaskList = React.createClass({
	render: function() {
  	  var taskNodes = this.props.data.map(function(task) {
    	  return (
        	<TaskElement priority={task.priority} key={task.id}>
        	  	{task.text}
       		</TaskElement>
      	);
    	});
		return (
			<div className="taskList">
				{taskNodes}
			</div>
		);
	}
});

var TaskElement = React.createClass({
	changePriorityButton: function() { //T0D0

	},
	editTaskElement: function() { //T0D0
		this.setState({
			text: "gofuckyourself"
		});
	},
	deleteTaskElement: function() { //T0D0
		this.setState({
			text: ""
		});
	},
	getInitialState: function() { //T0D0
		return {
			text: "{this.props.children}"
		}
	},
    render: function() {
        return (
            <div className="taskElement">
            	<i className="material-icons" onClick={this.editTaskElement}>mode_edit</i>
            	<i className="material-icons" onClick={this.deleteTaskElement}>delete</i>
            	<p>{this.props.priority}.{this.props.children}</p>
            </div>
        );
    }
});

var AddNewTask = React.createClass({
    render: function() {
        return (
            <div className="addNewTask">
            	<i className="material-icons">add</i>
            </div>
        );
    }
});

ReactDOM.render(
	<TaskBox data={data}/>,
	document.getElementById('content')
);
