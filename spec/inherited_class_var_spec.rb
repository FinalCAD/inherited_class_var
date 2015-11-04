require 'spec_helper'

describe InheritedClassVar do
  it 'has a version number' do
    expect(InheritedClassVar::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
