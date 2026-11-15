# NabComAu/Bpay.rb
# NabComAu::Bpay

require_relative '../Nab'

module NabComAu
  class Bpay < NabComAu::Account
    def initialize(source_bank_account_name_or_number: nil, biller_name_or_code: nil, customer_reference_number: nil, amount: nil)
      @source_bank_account_name_or_number = source_bank_account_name_or_number
      @biller_name_or_code = biller_name_or_code
      @customer_reference_number = customer_reference_number
      @amount = amount
    end

    def transfer_and_pay_button
      driver_wait.until do
        @driver.element_present?(:xpath, '//*[@id="transferPay"]/button')
      end
      @driver.find_element(xpath: '//*[@id="transferPay"]/button')
    end

    def bill_payment_link
      driver_wait.until do
        @driver.element_present?(:xpath, '//*[@id="transferPay"]/ul/li[1]/ul/li[4]/a')
      end
      @driver.find_element(xpath: '//*[@id="transferPay"]/ul/li[1]/ul/li[4]/a')
    end

    def bpay_bank_account_select_list
      driver_wait.until do
        @driver.element_present?(:css, '[name="selectedAcctIndx"]')
      end
      @driver.find_element(css: '[name="selectedAcctIndx"]')
    end

    def bpay_biller_select_list
      driver_wait.until do
        @driver.element_present?(:css, '[name="billerRef"]')
      end
      @driver.find_element(css: '[name="billerRef"]')
    end

    def bpay_biller_code_field
      driver_wait.until do
        @driver.element_present?(:css, '[name="billerCode"]')
      end
      @driver.find_element(css: '[name="billerCode"]')
    end

    def bpay_biller_name_field
      driver_wait.until do
        @driver.element_present?(:css, '[name="billerName"]')
      end
      @driver.find_element(css: '[name="billerName"]')
    end

    def bpay_submit_button
      @driver.find_element(css: '[name="search"]')
    end

    def bpay_select_bank_account(account_name_or_number)
      unless account_name_or_number.match(/[a-zA-Z]/)
        account_name_or_number = Nab.to_nab_account_number_format(account_name_or_number)
      end
      webdriver_select_list = Selenium::WebDriver::Support::Select.new(bpay_bank_account_select_list)
      if option = webdriver_select_list.options.detect{|option| option.attribute(:text) =~ /#{account_name_or_number}/}
        option.click
      else
        raise "Can't find supplied account name or number from the dropdown list."
      end
    end

    def bpay_select_biller(biller_name)
      webdriver_select_list = Selenium::WebDriver::Support::Select.new(bpay_biller_select_list)
      if option = webdriver_select_list.options.detect{|option| option.attribute(:text) =~ /#{biller_name}/}
        option.click
      end
      option
    end

    def bpay_enter_biller_code(biller_code)
      bpay_biller_code_field.clear
      bpay_biller_code_field.send_keys(biller_code)
    end

    def bpay_enter_biller_name(biller_name)
      bpay_biller_name_field.clear
      bpay_biller_name_field.send_keys(biller_name)
    end

    def bpay_biller_direct_hit?
      if element = @driver.find_element(xpath: '//*[@class="pageTitle"]')
        element.text.match(/New bill payment/)
      end
    end

    def bpay_search_result_selection(bpay_biller_code)
      bpay_biller_cell = @driver.find_element(xpath: "//td[contains(text(), '#{bpay_biller_code}')]")
      bpay_biller_cell.find_element(:xpath, '../td/a')
    end

    # New bill payment

    def bpay_customer_reference_number_field
      @driver.find_element(:name, 'custRefNumber')
    end

    def bpay_enter_customer_reference_number(customer_reference_number)
      bpay_customer_reference_number_field.clear
      bpay_customer_reference_number_field.send_keys(customer_reference_number)
    end

    def bpay_payment_amount_field
      @bpay_payment_amount_field ||= (
        driver_wait.until do
          @driver.element_present?(:css, '[name="paymentAmount"]')
        end
        @driver.find_element(css: '[name="paymentAmount"]')
      )
    end

    def bpay_enter_payment_amount(amount)
      bpay_payment_amount_field.clear
      bpay_payment_amount_field.send_keys(amount)
    end

    def bpay_new_bill_payment_next_button
      @bpay_new_bill_payment_next_button ||= (
        driver_wait.until do
          @driver.element_present?(:css, '[name="nextButton"]')
        end
        @driver.find_element(css: '[name="nextButton"]')
      )
    end

    def new_bill_payment(customer_reference_number:, amount:)
      bpay_enter_customer_reference_number(customer_reference_number)
      bpay_enter_payment_amount(amount)
      bpay_new_bill_payment_next_button.click
    end

    # New bill payment confirmation

    def bpay_password_field
      @bpay_password_field ||= (
        driver_wait.until do
          @driver.element_present?(:css, '[name="password"]')
        end
        @driver.find_element(css: '[name="password"]')
      )
    end

    def bpay_enter_password(password)
      bpay_password_field.clear
      bpay_password_field.send_keys(password)
    end

    def bpay_new_bill_payment_submit_button
      @bpay_new_bill_payment_submit_button ||= (
        driver_wait.until do
          @driver.element_present?(:css, '[name="nextButton"]')
        end
        @driver.find_element(css: '[name="nextButton"]')
      )
    end

    def new_bill_payment_confirmation(password:)
      bpay_enter_password(password)
      bpay_new_bill_payment_submit_button.click
    end

    def pay(source_bank_account_name_or_number: nil, biller_name_or_code: nil, customer_reference_number: nil, amount: nil, password: nil)
      source_bank_account_name_or_number ||= @source_bank_account_name_or_number
      biller_name_or_code ||= @biller_name_or_code
      customer_reference_number ||= @customer_reference_number
      amount ||= @amount
      password ||= @password
      validate_args(
        source_bank_account_name_or_number: source_bank_account_name_or_number,
        biller_name_or_code: biller_name_or_code,
        customer_reference_number: customer_reference_number,
        amount: amount,
        password: password
      )
      transfer_and_pay_button.click
      sleep 1
      bill_payment_link.click
      sleep 1
      bpay_select_bank_account(source_bank_account_name_or_number)
      if biller_name_or_code.match(/^\d+$/) # is a number, then enter code
        bpay_enter_biller_code(biller_name_or_code)
      else # is a name, then use the select list
        unless bpay_select_biller(biller_name_or_code) # If the the string can't be found in the dropdown list, then use the search field...
          bpay_enter_biller_name(biller_name_or_code)
        end
      end
      bpay_submit_button.click
      sleep 1
      unless bpay_biller_direct_hit?
        bpay_search_result_selection(biller_name_or_code).click
      end
      sleep 1
      new_bill_payment(customer_reference_number: customer_reference_number, amount: amount)
      sleep 1
      new_bill_payment_confirmation(password: password)
      sleep 1
    end
  end
end
