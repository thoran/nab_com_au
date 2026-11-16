# NabComAu/Account.rb
# NabComAu::Account

# Notes:
# 1. Searching by BPay biller code produces a substring match, hence even if the biller code is complete and correct, then an extra step is required.
# 2. new() is WebAccount's: it takes the browser's options, such as browser:, profile_directory: and headless:, and NAB's pages come from PAGE_SELECTORS, unless a keyword is given in place of one.
# 3. NAB's logout button appears twice, as text and as an icon, each with the id logoutInternetBanking, so as the text one is chosen by its label.
# 4. login() waits for the logout button for as long as default_login_timeout, so as the code NAB sends by SMS can be entered in the browser.

require 'webaccount'

module NabComAu

  autoload :Bpay, File.join(__dir__, 'Bpay')
  autoload :Transfer, File.join(__dir__, 'Transfer')

  class Account < WebAccount
    PAGE_SELECTORS = {
      login_page_url: 'https://ib.nab.com.au/nabib/index.jsp',
      login_page_username_field_selector: {id: 'username'},
      login_page_password_field_selector: {id: 'password'},
      login_page_submit_button_selector: {xpath: "//button[contains(text(), 'Login')]"},
      logout_button_selector: {xpath: "//button[@aria-label='Logout']"},
      logged_out_selector: {xpath: "//*[contains(text(), 'You have been successfully logged out.')]"}
    }

    attr_writer :driver

    def login(username: nil, password: nil)
      @logged_in = false
      username ||= self.username
      password ||= self.password
      validate_args(username: username, password: password)
      driver.attempt do
        get_login_page
        sleep 1
        enter_username(username)
        sleep 2
        enter_password(password)
        sleep 3
        login_page_submit_button.click
      end
      @logged_in = login_wait.until do
        driver.element_present?(logout_button_selector.keys.first, logout_button_selector.values.first)
      end
    end

    def bpay(source_bank_account_name_or_number:, biller_name_or_code:, customer_reference_number:, amount:)
      bpay = Bpay.new(
        source_bank_account_name_or_number: source_bank_account_name_or_number,
        biller_name_or_code: biller_name_or_code,
        customer_reference_number: customer_reference_number,
        amount: amount
      )
      bpay.driver = driver
      bpay.pay(password: password)
    end

    def transfer(source_bank_account_name_or_number: nil, target_bsb: nil, target_bank_account_number: nil, note: nil, amount: nil)
      transfer = Transfer.new(
        source_bank_account_name_or_number: source_bank_account_name_or_number,
        target_bsb: target_bsb,
        target_bank_account_number: target_bank_account_number,
        note: note,
        amount: amount
      )
      transfer.driver = driver
      transfer.pay
    end

    private

    # For logging in: the code sent by SMS, as well as the authentication and the redirect.
    def default_login_timeout
      180
    end

    def login_wait
      @login_wait ||= Selenium::WebDriver::Wait.new(timeout: default_login_timeout)
    end
  end
end
