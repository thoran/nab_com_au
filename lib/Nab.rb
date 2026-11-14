# Nab.rb
# Nab

# Notes:
# 1. Extracted from NabComAu 0.1.8.
# 2. This is a separate namespace from NabComAu because this isn't website traversal specific.

module Nab
  def to_nab_account_number_format(account_number)
    return unless account_number.match(/^[\d-]+$/)
    unless account_number.match(/^\d\d-\d\d\d-\d\d\d\d$/)
      unless account_number.match(/^\d\d\d\d\d\d\d\d\d$/)
        account_number = account_number.delete('-')
      end
      account_number_parts = account_number.split('')
      new_account_number_parts = []
      new_account_number_parts << "#{account_number_parts[0]}#{account_number_parts[1]}"
      new_account_number_parts << "#{account_number_parts[2]}#{account_number_parts[3]}#{account_number_parts[4]}"
      new_account_number_parts << "#{account_number_parts[5]}#{account_number_parts[6]}#{account_number_parts[7]}#{account_number_parts[8]}"
      account_number = new_account_number_parts.join('-')
    end
    account_number
  end

  module_function :to_nab_account_number_format
end
