# test/NabComAu/Bpay_test.rb

# Notes:
# 1. Every element pay() reaches for is a stand-in on the Bpay itself, and its browser is one which fails if used, so the submit clicked is only ever a stand-in's.

require_relative '../helper'

describe NabComAu::Bpay do
  PAYMENT = {
    source_bank_account_name_or_number: '123456789',
    biller_name_or_code: '1234',
    customer_reference_number: '5678',
    amount: '1.00',
    password: 'password'
  }

  # A Bpay whose pages are stand-ins: a list of accounts and a list of billers; and, where direct_hit is false, a search which ends upon a list of results.
  def bpay(payment: {}, accounts: ['Everyday Account 12-345-6789'], billers: ['Electricity'], direct_hit: true)
    elements = {
      transfer_and_pay_button: StandInElement.new,
      bill_payment_link: StandInElement.new,
      bpay_bank_account_select_list: stand_in_select(*accounts),
      bpay_biller_select_list: stand_in_select(*billers),
      bpay_biller_code_field: StandInElement.new,
      bpay_biller_name_field: StandInElement.new,
      bpay_submit_button: StandInElement.new,
      search_result: StandInElement.new,
      bpay_customer_reference_number_field: StandInElement.new,
      bpay_payment_amount_field: StandInElement.new,
      bpay_new_bill_payment_next_button: StandInElement.new,
      bpay_password_field: StandInElement.new,
      bpay_new_bill_payment_submit_button: StandInElement.new
    }
    bpay = NabComAu::Bpay.new(**payment)
    bpay.driver = untouchable_driver
    elements.each{|name, element| bpay.define_singleton_method(name){element}}
    bpay.define_singleton_method(:bpay_biller_direct_hit?){direct_hit}
    bpay.define_singleton_method(:bpay_search_result_selection){|biller| elements[:search_result]}
    bpay.define_singleton_method(:sleep){|*|}
    [bpay, elements]
  end

  def selected(select_list)
    select_list.find_elements.select(&:clicked?).map(&:text)
  end

  describe "#pay" do
    it "pays from the account given, with the biller code, reference, amount and password given" do
      bpay, elements = bpay()
      bpay.pay(**PAYMENT)
      _(selected(elements[:bpay_bank_account_select_list])).must_equal ['Everyday Account 12-345-6789']
      _(elements[:bpay_biller_code_field].typed).must_equal ['1234']
      _(elements[:bpay_customer_reference_number_field].typed).must_equal ['5678']
      _(elements[:bpay_payment_amount_field].typed).must_equal ['1.00']
      _(elements[:bpay_password_field].typed).must_equal ['password']
      _(elements[:bpay_new_bill_payment_submit_button].clicked?).must_equal true
    end

    it "chooses a biller named from the list" do
      bpay, elements = bpay()
      bpay.pay(**PAYMENT, biller_name_or_code: 'Electricity')
      _(selected(elements[:bpay_biller_select_list])).must_equal ['Electricity']
      _(elements[:bpay_biller_name_field].typed).must_be_empty
    end

    it "searches for a biller named which isn't in the list" do
      bpay, elements = bpay()
      bpay.pay(**PAYMENT, biller_name_or_code: 'Water')
      _(elements[:bpay_biller_name_field].typed).must_equal ['Water']
    end

    it "chooses from the search results where the biller code matches more than one biller" do
      bpay, elements = bpay(direct_hit: false)
      bpay.pay(**PAYMENT)
      _(elements[:search_result].clicked?).must_equal true
    end

    it "raises where the account isn't in the list" do
      bpay, elements = bpay(accounts: ['Savings Account 98-765-4321'])
      _{bpay.pay(**PAYMENT)}.must_raise RuntimeError
      _(elements[:bpay_new_bill_payment_submit_button].clicked?).must_equal false
    end

    PAYMENT.each_key do |name|
      it "says #{name}: is missing, before going to the payment" do
        bpay, elements = bpay()
        error = _{bpay.pay(**PAYMENT, name => nil)}.must_raise ArgumentError
        _(error.message).must_match(/#{name}:/)
        _(elements[:transfer_and_pay_button].clicked?).must_equal false
      end
    end

    it "takes the payment given to new()" do
      bpay, elements = bpay(payment: PAYMENT.reject{|name, _| name == :password})
      bpay.pay(password: 'password')
      _(elements[:bpay_customer_reference_number_field].typed).must_equal ['5678']
      _(elements[:bpay_new_bill_payment_submit_button].clicked?).must_equal true
    end
  end
end
