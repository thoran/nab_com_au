# NabComAu.rb
# NabComAu

# 20220508
# 0.1.8

# Notes:
# 1. Derived from WestpacComAu.rb 0.5.3 and MarketindexComAu 0.0.0.
# 2. Searching by BPay biller code produces a substring match, hence even if the biller code is complete and correct, then an extra step is required.

# Changes: (Add BPay payments)
# 1. + bpay()
# 2. + transfer_and_pay_button()
# 3. + bill_payment_link()
# 0/1
# 4. + bpay_bank_account_select_list()
# 5. ~ bpay()
# 1/2
# 6. + Nab#to_nab_account_number_format()
# 7. ~ bpay_select_bank_account()
# 2/3
# 8. + bpay_biller_select_list()
# 9. + bpay_biller_code_field()
# 10. + bpay_select_biller()
# 11. + bpay_enter_biller_code()
# 12. ~ bpay()
# 3/4
# 13. + bpay_submit_button()
# 14. ~ bpay()
# 15. ~ bpay_bank_account_select_list(), to use css name instead of xpath.
# 4/5
# 16. + bpay_enter_biller_name()
# 17. ~ bpay()
# 5/6: Handle ambiguity when entering biller codes.
# 18. + login(), so as to add delays, possibly temporary.
# 19. + bpay_biller_direct_hit?()
# 20. + bpay_search_result_selection()
# 21. ~ bpay(), to make use of disambiguation methods above.
# 6/7: New bill payment page
# 22. + bpay_customer_reference_number_field()
# 23. + bpay_enter_customer_reference_number()
# 24. + bpay_payment_amount_field()
# 25. + bpay_enter_payment_amount()
# 26. + bpay_new_bill_payment_next_button()
# 27. + new_bill_payment()
# 28. ~ bpay(), to make use of the methods above.
# 7/8: New bill payment confirmation page
# 29. + bpay_password_field()
# 30. + bpay_enter_password()
# 31. + bpay_new_bill_payment_submit_button()
# 32. + new_bill_payment_confirmation()
# 33. ~ bpay(), to make use of confirmation methods above; and to make use of a passed in value for password.

require 'WebAccount'

module Nab
  def to_nab_account_number_format(account_number)
    return unless account_number.match(/^[\d-]+$/)
    unless account_number.match(/^\d\d-\d\d\d-\d\d\d\d$/)
      unless account_number.match(/^\d\d\d\d\d\d\d\d\d$/)
        account_number.gsub!('-', '')
      end
      account_number_parts = account_number.split('')
      new_account_number_parts = []
      new_account_number_parts << "#{account_number_parts[0]}#{account_number_parts[1]}"
      new_account_number_parts << "#{account_number_parts[2]}#{account_number_parts[3]}#{account_number_parts[4]}"
      new_account_number_parts << "#{account_number_parts[5]}#{account_number_parts[6]}#{account_number_parts[7]}#{account_number_parts[8]}"
      account_number = new_account_number_parts.join('-')
    end
    account_number
  end

  module_function :to_nab_account_number_format
end

module NabComAu
  class Account < WebAccount

    PAGE_IDS = {
      login_page_url: 'https://ib.nab.com.au/nabib/index.jsp',
      login_page_username_field_id: 'userid',
      login_page_password_field_id: 'password',
      login_page_submit_button_id: 'loginBtn',
      logout_button_id: 'logoutButton',
      logged_out_xpath: ''
    }

    def initialize(username: nil, password: nil)
      super(
        username: username, password: password,
        login_page_url: PAGE_IDS[:login_page_url],
        login_page_username_field_id: PAGE_IDS[:login_page_username_field_id],
        login_page_password_field_id: PAGE_IDS[:login_page_password_field_id],
        login_page_submit_button_id: PAGE_IDS[:login_page_submit_button_id],
        logout_button_id: PAGE_IDS[:logout_button_id],
        logged_out_xpath: PAGE_IDS[:logged_out_xpath],
      )
    end

    def login(username: nil, password: nil)
      @logged_in = false
      username ||= self.username
      password ||= self.password
      attempts = 0
      driver.attempt do
        get_login_page
        # sleep 1
        enter_username(username)
        # sleep 2
        enter_password(password)
        # sleep 3
        login_page_submit_button.click
      end
      # @logged_in = driver_wait.until do
      #   driver.element_present?(:id, @logout_button_id)
      # end
    end

    def driver=(driver)
      @driver = driver
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

    def bpay(source_bank_account_name_or_number:, biller_name_or_code:, customer_reference_number:, amount:, password:)
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

if __FILE__ == $0
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--disable-blink-features=AutomationControlled')
  driver = Selenium::WebDriver.for(:chrome, capabilities: [options])

  nab_account = NabComAu::Account.new(username: ARGV[0], password: ARGV[1])
  nab_account.driver = driver
  nab_account.login
  nab_account.bpay(
    source_bank_account_name_or_number: ARGV[2],
    biller_name_or_code: ARGV[3],
    customer_reference_number: ARGV[4],
    amount: ARGV[5],
    password: ARGV[1]
  )
  sleep 120
  # nab_account.shutdown
end
