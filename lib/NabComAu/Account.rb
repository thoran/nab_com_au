# NabComAu.rb
# NabComAu

# 20220424
# 0.0.0

# Notes:
# 1. Derived from WestpacComAu.rb 0.5.3 and MarketindexComAu 0.0.0.

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

  end
end

if __FILE__ == $0
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--disable-blink-features=AutomationControlled")
  driver = Selenium::WebDriver.for :chrome, options: options

  nab_account = NabComAu::Account.new(username: ARGV[0], password: ARGV[1])
  nab_account.driver = driver
  nab_account.login
  sleep 60
  # nab_account.shutdown
end
