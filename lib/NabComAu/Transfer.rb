# NabComAu/Transfer.rb
# NabComAu::Transfer

module NabComAu
  class Transfer < NabComAu::Account
    def initialize(source_bank_account_name_or_number: nil, target_bsb: nil, target_bank_account_number: nil, note: nil, amount: nil)
      @source_bank_account_name_or_number = source_bank_account_name_or_number
      @target_bsb = target_bsb
      @target_bank_account_number = target_bank_account_number
      @note = note
      @amount = amount
    end

    def pay(source_bank_account_name_or_number: nil, target_bsb: nil, target_bank_account_number: nil, note: nil, amount: nil)
      raise NotImplementedError, "Transfers aren't made yet: the transfer page's fields haven't been worked out."
    end
  end
end
