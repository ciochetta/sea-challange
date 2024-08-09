require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, customer_success_away)
    @customer_success = customer_success
    @customers = customers
    @customer_success_away = customer_success_away
  end

  # Returns the id of the CustomerSuccess with the most customers
  def execute

    working_css = []

    @customer_success.each do |cs|
      if !@customer_success_away.include?(cs[:id])
        working_css.push(cs)
      end
    end

    sorted_working_css = working_css.sort_by { |cs| cs[:score] }
    sorted_customers = @customers.sort_by { |customer| customer[:score] }

    i = 0
    j = 0
    assingned_customers = {}

    while i < sorted_customers.length && j < sorted_working_css.length
      customer = sorted_customers[i]
      cs = sorted_working_css[j]

      if (customer[:score] > cs[:score])
        j+=1
        next
      end


      if (!assingned_customers.key?(cs[:id]))
        assingned_customers[cs[:id]] = []
      end

      assingned_customers[cs[:id]].push(customer[:id])

      i+=1
    end


    most_customers = { 
      ids: [],
      customers: 0
    }

    assingned_customers.each do |cs_id, customers|
      if customers.length > most_customers[:customers]
        most_customers[:customers] = customers.length
        most_customers[:ids] = [cs_id]
      elsif customers.length == most_customers[:customers]
        most_customers[:ids].push(cs_id)
      end
    end

    if most_customers[:ids].length == 1
      return most_customers[:ids][0]
    end

    return 0
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
   def test_scenario_one
     css = [{ id: 1, score: 60 }, { id: 2, score: 20 }, { id: 3, score: 95 }, { id: 4, score: 75 }]
     customers = [{ id: 1, score: 90 }, { id: 2, score: 20 }, { id: 3, score: 70 }, { id: 4, score: 40 }, { id: 5, score: 60 }, { id: 6, score: 10}]

     balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
     assert_equal 1, balancer.execute
   end

   def test_scenario_two
     css = array_to_map([11, 21, 31, 3, 4, 5])
     customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
     balancer = CustomerSuccessBalancing.new(css, customers, [])
     assert_equal 0, balancer.execute
   end

   def test_scenario_three
     customer_success = Array.new(1000, 0)
     customer_success[998] = 100

     customers = Array.new(10000, 10)
    
     balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [1000])

     result = Timeout.timeout(1.0) { balancer.execute }
     assert_equal 999, result
   end

   def test_scenario_four
     balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
     assert_equal 0, balancer.execute
   end

   def test_scenario_five
     balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
     assert_equal balancer.execute, 1
   end

   def test_scenario_six
     balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
     assert_equal balancer.execute, 0
   end

   def test_scenario_seven
     balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [4, 5, 6])
     assert_equal balancer.execute, 3
   end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end

Minitest.run