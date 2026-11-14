# test/helper.rb

# Notes:
# 1. No browser and no NAB: elements and browsers are stand-ins, which record what's done to them, so as nothing is ever sent anywhere.

require 'minitest/autorun'
require 'minitest-spec-context'

require_relative '../lib/NabComAu/Account'

# An element which records what's typed into it and whether it's been clicked. One given options is a select, as Selenium::WebDriver::Support::Select wants.
class StandInElement
  attr_reader :typed, :text

  def initialize(text: '', options: nil)
    @text, @options = text, options
    @typed = []
  end

  def clear; @typed.clear; end
  def send_keys(keys); @typed << keys; end
  def click; @clicked = true; end
  def clicked?; !!@clicked; end
  def attribute(name); @text if name.to_s == 'text'; end
  def tag_name; @options ? 'select' : 'input'; end
  def dom_attribute(name); nil; end
  def find_elements(*); @options || []; end
end

def stand_in_select(*texts)
  StandInElement.new(options: texts.map{|text| StandInElement.new(text: text)})
end

# A browser which fails the example if anything asks it to do anything.
def untouchable_driver
  driver = Object.new
  def driver.method_missing(name, *) = raise("The browser was used: #{name}.")
  def driver.respond_to_missing?(*) = true
  driver
end
