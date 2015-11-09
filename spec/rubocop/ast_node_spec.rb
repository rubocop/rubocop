# encoding: utf-8

require 'spec_helper'

describe Astrolabe::Node do
  describe '#asgn_method_call?' do
    it 'does not match ==' do
      parsed = parse_source('Object.new == value')

      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match !=' do
      parsed = parse_source('Object.new != value')

      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match <=' do
      parsed = parse_source('Object.new <= value')

      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match >=' do
      parsed = parse_source('Object.new >= value')

      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match ===' do
      parsed = parse_source('Object.new === value')

      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'matches =' do
      parsed = parse_source('Object.new = value')

      expect(parsed.ast.asgn_method_call?).to be(true)
    end
  end
end
