// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CrowdFounding {
    enum FoundraisingState { Opened, Closed }

    struct Contribution {
        address contributor;
        uint value;
    }

    struct Project{
        string id;
        string name;
        string description;
        address payable author;
        FoundraisingState state;
        uint founds;
        uint foundsGoal;
    }

    Project[] public projects;
    mapping(string => Contribution[]) public contributions;

    //string public id;
    //string public name;
    //string public description;
    //address payable public author;
    //uint public state;
    //uint public founds;
    //uint public foundsGoal;

    event ProjectCreated(
        string projectId,
        string name,
        string description,
        uint foundsGoal
    );

    event foudProject(
        address sender,
        string projectId,
        uint value
    );

    event changeProjectState(
        address author,
        string id,
        FoundraisingState state
    );

    //constructor(string memory _id, string memory _name, string memory _description, uint _foundsGoal){
    //    project = Project(_id, _name, _description, payable(msg.sender), FoundraisingState.Opened, 0, _foundsGoal);
    //}

    modifier onlyAuthor(uint projectIndex){
        require(
            projects[projectIndex].author == msg.sender,
            //msg.sender == project.author,
            "Only author can change the state"
        );
        //Modificacion por author
        _;
    }

    modifier noAuthorPay(uint projectIndex){
        require(
            projects[projectIndex].author != msg.sender,
            //project.author != msg.sender,
            "Autofinance is not avaible" 
        );
        _;
    }

    function createProject(string calldata id, string calldata name, string calldata description, uint foundsGoal) public {
        require(foundsGoal > 0, "Foundarising Goal must be greather than 0");
        Project memory project = Project(id, name, description, payable(msg.sender), FoundraisingState.Opened, 0, foundsGoal);
        projects.push(project);
        emit ProjectCreated(id, name, description, foundsGoal);
    }

    function fundProject(uint projectIndex) public payable noAuthorPay(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != FoundraisingState.Closed, "The project can not recive funds");
        require(msg.value > 0, "Found must to be grater than 0");
        project.author.transfer(msg.value);
        project.founds += msg.value;
        projects[projectIndex] = project;

        contributions[project.id].push(Contribution(msg.sender, msg.value));

        emit foudProject(msg.sender, project.id, msg.value);
    } 

    function changeProgectState(FoundraisingState newState, uint projectIndex) public onlyAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        require(project.state != newState, "The new state must be diferent");
        project.state = newState;
        projects[projectIndex] = project;

        emit changeProjectState(msg.sender, project.id, project.state);
    }

}