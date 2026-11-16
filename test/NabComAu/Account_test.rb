# test/NabComAu/Account_test.rb

# Notes:
# 1. NabComAu::Bpay.new is swapped for a stand-in which records what it was given, for the length of an example, and put back afterwards.

require_relative '../helper'

describe NabComAu::Account do
  def account(**args)
    NabComAu::Account.new(**args).tap{|account| account.driver = untouchable_driver}
  end

  def recording_bpay_pay
    calls = []
    NabComAu::Bpay.define_singleton_method(:new) do |**payment|
      bpay = Object.new
      bpay.define_singleton_method(:driver=){|driver| @driver = driver}
      bpay.define_singleton_method(:pay){|**args| calls << {driver: @driver, payment: payment, args: args}}
      bpay
    end
    yield calls
  ensure
    NabComAu::Bpay.singleton_class.remove_method(:new)
  end

  describe "PAGE_SELECTORS" do
    it "gives NAB's login page, its fields and buttons" do
      account = account()
      _(account.send(:login_page_url)).must_equal 'https://ib.nab.com.au/nabib/index.jsp'
      _(account.send(:login_page_username_field_selector)).must_equal({id: 'username'})
      _(account.send(:login_page_password_field_selector)).must_equal({id: 'password'})
      _(account.send(:login_page_submit_button_selector)).must_equal({xpath: "//button[contains(text(), 'Login')]"})
      _(account.send(:logout_button_selector)).must_equal({id: 'logoutButton'})
      _(account.logged_out_selector).must_equal({xpath: "//*[contains(text(), 'You have been successfully logged out.')]"})
    end

    it "gives way to a keyword given to new()" do
      account = account(login_page_url: 'https://example.com/login')
      _(account.send(:login_page_url)).must_equal 'https://example.com/login'
    end

    it "is a Bpay's too" do
      _(NabComAu::Bpay.new.send(:login_page_url)).must_equal 'https://ib.nab.com.au/nabib/index.jsp'
    end
  end

  describe "#initialize" do
    it "is WebAccount's" do
      _(NabComAu::Account.instance_method(:initialize).owner).must_equal WebAccount
    end

    it "takes the browser's options" do
      account = NabComAu::Account.new(browser: :firefox, profile_directory: '/profile', headless: true)
      _(account.send(:browser)).must_equal :firefox
      _(account.instance_variable_get(:@profile_directory)).must_equal '/profile'
      _(account.instance_variable_get(:@headless)).must_equal true
    end

    it "says which keyword is mistyped" do
      error = _{NabComAu::Account.new(brower: :firefox)}.must_raise ArgumentError
      _(error.message).must_match(/brower/)
    end
  end

  describe "#validate_args" do
    it "is WebAccount's" do
      _(NabComAu::Account.instance_method(:validate_args).owner).must_equal WebAccount
      _(NabComAu::Bpay.instance_method(:validate_args).owner).must_equal WebAccount
    end
  end

  describe "#driver=" do
    it "is the browser driven, none being started" do
      driver = untouchable_driver
      account = NabComAu::Account.new
      account.driver = driver
      _(account.driver).must_be_same_as driver
    end
  end

  describe "#login" do
    it "says username is missing, before using the browser" do
      error = _{account(password: 'password').login}.must_raise ArgumentError
      _(error.message).must_equal 'username is missing.'
    end

    it "says password is missing, before using the browser" do
      error = _{account(username: 'username').login}.must_raise ArgumentError
      _(error.message).must_equal 'password is missing.'
    end

    it "says both are missing at once, before using the browser" do
      error = _{account.login}.must_raise ArgumentError
      _(error.message).must_equal 'username, password are missing.'
    end
  end

  describe "#bpay" do
    it "pays with the account's browser and password" do
      recording_bpay_pay do |calls|
        account = account(username: 'username', password: 'password')
        account.bpay(source_bank_account_name_or_number: 'Everyday Account', biller_name_or_code: '1234', customer_reference_number: '5678', amount: '1.00')
        _(calls.size).must_equal 1
        _(calls.first[:driver]).must_be_same_as account.driver
        _(calls.first[:payment]).must_equal({source_bank_account_name_or_number: 'Everyday Account', biller_name_or_code: '1234', customer_reference_number: '5678', amount: '1.00'})
        _(calls.first[:args]).must_equal({password: 'password'})
      end
    end
  end

  describe "#transfer" do
    it "raises rather than making a transfer" do
      _{account.transfer(source_bank_account_name_or_number: 'Everyday Account', target_bsb: '000-000', target_bank_account_number: '000000000', note: 'note', amount: '1.00')}.must_raise NotImplementedError
    end
  end
end
