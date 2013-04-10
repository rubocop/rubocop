# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  module Report
    describe EmacsStyle do
      let(:emacs_style) { Rubocop::Report.create('test', :emacs_style) }

      it 'displays parsable text' do
        cop = Cop::Cop.new
        cop.add_offence(:convention, 1, 'message 1')
        cop.add_offence(:fatal,     11, 'message 2')

        emacs_style << cop

        s = StringIO.new
        emacs_style.display(s)
        expect(s.string).to eq ['test:1: C: message 1',
                                "test:11: F: message 2\n"].join("\n")
      end
    end
  end
end
