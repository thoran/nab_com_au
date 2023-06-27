# NabComAu.rb
# NabComAu

# 20230627
# 0.2.0

# Notes:
# 1. Searching by BPay biller code produces a substring match, hence even if the biller code is complete and correct, then an extra step is required.

# Changes:
# -/0:
# 1.

require 'WebAccount'

module NabComAu

  autoload :Bpay, 'Bpay.rb'
  autoload :Transfer, 'Transfer.rb'

  class Account < WebAccount
    PAGE_IDS = {
      login_page_url: 'https://ib.nab.com.au/nabib/index.jsp',
      # login_page_url: 'https://ib.nab.com.au/login',
      login_page_username_field_id: 'username',
      login_page_password_field_id: 'password',
      # login_page_submit_button_id: 'loginBtn',
      logout_button_id: 'logoutButton',
      logged_out_xpath: ''
    }

    attr_accessor :driver

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
        sleep 1
        enter_username(username)
        sleep 2
        enter_password(password)
        sleep 3
        login_page_submit_button.click
      end
      # @logged_in = driver_wait.until do
      #   driver.element_present?(:id, @logout_button_id)
      # end
    end

    # def driver=(driver)
    #   @driver = driver
    # end

    def login_page_submit_button
      # driver.find_element(:tag_name, "button")
      driver.find_element(:xpath, "//button[contains(text(), 'Login')]")
    end

    def bpay(source_bank_account_name_or_number:, biller_name_or_code:, customer_reference_number:, amount:)
      bpay = Bpay.new(
        source_bank_account_name_or_number: source_bank_account_name_or_number,
        biller_name_or_code: biller_name_or_code,
        customer_reference_number: customer_reference_number,
        amount: amount
      )
      bpay.pay
    end

    def transfer(source_bank_account_name_or_number: nil, target_bsb: nil, target_bank_account_number: nil, note: nil, amount: nil)
      p transfer = Transfer.new(
        source_bank_account_name_or_number: ,
        target_bsb: target,
        target_bank_account_number: customer_reference_number,
        note: note,
        amount: amount
      )
      # transfer.pay
    end
  end
end
