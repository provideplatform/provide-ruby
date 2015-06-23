require 'spec_helper'

describe Provide::Product do
  it 'exposes :find' do
    expect(Provide::Product.find(1).code).not_to be nil
  end
end
