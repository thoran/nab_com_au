# test/NabComAu/Transfer_test.rb

require_relative '../helper'

describe NabComAu::Transfer do
  describe "#pay" do
    it "raises without using the browser" do
      transfer = NabComAu::Transfer.new(source_bank_account_name_or_number: 'Everyday Account', target_bsb: '000-000', target_bank_account_number: '000000000', note: 'note', amount: '1.00')
      transfer.driver = untouchable_driver
      _{transfer.pay}.must_raise NotImplementedError
    end
  end
end
