# test/Nab_test.rb

require_relative './helper'
require_relative '../lib/Nab'

describe Nab do
  describe ".to_nab_account_number_format" do
    it "groups nine digits in twos, threes and fours" do
      _(Nab.to_nab_account_number_format('123456789')).must_equal '12-345-6789'
    end

    it "leaves an account number already in that form as it is" do
      _(Nab.to_nab_account_number_format('12-345-6789')).must_equal '12-345-6789'
    end

    it "regroups an account number with its dashes elsewhere" do
      _(Nab.to_nab_account_number_format('1234-56789')).must_equal '12-345-6789'
    end

    it "doesn't change the string it's given" do
      account_number = '1234-56789'
      Nab.to_nab_account_number_format(account_number)
      _(account_number).must_equal '1234-56789'
    end

    it "is nil for an account name" do
      _(Nab.to_nab_account_number_format('Everyday Account')).must_be_nil
    end
  end
end
