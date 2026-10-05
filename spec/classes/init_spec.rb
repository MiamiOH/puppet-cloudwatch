require 'spec_helper'
describe 'cloudwatch' do
  context 'with default values for all parameters' do
    it { is_expected.to contain_class('cloudwatch') }
  end
end
