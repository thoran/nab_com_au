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

  describe "#initialize" do
    it "finds the login fields and the logout button by their ids" do
      account = account()
      _(account.send(:username_field_selector)).must_equal({id: 'username'})
      _(account.send(:password_field_selector)).must_equal({id: 'password'})
      _(account.send(:logout_button_selector)).must_equal({id: 'logoutButton'})
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
    it "says username: is missing, before using the browser" do
      error = _{account(password: 'password').login}.must_raise ArgumentError
      _(error.message).must_match(/username:/)
    end

    it "says password: is missing, before using the browser" do
      error = _{account(username: 'username').login}.must_raise ArgumentError
      _(error.message).must_match(/password:/)
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
