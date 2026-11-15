require_relative './lib/NabComAu/VERSION'

class Gem::Specification
  def dependencies=(gems)
    gems.each{|gem| add_dependency(*gem)}
  end

  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'nab_com_au'
  spec.version = NabComAu::VERSION

  spec.summary = "Pay bills by BPAY from NAB Internet Banking via Selenium WebDriver."
  spec.description = "Log into NAB Internet Banking with a username and password, and pay a bill by BPAY from an account, going as far as the confirmation page unless told to confirm."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/nab_com_au'
  spec.license = 'MIT'

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.3'

  spec.files = [
    'nab_com_au.gemspec',
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
    'CHANGELOG',
    'Gemfile',
    'Rakefile',
  ].flatten

  spec.dependencies = [
    ['selenium-webdriver', '>= 4.0'],
    ['webaccount', '~> 0.8']
  ]

  spec.development_dependencies = %w{
    minitest
    minitest-spec-context
    rake
  }
end
