# NabComAu.rb
# NabComAu

# 20220425
# 0.1.1

# Notes:
# 1. Derived from WestpacComAu.rb 0.5.3 and MarketindexComAu 0.0.0.

# Changes: (Add BPay payments)
# 1. + bpay()
# 2. + transfer_and_pay_button()
# 3. + bill_payment_link()
# 0/1
# 4. + bpay_bank_account_select_list()
# 5. ~ bpay()

require 'WebAccount'

module NabComAu
  class Account < WebAccount

    PAGE_IDS = {
      login_page_url: 'https://ib.nab.com.au/nabib/index.jsp',
      login_page_username_field_id: 'userid',
      login_page_password_field_id: 'password',
      login_page_submit_button_id: 'loginBtn',
      logout_button_id: '',
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
        @driver.element_present?(:xpath, '//*[@id="bodyContent"]/table/tbody/tr/td/table/tbody/tr/td[2]/div/div/table/tbody/tr/td/form/table[1]/tbody/tr[1]/td[2]/select')
      end
      @driver.find_element(xpath: '//*[@id="bodyContent"]/table/tbody/tr/td/table/tbody/tr/td[2]/div/div/table/tbody/tr/td/form/table[1]/tbody/tr[1]/td[2]/select')
    end

    def bpay_select_bank_account(account_name_or_number)
      webdriver_select_list = Selenium::WebDriver::Support::Select.new(bpay_bank_account_select_list)
      if option = webdriver_select_list.options.detect{|option| option.attribute(:text) =~ /#{account_name_or_number}/}
        option.click
      else
        raise "Can't find supplied account number from the dropdown list."
      end
    end

    def bpay(account_name_or_number:)
      transfer_and_pay_button.click
      bill_payment_link.click
      bpay_select_bank_account(account_name_or_number)
    end

  end
end

if __FILE__ == $0
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--disable-blink-features=AutomationControlled")
  driver = Selenium::WebDriver.for :chrome, options: options

  nab_account = NabComAu::Account.new(username: ARGV[0], password: ARGV[1])
  nab_account.driver = driver
  nab_account.login
  nab_account.bpay(account_name_or_number: ARGV[2])
  sleep 120
  # nab_account.shutdown
end
