# frozen_string_literal: true

RSpec.describe BitcoinKernel::BlockValidationState do
  describe 'instance methods' do
    it 'has validation mode methods' do
      expect(described_class.instance_methods).to include(:validation_mode)
      expect(described_class.instance_methods).to include(:valid?)
      expect(described_class.instance_methods).to include(:invalid?)
      expect(described_class.instance_methods).to include(:internal_error?)
      expect(described_class.instance_methods).to include(:block_validation_result)
    end
  end
end