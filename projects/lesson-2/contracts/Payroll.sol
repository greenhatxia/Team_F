pragma solidity ^0.4.14;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayDate;
    }
    
    uint constant payDuration = 30 days;
    
    address owner;
    Employee[] employees;
    
    constructor () payable public {
        owner = msg.sender;
    }
    
	function _findEmployee(address employeeId)  private view returns (Employee, uint) {
	    for(uint i = 0; i < employees.length; i++) {
	        if(employees[i].id == employeeId)
	            return (employees[i], i);
	    }
	}
	
	function _partialPaid(Employee employee) private {
	    uint payment = employee.salary * (now - employee.lastPayDate) / payDuration;
	    employee.lastPayDate = now;
	    employee.id.transfer(payment);
	}
	
    function addEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        
        employees.push(Employee(employeeId, salary * 1 ether, now)); 
    }

    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(employeeId);
	    assert(employee.id != 0x0);
	    
	    _partialPaid(employee);
	    
	    delete employees[index];
	    employees[index] = employees[employees.length - 1];
	    employees.length -= 1;       
    }

    function updateEmployee(address employeeId, uint salary) public {
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(employeeId);
	    assert(employee.id != 0x0);
	    
	    _partialPaid(employee);
	    employees[index].salary = salary * 1 ether;
	    employees[index].lastPayDate = now;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        uint totalSalary = 0;
        for(uint i = 0; i < employees.length; i++){
            totalSalary += employees[i].salary;
        }
        
        assert(totalSalary > 0);
        
    	return address(this).balance / totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        var (employee, index) = _findEmployee(msg.sender);
        
	    assert(employee.id != 0x0);

	    uint nextPayday = employee.lastPayDate + payDuration;
	    assert(nextPayday < now);
	    
	    employees[index].lastPayDate = nextPayday;
	    employees[index].id.transfer(employee.salary);    
    }
}