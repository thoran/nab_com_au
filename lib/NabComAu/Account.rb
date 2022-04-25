# NabComAu.rb
# NabComAu

# 20220425
# 0.1.4

# Notes:
# 1. Derived from WestpacComAu.rb 0.5.3 and MarketindexComAu 0.0.0.

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
      else
        raise "Can't find supplied biller name from the dropdown list."
      end
    end

    def bpay_enter_biller_code(biller_code)
      bpay_biller_code_field.clear
      bpay_biller_code_field.send_keys(biller_code)
    end

    def bpay(account_name_or_number:, biller_name_or_code:)
      transfer_and_pay_button.click
      bill_payment_link.click
      bpay_select_bank_account(account_name_or_number)
      if biller_name_or_code.match(/^\d+$/) # is a number, then enter code
        bpay_enter_biller_code(biller_name_or_code)
      else # is a name, then use the select list
        bpay_select_biller(biller_name_or_code)
      end
      bpay_submit_button.click
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
  nab_account.bpay(account_name_or_number: ARGV[2], biller_name_or_code: ARGV[3])
  sleep 120
  # nab_account.shutdown
end
