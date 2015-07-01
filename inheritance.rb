class Employee
  attr_reader :name, :title, :salary
  attr_accessor :boss

  def initialize(name, title, salary, boss = nil)
    @name = name
    @title = title
    @salary = salary
    @boss = boss
  end

  def bonus(multiplier)
    salary * multiplier
  end

  def employee_salaries
    0
  end
end

class Manager < Employee
  attr_reader :employees

  def initialize(name, title, salary, boss = nil)
    super
    @employees = []
  end

  def bonus(multiplier)
    employee_salaries * multiplier
  end

  def employee_salaries
    @employees.inject(0) do |sum, employee|
      sum += employee.salary
      sum += employee.employee_salaries
    end
  end

  def add_employee(employee)
    employees << employee
    employee.boss = self.name
  end
end

if __FILE__ == $PROGRAM_NAME
  ned = Manager.new("Ned", "Founder", 1_000_000)
  darren = Manager.new("Darren", "TA Manager", 78_000)
  shawna = Employee.new("Shawna", "TA", 12_000)
  david = Employee.new("David", "TA", 10_000)

  darren.add_employee(shawna)
  darren.add_employee(david)
  ned.add_employee(darren)

  puts ned.bonus(5)
  puts darren.bonus(4)
  puts david.bonus(3)
end
